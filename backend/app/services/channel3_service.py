import logging
from datetime import datetime, timezone
from typing import List, Optional

import httpx

from app.schemas.product import NormalizedProduct
from app.core.exceptions import Channel3AuthError, Channel3RateLimitError, Channel3ServiceError
from app.config import settings

logger = logging.getLogger("proofbuy.channel3")

# Module-level mock products used when no API key is configured
MOCK_PRODUCTS: List[NormalizedProduct] = [
    NormalizedProduct(
        channel3_product_id="C3-MOCK-001",
        name="Dell XPS 15",
        price=999.99,
        currency="USD",
        merchant="Dell Official Store",
        source_url="https://www.dell.com/en-us/shop/laptops/xps-15-laptop",
        image_url="https://i.dell.com/xps-15.jpg",
        specs={
            "ram": "16GB DDR5",
            "storage": "512GB SSD",
            "processor": "Intel Core i7-13700H",
            "display": '15.6" OLED 3.5K',
            "battery": "86Wh",
            "weight_kg": 1.86,
        },
        retrieved_at=datetime(2024, 1, 1, tzinfo=timezone.utc),
        data_complete=True,
    ),
    NormalizedProduct(
        channel3_product_id="C3-MOCK-002",
        name="MacBook Pro 16",
        price=1299.99,
        currency="USD",
        merchant="Apple",
        source_url="https://www.apple.com/shop/buy-mac/macbook-pro/16-inch",
        image_url="https://store.storeimages.cdn-apple.com/macbook-pro-16.jpg",
        specs={
            "ram": "18GB Unified Memory",
            "storage": "512GB SSD",
            "processor": "Apple M3 Pro",
            "display": '16.2" Liquid Retina XDR',
            "battery": "100Wh",
            "weight_kg": 2.14,
        },
        retrieved_at=datetime(2024, 1, 1, tzinfo=timezone.utc),
        data_complete=True,
    ),
    NormalizedProduct(
        channel3_product_id="C3-MOCK-003",
        name="Framework Laptop 13",
        price=849.00,
        currency="USD",
        merchant="Framework",
        source_url="https://frame.work/products/laptop-13-gen-intel",
        image_url="https://frame.work/laptop-13.jpg",
        specs={
            "ram": "16GB DDR5",
            "storage": "512GB SSD",
            "processor": "Intel Core i5-1340P",
            "display": '13.5" IPS',
            "battery_life": None,
            "weight_kg": None,
        },
        retrieved_at=datetime(2024, 1, 1, tzinfo=timezone.utc),
        data_complete=True,
    ),
]


class Channel3Service:
    def __init__(self, api_key: str, base_url: str = "https://api.trychannel3.com") -> None:
        self.api_key = api_key
        self.base_url = base_url

    def _is_mock(self) -> bool:
        return not self.api_key

    def _normalize(self, raw: dict) -> NormalizedProduct:
        offers = raw.get("offers", [])
        images = raw.get("images", [])
        key_features = raw.get("key_features", [])
        structured_attributes = raw.get("structured_attributes", {}) or {}

        price = offers[0]["price"]["price"] if offers else None
        currency = offers[0]["price"]["currency"] if offers else None
        source_url = offers[0]["url"] if offers else None
        image_url = images[0] if images else None

        # Build specs: merge key_features list (as {k: k}) with structured_attributes dict
        if isinstance(key_features, list):
            specs: dict = {k: k for k in key_features}
        elif isinstance(key_features, dict):
            specs = dict(key_features)
        else:
            specs = {}
        specs.update(structured_attributes)

        name = raw.get("title", raw.get("name", ""))
        brands = raw.get("brands", [None])
        merchant = brands[0] if brands else None

        data_complete = (
            price is not None
            and currency is not None
            and bool(name)
        )

        return NormalizedProduct(
            channel3_product_id=raw["id"],
            name=name,
            price=price,
            currency=currency,
            merchant=merchant,
            source_url=source_url,
            image_url=image_url,
            specs=specs if specs is not None else {},
            retrieved_at=datetime.now(timezone.utc),
            data_complete=data_complete,
        )

    async def search_products(
        self,
        query: str,
        filters: Optional[dict] = None,
        limit: int = 10,
    ) -> List[NormalizedProduct]:
        if self._is_mock():
            logger.warning(
                "Channel3 running in MOCK MODE — set CHANNEL3_API_KEY for real data"
            )
            return MOCK_PRODUCTS[:limit]

        try:
            async with httpx.AsyncClient(timeout=30.0) as client:
                response = await client.post(
                    self.base_url + "/v1/search",
                    headers={
                        "x-api-key": self.api_key,
                        "Content-Type": "application/json",
                    },
                    json={"query": query, "limit": limit, **(filters or {})},
                )
        except httpx.TimeoutException:
            raise Channel3ServiceError("Channel3 API timeout")

        if response.status_code == 401:
            raise Channel3AuthError()
        if response.status_code == 429:
            raise Channel3RateLimitError()
        if response.status_code >= 500:
            raise Channel3ServiceError(f"Channel3 API error: {response.status_code}")

        response.raise_for_status()

        data = response.json()
        products = data.get("products", data.get("results", []))
        return [self._normalize(p) for p in products]

    async def get_product(self, product_id: str) -> Optional[NormalizedProduct]:
        if self._is_mock():
            return next(
                (p for p in MOCK_PRODUCTS if p.channel3_product_id == product_id),
                None,
            )

        try:
            async with httpx.AsyncClient(timeout=30.0) as client:
                response = await client.get(
                    self.base_url + f"/v1/products/{product_id}",
                    headers={"x-api-key": self.api_key},
                )
        except httpx.TimeoutException:
            raise Channel3ServiceError("Channel3 API timeout")

        if response.status_code == 404:
            return None
        if response.status_code == 401:
            raise Channel3AuthError()
        if response.status_code == 429:
            raise Channel3RateLimitError()
        if response.status_code >= 500:
            raise Channel3ServiceError(f"Channel3 API error: {response.status_code}")

        response.raise_for_status()
        return self._normalize(response.json())

    async def close(self) -> None:
        # AsyncClient is opened per-request; nothing to close here
        pass


def get_channel3_service() -> Channel3Service:
    return Channel3Service(api_key=settings.channel3_api_key)


# ---------------------------------------------------------------------------
# Backward-compatible module-level function for shopping.py call site
# ---------------------------------------------------------------------------

async def search_products(query: str, session_id: str) -> list:
    """Backward-compatible wrapper returning the dict shape shopping.py expects."""
    svc = get_channel3_service()
    products = await svc.search_products(query)
    return [
        {
            "channel3_product_id": p.channel3_product_id,
            "name": p.name,
            "price": p.price if p.price is not None else 0.0,
            "currency": p.currency or "USD",
            "merchant": p.merchant,
            "specs_json": p.specs,
            "source_url": p.source_url,
            "constraint_results_json": None,
            "ranking_score": None,
            "retrieved_at": p.retrieved_at.isoformat(),
            "session_id": session_id,
        }
        for p in products
    ]
