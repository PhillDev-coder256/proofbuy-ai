/// Sealed hierarchy of typed application exceptions.
///
/// Every failure that crosses an API or network boundary should be
/// mapped to one of these subtypes so callers can pattern-match
/// without inspecting raw [DioException] internals.
sealed class AppException implements Exception {
  const AppException();
}

/// The device could not reach the server (timeout, no connectivity, …).
class NetworkException extends AppException {
  const NetworkException(this.message);
  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

/// The server responded with a non-success HTTP status.
class ServerException extends AppException {
  const ServerException(this.statusCode, this.message);
  final int statusCode;
  final String message;

  @override
  String toString() => 'ServerException($statusCode): $message';
}

/// The requested resource was not found (HTTP 404).
class NotFoundException extends AppException {
  const NotFoundException(this.message);
  final String message;

  @override
  String toString() => 'NotFoundException: $message';
}

/// The request payload failed validation (HTTP 422).
class ValidationException extends AppException {
  const ValidationException(this.message);
  final String message;

  @override
  String toString() => 'ValidationException: $message';
}

/// A payment-specific error (HTTP 402).
class PaymentException extends AppException {
  const PaymentException(this.message);
  final String message;

  @override
  String toString() => 'PaymentException: $message';
}
