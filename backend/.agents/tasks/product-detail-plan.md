# Implementation Plan: Product Detail — Full Rich Data

**Worktree root:** `/Users/testbedmac1/philldevcoder/projects/proofBuy-AI`

## Key decisions made during exploration

- **Route ordering in products.py:** The new `/detail/{channel3_product_id}` route MUST be declared in the file BEFORE the existing `/{session_id}` route. FastAPI registers routes in declaration order; if `/{session_id}` comes first it will swallow any path including "detail" as a session ID. The existing router already demonstrates this pattern for `/checkout/return` vs `/checkout/:purchaseId` in `router.dart`.
- **Python 3.9 compat:** All new Pydantic models use `Optional[X]` and `List[X]` from `typing` — never `X | Y`. The existing `channel3_service.py` and `schemas/product.py` follow this convention throughout.
- **Freezed codegen:** After editing `ranked_product.dart`, build_runner must be re-run before the Flutter screen can compile. The `.freezed.dart` and `.g.dart` files are checked in and must be regenerated.
- **Repository pattern:** `ProductDetailRepository` follows `ProductsRepository` exactly — takes `Dio` from `apiClientProvider`, registered via `@riverpod` in `repositories_providers.dart`, triggers codegen of `productDetailRepositoryProvider`.
- **Shimmer loading on detail screen:** `ProductDetailsShimmer` already exists in `shimmer_widgets.dart` — use it directly while the detail fetch is in-flight.
- **Image URL:** Use `cleanedUrl ?? url` from `ProductImage` for all `CachedNetworkImage` sources — Channel3 provides cleaned CDN URLs on most products.
- **No AppBar on rebuilt screen:** Floating back button (white pill, top-left) replaces the AppBar for a full-bleed immersive gallery feel.
- **FutureBuilder approach for detail fetch:** A simple `Future<ProductData?>` field in `_ProductDetailsViewState` initialized in `initState` avoids introducing a new Riverpod provider, keeps the pattern lightweight, and matches the existing ConsumerWidget architecture.

---

## FEAT-001: Backend — rich product data schema + detail endpoint

- [ ] 1. **Add ProductImage, ProductOffer, ProductRatings to schemas/product.py and extend NormalizedProduct.**
      Add `from typing import List` to existing imports (Optional already present). Define three new `BaseModel` subclasses: `ProductImage`, `ProductOffer`, `ProductRatings` (see spec in task description — all fields use `Optional[X]` or bare types, never `X | Y`). Extend `NormalizedProduct` with: `all_images: List[ProductImage] = []`, `all_offers: List[ProductOffer] = []`, `ratings: Optional[ProductRatings] = None`, `materials: Optional[List[str]] = None`, `key_features: Optional[List[str]] = None`, `variants_options: Optional[List[dict]] = None`, `structured_attributes: Optional[dict] = None`, `category_title: Optional[str] = None`, `gender: Optional[str] = None`, `description: Optional[str] = None`. Keep all existing fields and `model_validator` intact.
      Files: `backend/app/schemas/product.py`
      Verify: `cd /Users/testbedmac1/philldevcoder/projects/proofBuy-AI/backend && .venv/bin/python -c "from app.schemas.product import NormalizedProduct, ProductImage, ProductOffer, ProductRatings; print('OK')"` — prints OK.

