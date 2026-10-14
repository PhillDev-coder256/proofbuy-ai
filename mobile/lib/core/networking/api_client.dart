import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../errors/app_exception.dart';

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
        handler.next(response);
      },
      onError: (DioException e, handler) {
        handler.next(_mapException(e));
      },
    ),
  );

  return instance;
}

/// Maps a [DioException] to a typed [AppException] carried as the error field.
DioException _mapException(DioException e) {
  final AppException mapped;

  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
      mapped = NetworkException(e.message ?? 'Connection timed out');
    case DioExceptionType.connectionError:
      mapped = NetworkException(e.message ?? 'Connection error');
    default:
      final status = e.response?.statusCode;
      if (status == null) {
        mapped = NetworkException(e.message ?? 'Unknown network error');
      } else if (status == 404) {
        mapped = NotFoundException(
          _responseMessage(e.response) ?? 'Resource not found',
        );
      } else if (status == 422) {
        mapped = ValidationException(
          _responseMessage(e.response) ?? 'Validation error',
        );
      } else if (status == 402) {
        mapped = PaymentException(
          _responseMessage(e.response) ?? 'Payment error',
        );
      } else {
        mapped = ServerException(
          status,
          _responseMessage(e.response) ?? 'Server error',
        );
      }
  }

  return DioException(
    requestOptions: e.requestOptions,
    response: e.response,
    type: e.type,
    error: mapped,
    message: mapped.toString(),
    stackTrace: e.stackTrace,
  );
}

String? _responseMessage(Response<dynamic>? response) {
  if (response == null) return null;
  final data = response.data;
  if (data is Map<String, dynamic>) {
    return data['detail']?.toString() ?? data['message']?.toString();
  }
  return data?.toString();
}

/// Top-level singleton — shared across the app.
final dio = createDio();

/// Riverpod provider that exposes the [Dio] instance.
final apiClientProvider = Provider<Dio>((ref) => dio);
