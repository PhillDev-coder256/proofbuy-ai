# ProofBuy AI — Enterprise-Grade Implementation Plan

## Project Context (read before every task)

- **Backend**: FastAPI + SQLAlchemy async, Python 3.12, venv at `backend/.venv`
- **Mobile**: Flutter 3.x + Riverpod (codegen) + go_router + freezed
- **Build commands**:
  - Backend install: `cd backend && .venv/bin/pip install -r requirements.txt`
  - Backend tests:   `cd backend && .venv/bin/python -m pytest tests/ -v`
  - Flutter deps:    `cd mobile && flutter pub get`
  - Flutter analyze: `cd mobile && flutter analyze`
  - Flutter tests:   `cd mobile && flutter test`
- **Workspace root**: `/Users/testbedmac1/philldevcoder/projects/proofBuy-AI`
- **All relative paths below are relative to that root.**

---

## Ordering constraints

Tasks 1, 2, 12 are independent; do them first (they touch no shared state).  
Task 3 depends on Task 2 (CORS changes must land first so middleware.py is in final form before adding limiter imports).  
Task 4 depends on nothing but must be done before Task 10 (cache avoids the double-fetch that Task 10 also addresses from the Flutter side).  
Tasks 5, 6, 7, 8, 9 are independent Flutter UI tasks; they can be done in any order.  
Task 10 depends on Task 5 (product details screen must be updated before comparison screen reads from cache).  
Task 11 is independent.  
Recommended ordering: 1 → 2 → 12 → 3 → 4 → 5 → 6 → 7 → 8 → 9 → 10 → 11 → (verification).

---

## Tasks

- [ ] 1. Fix Flutter `unused_local_variable` lint warning in checkout_provider.dart

  **What**: On line 75 of `checkout_provider.dart`, inside `captureOrder`, there is a variable
  assignment whose value is never read (the lint fires on `message`). The fix is to replace the
  two-step `final msg = _messageFor(e); state = CheckoutState.failure(message: msg);` pattern
  with an inline call `state = CheckoutState.failure(message: _messageFor(e));`, removing the
  intermediate `msg` local entirely. Confirm by reading the actual line before editing.

  **Files**: `mobile/lib/features/checkout/checkout_provider.dart`

  **Verify**: `cd mobile && flutter analyze` — zero `unused_local_variable` warnings in
  `checkout_provider.dart`.

---

- [ ] 2. Fix CORS origins for production/development environments

  **What (config.py)**: Change the default for `cors_allowed_origins` from
  `["http://localhost:3000"]` to
  `["http://localhost:3000", "http://localhost:8080", "http://10.0.2.2:8000"]`.
  The `parse_cors_origins` validator already handles list and string formats — no other changes
  needed in config.py.

  **What (middleware.py)**: In `add_middleware`, change the `allow_origins` argument passed to
  `CORSMiddleware` so that if `settings.app_env == 'development'` it passes `allow_origins=['*']`,
  otherwise it passes `allow_origins=settings.cors_allowed_origins`. The rest of the middleware
  call (credentials, methods, headers) stays unchanged.

  **Files**:
  - `backend/app/config.py`
  - `backend/app/core/middleware.py`

  **Verify**: `cd backend && .venv/bin/python -m pytest tests/ -v` — all existing tests pass
  (the health and shopping tests exercise the app factory which runs `add_middleware`).

---

