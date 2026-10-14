import logging

from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse

logger = logging.getLogger("proofbuy")


class ProofBuyException(Exception):
    def __init__(self, message: str, status_code: int = 500):
        self.message = message
        self.status_code = status_code
        super().__init__(message)


class NotFoundError(ProofBuyException):
    def __init__(self, message: str):
        super().__init__(message, status_code=404)


class ValidationError(ProofBuyException):
    def __init__(self, message: str):
        super().__init__(message, status_code=422)


class ServiceUnavailableError(ProofBuyException):
    def __init__(self, message: str):
        super().__init__(message, status_code=503)


class AIRefusalError(ProofBuyException):
    def __init__(self, message: str):
        super().__init__(message, status_code=422)


class AIInvalidOutputError(ProofBuyException):
    def __init__(self, message: str):
        super().__init__(message, status_code=502)


class Channel3AuthError(ProofBuyException):
    def __init__(self, message: str = "Channel3 API authentication failed"):
        super().__init__(message, status_code=401)


class Channel3RateLimitError(ProofBuyException):
    def __init__(self, message: str = "Channel3 API rate limit exceeded"):
        super().__init__(message, status_code=429)


class Channel3ServiceError(ProofBuyException):
    def __init__(self, message: str = "Channel3 API service error"):
        super().__init__(message, status_code=503)


def add_exception_handlers(app: FastAPI) -> None:
    @app.exception_handler(ProofBuyException)
    async def proofbuy_exception_handler(request: Request, exc: ProofBuyException):
        return JSONResponse(
            status_code=exc.status_code,
            content={"error": exc.message, "status_code": exc.status_code},
        )

    @app.exception_handler(RequestValidationError)
    async def validation_exception_handler(request: Request, exc: RequestValidationError):
        return JSONResponse(
            status_code=422,
            content={"error": "Validation error", "detail": exc.errors()},
        )

    @app.exception_handler(Exception)
    async def generic_exception_handler(request: Request, exc: Exception):
        logger.exception("Unhandled exception: %s", exc)
        return JSONResponse(
            status_code=500,
            content={"error": "Internal server error"},
        )
