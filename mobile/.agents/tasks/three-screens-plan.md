# Implementation Plan — Three-Screen Flow Overhaul

## Context (discovered from codebase)

- **Build**: `cd mobile && flutter pub get` then `dart run build_runner build --delete-conflicting-outputs`
- **Test**: `cd mobile && flutter test`
- **Compile-check** (no device needed): `cd mobile && flutter build apk --debug --dart-define=BACKEND_URL=http://10.0.2.2:8000`
- **Font/style helper**: `pjs(size, weight, color, ...)` from `lib/app/theme.dart`
- **Brand gradient**: `ProofBuyGradients.button` = blue→purple; `ProofBuyGradients.screen` = dark navy gradient used on dark screens
- **Brand purple**: `Color(0xFF6C47FF)` — used consistently across onboarding, product cards, and buttons
- **Network image pattern**: `CachedNetworkImage` with `_Fallback` widget (established in `product_card.dart`)
- **Generated files that must be regenerated**: `product_search_screen.g.dart`, `product_comparison_screen.g.dart` (Riverpod `@riverpod` codegen)
- **No generated file for `review_requirements_screen.dart`** — it is a pure `ConsumerWidget`, no `@riverpod` annotation needed
- **Existing notifiers to preserve unchanged**: `ProductSearchNotifier` in `product_search_screen.dart`, `ProductComparisonNotifier` in `product_comparison_screen.dart`

---

## Items

- [ ] 1. REPLACE `product_search_screen.dart` — animated 5-step loading screen.

  Keep `ProductSearchNotifier` (build method + imports) exactly as-is. Replace
  `ProductSearchScreen` and all private helper widgets with a dark-gradient
  animated loading screen.

  **UI spec:**
  - `Scaffold` with no `AppBar`; background is `ProofBuyGradients.screen`
    (top: `Color(0xFF0A0E2E)`, mid: `Color(0xFF1A1464)`, bottom: `Color(0xFF2D1B69)`).
    Wrap in an `AnnotatedRegion<SystemUiOverlayStyle>(value: SystemUiOverlayStyle.light)`.
  - Centred column:
    1. ProofBuy logo mark (`assets/icons/logo_hero.png`, width 64, with `errorBuilder`
       fallback to `Icons.shopping_bag_outlined` in a `Color(0xFF6C47FF)` circle).
    2. `SizedBox(height: 32)`.
    3. Five step rows, each: `Icon` (24px) + `SizedBox(width: 12)` + `Text`.
       Steps (in order):
       - `Icons.search_rounded` — "Analyzing your requirements"
       - `Icons.compare_arrows_rounded` — "Searching product catalogue"
       - `Icons.auto_awesome_rounded` — "Ranking by AI score"
       - `Icons.fact_check_outlined` — "Verifying constraints"
       - `Icons.done_all_rounded` — "Preparing your results"
    4. Each row animates through three states driven by a single `_currentStep` int
       (0 = pending → dim white 40% opacity, 1 = active → `Color(0xFF6C47FF)` with
       a `SizedBox(width:16,height:16) CircularProgressIndicator(strokeWidth:2,color:Color(0xFF6C47FF))` replacing the icon,
       2 = done → `ProofBuyColors.pass` with `Icons.check_circle_rounded`).
    5. Step advances every **1.2 s** via a `Timer.periodic` started in `initState`
       of a `StatefulWidget` wrapper (`_AnimatedLoadingBody`). Timer is cancelled in
       `dispose`.
    6. Below the steps: `SizedBox(height: 40)` then a subtitle `Text` in
       `pjs(size:14, color:Color(0xFFB8C0E0))` that cycles through the active step's
       label. No explicit progress bar — the step rows serve that role.
  - **Navigation**: `_AnimatedLoadingBody` receives `AsyncValue<ShoppingSession>`.
    Inside `build`, if `state.hasValue && state.value != null` and `_currentStep >= 4`
    (all steps done), call `context.go('/review-requirements/${state.value!.id}')` once
    (guard with a `bool _navigated` flag). If the value arrives before all steps are
    done, set a `_pendingNavigate = true` flag and navigate when the timer reaches
    step 4.
  - **Error state**: if `state.hasError`, replace the loading column with the existing
    `ProofBuyErrorWidget` (white text on dark background — override its icon/message
    colors to white by wrapping in a `Theme` with `IconTheme(color: Colors.white)`).

  **Files:** `lib/features/product_search/product_search_screen.dart`

  **Verify:**
  ```
  cd mobile && dart run build_runner build --delete-conflicting-outputs
  cd mobile && flutter test
  ```
  Both commands must exit 0. The `.g.dart` file regenerates unchanged (notifier
  signature is preserved).

