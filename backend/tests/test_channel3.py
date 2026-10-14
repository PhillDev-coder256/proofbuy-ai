import pytest
import pytest_asyncio
from unittest.mock import patch
from datetime import datetime, timezone


# ---- mock mode tests (no HTTP needed) ----

@pytest.mark.asyncio
async def test_mock_mode_returns_normalized_products():
    from app.services.channel3_service import Channel3Service
    from app.schemas.product import NormalizedProduct
    svc = Channel3Service(api_key='')  # empty key -> mock mode
    products = await svc.search_products('laptop under 1000')
    assert len(products) > 0
    for p in products:
        assert isinstance(p, NormalizedProduct)
        assert p.channel3_product_id
        assert p.name
        assert isinstance(p.retrieved_at, datetime)


@pytest.mark.asyncio
async def test_mock_has_unknown_specs():
    from app.services.channel3_service import Channel3Service
    svc = Channel3Service(api_key='')
    products = await svc.search_products('laptop')
    has_none_spec = any(
        any(v is None for v in p.specs.values())
        for p in products
        if p.specs
    )
    assert has_none_spec, 'Expected at least one mock product with None spec field'


@pytest.mark.asyncio
async def test_mock_has_constraint_failures():
    from app.services.channel3_service import Channel3Service
    svc = Channel3Service(api_key='')
    products = await svc.search_products('laptop')
    expensive = [p for p in products if p.price is not None and p.price > 1200]
    assert len(expensive) >= 1, 'Expected at least one mock product with price > 1200'


# ---- HTTP-mocked tests ----

@pytest.mark.asyncio
async def test_search_request_shape(httpx_mock):
    from app.services.channel3_service import Channel3Service
    httpx_mock.add_response(
        method='POST',
        url='https://api.trychannel3.com/v1/search',
        json={'products': []},
        status_code=200,
    )
    svc = Channel3Service(api_key='test-key-abc')
    await svc.search_products('laptop under 1000', limit=5)
    request = httpx_mock.get_request()
    assert request.headers.get('x-api-key') == 'test-key-abc'
    import json
    body = json.loads(request.content)
    assert body['query'] == 'laptop under 1000'
    assert body['limit'] == 5


@pytest.mark.asyncio
async def test_rate_limit_raises_correctly(httpx_mock):
    from app.services.channel3_service import Channel3Service
    from app.core.exceptions import Channel3RateLimitError
    httpx_mock.add_response(
        method='POST',
        url='https://api.trychannel3.com/v1/search',
        status_code=429,
    )
    svc = Channel3Service(api_key='test-key-abc')
    with pytest.raises(Channel3RateLimitError):
        await svc.search_products('laptop')


@pytest.mark.asyncio
async def test_auth_error_raises_correctly(httpx_mock):
    from app.services.channel3_service import Channel3Service
    from app.core.exceptions import Channel3AuthError
    httpx_mock.add_response(
        method='POST',
        url='https://api.trychannel3.com/v1/search',
        status_code=401,
    )
    svc = Channel3Service(api_key='bad-key')
    with pytest.raises(Channel3AuthError):
        await svc.search_products('laptop')


@pytest.mark.integration
@pytest.mark.asyncio
async def test_live_integration():
    import os
    api_key = os.environ.get('CHANNEL3_API_KEY', '')
    if not api_key:
        pytest.skip('CHANNEL3_API_KEY not set — skipping live integration test')
    from app.services.channel3_service import Channel3Service
    from app.schemas.product import NormalizedProduct
    svc = Channel3Service(api_key=api_key)
    products = await svc.search_products('laptop', limit=3)
    assert isinstance(products, list)
    for p in products:
        assert isinstance(p, NormalizedProduct)
        assert p.channel3_product_id
        assert p.name
