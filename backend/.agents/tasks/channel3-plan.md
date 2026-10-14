# Implementation Plan: Channel3 Real Product Search Integration

## Context from Exploration

- **Build/test command**: `cd backend && pytest` (pytest.ini sets `asyncio_mode = auto`, so no `@pytest.mark.asyncio` needed — but existing tests already use it; keep the marker for clarity)
- **httpx**: `0.28.1` already in requirements.txt
- **pytest-httpx**: `0.35.0` already in requirements.txt; no new dependencies needed
- **shopping.py call site**: currently calls the module-level `channel3_service.search_products(request.brief, session.id)` returning `list[dict]`. After the refactor it must use `get_channel3_service().search_products(query, filters, limit)` returning `List[NormalizedProduct]`. The field mapping in `shopping.py` must also be updated because `NormalizedProduct` uses `specs` (not `specs_json`), and the `session_id` / `constraint_results_json` / `ranking_score` fields that currently come from the dict do not exist on `NormalizedProduct`.
- **products.py**: currently returns persisted `ProductResult` rows only. Needs a new optional `?query=` param that triggers a live `Channel3Service.search_products()` call and returns `List[NormalizedProduct]` instead of `List[ProductResultResponse]`. The response model therefore becomes a `Union` or the endpoint splits into a new route — see item 4 for the chosen approach.
- **ProofBuyException**: defined in `app/core/exceptions.py` with `__init__(message, status_code)`. New exception subclasses follow the same pattern.
- **settings.channel3_api_key**: already wired in `app/config.py`; mock mode triggers when the value is empty string `""` (the default).

---

## Implementation Plan

- [ ] 1. Add `NormalizedProduct` Pydantic model to `app/schemas/product.py`.
      Add the model after the existing `ProductResultResponse` class. Fields: `channel3_product_id: str`, `name: str`, `price: Optional[float] = None`, `currency: Optional[str] = None`, `merchant: Optional[str] = None`, `source_url: Optional[str] = None`, `image_url: Optional[str] = None`, `specs: dict = Field(default_factory=dict)`, `retrieved_at: datetime`, `data_complete: bool`. Compute `data_complete` via a `model_validator(mode="after")` that sets it to `True` only when `price` is not `None`, `currency` is not `None`, and `name` is non-empty. Import `Field` and `model_validator` from `pydantic` and add `timezone` to the `datetime` import.

      Files: `app/schemas/product.py`

      Verify: `cd backend && pytest tests/test_schemas.py -v` — all existing schema tests still pass. No new test for this item is needed yet; the new model is verified implicitly in item 6.

- [ ] 2. Add `Channel3AuthError`, `Channel3RateLimitError`, and `Channel3ServiceError` to `app/core/exceptions.py`.
      Each subclasses `ProofBuyException` directly. `Channel3AuthError.__init__(message)` calls `super().__init__(message, status_code=401)`. `Channel3RateLimitError.__init__(message)` calls `super().__init__(message, status_code=429)`. `Channel3ServiceError.__init__(message)` calls `super().__init__(message, status_code=503)` (treating all Channel3 5xx/timeout as service-unavailable downstream).

      Files: `app/core/exceptions.py`

      Verify: `cd backend && pytest tests/ -v` — all existing tests still pass (no behaviour change, only additions).

