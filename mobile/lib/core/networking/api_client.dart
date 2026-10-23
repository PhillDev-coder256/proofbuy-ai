import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../errors/app_exception.dart';

/// Global offline signal. True when the last request failed with a
/// connection error or timeout. Reset to false on the next successful response.
final ValueNotifier<bool> isOfflineNotifier = ValueNotifier<bool>(false);

/// Creates and configures the shared [Dio] instance.
Dio createDio() {
  final instance = Dio(
    BaseOptions(
      baseUrl: AppConfig.backendUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // Request logger (debug builds only).
  instance.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        if (kDebugMode) {
          debugPrint('[REQ] ${options.method} ${options.uri} ${options.data}');
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        isOfflineNotifier.value = false;
        handler.next(response);
      },
      onError: (DioException e, handler) {
        final mapped = _mapToAppException(e);
        // Update offline indicator for connection-level failures
        if (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          isOfflineNotifier.value = true;
        }
        // Reject with the mapped AppException directly so callers can
        // catch `on AppException` without unwrapping DioException.error.
        handler.reject(
          DioException(
            requestOptions: e.requestOptions,
            response: e.response,
            type: e.type,
            error: mapped,
            message: e.message,
            stackTrace: e.stackTrace,
          ),
        );
      },
    ),
  );

  return instance;
}

/// Maps a [DioException] to a typed [AppException].
AppException _mapToAppException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
      return NetworkException(e.message ?? 'Connection timed out');
    case DioExceptionType.connectionError:
      return NetworkException(
          'Cannot reach the server. Is it running?');
    default:
      final status = e.response?.statusCode;
      if (status == null) {
        return NetworkException(e.message ?? 'Unknown network error');
      } else if (status == 404) {
        return NotFoundException(
            _responseMessage(e.response) ?? 'Resource not found');
      } else if (status == 422) {
        return ValidationException(
            _responseMessage(e.response) ?? 'Validation error');
      } else if (status == 402) {
        return PaymentException(
            _responseMessage(e.response) ?? 'Payment error');
      } else {
        return ServerException(
            status, _responseMessage(e.response) ?? 'Server error');
      }
  }
}

String? _responseMessage(Response<dynamic>? response) {
  if (response == null) return null;
  final data = response.data;
  if (data is Map<String, dynamic>) {
    // Backend returns: {"error": "...", "status_code": ...}
    return data['error']?.toString()
        ?? data['detail']?.toString()
        ?? data['message']?.toString();
  }
  return data?.toString();
}

/// Top-level singleton — shared across the app.
final dio = createDio();

/// Riverpod provider that exposes the [Dio] instance.
final apiClientProvider = Provider<Dio>((ref) => dio);
