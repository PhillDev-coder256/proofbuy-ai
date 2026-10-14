from datetime import datetime, timedelta, timezone

import pytest

from app.services.paypal_service import PayPalService
from app.core.exceptions import PayPalOrderNotApprovedError

TOKEN_URL = "https://api-m.sandbox.paypal.com/v1/oauth2/token"
ORDERS_URL = "https://api-m.sandbox.paypal.com/v2/checkout/orders"
ORDER_URL = "https://api-m.sandbox.paypal.com/v2/checkout/orders/ORDER123"
CAPTURE_URL = "https://api-m.sandbox.paypal.com/v2/checkout/orders/ORDER123/capture"

TOKEN_RESPONSE = {"access_token": "tok123", "expires_in": 32400}


@pytest.mark.asyncio
async def test_token_fetch_succeeds(httpx_mock):
    httpx_mock.add_response(method="POST", url=TOKEN_URL, json=TOKEN_RESPONSE)
    svc = PayPalService("client_id", "secret", "sandbox")
    token = await svc._get_access_token()
    assert token == "tok123"
    assert svc._access_token == "tok123"
    assert svc._token_expires_at is not None


@pytest.mark.asyncio
async def test_token_refresh_when_expired(httpx_mock):
    httpx_mock.add_response(
        method="POST", url=TOKEN_URL, json={"access_token": "new_tok", "expires_in": 32400}
    )
    svc = PayPalService("client_id", "secret", "sandbox")
    svc._access_token = "old"
    svc._token_expires_at = datetime.now(timezone.utc) - timedelta(seconds=1)
    token = await svc._get_access_token()
    assert token == "new_tok"


@pytest.mark.asyncio
async def test_create_order_returns_approval_url(httpx_mock):
    httpx_mock.add_response(method="POST", url=TOKEN_URL, json=TOKEN_RESPONSE)
    httpx_mock.add_response(
        method="POST",
        url=ORDERS_URL,
        json={
            "id": "ORDER123",
            "status": "CREATED",
            "links": [
                {"rel": "self", "href": "https://api-m.sandbox.paypal.com/v2/checkout/orders/ORDER123", "method": "GET"},
                {"rel": "approve", "href": "https://www.sandbox.paypal.com/checkoutnow?token=ORDER123", "method": "GET"},
            ],
        },
    )
    svc = PayPalService("client_id", "secret", "sandbox")
    result = await svc.create_order("purchase-1", 99.99, "USD")
    assert result.order_id == "ORDER123"
    assert result.approval_url == "https://www.sandbox.paypal.com/checkoutnow?token=ORDER123"


@pytest.mark.asyncio
async def test_capture_checks_approved_first(httpx_mock):
    httpx_mock.add_response(method="POST", url=TOKEN_URL, json=TOKEN_RESPONSE)
    httpx_mock.add_response(
        method="GET",
        url=ORDER_URL,
        json={"id": "ORDER123", "status": "CREATED"},
    )
    svc = PayPalService("client_id", "secret", "sandbox")
    with pytest.raises(PayPalOrderNotApprovedError):
        await svc.capture_order("ORDER123")


@pytest.mark.asyncio
async def test_capture_succeeds_on_approved(httpx_mock):
    httpx_mock.add_response(method="POST", url=TOKEN_URL, json=TOKEN_RESPONSE)
    httpx_mock.add_response(
        method="GET",
        url=ORDER_URL,
        json={"id": "ORDER123", "status": "APPROVED"},
    )
    httpx_mock.add_response(
        method="POST",
        url=CAPTURE_URL,
        json={
            "id": "ORDER123",
            "status": "COMPLETED",
            "purchase_units": [
                {
                    "payments": {
                        "captures": [
                            {
                                "id": "CAP456",
                                "status": "COMPLETED",
                                "amount": {"value": "99.99", "currency_code": "USD"},
                            }
                        ]
                    }
                }
            ],
        },
    )
    svc = PayPalService("client_id", "secret", "sandbox")
    result = await svc.capture_order("ORDER123")
    assert result.capture_id == "CAP456"
    assert result.verified is True


@pytest.mark.asyncio
async def test_duplicate_capture_handled(httpx_mock):
    httpx_mock.add_response(method="POST", url=TOKEN_URL, json=TOKEN_RESPONSE)
    # First GET for capture_order's status check
    httpx_mock.add_response(
        method="GET",
        url=ORDER_URL,
        json={"id": "ORDER123", "status": "APPROVED"},
    )
    # POST capture returns 422 ORDER_ALREADY_CAPTURED
    httpx_mock.add_response(
        method="POST",
        url=CAPTURE_URL,
        status_code=422,
        json={
            "name": "UNPROCESSABLE_ENTITY",
            "details": [{"issue": "ORDER_ALREADY_CAPTURED"}],
        },
    )
    # Second GET for verify_order call
    httpx_mock.add_response(
        method="GET",
        url=ORDER_URL,
        json={
            "id": "ORDER123",
            "status": "COMPLETED",
            "purchase_units": [
                {"payments": {"captures": [{"status": "COMPLETED"}]}}
            ],
        },
    )
    svc = PayPalService("client_id", "secret", "sandbox")
    result = await svc.capture_order("ORDER123")
    assert result.verified is True


@pytest.mark.asyncio
async def test_invalid_amount_raises(httpx_mock):
    svc = PayPalService("client_id", "secret", "sandbox")
    with pytest.raises(ValueError):
        await svc.create_order("purchase-1", 0, "USD")


@pytest.mark.asyncio
async def test_mock_mode_no_http_calls(httpx_mock):
    svc = PayPalService("", "", "sandbox")
    result = await svc.create_order("purchase-1", 99.99, "USD")
    assert result.order_id.startswith("MOCK-ORDER-")
    assert httpx_mock.get_requests() == []
