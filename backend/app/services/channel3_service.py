import logging
from datetime import datetime, timezone
from typing import List, Optional
from urllib.parse import urlparse

import httpx
from cachetools import TTLCache

from app.schemas.product import NormalizedProduct, ProductImage, ProductOffer, ProductRatings
from app.core.exceptions import Channel3AuthError, Channel3RateLimitError, Channel3ServiceError
from app.config import settings

logger = logging.getLogger("proofbuy.channel3")

# Module-level TTL cache — 5 minute TTL, 256 entries
_product_cache: TTLCache = TTLCache(maxsize=256, ttl=300)

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
        all_images=[
            ProductImage(
                url="https://images.unsplash.com/photo-1593642632559-0c6d3fc62b89?w=800&q=80",
                cleaned_url="https://images.unsplash.com/photo-1593642632559-0c6d3fc62b89?w=800&q=80",
                is_main_image=True,
                shot_type="hero",
            ),
            ProductImage(
                url="https://images.unsplash.com/photo-1593642632559-0c6d3fc62b89?w=800&q=80&crop=entropy",
                cleaned_url="https://images.unsplash.com/photo-1593642632559-0c6d3fc62b89?w=800&q=80&crop=entropy",
                shot_type="lifestyle",
            ),
            ProductImage(
                url="https://images.unsplash.com/photo-1593642634524-b40b5baae6bb?w=800&q=80",
                cleaned_url="https://images.unsplash.com/photo-1593642634524-b40b5baae6bb?w=800&q=80",
                shot_type="detail",
            ),
            ProductImage(
                url="https://images.unsplash.com/photo-1593642634315-48f5414c3ad9?w=800&q=80",
                cleaned_url="https://images.unsplash.com/photo-1593642634315-48f5414c3ad9?w=800&q=80",
                shot_type="product_information",
            ),
        ],
        all_offers=[
            ProductOffer(
                url="https://www.dell.com/en-us/shop/laptops/xps-15-laptop",
                domain="dell.com",
                price=999.99,
                currency="USD",
                availability="InStock",
            ),
            ProductOffer(
                url="https://www.amazon.com/dp/B0C1234567",
                domain="amazon.com",
                price=1049.99,
                compare_at_price=1199.99,
                currency="USD",
                availability="InStock",
            ),
        ],
        ratings=ProductRatings(value=4.6, count=1247, source_count=3),
        materials=["Aluminium chassis", "Carbon fibre palm rest", "Gorilla Glass display"],
        key_features=["Thunderbolt 4", "Wi-Fi 6E", "Backlit keyboard"],
        description="The Dell XPS 15 combines a stunning OLED display with powerful Intel Core i7 performance, making it ideal for creative professionals and power users.",
        category_title="Laptops",
        structured_attributes={
            "ram": "16GB DDR5",
            "storage": "512GB SSD",
            "processor": "Intel Core i7-13700H",
        },
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
        all_images=[
            ProductImage(
                url="https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800&q=80",
                cleaned_url="https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800&q=80",
                is_main_image=True,
                shot_type="hero",
            ),
            ProductImage(
                url="https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800&q=80&crop=entropy",
                cleaned_url="https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800&q=80&crop=entropy",
                shot_type="lifestyle",
            ),
            ProductImage(
                url="https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800&q=80&crop=faces",
                cleaned_url="https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800&q=80&crop=faces",
                shot_type="detail",
            ),
            ProductImage(
                url="https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800&q=80&crop=top",
                cleaned_url="https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800&q=80&crop=top",
                shot_type="product_information",
            ),
        ],
        all_offers=[
            ProductOffer(
                url="https://www.apple.com/shop/buy-mac/macbook-pro/16-inch",
                domain="apple.com",
                price=1299.99,
                currency="USD",
                availability="InStock",
            ),
            ProductOffer(
                url="https://www.amazon.com/dp/B0CM5JV268",
                domain="amazon.com",
                price=1349.00,
                compare_at_price=1399.99,
                currency="USD",
                availability="InStock",
            ),
        ],
        ratings=ProductRatings(value=4.8, count=3421, source_count=4),
        materials=["Aluminium unibody", "Ceramic Shield glass", "Recycled aluminium"],
        key_features=["MagSafe charging", "HDMI port", "SD card slot"],
        description="The MacBook Pro 16 with M3 Pro delivers exceptional performance and battery life in a premium aluminium chassis.",
        category_title="Laptops",
        structured_attributes={
            "ram": "18GB Unified Memory",
            "storage": "512GB SSD",
            "processor": "Apple M3 Pro",
        },
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
        all_images=[
            ProductImage(
                url="https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=800&q=80",
                cleaned_url="https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=800&q=80",
                is_main_image=True,
                shot_type="hero",
            ),
            ProductImage(
                url="https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=800&q=80&crop=entropy",
                cleaned_url="https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=800&q=80&crop=entropy",
                shot_type="lifestyle",
            ),
            ProductImage(
                url="https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=800&q=80&crop=faces",
                cleaned_url="https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=800&q=80&crop=faces",
                shot_type="detail",
            ),
            ProductImage(
                url="https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=800&q=80&crop=top",
                cleaned_url="https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=800&q=80&crop=top",
                shot_type="product_information",
            ),
        ],
        all_offers=[
            ProductOffer(
                url="https://www.lenovo.com/us/en/laptops/thinkpad/thinkpad-x1/",
                domain="lenovo.com",
                price=849.00,
                currency="USD",
                availability="InStock",
            ),
            ProductOffer(
                url="https://www.amazon.com/dp/B0BXYZ1234",
                domain="amazon.com",
                price=879.99,
                compare_at_price=999.00,
                currency="USD",
                availability="InStock",
            ),
        ],
        ratings=ProductRatings(value=4.5, count=2108, source_count=3),
        materials=["Carbon fibre body", "Magnesium alloy", "Gorilla Glass"],
        key_features=["MIL-SPEC durability", "Fingerprint reader", "IR camera"],
        description="The ThinkPad X1 Carbon is the ultimate business ultrabook — incredibly light, durable, and packed with security features.",
        category_title="Laptops",
        structured_attributes={
            "ram": "16GB LPDDR5",
            "storage": "512GB SSD",
            "processor": "Intel Core i5-1335U",
        },
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

        # Parse ALL images into List[ProductImage]
        all_images: List[ProductImage] = []
        for img in images:
            if isinstance(img, dict):
                url = img.get("cleaned_url") or img.get("url") or img.get("src")
                if url:
                    all_images.append(ProductImage(
                        url=url,
                        cleaned_url=img.get("cleaned_url"),
                        is_main_image=bool(img.get("is_main_image", False)),
                        shot_type=img.get("shot_type"),
                        alt_text=img.get("alt_text"),
                    ))
            elif isinstance(img, str) and img:
                all_images.append(ProductImage(url=img))

        # Derive image_url from parsed images
        image_url = (
            next((i.url for i in all_images if i.is_main_image), None)
            or next((i.url for i in all_images if i.shot_type == "hero"), None)
            or (all_images[0].url if all_images else None)
        )

        # Parse ALL offers into List[ProductOffer]
        all_offers: List[ProductOffer] = []
        for o in offers:
            o_url = o.get("url", "")
            domain = (
                o.get("domain")
                or urlparse(o_url).netloc
                or "unknown"
            )
            o_price = float(o["price"]["price"]) if o.get("price") else 0.0
            compare_at = o["price"].get("compare_at_price") if o.get("price") else None
            o_currency = o["price"].get("currency", "USD") if o.get("price") else "USD"
            all_offers.append(ProductOffer(
                url=o_url,
                domain=domain,
                price=o_price,
                compare_at_price=compare_at,
                currency=o_currency,
                availability=o.get("availability", ""),
                condition=o.get("condition"),
            ))

        # Parse ratings
        ratings: Optional[ProductRatings] = None
        r = raw.get("ratings")
        if r and isinstance(r, dict) and "value" in r:
            ratings = ProductRatings(
                value=float(r["value"]),
                count=int(r.get("count", 0)),
                source_count=int(r.get("source_count", 0)),
            )

        # Parse materials
        materials: Optional[List[str]] = None
        raw_materials = raw.get("materials")
        if isinstance(raw_materials, list) and raw_materials:
            if all(isinstance(m, str) for m in raw_materials):
                materials = raw_materials
            elif all(isinstance(m, dict) for m in raw_materials):
                materials = [m["name"] for m in raw_materials if "name" in m]

        # Parse key_features as clean list
        parsed_key_features: Optional[List[str]] = None
        if isinstance(key_features, list) and key_features:
            parsed_key_features = [str(f) for f in key_features]

        # Parse variants_options
        variants_options: Optional[List[dict]] = None
        variants_raw = raw.get("variants", {})
        if isinstance(variants_raw, dict):
            opts = variants_raw.get("options")
            if isinstance(opts, list):
                variants_options = opts

        # Parse category_title
        category_title: Optional[str] = None
        cat = raw.get("category")
        if isinstance(cat, dict):
            category_title = cat.get("title")
        elif isinstance(cat, str):
            category_title = cat

        # Parse gender
        gender: Optional[str] = raw.get("gender")

        # Parse description
        description = (
            raw.get("description")
            or raw.get("short_description")
            or raw.get("overview")
            or ""
        ) or None

        # Build full specs dict
        specs: dict = {}
        if isinstance(structured_attributes, dict):
            specs.update({k: v for k, v in structured_attributes.items() if v is not None})

        # key_features -> store as list in specs["features"]
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
            all_images=all_images,
            all_offers=all_offers,
            ratings=ratings,
            materials=materials,
            key_features=parsed_key_features,
            variants_options=variants_options,
            structured_attributes=structured_attributes if structured_attributes else None,
            category_title=category_title,
            gender=gender,
            description=description,
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

    async def get_product_detail(self, product_id: str) -> Optional[NormalizedProduct]:
        """Semantic alias for get_product(), used by the detail router."""
        return await self.get_product(product_id)

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
    Results are cached by query for 5 minutes to avoid redundant API calls.
    """
    cache_key = query.lower().strip()
    if cache_key in _product_cache:
        # Re-attach session_id since it's caller-specific
        return [
            {**item, "session_id": session_id}
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
            "all_images": [img.model_dump() for img in p.all_images],
            "all_offers": [o.model_dump() for o in p.all_offers],
            "ratings": p.ratings.model_dump() if p.ratings else None,
            "materials": p.materials,
            "key_features": p.key_features,
            "structured_attributes": p.structured_attributes,
            "category_title": p.category_title,
            "variants_options": p.variants_options,
            "description": p.description,
        }
        for p in products
    ]
    # Cache without session_id so other sessions benefit from the same data
    _product_cache[cache_key] = [
        {k: v for k, v in item.items() if k != "session_id"}
        for item in result
    ]
    return result
