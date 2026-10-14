# Implementation Plan — ProofBuy AI Flutter Mobile App

**Flutter**: 3.47.1 (Dart 3.13.1) at `/opt/homebrew/bin/flutter`  
**Android SDK**: `/Users/testbedmac1/Library/Android/sdk` (licenses need accepting — see step 1)  
**App root**: `/Users/testbedmac1/philldevcoder/projects/proofBuy-AI/mobile/` (does not exist yet)  
**Build/test commands**: all run from inside `mobile/`  
**Code gen**: `dart run build_runner build --delete-conflicting-outputs`

---

## Design decisions

- **Riverpod + code generation**: Use `@riverpod` annotation everywhere (riverpod_generator). This avoids hand-writing provider boilerplate and catches ref misuse at compile time. All business logic in AsyncNotifier or Notifier subclasses, never setState.
- **Freezed for all shared models**: Every API response shape is an immutable Freezed class with json_serializable. This gives compile-time null safety across the API boundary.
- **Sealed AppException hierarchy**: Dio errors are mapped to typed AppException subtypes in a single interceptor. Screens pattern-match on the type for user-facing messages.
- **GoRouter for all navigation**: Deep link `proofbuy://checkout/return` handled via a custom `deepLinkTransformer`; no raw `onGenerateRoute` needed.
- **Never expose backend verified=false as success**: CheckoutNotifier has a CheckoutSuccess variant that is only set when `capture_response.verified == true`. The screen only navigates on CheckoutSuccess.
- **ProductResult DB id problem**: The backend `GET /api/v1/products/{session_id}` returns `RankedProduct` objects whose `product` field is the raw Channel3 dict — the DB UUID (`ProductResult.id`) is not currently included. The coder must add an `id: Optional[str]` field to the backend `RankedProduct` Pydantic schema and populate it in `products.py`. This is a one-line backend change that unblocks the checkout flow.
- **No hardcoded localhost**: `AppConfig.backendUrl` reads `BACKEND_URL` from `--dart-define` with default `http://10.0.2.2:8000` (Android emulator's loopback).

---

## Pre-flight checklist

Before starting, run:
```bash
flutter doctor --android-licenses   # accept all prompts
flutter doctor                      # confirm [✓] Android toolchain
```

---

- [ ] 1. **Scaffold the Flutter project**
      Run inside `/Users/testbedmac1/philldevcoder/projects/proofBuy-AI/`:
      ```bash
      flutter create mobile --org com.proofbuy --project-name proofbuy_ai
      ```
      This creates `mobile/` with standard structure. The default `lib/main.dart`, `test/widget_test.dart`, and `android/` are the starting point — all will be replaced.
      Files: `mobile/` (new directory)
      Verify: `cd mobile && flutter run --help` exits 0; `ls mobile/pubspec.yaml` exists.

- [ ] 2. **Replace pubspec.yaml with pinned dependencies**
      Replace `mobile/pubspec.yaml` entirely. Set `name: proofbuy_ai`, `description: ProofBuy AI mobile client`, `version: 1.0.0+1`. Set Dart SDK constraint `'>=3.0.0 <4.0.0'`. Add all dependencies and dev_dependencies exactly as specified in the task brief.
      Files: `mobile/pubspec.yaml`
      Verify: `cd mobile && flutter pub get` exits 0.

- [ ] 3. **Core infrastructure: AppConfig, AppException, Dio API client**
      Create three files:
      - `mobile/lib/core/config/app_config.dart` — `AppConfig.backendUrl` reads `BACKEND_URL` dart-define, default `http://10.0.2.2:8000`.
      - `mobile/lib/core/errors/app_exception.dart` — sealed class with NetworkException, ServerException, NotFoundException, ValidationException, PaymentException.
      - `mobile/lib/core/networking/api_client.dart` — Dio with 30s timeouts, debug-only request logger, error interceptor mapping DioException to AppException subtypes. Exports `final dio = createDio()` and an `@riverpod Dio apiClient(...)` provider.
      Files: `mobile/lib/core/config/app_config.dart`, `mobile/lib/core/errors/app_exception.dart`, `mobile/lib/core/networking/api_client.dart`
      Verify: `flutter analyze` — 0 errors on new files.

- [ ] 4. **Base widgets: LoadingWidget, ProofBuyErrorWidget, EmptyStateWidget**
      Files: `mobile/lib/core/widgets/loading_widget.dart`, `mobile/lib/core/widgets/error_widget.dart`, `mobile/lib/core/widgets/empty_state_widget.dart`
      Note: Name the error widget class `ProofBuyErrorWidget` to avoid collision with Flutter's built-in `ErrorWidget`.
      Verify: `flutter analyze` — 0 errors.

- [ ] 5. **Theme and app shell**
      - `mobile/lib/app/theme.dart` — `ProofBuyTheme.lightTheme` and `darkTheme` with primary `#1A73E8`, secondary `#34A853`, error `#EA4335`. `ProofBuyColors` constants for pass/fail/unknown/surface/background.
      - Stub all screen files (empty Scaffold + AppBar): onboarding, shopping_brief, product_search, product_comparison, product_details, purchase_review, checkout, checkout_return, transaction_result, history, settings.
      - `mobile/lib/app/router.dart` — GoRouter with all 11 routes (see spec). Deep link `proofbuy://checkout/return` handled via GoRouter `deepLinkTransformer` or `initialLocation`+`redirect`.
      - `mobile/lib/app/app.dart` — `ProofBuyApp` ConsumerWidget using `MaterialApp.router`.
      - `mobile/lib/main.dart` — `runApp(ProviderScope(child: ProofBuyApp()))`.
      Files: `mobile/lib/app/theme.dart`, `mobile/lib/app/router.dart`, `mobile/lib/app/app.dart`, `mobile/lib/main.dart`, all stub screen files.
      Verify: `flutter analyze` — 0 errors; `flutter test` — default widget test passes (update it to pump ProofBuyApp).

- [ ] 6. **Configure Android deep links**
      Edit `mobile/android/app/src/main/AndroidManifest.xml`. Inside the main `<activity>`, add an `<intent-filter android:autoVerify="true">` with VIEW action, DEFAULT and BROWSABLE categories, and `<data android:scheme="proofbuy" android:host="checkout" android:pathPrefix="/return"/>`.
      Also add a `<queries>` block at the manifest level for `https` and `http` schemes (required for url_launcher on Android 11+).
      Files: `mobile/android/app/src/main/AndroidManifest.xml`
      Verify: `flutter build apk --debug` exits 0.

- [ ] 7. **Backend patch: expose ProductResult id in products API response**
      The `GET /api/v1/products/{session_id}` response currently omits the DB UUID (`ProductResult.id`). The Flutter checkout flow needs this id. Make a minimal backend change:
      - In `backend/app/schemas/product.py`: add `id: Optional[str] = None` to the `RankedProduct` class.
      - In `backend/app/routers/products.py`: set `id=str(product_row.id)` when constructing each `RankedProduct(...)` in the response list.
      Files: `backend/app/schemas/product.py`, `backend/app/routers/products.py`
      Verify: `cd backend && python3 -m pytest tests/ -v` — all existing tests still pass.

- [ ] 8. **Freezed shared models**
      Create all Freezed models in `mobile/lib/shared/models/`:
      - `shopping_session.dart` — ShoppingSession (id, briefText, requirementsJson Map?, status, createdAt, updatedAt). JSON: brief_text, requirements_json, created_at, updated_at.
      - `ranked_product.dart` — ProductData (inner product dict fields: channel3ProductId String?, name, price double?, currency String?, merchant String?, sourceUrl String?, imageUrl String?, specs Map?, retrievedAt String?) and RankedProduct (productData, constraintResults Map<String,String>, rankingScore double, rankingConfidence double, explanation String?, **productResultId String?** — this maps the new `id` field from step 7).
      - `purchase_record.dart` — PurchaseRecord (id, sessionId, productResultId, amount, currency, status, paypalOrderId String?, idempotencyKey String?, createdAt, updatedAt).
      - `app_transaction.dart` — AppTransaction (id, purchaseRecordId, paypalCaptureId String?, status, verifiedAt DateTime?, createdAt).
      - `checkout_models.dart` — CheckoutCreateResponse (orderId, approvalUrl, purchaseId), CheckoutCaptureResponse (transactionId, status, verified bool).
      - `history_item.dart` — HistoryItem (purchaseRecord PurchaseRecord, product ProductData?, session ShoppingSession?).
      Run `dart run build_runner build --delete-conflicting-outputs` to generate `.freezed.dart` and `.g.dart` files.
      Files: `mobile/lib/shared/models/*.dart` (6 files + generated .freezed.dart/.g.dart)
      Verify: `flutter analyze` — 0 errors; `flutter test` passes.

- [ ] 9. **Repository layer and Riverpod providers**
      Create four repositories:
      - `mobile/lib/core/networking/shopping_repository.dart` — `submitBrief(brief)` → POST `/api/v1/shopping/brief`, `getSession(sessionId)` → GET.
      - `mobile/lib/core/networking/products_repository.dart` — `getProducts(sessionId)` → GET list of RankedProduct.
      - `mobile/lib/core/networking/checkout_repository.dart` — `createCheckout(productResultId)` → POST create, `captureCheckout(orderId, purchaseId)` → POST capture.
      - `mobile/lib/core/networking/transactions_repository.dart` — `getTransaction(purchaseId)` → GET AppTransaction, `getHistory()` → GET list of HistoryItem.
      Create `mobile/lib/core/networking/repositories_providers.dart` with `@riverpod` providers for each repository (each reads `apiClientProvider`).
      Run build_runner to generate provider `.g.dart` files.
      Files: `mobile/lib/core/networking/shopping_repository.dart`, `products_repository.dart`, `checkout_repository.dart`, `transactions_repository.dart`, `repositories_providers.dart`
      Verify: `flutter analyze` — 0 errors; `flutter test` passes.

- [ ] 10. **Onboarding + ShoppingBrief screens**
       Implement (replacing stubs):
       - `mobile/lib/features/onboarding/onboarding_screen.dart` — welcome + 'Get Started' → `/brief`.
       - `mobile/lib/features/shopping_brief/shopping_brief_provider.dart` — `ShoppingBriefNotifier` (AsyncNotifier<ShoppingSession?>) with `submitBrief(brief)`.
       - `mobile/lib/features/shopping_brief/shopping_brief_screen.dart` — TextField + char counter (min 10, max 500) + 'Find Products' button, disabled while loading or text < 10 chars. On success navigate to `/loading/${session.id}`.
       Files: above 3 files + build_runner output
       Verify: `flutter analyze` — 0 errors; `flutter test` passes.

- [ ] 11. **ProductSearch + ProductComparison + ConstraintBadge + ProductCard screens**
       Implement:
       - `mobile/lib/features/product_search/product_search_screen.dart` — polls session then products, shows requirements summary, two action buttons.
       - `mobile/lib/features/product_comparison/constraint_badge.dart` — PASS/FAIL/UNKNOWN colored chips.
       - `mobile/lib/features/product_comparison/product_card.dart` — image, name, merchant, price (intl NumberFormat.currency), ranking LinearProgressIndicator, constraint badges, 'View Details' button.
       - `mobile/lib/features/product_comparison/product_comparison_screen.dart` — ListView sorted by rankingScore desc; passes RankedProduct via GoRouter extras to product details route.
       Files: above 4 files
       Verify: `flutter analyze` — 0 errors; `flutter test` passes.

- [ ] 12. **ProductDetails screen**
       Implement `mobile/lib/features/product_details/product_details_screen.dart`:
       - Receives RankedProduct via GoRouter extras.
       - Shows CachedNetworkImage, name, price, merchant, specs expansion tile, evidence section with ConstraintBadge per attribute, AI explanation text, confidence percentage.
       - 'Buy with PayPal' → navigate to `/review/${product.productResultId}` with product as extras.
       Files: `mobile/lib/features/product_details/product_details_screen.dart`
       Verify: `flutter analyze` — 0 errors; `flutter test` passes.

- [ ] 13. **PurchaseReview screen**
       Implement `mobile/lib/features/purchase_review/purchase_review_screen.dart`:
       - Receives RankedProduct via extras.
       - Shows product name, formatted price, constraint results list with ConstraintBadge.
       - If any constraint result is 'UNKNOWN', show a yellow `MaterialBanner` listing the unverified attribute names.
       - 'Confirm and Pay with PayPal' → navigate to `/checkout/${product.productResultId}` with product as extras.
       - 'Cancel' → `context.pop()`.
       Files: `mobile/lib/features/purchase_review/purchase_review_screen.dart`
       Verify: `flutter analyze` — 0 errors; `flutter test` passes.

- [ ] 14. **Checkout flow: CheckoutProvider + CheckoutScreen + CheckoutReturnScreen**
       - `mobile/lib/features/checkout/checkout_provider.dart` — CheckoutState Freezed union (Idle, CreatingOrder, AwaitingApproval, Capturing, Success, Failure). CheckoutNotifier Notifier<CheckoutState> with `createOrder(productResultId)` and `captureOrder(orderId, purchaseId)`. `captureOrder` sets Success only when `response.verified == true`; sets Failure otherwise.
       - `mobile/lib/features/checkout/checkout_screen.dart` — on initState calls `createOrder`. Shows each state as documented. 'Open PayPal' calls `launchUrl(Uri.parse(approvalUrl), mode: LaunchMode.externalApplication)`. 'I've completed payment' calls `captureOrder`. On Success state navigate to `/transaction/${state.transactionId}`.
       - `mobile/lib/features/checkout/checkout_return_screen.dart` — shows 'Returning from PayPal...' and 'Continue to confirmation' button that pops back.
       Files: above 3 files + build_runner output
       Verify: `flutter analyze` — 0 errors; `flutter test` passes (especially checkout_test.dart).

- [ ] 15. **TransactionResult screen**
       Implement `mobile/lib/features/transaction_result/transaction_result_screen.dart`:
       - Receives transactionId via route param.
       - FutureProvider calls `transactionsRepositoryProvider.getTransaction(transactionId)`.
       - Shows success icon (green check_circle), 'Payment Verified!', transaction id, status, formatted verifiedAt.
       - Buttons: 'View History' → `/history`, 'Back to Shopping' → `/brief`.
       Files: `mobile/lib/features/transaction_result/transaction_result_screen.dart`
       Verify: `flutter analyze` — 0 errors; `flutter test` passes.

- [ ] 16. **TransactionHistory and Settings screens**
       Implement:
       - `mobile/lib/features/transaction_history/history_screen.dart` — FutureProvider on `getHistory()`, ListView with status icons, EmptyStateWidget on empty.
       - `mobile/lib/features/settings/settings_screen.dart` — backend URL display (from AppConfig.backendUrl), app version, clear local data (SharedPreferences.clear() with confirmation dialog).
       Files: above 2 files
       Verify: `flutter analyze` — 0 errors; `flutter test` passes.

- [ ] 17. **Unit tests for repositories**
       Create:
       - `mobile/test/repositories/shopping_repository_test.dart` — mock Dio, test submitBrief (200 → ShoppingSession, 422 → ValidationException), getSession (200 → ShoppingSession, 404 → NotFoundException).
       - `mobile/test/repositories/checkout_repository_test.dart` — test createCheckout (200 → CheckoutCreateResponse), captureCheckout (200 verified=true → success, 200 verified=false → success with verified=false — not exception).
       - `mobile/test/features/product_comparison_test.dart` — mock ProductsRepository, test loading/error/data states and sort order.
       - `mobile/test/features/checkout_test.dart` — mock CheckoutRepository, test all CheckoutState transitions including verified=false → CheckoutFailure.
       Files: above 4 test files
       Verify: `flutter test` — all tests pass.

- [ ] 18. **Write mobile/README.md**
       Document prerequisites, setup, code generation, run on emulator/device (with `--dart-define=BACKEND_URL=...`), build APK, test, common failure recovery (Android licenses, build_runner conflicts, emulator connectivity).
       Files: `mobile/README.md`
       Verify: file exists and is readable.

- [ ] 19. **Final full build**
       Run the complete sequence in `mobile/`:
       ```bash
       flutter pub get
       dart run build_runner build --delete-conflicting-outputs
       flutter analyze
       flutter test
       flutter build apk --debug --dart-define=BACKEND_URL=http://10.0.2.2:8000
       ```
       All four commands must exit 0. The debug APK must exist at `mobile/build/outputs/flutter-apk/app-debug.apk`.
       Files: no new files — verification only.
       Verify: All commands exit 0; APK file exists.

---

## Common failure recovery

| Failure | Cause | Fix |
|---|---|---|
| `flutter pub get` fails on `flutter_secure_storage` | Missing iOS pod config | Run `cd mobile/ios && pod install` (iOS only — skip for Android-only demo) |
| `build_runner` throws `ConflictingOutputsException` | Old .g.dart files | Add `--delete-conflicting-outputs` flag |
| `flutter analyze` reports `undefined class` for generated types | build_runner not run yet | Run `dart run build_runner build --delete-conflicting-outputs` |
| `flutter build apk --debug` fails with `license not accepted` | Android SDK licenses | Run `flutter doctor --android-licenses` and accept all |
| `flutter build apk` fails with `Kotlin version` | Gradle/Kotlin mismatch | Update `mobile/android/app/build.gradle` Kotlin version to match required |
| `url_launcher` throws `PlatformException` in debug | Missing `<queries>` block | Add the queries intent block to AndroidManifest.xml (step 6) |
| Connection refused from emulator | Wrong IP | Emulator uses `10.0.2.2` not `localhost` — pass `--dart-define=BACKEND_URL=http://10.0.2.2:8000` |
| `DioException` on every request | Backend not running | Start backend: `cd backend && uvicorn app.main:app --reload` |

---

## FEAT decomposition (for workflow)

This plan is decomposed into 5 FEATs under `backend/.agents/tasks/task-flutter-mobile/features/`:
- **FEAT-001**: Project scaffold + core infrastructure + theme + router (all screen stubs)
- **FEAT-002**: Freezed models + repository layer + Riverpod providers
- **FEAT-003**: Shopping Brief → Product Search → Comparison → Details screens
- **FEAT-004**: PayPal checkout flow (Review → Checkout → Return → TransactionResult)
- **FEAT-005**: History + Settings + test suite + README + final APK build