- [ ] 2. **Update `Channel3Service._normalize()` to parse all images, offers, ratings, materials, features, variants, category, gender.**
      Add `from urllib.parse import urlparse` import at top of file. Update the import from `app.schemas.product` to include `ProductImage, ProductOffer, ProductRatings`. In `_normalize()`:
      - Replace existing `all_image_urls` list with `all_images: List[ProductImage]` built from `raw.get('images',[])` — for each dict extract `url` (prefer `cleaned_url` key, fallback `url`/`src`), `cleaned_url`, `is_main_image`, `shot_type`, `alt_text`; for bare strings create `ProductImage(url=s)`.
      - Set `image_url` using: first `is_main_image=True` image's url, else first `shot_type=='hero'`, else `all_images[0].url` if any.
      - Parse `all_offers: List[ProductOffer]` from `raw.get('offers',[])` — extract domain from `o.get('domain')` or `urlparse(o.get('url','')).netloc`.
      - Parse `ratings` from `raw.get('ratings')` → `ProductRatings` if `value` key exists.
      - Parse `materials` from `raw.get('materials')` — handle list-of-strings and list-of-dicts.
      - Keep `key_features` assignment to `specs['features']` AND also set `key_features` kwarg on `NormalizedProduct`.
      - Parse `structured_attributes`, `variants_options` (from `raw.get('variants',{}).get('options')`), `category_title` (from `raw.get('category',{}).get('title')`), `gender`.
      - Set `description` directly on `NormalizedProduct` (in addition to `specs['description']`).
      - Pass all new fields to `NormalizedProduct(...)` constructor.
      Files: `backend/app/services/channel3_service.py`
      Verify: `cd /Users/testbedmac1/philldevcoder/projects/proofBuy-AI/backend && .venv/bin/python -m pytest tests/test_channel3.py -q` — all existing tests pass.

- [ ] 3. **Enrich MOCK_PRODUCTS with full sample data.**
      Each of the 3 mocks needs `all_images` (4 entries, different shot_types), `all_offers` (2 entries, different domains), `ratings`, `materials`, `key_features`, `description`. Use Unsplash photo IDs already in each mock's `image_url` to build gallery variant URLs (append `&crop=entropy`, `&crop=faces`, etc.). Set `is_main_image=True` on the first image. Keep all existing `specs` dict content unchanged (test `test_mock_has_unknown_specs` relies on `battery_life: None` in mock 003).
      Files: `backend/app/services/channel3_service.py`
      Verify: `cd /Users/testbedmac1/philldevcoder/projects/proofBuy-AI/backend && .venv/bin/python -m pytest tests/test_channel3.py -q` — all pass including `test_mock_has_unknown_specs`.

- [ ] 4. **Add `get_product_detail()` alias to `Channel3Service` and the new router endpoint.**
      In `Channel3Service`, add: `async def get_product_detail(self, product_id: str) -> Optional[NormalizedProduct]: return await self.get_product(product_id)`.
      In `products.py`, add a new route handler **before** the existing `/{session_id}` route:
      ```python
      @router.get("/detail/{channel3_product_id}")
      @limiter.limit("30/minute")
      async def get_product_detail(
          request: Request,
          channel3_product_id: str,
          db: AsyncSession = Depends(get_db),
      ):
          from fastapi.responses import JSONResponse
          import json
          svc = get_channel3_service()
          product = await svc.get_product_detail(channel3_product_id)
          if product is None:
              result = await db.execute(
                  select(ProductResult).where(
                      ProductResult.channel3_product_id == channel3_product_id
                  )
              )
              row = result.scalars().first()
              if row is None:
                  raise NotFoundError(f"Product '{channel3_product_id}' not found")
              # Return minimal data from DB row
              return {"channel3_product_id": channel3_product_id, "name": row.name,
                      "price": row.price, "currency": row.currency}
          d = product.model_dump()
          d["retrieved_at"] = product.retrieved_at.isoformat()
          return d
      ```
      Add imports: `from app.services.channel3_service import get_channel3_service` and `from app.schemas.product import NormalizedProduct` at top of `products.py`.
      Files: `backend/app/services/channel3_service.py`, `backend/app/routers/products.py`
      Verify: `cd /Users/testbedmac1/philldevcoder/projects/proofBuy-AI/backend && .venv/bin/python -m pytest tests/ -q` — all pass.

- [ ] 5. **Update backward-compat `search_products()` wrapper with new fields.**
      In the module-level `search_products()` function, add to each result dict:
      `'all_images': [img.model_dump() for img in p.all_images]`,
      `'all_offers': [o.model_dump() for o in p.all_offers]`,
      `'ratings': p.ratings.model_dump() if p.ratings else None`,
      `'materials': p.materials`,
      `'key_features': p.key_features`,
      `'structured_attributes': p.structured_attributes`,
      `'category_title': p.category_title`,
      `'variants_options': p.variants_options`,
      `'description': p.description`.
      Files: `backend/app/services/channel3_service.py`
      Verify: `cd /Users/testbedmac1/philldevcoder/projects/proofBuy-AI/backend && .venv/bin/python -m pytest tests/ -q` — full suite still passes.