- [ ] 3. Replace `app/services/channel3_service.py` with the class-based async implementation.
      The file should contain:

      **`Channel3Service` class:**
      - `__init__(self, api_key: str, base_url: str = "https://api.trychannel3.com")` — stores both; creates a private `httpx.AsyncClient` with base URL and default headers `{"x-api-key": api_key, "Content-Type": "application/json"}`. Set a 30-second timeout.
      - `async search_products(self, query: str, filters: dict | None = None, limit: int = 10) -> List[NormalizedProduct]` — if `self._mock_mode` is `True`, return the three mock products defined below; otherwise POST `/v1/search` with body `{"query": query, "limit": limit, **(filters or {})}`, call `_handle_response(response)`, then parse each item in `response.json()["products"]` (or the root list if the payload is a list) into `NormalizedProduct` using `_parse_product()`.
      - `async get_product(self, product_id: str) -> Optional[NormalizedProduct]` — if mock mode, return `None`; otherwise GET `/v1/products/{product_id}`, call `_handle_response`, parse with `_parse_product()`. If the endpoint returns 404, return `None` rather than raising.
      - `_handle_response(self, response: httpx.Response) -> None` — raises `Channel3AuthError` on 401, `Channel3RateLimitError` on 429, `Channel3ServiceError` on any 5xx; re-raises `httpx.TimeoutException` as `Channel3ServiceError`.
      - `_parse_product(self, data: dict) -> NormalizedProduct` — maps API response fields to `NormalizedProduct`. Missing fields stay `None` (never inferred). `retrieved_at` defaults to `datetime.now(timezone.utc)` if absent. `specs` defaults to `{}` if absent or `None`.
      - `async def close(self)` — closes the internal `httpx.AsyncClient`.

      **Mock mode:** `self._mock_mode = not bool(api_key)`. When true, log `"Channel3 running in MOCK MODE — set CHANNEL3_API_KEY for real data"` at `WARNING` level via `logging.getLogger("proofbuy")`. Return these three fixed `NormalizedProduct` objects:
      1. Dell XPS 15 — `price=999.99`, `currency="USD"`, `name` set → `data_complete=True`, all spec fields populated.
      2. ASUS ROG Zephyrus — `price=1499.00`, `currency="USD"`, `name` set → `data_complete=True`, price > $1200 to exercise constraint failure.
      3. Generic Laptop — `price=None`, `currency=None`, `name="Unknown Laptop"` → `data_complete=False`, `specs={"ram": None, "storage": None}` to exercise None spec fields.

      **`get_channel3_service()` factory function (module-level):**
      ```python
      def get_channel3_service() -> Channel3Service:
          return Channel3Service(api_key=settings.channel3_api_key)
      ```
      Import `settings` from `app.config`.

      Files: `app/services/channel3_service.py`

      Verify: `cd backend && pytest tests/test_channel3.py -v -k "mock"` — mock-mode tests pass (test file written in item 6, but this item must not break imports). Also run `cd backend && pytest tests/test_shopping.py -v` after item 4 is complete to confirm no regression.

- [ ] 4. Update `app/routers/shopping.py` to use the class-based `Channel3Service`.
      Remove `from app.services import ai_service, channel3_service` for the channel3 import and replace with `from app.services.channel3_service import get_channel3_service`. In `submit_brief`, replace:
      ```python
      products_data = await channel3_service.search_products(request.brief, session.id)
      ```
      with:
      ```python
      svc = get_channel3_service()
      normalized = await svc.search_products(query=request.brief)
      await svc.close()
      ```
      Then loop over `normalized` (each item is a `NormalizedProduct`) and map to `ProductResult`:
      - `channel3_product_id` → `product.channel3_product_id`
      - `name` → `product.name`
      - `price` → `product.price` (may be `None`; the DB column must accept `None` — confirm in item 4a below)
      - `currency` → `product.currency` (default `"USD"` if `None`)
      - `merchant` → `product.merchant`
      - `source_url` → `product.source_url`
      - `specs` → `product.specs_json` (the `NormalizedProduct.specs` dict maps to the DB column `specs_json`)
      - `retrieved_at` → `product.retrieved_at`
      - `constraint_results_json` → `None` (Channel3Service no longer provides this; AI service will populate it separately in a future phase)
      - `ranking_score` → `None` (same reason)

      **4a — Compatibility check:** The existing `ProductResult` DB model column `price` must allow `NULL`. Read `app/models/product_result.py` first; if `price` is declared `nullable=False`, change it to `nullable=True` (or `Optional[float]`). Similarly confirm `currency` allows `NULL` or apply a default.

      Files: `app/routers/shopping.py`, `app/models/product_result.py` (conditionally)

      Verify: `cd backend && pytest tests/test_shopping.py -v` — all five existing shopping tests still pass.

- [ ] 5. Update `app/routers/products.py` to support an optional live Channel3 search.
      Add `query: Optional[str] = None` as a query parameter to `get_products_for_session`. When `query` is `None`, keep the existing behaviour (return persisted `ProductResult` rows as `List[ProductResultResponse]`). When `query` is provided, inject `Channel3Service` via `svc: Channel3Service = Depends(get_channel3_service)`, call `await svc.search_products(query=query)`, close the client, and return the result as `List[NormalizedProduct]`. Because the two branches return different model shapes, change the endpoint's `response_model` to `None` and return a `JSONResponse` or simply rely on FastAPI's implicit serialisation — the simpler approach is to keep `response_model=None` and return `products` (Pydantic models serialise automatically). Add the necessary imports: `Optional` from `typing`, `Query` from `fastapi`, `NormalizedProduct` from `app.schemas.product`, `Channel3Service` and `get_channel3_service` from `app.services.channel3_service`.

      Files: `app/routers/products.py`

      Verify: `cd backend && pytest tests/ -v` — all existing tests pass. Manual curl after starting the server is optional; the unit-test suite is sufficient for this step.

