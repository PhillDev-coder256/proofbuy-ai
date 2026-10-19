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
        name="Dell XPS 15 9530",
        price=999.99,
        currency="USD",
        merchant="Dell Official Store",
        source_url="https://www.dell.com/en-us/shop/laptops/xps-15-laptop",
        image_url="https://images.unsplash.com/photo-1593642632559-0c6d3fc62b89?w=400&q=80",
        specs={
            "ram": "16GB DDR5",
            "storage": "512GB SSD",
            "processor": "Intel Core i7-13700H",
            "display": '15.6" OLED 3.5K',
            "battery": "86Wh",
            "weight_kg": 1.86,
            "features": ["Thunderbolt 4", "Wi-Fi 6E", "Backlit keyboard"],
            "description": "The Dell XPS 15 combines a stunning OLED display with powerful Intel Core i7 performance, making it ideal for creative professionals and power users.",
        },
        retrieved_at=datetime(2026, 10, 1, tzinfo=timezone.utc),
        data_complete=True,
    ),
    NormalizedProduct(
        channel3_product_id="C3-MOCK-002",
        name="MacBook Pro 16 M3 Pro",
        price=1299.99,
        currency="USD",
        merchant="Apple Store",
        source_url="https://www.apple.com/shop/buy-mac/macbook-pro/16-inch",
        image_url="https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400&q=80",
        specs={
            "ram": "18GB Unified Memory",
            "storage": "512GB SSD",
            "processor": "Apple M3 Pro",
            "display": '16.2" Liquid Retina XDR',
            "battery": "100Wh",
            "weight_kg": 2.14,
            "features": ["MagSafe charging", "HDMI port", "SD card slot"],
            "description": "The MacBook Pro 16 with M3 Pro delivers exceptional performance and battery life in a premium aluminium chassis.",
        },
        retrieved_at=datetime(2026, 10, 1, tzinfo=timezone.utc),
        data_complete=True,
    ),
    NormalizedProduct(
        channel3_product_id="C3-MOCK-003",
        name="Lenovo ThinkPad X1 Carbon Gen 11",
        price=849.00,
        currency="USD",
        merchant="Lenovo",
        source_url="https://www.lenovo.com/us/en/laptops/thinkpad/thinkpad-x1/",
        image_url="https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=400&q=80",
        specs={
            "ram": "16GB LPDDR5",
            "storage": "512GB SSD",
            "processor": "Intel Core i5-1335U",
            "display": '14" IPS 1920x1200',
            "battery_life": None,
            "weight_kg": 1.12,
            "features": ["MIL-SPEC durability", "Fingerprint reader", "IR camera"],
            "description": "The ThinkPad X1 Carbon is the ultimate business ultrabook — incredibly light, durable, and packed with security features.",
        },
        retrieved_at=datetime(2026, 10, 1, tzinfo=timezone.utc),
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

        # Best offer: prefer in-stock, then first available
        best_offer = None
        for o in offers:
            avail = (o.get("availability") or "").lower().replace(" ", "_")
            if avail in ("in_stock", "instock", "available", "yes"):
                best_offer = o
                break
        if best_offer is None and offers:
            best_offer = offers[0]

        price = best_offer["price"]["price"] if best_offer else None
        currency = best_offer["price"]["currency"] if best_offer else None
        source_url = best_offer["url"] if best_offer else None

        # Collect all image URLs — handle both string and object formats
        all_image_urls = []
        for img in images:
            if isinstance(img, dict):
                url = img.get("url") or img.get("src") or img.get("link")
                if url:
                    all_image_urls.append(url)
            elif isinstance(img, str) and img:
                all_image_urls.append(img)
        image_url = all_image_urls[0] if all_image_urls else None

        # Build full specs dict
        specs: dict = {}
        if isinstance(structured_attributes, dict):
            specs.update({k: v for k, v in structured_attributes.items() if v is not None})

        # key_features: list of strings -> store as list
        if isinstance(key_features, list) and key_features:
            specs["features"] = key_features
        elif isinstance(key_features, dict):
            specs.update(key_features)

        # Harvest any extra top-level product fields
        for field in ("color", "material", "size", "weight", "dimensions",
                      "connectivity", "compatibility", "model", "sku",
                      "series", "category"):
            val = raw.get(field)
            if val and field not in specs:
                specs[field] = val

        # Description
        description = (raw.get("description") or
                       raw.get("short_description") or
                       raw.get("overview") or "")
        if description:
            specs["description"] = description

        name = raw.get("title", raw.get("name", ""))

        # brands[] can be strings or objects with a "name" key
        brands = raw.get("brands", [])
        if brands:
            first_brand = brands[0]
            merchant = (first_brand.get("name")
                        if isinstance(first_brand, dict)
                        else first_brand)
        else:
            merchant = None

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
    """Backward-compatible wrapper returning the dict shape the products router expects.
    Includes ALL available product data: image, description, full specs, source URL.
    """
    svc = get_channel3_service()
    products = await svc.search_products(query)
    return [
        {
            "channel3_product_id": p.channel3_product_id,
            "name": p.name,
            "price": p.price,
            "currency": p.currency,
            "merchant": p.merchant,
            "specs_json": p.specs,
            "source_url": p.source_url,
            "image_url": p.image_url,          # ← was missing
            "data_complete": p.data_complete,   # ← was missing
            "constraint_results_json": None,
            "ranking_score": None,
            "retrieved_at": p.retrieved_at.isoformat(),
            "session_id": session_id,
        }
        for p in products
    ]