---

## FEAT-002: Flutter — Freezed models, ProductDetailRepository, rebuilt detail screen

> **FEAT-002 depends on FEAT-001 being committed first** — the Flutter screen calls the `/detail/{id}` endpoint added in FEAT-001.

- [ ] 6. **Add ProductImage, ProductOffer, ProductRatings Freezed models and extend ProductData in ranked_product.dart.**
      Insert three new `@freezed abstract class` definitions before the existing `ProductData` class — `ProductImage`, `ProductOffer`, `ProductRatings` — following the exact `freezed_annotation` pattern used by `RankedProduct` in the same file (same imports, `part` directives already cover all classes in the file). In `ProductData`'s factory constructor, add these fields after `retrievedAt`: `@JsonKey(name:'all_images') @Default([]) List<ProductImage> allImages`, `@JsonKey(name:'all_offers') @Default([]) List<ProductOffer> allOffers`, `ProductRatings? ratings`, `List<String>? materials`, `@JsonKey(name:'key_features') List<String>? keyFeatures`, `@JsonKey(name:'structured_attributes') Map<String,dynamic>? structuredAttributes`, `@JsonKey(name:'category_title') String? categoryTitle`, `String? description`. Keep all existing `ProductData` and `RankedProduct` fields exactly as-is.
      Files: `mobile/lib/shared/models/ranked_product.dart`
      Verify: file saves without syntax errors (codegen runs next step).

- [ ] 7. **Create ProductDetailRepository and wire into providers.**
      Create `mobile/lib/core/networking/product_detail_repository.dart` following `products_repository.dart` exactly — constructor takes `Dio`, method `getProductDetail(String channel3ProductId)` calls `GET /api/v1/products/detail/$channel3ProductId`, parses response with `ProductData.fromJson()`, returns `null` on 404 or any error (never throws — same defensive pattern as `_fallbackProducts()`).
      In `mobile/lib/core/networking/repositories_providers.dart`: add `import 'product_detail_repository.dart';` and add `@riverpod ProductDetailRepository productDetailRepository(Ref ref) => ProductDetailRepository(ref.watch(apiClientProvider));`.
      Files: `mobile/lib/core/networking/product_detail_repository.dart` (new), `mobile/lib/core/networking/repositories_providers.dart`
      Verify: file saved; codegen runs next step.

- [ ] 8. **Run build_runner to regenerate Freezed and Riverpod code.**
      `cd /Users/testbedmac1/philldevcoder/projects/proofBuy-AI/mobile && flutter pub run build_runner build --delete-conflicting-outputs`
      This regenerates: `ranked_product.freezed.dart`, `ranked_product.g.dart`, `repositories_providers.g.dart`.
      Fix any codegen errors (most common: incorrect `@Default` annotation on a non-simple type — use `@Default([])` only for `List<T>`, use `Map<String,dynamic>?` with nullable for maps).
      Files: `mobile/lib/shared/models/ranked_product.freezed.dart`, `mobile/lib/shared/models/ranked_product.g.dart`, `mobile/lib/core/networking/repositories_providers.g.dart`
      Verify: command exits with code 0, no `[SEVERE]` lines in output.