- [ ] 6. Write `tests/test_channel3.py` with all required test cases.
      The test file must include:

      - **`test_mock_mode_returns_normalized_products`**: Instantiate `Channel3Service(api_key="")`. Call `await svc.search_products("laptop")`. Assert the result is a list of `NormalizedProduct` instances, length == 3.
      - **`test_mock_has_unknown_specs`**: Same setup. Assert at least one product has a `None` value inside its `specs` dict (e.g. `any(None in p.specs.values() for p in products)`).
      - **`test_mock_has_constraint_failures`**: Same setup. Assert at least one product has `price > 1200`.
      - **`test_mock_data_complete_flag`**: Assert that the mock product with all fields present has `data_complete=True`, and the incomplete mock has `data_complete=False`.
      - **`test_search_request_shape`**: Use `pytest-httpx`'s `httpx_mock` fixture. Instantiate `Channel3Service(api_key="test-key-123")`. Register a mock response for `POST https://api.trychannel3.com/v1/search` returning `{"products": [...one product dict...]}`. Call `await svc.search_products("gaming laptop", filters={"category": "laptops"}, limit=5)`. Assert the captured request has header `x-api-key: test-key-123` and JSON body `{"query": "gaming laptop", "limit": 5, "category": "laptops"}`.
      - **`test_rate_limit_raises_correctly`**: Use `httpx_mock` to return status 429. Call `svc.search_products(...)`. Assert `Channel3RateLimitError` is raised.
      - **`test_auth_error_raises_correctly`**: Use `httpx_mock` to return status 401. Assert `Channel3AuthError` is raised.
      - **`test_live_integration`**: Decorated with `@pytest.mark.integration`. At the top of the test body: `api_key = os.environ.get("CHANNEL3_API_KEY"); pytest.skip("No CHANNEL3_API_KEY set") if not api_key`. Instantiate `Channel3Service(api_key=api_key)`. Call `await svc.search_products("laptop")`. Assert the result is a non-empty list, each element is a `NormalizedProduct`, and at least one has `data_complete=True`.

      Import notes: `import os`, `import pytest`, `from app.services.channel3_service import Channel3Service, get_channel3_service`, `from app.schemas.product import NormalizedProduct`, `from app.core.exceptions import Channel3AuthError, Channel3RateLimitError, Channel3ServiceError`.

      Files: `tests/test_channel3.py`

      Verify: `cd backend && pytest tests/test_channel3.py -v -m "not integration"` — all 7 non-integration tests pass. Then run `cd backend && pytest tests/ -v -m "not integration"` — full suite (health, schemas, shopping, channel3) all pass.

---

## Dependency Order

```
Item 1 (NormalizedProduct schema)
  └─> Item 2 (exceptions) — independent of item 1, can be done in any order
  └─> Item 3 (Channel3Service) — depends on items 1 and 2
        └─> Item 4 (shopping.py) — depends on item 3
        └─> Item 5 (products.py) — depends on items 1 and 3
              └─> Item 6 (tests) — depends on items 1, 2, 3, 4, 5
```

Items 1 and 2 are independent of each other and can be implemented in either order. All other items follow the dependency chain above.

---

## Key Decisions & Rationale

- **`NormalizedProduct.data_complete` via `model_validator`**: Computed at validation time rather than as a property so it is serialised correctly and visible in API responses without extra work.
- **`specs` not `specs_json` on NormalizedProduct**: The DB model uses `specs_json` as the column name; `NormalizedProduct` is the API/service layer model and uses the cleaner `specs` name. The mapping happens in `shopping.py` at the call site, keeping each layer's naming consistent with its domain.
- **`get_channel3_service()` as a plain function, not a FastAPI `Depends` generator**: The service holds an `httpx.AsyncClient`; the caller is responsible for calling `svc.close()` after use. A simple factory keeps things explicit and avoids lifecycle complexity. If per-request lifespan management becomes important later, it can be converted to an async generator dependency.
- **`response_model=None` on the `?query=` products route**: The two branches return `List[ProductResultResponse]` and `List[NormalizedProduct]` respectively. Using `response_model=None` lets FastAPI serialise Pydantic models automatically without a Union that would confuse OpenAPI docs.
- **`constraint_results_json` and `ranking_score` set to `None` in shopping.py**: The Channel3 API does not return constraint evaluation or ranking; these will be computed by the AI service in a future phase. Setting them to `None` now is correct and backward-compatible with the DB schema.
- **Mock products use `price=1499.00` for the overpriced item**: 1499 > 1200 satisfies the `test_mock_has_constraint_failures` requirement while being a realistic laptop price.