- [ ] 3. Add slowapi rate limiting to all routers (depends on Task 2)

  **What (requirements.txt)**: Append `slowapi==0.1.9` to the file. Keep the existing pinned
  versions untouched.

  **What (main.py)**:
  1. Add imports:
     ```python
     from slowapi import Limiter, _rate_limit_exceeded_handler
     from slowapi.util import get_remote_address
     from slowapi.errors import RateLimitExceeded
     from slowapi.middleware import SlowAPIMiddleware
     ```
  2. Create the limiter at module level (before `app = FastAPI(...)`):
     ```python
     limiter = Limiter(key_func=get_remote_address)
     ```
  3. After `app = FastAPI(...)`, add:
     ```python
     app.state.limiter = limiter
     app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)
     app.add_middleware(SlowAPIMiddleware)
     ```
  4. The existing `add_middleware(app)` call stays — SlowAPIMiddleware is separate and must be
     added via `app.add_middleware` (not inside `add_middleware()`).

  **What (shopping.py)** — `POST /brief` endpoint:
  - Import `Request` from `fastapi` and `limiter` from `app.main`.
  - Add `@limiter.limit('10/minute')` decorator directly above `async def submit_brief`.
  - Add `request: Request` as the **first** positional parameter of `submit_brief`. The existing
    `request: ShoppingBriefRequest` parameter must be renamed to e.g. `body: ShoppingBriefRequest`
    and all references to `request.brief` updated to `body.brief`.

    Alternatively, since `ShoppingBriefRequest` is already named `request`, rename it to `payload`
    and update `payload.brief` throughout the function body to avoid shadowing.

  **What (products.py)** — `GET /{session_id}` endpoint:
  - Import `Request` from `fastapi` and `limiter` from `app.main`.
  - Add `@limiter.limit('30/minute')` above `async def get_products_for_session`.
  - Add `request: Request` as the **first** positional parameter (before `session_id: str`).

  **What (checkout.py)** — both `POST /create` and `POST /capture` endpoints:
  - Import `Request` from `fastapi` and `limiter` from `app.main`.
  - On `create_checkout`: add `@limiter.limit('20/minute')` and `request: Request` as first param
    (before `request: CheckoutCreateRequest` → rename to `body: CheckoutCreateRequest`; update
    all `request.product_result_id` to `body.product_result_id`).
  - On `capture_checkout`: same pattern — `@limiter.limit('20/minute')`, `request: Request` first,
    rename `request: CheckoutCaptureRequest` to `body: CheckoutCaptureRequest`; update
    `body.purchase_id`, `body.order_id`.

  **What (auth.py)** — `POST /register` and `POST /login` endpoints:
  - Import `Request` from `fastapi` and `limiter` from `app.main`.
  - On `register`: add `@limiter.limit('5/minute')` and `request: Request` as first param (before
    `request: RegisterRequest` → rename to `body: RegisterRequest`; update `body.email`,
    `body.full_name`, `body.password`, `body.country`).
  - On `login`: same pattern — `@limiter.limit('5/minute')`, `request: Request` first, rename
    `request: LoginRequest` to `body: LoginRequest`; update `body.email`, `body.password`.

  **⚠ Circular import guard**: `shopping.py`, `products.py`, `checkout.py`, and `auth.py` all
  import `limiter` from `app.main`. To avoid a circular import (`main.py` imports routers → routers
  import main.py), move the `limiter` instance to a new dedicated file:

  Create `backend/app/core/rate_limiter.py`:
  ```python
  from slowapi import Limiter
  from slowapi.util import get_remote_address

  limiter = Limiter(key_func=get_remote_address)
  ```
  Then in `main.py` import `from app.core.rate_limiter import limiter` and in each router
  import `from app.core.rate_limiter import limiter`. This eliminates the circular dependency.

  **Files**:
  - `backend/requirements.txt`
  - `backend/app/main.py`
  - `backend/app/core/rate_limiter.py` ← new file
  - `backend/app/routers/shopping.py`
  - `backend/app/routers/products.py`
  - `backend/app/routers/checkout.py`
  - `backend/app/routers/auth.py`

  **Verify**:
  1. `cd backend && .venv/bin/pip install -r requirements.txt` — installs slowapi 0.1.9 without errors.
  2. `cd backend && .venv/bin/python -m pytest tests/ -v` — all tests pass. The rate limiting
     middleware is transparent in tests because test requests come from 127.0.0.1 and limits
     are per-minute (tests don't hit the same endpoint >30 times in a minute).

---

- [ ] 4. Add TTLCache in-memory product caching to channel3_service.py (independent)

  **What**: Prevent the double HTTP call that happens when `products.py` and any other caller
  both invoke `search_products` for the same query in the same request cycle.

  1. In `requirements.txt` append `cachetools==5.5.0`.
  2. In `channel3_service.py` add at module level:
     ```python
     from cachetools import TTLCache
     _product_cache: TTLCache = TTLCache(maxsize=256, ttl=300)
     ```
  3. In the module-level `search_products` wrapper function (bottom of file), wrap the existing
     logic with a cache check keyed by `(query, session_id)` — but since `session_id` differs per
     user and defeats sharing, key only by `query`. Change to:
     ```python
     async def search_products(query: str, session_id: str) -> list:
         cache_key = query.lower().strip()
         if cache_key in _product_cache:
             # Re-attach session_id since it's caller-specific
             return [
                 {**item, 'session_id': session_id}
                 for item in _product_cache[cache_key]
             ]
         svc = get_channel3_service()
         products = await svc.search_products(query)
         result = [
             {
                 "channel3_product_id": p.channel3_product_id,
                 "name": p.name,
                 "price": p.price,
                 "currency": p.currency,
                 "merchant": p.merchant,
                 "specs_json": p.specs,
                 "source_url": p.source_url,
                 "image_url": p.image_url,
                 "data_complete": p.data_complete,
                 "constraint_results_json": None,
                 "ranking_score": None,
                 "retrieved_at": p.retrieved_at.isoformat(),
                 "session_id": session_id,
             }
             for p in products
         ]
         # Cache without session_id so other sessions benefit too
         _product_cache[cache_key] = [
             {k: v for k, v in item.items() if k != 'session_id'}
             for item in result
         ]
         return result
     ```
  4. Note: `TTLCache` is not thread-safe for asyncio by itself, but CPython's GIL provides
     sufficient protection for single-process uvicorn. For multi-worker production, replace with
     Redis; that is out of scope for this plan.

  **Files**:
  - `backend/requirements.txt`
  - `backend/app/services/channel3_service.py`

  **Verify**: `cd backend && .venv/bin/python -m pytest tests/test_channel3.py -v` — all channel3
  tests pass. The cache is warmed on first call and served on second call within TTL.

---

- [ ] 5. Professional Product Details screen (independent)

  **What**: Enhance `product_details_screen.dart` to the polished design spec. The existing
  screen already has correct structure (image, price, merchant, confidence, AI card, constraints,
  specs, Buy button) but needs visual enhancements. Apply changes in-place; do not restructure
  routing or provider logic.

  Specific changes to `_ProductDetailsView.build`:
  - **Hero image**: increase height from 220 to 250, ensure it uses `CachedNetworkImage` with
    `errorBuilder` returning `_ImagePlaceholder()` (already present — confirm and tighten).
  - **Product name**: increase from 18px to 24px bold (FontWeight.w800).
  - **Price text**: confirm it uses `Color(0xFF2563EB)` — already does, increase size to 26px.
  - **Merchant row**: already present — no change needed.
  - **Confidence score bar**: replace the plain text `Row` with a `Column` containing the label
    row plus a `LinearProgressIndicator(value: product.rankingConfidence, ...)` with
    `color: ProofBuyColors.accent` and `backgroundColor: Color(0xFFE2E8F0)`.
  - **Specs section restructure**: split into three sub-sections:
    - _Features_ bullet list: if `data.specs!['features']` exists and is a `List`, render each
      entry as a `Row` with a small `Icons.check_circle_outline` icon and text.
    - _Description_ block: if `data.specs!['description']` exists, render it as a Text paragraph.
    - _Technical Specs_ grid: show remaining keys (excluding 'features' and 'description') in a
      `Wrap` or two-column `GridView`-like layout using `Row(children:[Expanded, Expanded])` pairs.
      Keep the existing `ExpansionTile` wrapper so the section collapses.
  - **Constraint section**: already renders `ConstraintBadge` — confirm it is present (it is),
    no structural change needed.
  - **AI explanation card**: already present with light blue tint — no change needed.
  - **Buy with PayPal button**: already full-width, navigates to `/review/$productResultId` —
    confirm and keep. Add `url_launcher` secondary button below it:
    ```dart
    if (data.sourceUrl != null && data.sourceUrl!.isNotEmpty)
      OutlinedButton.icon(
        onPressed: () async {
          final uri = Uri.parse(data.sourceUrl!);
          if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
        },
        icon: const Icon(Icons.open_in_new, size: 16),
        label: Text('View on retailer site', style: pjs(size: 14, weight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
      ),
    ```
  - Add import: `import 'package:url_launcher/url_launcher.dart';` (already in pubspec.yaml).

  **Files**: `mobile/lib/features/product_details/product_details_screen.dart`

  **Verify**: `cd mobile && flutter analyze` — zero new errors. `cd mobile && flutter test` passes.

---

- [ ] 6. Professional Purchase Review screen (independent)

  **What**: Enhance `purchase_review_screen.dart`. The existing screen already has the core
  sections (warning banner, product card, constraint list, total, PayPal button, cancel). Apply
  the following additions in-place:

  - **Product image thumbnail**: inside the Product Card Summary `Container`, add a leading
    `CachedNetworkImage` thumbnail (80×80, `BorderRadius.circular(12)`) next to the name/price
    column. Use a `Row(crossAxisAlignment: CrossAxisAlignment.start)` with the image on the left
    and an `Expanded` column on the right.
  - **Order summary card**: add a new `Container` between the product card and the constraint card:
    - Rows: "Product", "Qty", "1"; "Subtotal", `priceText`
    - Bottom row: a "Powered by PayPal" badge — small PayPal logo icon + text in PayPal blue.
    - Style: white card, rounded corners 16, border `Color(0xFFE2E8F0)`.
  - **Constraint summary row**: above the constraint list, add a summary line:
    `X met, Y unverified` where X = PASS count, Y = UNKNOWN count.
  - **PayPal redirect explanation**: above the button, add a short Text:
    `'You'll be redirected to PayPal to complete this payment securely.'`
    styled with `pjs(size: 13, color: Color(0xFF64748B))`.
  - **Pay button**: already correct color `Color(0xFF0070BA)` — no change.
  - **Security note**: below the PayPal button, add:
    `Text('256-bit SSL encryption. ProofBuy AI never stores your payment details.',
         textAlign: TextAlign.center, style: pjs(size: 11, color: Color(0xFF9CA3AF)))`
  - Add `import 'package:cached_network_image/cached_network_image.dart';` if not present.

  **Files**: `mobile/lib/features/purchase_review/purchase_review_screen.dart`

  **Verify**: `cd mobile && flutter analyze` — zero new errors. `cd mobile && flutter test` passes.

---

- [ ] 7. Professional Transaction Result screen (depends on nothing; replace animated success view)

  **What**: Replace `_TransactionSuccessView` with a polished animated version using
  `StatefulWidget` + `AnimationController`.

  1. Convert `_TransactionSuccessView` from `StatelessWidget` to `StatefulWidget` (rename to
     `_TransactionSuccessView` extending `State<_TransactionSuccessViewWidget>`, or use a single
     class pattern — pick whichever avoids renaming the outer reference in `TransactionResultScreen`).
  2. In `initState`:
     - Create `AnimationController _controller` with `vsync: this`,
       `duration: const Duration(milliseconds: 600)`.
     - Create `_scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.elasticOut)`.
     - Call `WidgetsBinding.instance.addPostFrameCallback((_) => _controller.forward())`.
  3. In `build`, replace the plain `Icon(Icons.check_circle, ...)` with:
     ```dart
     ScaleTransition(
       scale: _scaleAnim,
       child: Container(
         width: 80, height: 80,
         decoration: BoxDecoration(
           color: ProofBuyColors.pass,
           shape: BoxShape.circle,
         ),
         child: const Icon(Icons.check_rounded, color: Colors.white, size: 44),
       ),
     )
     ```
  4. Replace `'Payment Verified!'` heading with `'Payment Successful!'` at 24px bold dark
     (`Color(0xFF0F172A)`) via `pjs()`.
  5. Add subtitle text below heading:
     `'Your order is confirmed and payment has been captured.'`
     using `pjs(size: 14, color: Color(0xFF64748B))`.
  6. Transaction details card — show only what `AppTransaction` actually has
     (id, status, verifiedAt, createdAt). Fields:
     - **Transaction ID**: `transaction.id` truncated to 8 chars + `'...'`
       (`transaction.id.length > 8 ? '${transaction.id.substring(0, 8)}...' : transaction.id`).
     - **Status**: `transaction.status.toUpperCase()` with a green `Color(0xFF16A34A)` text color
       if status == 'captured', otherwise amber.
     - **Verified**: `verifiedAtText` (already formatted via `DateFormat`).
     - **Created**: `DateFormat.yMMMMd().add_jm().format(transaction.createdAt)`.
     - Do NOT add amount, currency, or merchant — those fields do not exist on `AppTransaction`.
  7. Replace `'View History'` button with:
     - `ElevatedButton` labeled `'Continue Shopping'` → `context.go('/brief')`.
     - `TextButton` labeled `'View Order History'` → `context.go('/history')`.
  8. All text via `pjs()`, colors from `ProofBuyColors`.
  9. Add `with SingleTickerProviderStateMixin` to the State class and `dispose()` the controller.

  **Files**: `mobile/lib/features/transaction_result/transaction_result_screen.dart`

  **Verify**: `cd mobile && flutter analyze` — zero new errors. `cd mobile && flutter test` passes.

---

- [ ] 8. Professional History screen (independent)

  **What**: Replace the existing `HistoryScreen` with a professional implementation. The existing
  screen uses `_historyProvider` (FutureProvider), `_HistoryListTile`, and relies on
  `HistoryItem` (which has `purchaseRecord: PurchaseRecord` and `product: ProductData?`).

  1. Convert `HistoryScreen` from `ConsumerWidget` to `ConsumerStatefulWidget` to hold local
     filter state. Add `String _activeFilter = 'All'` in the state.
  2. AppBar: title `'Orders'` using `pjs(size: 18, weight: FontWeight.w700, color: Color(0xFF0F172A))`.
  3. Filter chips row: wrap a `SingleChildScrollView(scrollDirection: Axis.horizontal)` with chips
     for `['All', 'Completed', 'Pending', 'Failed']`. Use `FilterChip` or a custom pill matching
     the app's existing pill style (see `_FilterPill` in comparison screen for reference).
     On tap, `setState(() => _activeFilter = label)`.
  4. Filtering logic: map chip labels to status values:
     - 'All' → no filter
     - 'Completed' → `purchaseRecord.status == 'captured'`
     - 'Pending' → `purchaseRecord.status == 'pending'`
     - 'Failed' → `purchaseRecord.status == 'failed'`
     Apply filter to the in-memory `items` list after the provider resolves.
  5. Empty state: if filtered list is empty, show:
     - `Icon(Icons.receipt_long_outlined, size: 64, color: Color(0xFFD1D5DB))`
     - `Text('No orders yet', style: pjs(size: 18, weight: FontWeight.w700, color: Color(0xFF0F172A)))`
     - `ElevatedButton` labeled `'Start Shopping'` → `context.go('/brief')`
  6. Order card (`_OrderCard`): replace `_HistoryListTile` with a `Card`-like `Container`:
     - White background, `BorderRadius.circular(16)`, subtle shadow.
     - Leading: `CachedNetworkImage` 60×60 with `BoxFit.cover`, `BorderRadius.circular(10)`,
       fallback `Icon(Icons.shopping_bag_outlined, color: Color(0xFF94A3B8))`.
       Image URL: `item.product?.imageUrl` (field exists on `ProductData`).
     - Product name: `item.product?.name ?? 'Unknown product'` — 14px semibold.
     - Merchant: `item.product?.merchant ?? ''` — 12px muted.
     - Amount: `'${record.amount.toStringAsFixed(2)} ${record.currency}'` — right-aligned.
     - Status badge: small `Container` with rounded corners:
       - 'captured' → green background `Color(0xFFDCFCE7)`, text `Color(0xFF16A34A)`, label 'Completed'
       - 'failed' → red background `Color(0xFFFEE2E2)`, text `Color(0xFFDC2626)`, label 'Failed'
       - default → amber background `Color(0xFFFEF9C3)`, text `Color(0xFFD97706)`, label 'Pending'
     - Date: `DateFormat('MMM d, y').format(record.createdAt.toLocal())` — 11px muted.
     - Trailing arrow: `Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF))`.
     - `onTap`: if status == 'captured', `context.go('/transaction/${record.id}')`.
  7. `RefreshIndicator` wrapping the `ListView.separated`:
     `onRefresh: () async => ref.invalidate(_historyProvider)`.
  8. Import `package:cached_network_image/cached_network_image.dart`.

  **Files**: `mobile/lib/features/transaction_history/history_screen.dart`

  **Verify**: `cd mobile && flutter analyze` — zero new errors. `cd mobile && flutter test` passes.

---

- [ ] 9. Professional Settings screen (independent)

  **What**: Replace `SettingsScreen` with a full Riverpod `ConsumerWidget` implementation.

  1. Change `SettingsScreen` to `ConsumerWidget` (or `ConsumerStatefulWidget` if local state is
     needed for async operations).
  2. Import `currentUserProvider` and `CurrentUserNotifier` from
     `'../../features/auth/auth_repository.dart'`.
     Import `authRepositoryProvider` from the same file.
     Import `AppConfig` from `'../../core/config/app_config.dart'`.
     Import `go_router` for `context.go(...)`.
     Import `shared_preferences` for the clear history action.
  3. Read user: `final user = ref.watch(currentUserProvider)`.
  4. **User header section**: a `Container` (light blue tint or white card) with:
     - `CircleAvatar(radius: 32)` with initials: `user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : '?'`
     - Name: `user?.fullName ?? 'Guest'` — 18px bold.
     - Email: `user?.email ?? ''` — 13px muted.
  5. **Section 'Account'**: use `_SettingsSection` helper widget (or inline `Column` with dividers):
     - `ListTile` → 'Edit Profile' → `ScaffoldMessenger.of(context).showSnackBar(...)` placeholder.
     - `ListTile` → 'Change Password' → placeholder snackbar.
  6. **Section 'App'**:
     - `ListTile` title 'Backend URL', subtitle `AppConfig.backendUrl`, read-only.
     - `ListTile` title 'App Version', subtitle `'1.0.0+1'`.
     - `ListTile` title 'Clear Search History', trailing `IconButton(icon: Icon(Icons.delete_outline))`:
       on tap, `SharedPreferences.getInstance()` → `prefs.remove('search_history')` → snackbar.
  7. **Section 'About'**:
     - `ListTile` → 'Privacy Policy' → placeholder snackbar.
     - `ListTile` → 'Terms of Service' → placeholder snackbar.
     - `ListTile` → subtitle `'Built for PayPal AI Hackathon 2026'`, read-only (no leading icon).
  8. **Sign Out button**: red `ElevatedButton` at bottom:
     ```dart
     ElevatedButton(
       style: ElevatedButton.styleFrom(
         backgroundColor: const Color(0xFFEF4444),
         minimumSize: const Size.fromHeight(52),
       ),
       onPressed: () async {
         final confirm = await showDialog<bool>(
           context: context,
           builder: (ctx) => AlertDialog(
             title: Text('Sign Out'),
             content: Text('Are you sure you want to sign out?'),
             actions: [
               TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text('Cancel')),
               TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text('Sign Out')),
             ],
           ),
         );
         if (confirm == true) {
           await ref.read(authRepositoryProvider).logout();
           ref.read(currentUserProvider.notifier).setUser(null);
           if (context.mounted) context.go('/onboarding');
         }
       },
       child: Text('Sign Out', style: pjs(size: 16, weight: FontWeight.w700, color: Colors.white)),
     )
     ```
  9. All text via `pjs()`, section headers via `pjs(size: 12, weight: FontWeight.w600, color: Color(0xFF9CA3AF), letterSpacing: 0.8)` uppercase.
  10. Scaffold background `Color(0xFFF8FAFC)`.

  **Files**: `mobile/lib/features/settings/settings_screen.dart`

  **Verify**: `cd mobile && flutter analyze` — zero new errors. `cd mobile && flutter test` passes.

---

- [ ] 10. Fix double-fetch in product search / comparison (depends on Task 5)

  **What**: Add a Riverpod `StateProvider` to share the fetched products between
  `ProductSearchNotifier` and `ProductComparisonNotifier`, so the second call hits the
  backend cache (Task 4) or ideally skips the API call entirely when data is already in memory.

  1. In `product_search_screen.dart`, add at module level (after the `part` directive):
     ```dart
     final cachedProductsProvider = StateProvider<List<RankedProduct>?>((ref) => null);
     ```
     Import: `import '../../shared/models/ranked_product.dart';`
     (path: `../../shared/models/ranked_product.dart` — confirmed correct from existing imports
     in the comparison screen).

  2. In `ProductSearchNotifier.build()`, after the existing
     `await ref.read(productsRepositoryProvider).getProducts(sessionId)` call, capture the
     result and write it to the cache:
     ```dart
     final products = await ref.read(productsRepositoryProvider).getProducts(sessionId);
     ref.read(cachedProductsProvider.notifier).state = products;
     ```
     The return type stays `Future<ShoppingSession>` — `products` is fetched for the side-effect
     of warming the cache/server-side cache; the session is still the return value.

  3. In `product_comparison_screen.dart`, update `ProductComparisonNotifier.build()` to check
     the cache first:
     ```dart
     @override
     Future<List<RankedProduct>> build(String sessionId) async {
       final cached = ref.read(cachedProductsProvider);
       if (cached != null && cached.isNotEmpty) return cached;
       return ref.read(productsRepositoryProvider).getProducts(sessionId);
     }
     ```
     Add import: `import '../product_search/product_search_screen.dart'` 
     (for `cachedProductsProvider` — same file that defines it).

  4. `cachedProductsProvider` is defined in `product_search_screen.dart` and exported implicitly
     by the Dart import system — no barrel file needed.

  **Files**:
  - `mobile/lib/features/product_search/product_search_screen.dart`
  - `mobile/lib/features/product_comparison/product_comparison_screen.dart`

  **Verify**: `cd mobile && flutter analyze` — zero errors. `cd mobile && flutter test` passes.
  Confirm the import resolves by checking the relative path from `product_comparison_screen.dart`
  to `product_search_screen.dart`:
  `mobile/lib/features/product_comparison/` → `../product_search/product_search_screen.dart` ✓

---

- [ ] 11. Network connectivity indicator — `isOfflineNotifier` + `OfflineBanner` widget (independent)

  **What**: Use a module-level `ValueNotifier<bool>` to signal offline state from the Dio
  interceptor, then consume it in a dedicated widget. This approach requires no Riverpod
  restructuring and no changes to `app.dart`.

  **Step A — api_client.dart**:
  1. Add at module level (before `createDio()`):
     ```dart
     /// Global offline signal. True when the last request failed with a
     /// connection error or timeout. Reset to false on the next successful response.
     final ValueNotifier<bool> isOfflineNotifier = ValueNotifier(false);
     ```
  2. In the `onResponse` handler (currently just calls `handler.next(response)`), add before
     the `handler.next` call:
     ```dart
     isOfflineNotifier.value = false;
     ```
  3. In the `onError` handler, after building the mapped `AppException`, check if the exception
     is a `NetworkException` whose message indicates a connection issue:
     ```dart
     final mapped = _mapToAppException(e);
     if (mapped is NetworkException &&
         (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout)) {
       isOfflineNotifier.value = true;
     }
     ```
     Then proceed with the existing `handler.reject(...)` call (update it to use `mapped` rather
     than calling `_mapToAppException(e)` again — rename the variable).

  **Step B — offline_banner.dart** (new file):
  Create `mobile/lib/core/widgets/offline_banner.dart`:
  ```dart
  import 'package:flutter/material.dart';
  import '../networking/api_client.dart';
  import '../../app/theme.dart';

  /// Wraps [child] with an animated red offline banner that appears when
  /// [isOfflineNotifier] is true.
  class OfflineBanner extends StatelessWidget {
    const OfflineBanner({super.key, required this.child});

    final Widget child;

    @override
    Widget build(BuildContext context) {
      return ValueListenableBuilder<bool>(
        valueListenable: isOfflineNotifier,
        builder: (context, isOffline, _) {
          return Column(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isOffline
                    ? Container(
                        key: const ValueKey('offline'),
                        width: double.infinity,
                        color: const Color(0xFFEF4444),
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.wifi_off_rounded,
                                size: 14, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              'No internet connection',
                              style: pjs(
                                  size: 12,
                                  weight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('online')),
              ),
              Expanded(child: child),
            ],
          );
        },
      );
    }
  }
  ```

  **Usage note** (document in a comment in the file, do not change `app.dart` in this task):
  To activate `OfflineBanner` app-wide, wrap the `MaterialApp`'s `builder` in `app.dart`
  with `OfflineBanner(child: child!)`. That change is out of scope for this task — the widget
  must exist and be importable.

  **Files**:
  - `mobile/lib/core/networking/api_client.dart`
  - `mobile/lib/core/widgets/offline_banner.dart` ← new file

  **Verify**: `cd mobile && flutter analyze` — zero new errors. `cd mobile && flutter test` passes.

---

- [ ] 12. Register `integration` pytest mark in pytest.ini (independent)

  **What**: The existing `backend/pytest.ini` contains only `asyncio_mode = auto`. Add the
  `integration` marker registration so pytest does not emit "PytestUnknownMarkWarning" when tests
  use `@pytest.mark.integration`.

  Replace the entire file contents with:
  ```ini
  [pytest]
  asyncio_mode = auto
  markers =
      integration: marks tests as integration tests requiring live API keys
  ```

  **Files**: `backend/pytest.ini`

  **Verify**: `cd backend && .venv/bin/python -m pytest tests/ -v --markers` — output lists
  `integration: marks tests as integration tests requiring live API keys`.

---

## Post-task verification (run after all 12 tasks are complete)

Run in order:

```bash
# 1. Install backend deps (picks up slowapi + cachetools)
cd /Users/testbedmac1/philldevcoder/projects/proofBuy-AI/backend \
  && .venv/bin/pip install -r requirements.txt

# 2. Run backend test suite
cd /Users/testbedmac1/philldevcoder/projects/proofBuy-AI/backend \
  && .venv/bin/python -m pytest tests/ -v

# 3. Install Flutter deps
cd /Users/testbedmac1/philldevcoder/projects/proofBuy-AI/mobile \
  && flutter pub get

# 4. Static analysis
cd /Users/testbedmac1/philldevcoder/projects/proofBuy-AI/mobile \
  && flutter analyze

# 5. Flutter unit tests
cd /Users/testbedmac1/philldevcoder/projects/proofBuy-AI/mobile \
  && flutter test
```

Report exact counts:
- Backend: `X passed, Y failed` from pytest output.
- Flutter analyze: `X issues found` (target: 0 errors, 0 warnings; info-level hints acceptable).
- Flutter test: `X tests passed`.

---

## Known assumptions & caveats

1. **slowapi circular import**: the plan uses `app/core/rate_limiter.py` as the limiter singleton
   to avoid `main.py ↔ router` circular imports. If the existing test setup imports `app.main`
   directly, confirm that tests still pass after this refactor — the `app` object is still
   created in `main.py`, the limiter is just housed elsewhere.

2. **checkout.py param rename**: the task renames `request: CheckoutCreateRequest` to
   `body: CheckoutCreateRequest` to free up the name `request` for the `Request` object that
   slowapi requires as the first param. Confirm the rename is consistent throughout the function
   body (grepping for `request.product_result_id`, `request.purchase_id`, `request.order_id`
   before editing).

3. **cachedProductsProvider placement**: defining it in `product_search_screen.dart` means it is
   only available if that file is imported. If other screens need it in the future, move it to
   `mobile/lib/core/providers/cached_products_provider.dart` and update both imports.

4. **AppTransaction.amount/currency absent**: Task 7 explicitly prohibits showing amount/currency
   on the transaction result screen because those fields only exist on `PurchaseRecord`, not on
   `AppTransaction`. The transaction details card shows only: id (truncated), status, verifiedAt,
   createdAt. This is correct per the model definition confirmed in the codebase.

5. **OfflineBanner not wired into app.dart**: Task 11 creates the widget but does not modify
   `app.dart`. The coder must add the import and `builder` wrapping in a follow-up if app-wide
   display is needed. The widget is fully self-contained and tested independently.