---

- [ ] 2. CREATE `review_requirements_screen.dart` — requirements review/edit screen.

  No `@riverpod` annotation. It receives `sessionId` and reads
  `productSearchProvider(sessionId)` (already populated in the cache from step 1's
  notifier) with `ref.watch`.

  **UI spec (light-surface, matches home screen style):**
  - `Scaffold`, `backgroundColor: Color(0xFFF5F6FF)`.
  - `AppBar`: `backgroundColor: Colors.transparent`, elevation 0, leading back
    button (`Icons.arrow_back_ios_new_rounded`, color `Color(0xFF0A0E2E)`),
    title `pjs(size:18, weight:FontWeight.w700, color:Color(0xFF0A0E2E))` with
    text `"Review Requirements"`.
  - Body is `SafeArea` > `state.when(loading:…, error:…, data:…)`.
  - `loading:` → `LoadingWidget(message: 'Loading session…')`.
  - `error:` → `ProofBuyErrorWidget(message: error.toString(), onRetry: () => ref.invalidate(productSearchProvider(sessionId)))`.
  - `data:` → scrollable column:
    1. **Brief summary card** (white, radius 20, shadow `0x0A000000` blur 12):
       - Label `pjs(size:11, weight:w600, color:Color(0xFF9CA3AF))` → "YOUR BRIEF"
       - Body text `pjs(size:14, color:Color(0xFF374151), height:1.55)` → `session.briefText`
    2. `SizedBox(height: 20)`.
    3. **Requirements section header**: `pjs(size:16, weight:w700, color:Color(0xFF0A0E2E))` → "Requirements Detected"
       followed by subtitle `pjs(size:12, color:Color(0xFF6B7280))` → "Review and edit before searching".
    4. `SizedBox(height: 12)`.
    5. For each entry in `session.requirementsJson ?? {}`:
       - A white rounded card (radius 16, same shadow) containing:
         - Key label (uppercased, `pjs(size:11, weight:w700, color:Color(0xFF6C47FF))`).
         - A `TextFormField` (no border box — use `InputBorder.none`, `contentPadding` EdgeInsets.zero)
           pre-filled with `value.toString()`, style `pjs(size:14, color:Color(0xFF0A0E2E))`.
           Store all controllers in a `Map<String, TextEditingController> _controllers`
           in a `StatefulWidget` wrapper (`_RequirementsBody`). Init in `initState`,
           dispose in `dispose`.
    6. `SizedBox(height: 32)`.
    7. **Primary CTA button** (full-width, height 56, gradient
       `LinearGradient(colors:[Color(0xFF6C47FF),Color(0xFF9F6EFF)])`, radius 16,
       shadow `Color(0x406C47FF)` blur 20):
       - Label `pjs(size:17, weight:w700, color:Colors.white)` → "Find Products →"
       - `onTap`: navigates `context.go('/results/$sessionId')`.
    8. `SizedBox(height: 12)`.
    9. **Secondary button** (full-width, height 52, white bg, border
       `Border.all(color:Color(0xFFE5E7EB))`, radius 16):
       - Label `pjs(size:15, weight:w600, color:Color(0xFF6C47FF))` → "← Edit brief"
       - `onTap`: `context.go('/brief')`.
    10. `SizedBox(height: 24)`.
  - Requirements map: if `requirementsJson` is null or empty, show a single
    `Container` with the text "No specific requirements detected — all products
    will be returned." in `pjs(size:13, color:Color(0xFF6B7280))`.

  **Files:** `lib/features/product_search/review_requirements_screen.dart`

  **Verify:**
  ```
  cd mobile && flutter test
  ```
  Smoke test passes (app still boots to OnboardingScreen correctly).

---

