import base64
import logging
from datetime import datetime, timedelta, timezone
from typing import Optional

import httpx
from pydantic import BaseModel

from app.core.exceptions import (
    PayPalAuthError,
    PayPalOrderNotApprovedError,
    PayPalInstrumentDeclinedError,
    PayPalDuplicateCaptureError,
    PayPalServiceError,
)

logger = logging.getLogger("proofbuy")


class PayPalOrderResult(BaseModel):
    order_id: str
    approval_url: str
    status: str


class PayPalCaptureResult(BaseModel):
    capture_id: str
    order_id: str
    status: str
    verified: bool
    amount: Optional[float] = None
    currency: Optional[str] = None


class PayPalOrderStatus(BaseModel):
    order_id: str
    status: str
    is_completed: bool


class PayPalService:
    def __init__(self, client_id: str, client_secret: str, environment: str = "sandbox"):
        self._client_id = client_id
        self._client_secret = client_secret
        self._base_url = (
            "https://api-m.sandbox.paypal.com"
            if environment == "sandbox"
            else "https://api-m.paypal.com"
        )
        self._access_token: Optional[str] = None
        self._token_expires_at: Optional[datetime] = None
        self._mock_mode = not client_id
        if self._mock_mode:
            logger.warning(
                "PayPal running in MOCK MODE — set PAYPAL_CLIENT_ID and "
                "PAYPAL_CLIENT_SECRET for real transactions"
            )

    async def _get_access_token(self) -> str:
        now = datetime.now(timezone.utc)
        if self._access_token and self._token_expires_at and now < self._token_expires_at:
            return self._access_token
        credentials = base64.b64encode(
            f"{self._client_id}:{self._client_secret}".encode()
        ).decode()
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{self._base_url}/v1/oauth2/token",
                headers={
                    "Authorization": f"Basic {credentials}",
                    "Content-Type": "application/x-www-form-urlencoded",
                },
                data={"grant_type": "client_credentials"},
            )
        if response.status_code != 200:
            raise PayPalAuthError(f"PayPal OAuth2 failed: {response.status_code}")
        data = response.json()
        self._access_token = data["access_token"]
        expires_in = data.get("expires_in", 32400)  # default 9h
        self._token_expires_at = now + timedelta(seconds=expires_in - 60)
        return self._access_token

    async def create_order(
        self, purchase_id: str, amount: float, currency: str
    ) -> PayPalOrderResult:
        if not purchase_id:
            raise ValueError("purchase_id must not be empty")
        if amount <= 0:
            raise ValueError("amount must be greater than 0")
        if len(currency) != 3:
            raise ValueError("currency must be a 3-letter ISO code")
        if self._mock_mode:
            return PayPalOrderResult(
                order_id=f"MOCK-ORDER-{purchase_id[:8]}",
                approval_url=(
                    f"https://www.sandbox.paypal.com/checkoutnow?token=MOCK-{purchase_id[:8]}"
                ),
                status="CREATED",
            )
        token = await self._get_access_token()
        body = {
            "intent": "CAPTURE",
            "purchase_units": [
                {
                    "reference_id": purchase_id,
                    "amount": {
                        "currency_code": currency,
                        "value": str(round(amount, 2)),
                    },
                }
            ],
            "payment_source": {
                "paypal": {
                    "experience_context": {
                        "return_url": "proofbuy://checkout/return",
                        "cancel_url": "proofbuy://checkout/cancel",
                        "brand_name": "ProofBuy AI",
                    }
                }
            },
        }
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{self._base_url}/v2/checkout/orders",
                headers={
                    "Authorization": f"Bearer {token}",
                    "Content-Type": "application/json",
                },
                json=body,
            )
        if response.status_code not in (200, 201):
            raise PayPalServiceError(f"PayPal create order failed: {response.status_code}")
        data = response.json()
        approval_url = next(
            # PayPal returns rel="payer-action" for the payment_source.paypal flow
            # and rel="approve" for the redirect flow — accept both
            (
                link["href"]
                for link in data.get("links", [])
                if link.get("rel") in ("approve", "payer-action")
            ),
            "",
        )
        return PayPalOrderResult(
            order_id=data["id"],
            approval_url=approval_url,
            status=data["status"],
        )

    async def capture_order(self, order_id: str) -> PayPalCaptureResult:
        if self._mock_mode:
            return PayPalCaptureResult(
                capture_id=f"MOCK-CAPTURE-{order_id[-8:]}",
                order_id=order_id,
                status="COMPLETED",
                verified=True,
                amount=None,
                currency=None,
            )
        token = await self._get_access_token()
        async with httpx.AsyncClient() as client:
            get_resp = await client.get(
                f"{self._base_url}/v2/checkout/orders/{order_id}",
                headers={"Authorization": f"Bearer {token}"},
            )
            if get_resp.status_code != 200:
                raise PayPalServiceError(f"PayPal get order failed: {get_resp.status_code}")
            order_data = get_resp.json()
            if order_data.get("status") != "APPROVED":
                raise PayPalOrderNotApprovedError(
                    f"Order {order_id} is not APPROVED (status: {order_data.get('status')})"
                )
            cap_resp = await client.post(
                f"{self._base_url}/v2/checkout/orders/{order_id}/capture",
                headers={
                    "Authorization": f"Bearer {token}",
                    "Content-Type": "application/json",
                    "PayPal-Request-Id": order_id,
                },
                json={},
            )
        if cap_resp.status_code == 422:
            err_data = cap_resp.json()
            issues = err_data.get("details", [])
            for issue in issues:
                if issue.get("issue") == "INSTRUMENT_DECLINED":
                    raise PayPalInstrumentDeclinedError("Payment instrument declined")
                if issue.get("issue") in ("ORDER_ALREADY_CAPTURED", "ORDER_ALREADY_COMPLETED"):
                    existing = await self.verify_order(order_id)
                    return PayPalCaptureResult(
                        capture_id=order_id + "-existing",
                        order_id=order_id,
                        status=existing.status,
                        verified=existing.is_completed,
                        amount=None,
                        currency=None,
                    )
            raise PayPalServiceError(
                f"PayPal capture failed: {cap_resp.status_code} {cap_resp.text}"
            )
        if cap_resp.status_code not in (200, 201):
            raise PayPalServiceError(f"PayPal capture failed: {cap_resp.status_code}")
        cap_data = cap_resp.json()
        captures = (
            cap_data.get("purchase_units", [{}])[0]
            .get("payments", {})
            .get("captures", [{}])
        )
        capture = captures[0] if captures else {}
        cap_amount_obj = capture.get("amount", {})
        order_status = cap_data.get("status", "")
        cap_status = capture.get("status", "")
        verified = order_status == "COMPLETED" and cap_status == "COMPLETED"
        return PayPalCaptureResult(
            capture_id=capture.get("id", ""),
            order_id=order_id,
            status=cap_status or order_status,
            verified=verified,
            amount=float(cap_amount_obj["value"]) if "value" in cap_amount_obj else None,
            currency=cap_amount_obj.get("currency_code"),
        )

    def get_approval_url(self, order_id: str) -> str:
        """Return the buyer-facing approval URL for a PayPal order ID.

        Uses the configured environment's hostname so sandbox and live orders
        both resolve to the correct domain.
        """
        if "sandbox" in self._base_url:
            return f"https://www.sandbox.paypal.com/checkoutnow?token={order_id}"
        return f"https://www.paypal.com/checkoutnow?token={order_id}"

    async def verify_order(self, order_id: str) -> PayPalOrderStatus:
        if self._mock_mode:
            return PayPalOrderStatus(
                order_id=order_id,
                status="COMPLETED",
                is_completed=True,
            )
        token = await self._get_access_token()
        async with httpx.AsyncClient() as client:
            response = await client.get(
                f"{self._base_url}/v2/checkout/orders/{order_id}",
                headers={"Authorization": f"Bearer {token}"},
            )
        if response.status_code != 200:
            raise PayPalServiceError(f"PayPal verify order failed: {response.status_code}")
        data = response.json()
        order_status = data.get("status", "")
        captures = (
            data.get("purchase_units", [{}])[0]
            .get("payments", {})
            .get("captures", [{}])
        )
        cap_status = captures[0].get("status", "") if captures else ""
        is_completed = order_status == "COMPLETED" and cap_status == "COMPLETED"
        return PayPalOrderStatus(
            order_id=data["id"],
            status=order_status,
            is_completed=is_completed,
        )


from app.config import settings  # noqa: E402


def get_paypal_service() -> PayPalService:
    return PayPalService(
        client_id=settings.paypal_client_id,
        client_secret=settings.paypal_client_secret,
        environment=settings.paypal_environment,
    )
