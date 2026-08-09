from __future__ import annotations

import os
from typing import Any

import requests


DEFAULT_BASE_URL = os.getenv("MA_WAREHOUSE_API_URL", "http://127.0.0.1:3000").rstrip("/")
DEFAULT_TIMEOUT = 15


class APIError(RuntimeError):
    """Raised when the desktop client cannot complete an API request."""


class API:
    def __init__(
        self,
        base_url: str | None = None,
        timeout: int = DEFAULT_TIMEOUT,
        session: requests.Session | None = None,
    ) -> None:
        self.base_url = (base_url or DEFAULT_BASE_URL).rstrip("/")
        self.timeout = timeout
        self.session = session or requests.Session()
        self.token: str | None = None
        self.user: dict[str, Any] | None = None

    @property
    def auth_headers(self) -> dict[str, str]:
        if not self.token:
            return {"Accept": "application/json"}
        return {
            "Accept": "application/json",
            "Authorization": f"Bearer {self.token}",
        }

    def _request(
        self,
        method: str,
        path: str,
        *,
        expected_key: str | None = None,
        **kwargs: Any,
    ) -> Any:
        headers = {**self.auth_headers, **kwargs.pop("headers", {})}
        if "json" in kwargs:
            headers.setdefault("Content-Type", "application/json")

        try:
            response = self.session.request(
                method=method,
                url=f"{self.base_url}{path}",
                headers=headers,
                timeout=self.timeout,
                **kwargs,
            )
        except requests.Timeout as exc:
            raise APIError("ارتباط با سرور بیش از حد طول کشید.") from exc
        except requests.RequestException as exc:
            raise APIError("اتصال به سرور برقرار نشد.") from exc

        payload = self._parse_response(response)
        if expected_key is None:
            return payload
        if isinstance(payload, dict):
            return payload.get(expected_key, [])
        raise APIError("پاسخ سرور در قالب مورد انتظار نبود.")

    def _parse_response(self, response: requests.Response) -> Any:
        try:
            payload: Any = response.json()
        except ValueError:
            payload = {}

        if not response.ok:
            if isinstance(payload, dict):
                message = payload.get("error") or payload.get("message")
            else:
                message = None
            raise APIError(message or "درخواست به سرور با خطا مواجه شد.")

        return payload

    def login(self, phone: str, password: str) -> dict[str, Any]:
        payload = self._request(
            "POST",
            "/api/auth/login",
            json={"phone": phone, "password": password},
        )
        if not isinstance(payload, dict):
            raise APIError("پاسخ ورود نامعتبر است.")

        self.token = payload.get("token")
        self.user = payload.get("user")
        if not self.token or not self.user:
            raise APIError("اطلاعات کاربری کامل دریافت نشد.")
        return payload

    def get_my_warehouse(self) -> dict[str, Any]:
        return self._request(
            "GET",
            "/api/warehouse-keeper/my-warehouse",
            expected_key="warehouse",
        )

    def get_cartons(self) -> list[dict[str, Any]]:
        return self._request(
            "GET",
            "/api/warehouse-keeper/checkin/recent",
            expected_key="cartons",
        )

    def get_shipped_cartons(self) -> list[dict[str, Any]]:
        return self._request(
            "GET",
            "/api/warehouse-keeper/cartons/shipped",
            expected_key="cartons",
        )

    def get_orders(self) -> list[dict[str, Any]]:
        return self._request(
            "GET",
            "/api/warehouse-keeper/orders",
            expected_key="orders",
        )

    def get_transactions(self, date: str | None = None) -> list[dict[str, Any]]:
        params = {"date": date} if date else None
        return self._request(
            "GET",
            "/api/warehouse-keeper/transactions",
            params=params,
            expected_key="transactions",
        )

    def get_labels(self) -> list[dict[str, Any]]:
        return self._request(
            "GET",
            "/api/warehouse-keeper/labels",
            expected_key="cartons",
        )

    def get_badges(self) -> list[dict[str, Any]]:
        return self._request("GET", "/api/badges")

    def logout(self) -> None:
        self.token = None
        self.user = None