- [ ] 9. **Completely rebuild product_details_screen.dart.**
      Replace the entire file content. Outer `ProductDetailsScreen` ConsumerWidget stays identical (same signature, same GoRouter extra + `selectedProductProvider` fallback, same null guard showing "unavailable" text).
      Change `_ProductDetailsView` to a `ConsumerStatefulWidget` / `_ProductDetailsViewState`. In state:
      - Declare `Future<ProductData?>? _detailFuture;`
      - In `initState`, if `product.productData.channel3ProductId != null`, set `_detailFuture = ref.read(productDetailRepositoryProvider).getProductDetail(id);`
      - Build with `FutureBuilder<ProductData?>(future: _detailFuture, builder: (ctx, snap) { if (snap.connectionState != ConnectionState.done) return ProductDetailsShimmer(); final effectiveData = snap.data ?? product.productData; return _buildBody(ctx, effectiveData); })`.

      `_buildBody` returns `Scaffold(backgroundColor: Color(0xFFF8FAFC), body: SafeArea(child: SingleChildScrollView(child: Column(children: [ _imageGallery(effectiveData), _paddedContent(effectiveData) ]))))`.

      **`_imageGallery(ProductData data)`** — returns `Stack(children: [ SizedBox(height:300, child: data.allImages.isEmpty ? _ImagePlaceholder() : PageView.builder(controller:_pageController, onPageChanged:(i)=>setState(()=>_currentPage=i), itemCount:data.allImages.length, itemBuilder:(ctx,i){ final img=data.allImages[i]; final src=img.cleanedUrl??img.url; return CachedNetworkImage(imageUrl:src, fit:BoxFit.cover, height:300, width:double.infinity, placeholder:(c,u)=>ProofShimmer(child:ShimmerBox(width:double.infinity,height:300,radius:0)), errorWidget:(c,u,e)=>_ImagePlaceholder()); }) ), Positioned(top:48,left:16, child: GestureDetector(onTap:()=>context.pop(), child:Container(padding:EdgeInsets.all(10), decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(20),boxShadow:[BoxShadow(color:Color(0x18000000),blurRadius:8,offset:Offset(0,2))]), child:Icon(Icons.arrow_back_ios_new_rounded,size:18,color:Color(0xFF0F172A))))), if (data.allImages.length > 1) Positioned(bottom:12, left:0, right:0, child:Row(mainAxisAlignment:MainAxisAlignment.center, children: List.generate(data.allImages.length, (i)=>Container(margin:EdgeInsets.symmetric(horizontal:3), width:_currentPage==i?8:6, height:_currentPage==i?8:6, decoration:BoxDecoration(color:_currentPage==i?ProofBuyColors.accent:Color(0xFFCBD5E1),shape:BoxShape.circle))))) ])`.

      **`_paddedContent(ProductData data)`** — Padding(padding:EdgeInsets.symmetric(horizontal:20), child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[ SizedBox(height:16), // brand if (data.merchant!=null && data.merchant!.isNotEmpty) Text(data.merchant!, style:pjs(12,color:Color(0xFF64748B))), // title Text(data.name, style:pjs(24,weight:FontWeight.w800,color:Color(0xFF0F172A),height:1.3)), SizedBox(height:8), // ratings row if (data.ratings!=null) Row(children:[Icon(Icons.star_rounded,color:Color(0xFFF59E0B),size:16),SizedBox(width:4),Text('${data.ratings!.value.toStringAsFixed(1)}',style:pjs(13,weight:FontWeight.w700,color:Color(0xFF0F172A))),SizedBox(width:4),Text('(${data.ratings!.count} reviews)',style:pjs(12,color:Color(0xFF64748B)))]), // category pill if (data.categoryTitle!=null) Chip(label:Text(data.categoryTitle!,style:pjs(11)),backgroundColor:Color(0xFFEFF6FF),side:BorderSide.none,padding:EdgeInsets.symmetric(horizontal:4)), Divider(color:Color(0xFFE2E8F0),height:24), // price section _priceSection(data), // all offers if (data.allOffers.isNotEmpty) _offersSection(data.allOffers), Divider(color:Color(0xFFE2E8F0),height:24), // description _descriptionSection(data), // key features _featuresSection(data), // specs _specsSection(data), // materials _materialsSection(data), SizedBox(height:16), // AI explanation card (existing impl) if (product.explanation!=null && product.explanation!.isNotEmpty) _aiCard(product.explanation!), // constraint results (existing impl) if (product.constraintResults.isNotEmpty) _constraintsCard(product), // confidence bar (existing impl) _confidenceBar(product), SizedBox(height:28), // buy button _buyButton(context,ref), // retailer button if (data.sourceUrl!=null) _retailerButton(data.sourceUrl!), SizedBox(height:20) ])).

      Helper methods:
      - `_priceSection`: best price from `data.price`, plus `data.allOffers.isNotEmpty ? data.allOffers.reduce(...)` for compare_at. Availability badge.
      - `_offersSection`: `SizedBox(height:120, child:ListView.builder(scrollDirection:Axis.horizontal,...))` — each card: domain, price, 'Shop Now' button calling `launchUrl`.
      - `_descriptionSection`: source `data.description ?? data.specs?['description']`, no truncation.
      - `_featuresSection`: source `data.keyFeatures?.isNotEmpty==true ? data.keyFeatures : (data.specs?['features'] as List?)?.cast<String>()`, bullet list with `Icons.check_circle_outline_rounded`.
      - `_specsSection`: `data.specs` entries excluding 'description' and 'features', ExpansionTile grid (keep existing layout).
      - `_materialsSection`: `data.materials?.isNotEmpty==true ? Wrap(children:data.materials!.map((m)=>Chip(label:Text(m,style:pjs(12)),backgroundColor:Color(0xFFF1F5F9),...)).toList()) : SizedBox.shrink()`.
      - Keep `_aiCard`, `_constraintsCard`, `_confidenceBar`, `_buyButton`, `_retailerButton` identical to current implementation.

      Files: `mobile/lib/features/product_details/product_details_screen.dart`
      Verify: `cd /Users/testbedmac1/philldevcoder/projects/proofBuy-AI/mobile && flutter analyze` — zero errors.

- [ ] 10. **Run final verification — fix all remaining issues.**
      Run in order:
      1. `cd /Users/testbedmac1/philldevcoder/projects/proofBuy-AI/backend && .venv/bin/python -m pytest tests/ -q` — must pass.
      2. `cd /Users/testbedmac1/philldevcoder/projects/proofBuy-AI/mobile && flutter pub run build_runner build --delete-conflicting-outputs` — zero errors.
      3. `cd /Users/testbedmac1/philldevcoder/projects/proofBuy-AI/mobile && flutter analyze` — zero errors.
      Common issues and fixes:
      - `model_dump()` on `ProductOffer`/`ProductImage` may fail if `datetime` fields are present — use `model_dump(mode='json')` or manual `isoformat()`.
      - Flutter `FutureBuilder` null safety: always handle `snap.data == null` without crash.
      - `PageController` must be disposed in `dispose()` override.
      - `List<String>` cast: `(specs['features'] as List).cast<String>()` — guard with `is List` check.
      Files: any files with remaining errors.
      Verify: all three commands above complete with zero failures.

---

## Gotchas summary

1. **Route order in `products.py`:** `/detail/{id}` must appear before `/{session_id}` in source — FastAPI uses declaration order.
2. **Python 3.9 compat:** `List[dict]` not `list[dict]`, `Optional[str]` not `str | None`.
3. **`model_dump()` + datetime:** `NormalizedProduct.retrieved_at` is a `datetime` — when returning from the endpoint, call `.isoformat()` before serialising or use `model.model_dump(mode='json')`.
4. **Freezed `@Default([])` on `List<ProductImage>`:** Freezed supports this but the generated code requires the inner type to have a `fromJson`. Since `ProductImage` has `fromJson`, this is fine — but the class must appear BEFORE `ProductData` in the file.
5. **`_detailFuture` init:** Call `ref.read(...)` inside `initState` is valid in Riverpod 3.x for a one-shot read. Do NOT call `ref.watch` in `initState`.
6. **`PageController` dispose:** `_ProductDetailsViewState` must override `dispose()` to call `_pageController.dispose()` — flutter analyze will warn otherwise.
7. **`test_mock_has_unknown_specs`:** The ThinkPad mock has `"battery_life": None` — keep that key when enriching.
8. **`repositories_providers.g.dart` hash:** After adding a new `@riverpod` function, running build_runner regenerates the `.g.dart` with a new hash. The file is checked in — commit the new version.
