# Channel3 Service Integration — Pass 2

The Channel3 integration replaces a previous stub with a production-capable `Channel3Service` backed by `httpx`, a `NormalizedProduct` Pydantic schema, and a module-level backward-compat wrapper so `products.py` requires no import changes. Mock mode activates when no API key is configured, returning three pre-built products spanning the range of real-world data quality. This is a second-pass review; the prior pass's HIGH finding (None-masking in the backward-compat wrapper) has been resolved — `p.price` and `p.currency` are now passed through as-is. Three concerns remain, one of which is a NEW finding introduced by the fix.

Watch for: (1) **confirmed** — the `products.py` router applies `.get("currency", "USD")` when persisting to the `ProductResult` DB row, partially re-introducing the None-masking that the wrapper fix was meant to eliminate; (2) **confirmed** — `_normalize()` passes `data_complete=False` to `NormalizedProduct` but the `model_validator` always overwrites it, making that argument dead code; (3) **confirmed** — the `ProductResult` DB model declares `price` as `Numeric(10,2), nullable=False`, which means a product with `price=None` from the wrapper will cause a DB write failure at runtime rather than a graceful error.

**Verdict**: NEEDS_CHANGES

---

## High-level view

The backward-compat wrapper now passes `None` price and currency through correctly, satisfying the UNKNOWN-must-be-explicit requirement at the service layer. However, `products.py` persists product rows with `currency=ranked_product.get("currency", "USD")` — a fallback default that silently converts `None` to `"USD"` at the DB layer. This is a subtler version of the same problem: the constraint engine sees the correct `None`, but the persisted row carries a fabricated `"USD"`. Whether this matters depends on whether currency is ever read back from the DB for constraint evaluation (it currently isn't), but the inconsistency between in-memory representation and persisted state is a latent bug.

More immediately: `ProductResult.price` is `Numeric(10,2), nullable=False` in the DB model. If Channel3 returns a product with no price, the wrapper passes `price=None` to the router, which calls `ranked_product["price"]` without a None guard. SQLAlchemy will attempt to insert `NULL` into a non-nullable column, raising an integrity error at runtime. No test covers this path.

The `data_complete=False` argument in `_normalize()` is dead — the `model_validator` unconditionally recomputes the value after construction, and a comment even acknowledges this. The argument still implies the service controls `data_complete` when the schema does; removing it would make that contract unambiguous.

---

<details>
<summary>Issues (3)</summary>

1. **Currency None-masking re-introduced at DB layer** — `products.py` line 77 applies `.get("currency", "USD")` when constructing the `ProductResult` row. Products with `currency=None` are stored with `"USD"` in the DB even though the in-memory dict correctly carries `None`. Audit whether any downstream read path uses `ProductResult.currency` for constraint evaluation; if so, align the persisted value with the in-memory representation or add an explicit `UNKNOWN_CURRENCY` sentinel. MEDIUM.

2. **Null price causes DB integrity error at runtime** — `ProductResult.price` is `Numeric(10,2), nullable=False`. If a product has `price=None`, `products.py` line 77 passes `None` to the `price` column without a guard, producing a runtime IntegrityError on DB commit rather than a handled error. Add a `None` check before constructing `ProductResult` (skip the product, use `data_complete=False` as a filter, or raise a structured error). MEDIUM.

3. **Dead `data_complete` argument in `_normalize()`** — `_normalize()` passes `data_complete=False` to `NormalizedProduct(...)`, but the `model_validator` always overwrites it. Remove the argument so callers aren't misled about who owns `data_complete`. LOW.

</details>

<details>
<summary>Details</summary>

### Currency None-masking re-introduced at DB layer

The backward-compat wrapper fix (now passing `p.currency` directly) was undone one layer up. In `products.py`:

```python
product_row = ProductResult(
    ...
    price=ranked_product["price"],
    currency=ranked_product.get("currency", "USD"),  # re-introduces the default
    ...
)
```

The in-memory path (constraint engine, ranking) correctly receives `None` for unknown currency. The persisted `ProductResult` row receives `"USD"`. Whether this divergence causes behavioral bugs today depends on whether `ProductResult.currency` is ever read back for constraint evaluation — currently it isn't, since constraints operate on the in-memory dict. But the inconsistency makes future reads unreliable and constitutes a stealth reintroduction of the prior HIGH finding at the persistence layer.

### Null price causes DB integrity error

The `ProductResult` DB model declares:

```python
price: Mapped[float] = mapped_column(Numeric(10, 2), nullable=False)
```

The router constructs the row with `price=ranked_product["price"]`. If the Channel3 API returns a product with no price, `_normalize()` sets `price=None`, the wrapper passes it through, the constraint engine receives it, and then `products.py` attempts to insert `NULL` into a `NOT NULL` column. This raises a DB integrity error on `await db.commit()` — after the per-product loop has already partially executed — which means some rows may be committed before the error. The fix is to filter out `data_complete=False` products (or products with `price=None`) before the persistence loop, consistent with how `data_complete` was designed to be used.


</details>

---

<details>
<summary>File map</summary>

| File | Change |
|---|---|
| `app/schemas/product.py` | Added `NormalizedProduct` with `model_validator`; `ProductResultResponse` and `RankedProduct` untouched |
| `app/core/exceptions.py` | Added `Channel3AuthError`, `Channel3RateLimitError`, `Channel3ServiceError` as `ProofBuyException` subclasses |
| `app/services/channel3_service.py` | Full replacement: `Channel3Service` class, `MOCK_PRODUCTS`, `get_channel3_service()`, backward-compat `search_products()` wrapper (None-transparent, prior HIGH finding resolved) |
| `app/routers/products.py` | Switched import to `from app.services import channel3_service`; calls module-level `channel3_service.search_products()` |
| `tests/test_channel3.py` | 8 tests: mock mode, HTTP error codes (401, 429, 500), request shape, live integration |

Prior review: `channel3-review.md` (same path, overwritten by this pass)

</details>
