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
        handler.reject(
          DioException(
            requestOptions: e.requestOptions,
            response: e.response,
            type: e.type,
            error: mapped,
            message: mapped.toString(),
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
      final msg = _responseMessage(e.response);
      if (status == null) {
        return NetworkException(msg ?? 'Unknown network error');
      } else if (status == 404) {
        return NotFoundException(msg ?? 'Resource not found');
      } else if (status == 422) {
        return ValidationException(msg ?? 'Validation error');
      } else if (status == 402) {
        return PaymentException(msg ?? 'Payment error');
      } else {
        return ServerException(status, msg ?? 'Server error ($status)');
      }
  }
}

/// Extracts a clean, human-readable error string from the response data,
/// ensuring raw HTML error pages (e.g. 500 Internal Server Error) are never exposed.
String? _responseMessage(Response<dynamic>? response) {
  if (response == null) return null;
  final data = response.data;
  if (data is Map<String, dynamic>) {
    return data['error']?.toString() ??
        data['detail']?.toString() ??
        data['message']?.toString();
  }
  if (data is String) {
    final str = data.trim();
    // Detect HTML responses (e.g. 500 Internal Server Error HTML pages)
    if (str.startsWith('<!DOCTYPE') ||
        str.startsWith('<html') ||
        str.contains('<title>') ||
        str.contains('<style>')) {
      return 'Server configuration error (${response.statusCode ?? 500}). Please try again.';
    }
    if (str.length > 150) {
      return 'Server error (${response.statusCode ?? 500}). Please try again.';
    }
    return str;
  }
  return null;
}

/// Top-level singleton — shared across the app.
final dio = createDio();

/// Riverpod provider that exposes the [Dio] instance.
final apiClientProvider = Provider<Dio>((ref) => dio);