- [ ] 3. REPLACE `product_comparison_screen.dart` — horizontal card list UI.

  Keep `ProductComparisonNotifier` (build method + imports) exactly as-is.
  Replace `ProductComparisonScreen`'s body with the new horizontal scroll layout.

  **UI spec:**
  - `Scaffold`, `backgroundColor: Color(0xFFF5F6FF)`.
  - `AppBar`: transparent, elevation 0, leading back arrow (`Icons.arrow_back_ios_new_rounded`,
    color `Color(0xFF0A0E2E)`), title `pjs(size:18, weight:w700, color:Color(0xFF0A0E2E))`
    → "Best Matches".
  - `state.when` wraps the body (keep existing `loading:` and `error:` branches).
  - `data:` branch:
    1. Sort products by `rankingScore` descending (keep existing sort).
    2. If empty: centred `Text('No products found.', style: pjs(size:15, color:Color(0xFF6B7280)))`.
    3. Otherwise, a `Column` containing:
       a. **Results count header** — `Padding(horizontal:20, top:16, bottom:4)`:
          `RichText` → `"${products.length} "` in `pjs(size:22, weight:w800, color:Color(0xFF0A0E2E))`
          + `"products found"` in `pjs(size:16, weight:w400, color:Color(0xFF6B7280))`.
       b. **Sort strip** — `Padding(horizontal:20, bottom:12)`:
          `Row` with two pill chips: "Best Match" (active: `Color(0xFF6C47FF)` bg, white text)
          and "Lowest Price" (inactive: white bg, `Color(0xFF6B7280)` text, border).
          These are cosmetic-only for now — tapping "Lowest Price" sorts by `productData.price`
          ascending and tapping "Best Match" re-sorts by `rankingScore` descending.
          Manage selected sort with `ValueNotifier<String>` inside a `StatefulWidget`
          wrapper (`_ProductListBody`).
       c. **Card list** — `Expanded(child: ListView.builder(...))` reusing the
          existing `ProductCard` widget from `product_card.dart` (no changes to that file).
          `itemCount: sorted.length`, same `onTap` navigation as current code:
          `context.go('/product/${product.productResultId ?? product.productData.channel3ProductId ?? index.toString()}', extra: product)`.
       d. **Bottom "Back to Brief" link** (outside the list, in the Column after
          Expanded): `Padding(horizontal:20, vertical:12)`, `GestureDetector` →
          `context.go('/brief')`, with a `Row(mainAxisAlignment:center)` containing
          `Icons.arrow_back_rounded(size:14, color:Color(0xFF6C47FF))` +
          `Text('Start a new search', style:pjs(size:13, weight:w600, color:Color(0xFF6C47FF)))`.

  **Files:** `lib/features/product_comparison/product_comparison_screen.dart`

  **Verify:**
  ```
  cd mobile && dart run build_runner build --delete-conflicting-outputs
  cd mobile && flutter test
  ```
  `.g.dart` regenerates unchanged (notifier signature is preserved).

---

- [ ] 4. UPDATE `router.dart` — add `/review-requirements/:sessionId` route.

  Insert a new `GoRoute` entry between the `/loading/:sessionId` route and the
  `/results/:sessionId` route. Add the import for `review_requirements_screen.dart`.

  ```dart
  import '../features/product_search/review_requirements_screen.dart';
  ```

  New route block:
  ```dart
  GoRoute(
    path: '/review-requirements/:sessionId',
    builder: (context, state) => ReviewRequirementsScreen(
      sessionId: state.pathParameters['sessionId']!,
    ),
  ),
  ```

  No other routes are touched. The existing `/loading/:sessionId` already
  navigates to `/review-requirements/:sessionId` (after step 1).

  **Files:** `lib/app/router.dart`

  **Verify:**
  ```
  cd mobile && flutter test
  ```
  Smoke test passes. `flutter build apk --debug --dart-define=BACKEND_URL=http://10.0.2.2:8000`
  compiles clean (no "Could not find the correct Provider" or "undefined name" errors).

---

## Dependency order

Items must be implemented in order 1 → 2 → 3 → 4 (or 1+3 in parallel, then 2, then 4
since the router update references `ReviewRequirementsScreen` which doesn't exist until
item 2 is done). Safest is strictly sequential.

After all four items: run `dart run build_runner build --delete-conflicting-outputs`
once more to ensure no stale generated files, then `flutter test` for a final clean pass.
