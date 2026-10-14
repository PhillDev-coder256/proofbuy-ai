import 'package:dio/dio.dart';

import '../../shared/models/checkout_models.dart';

class CheckoutRepository {
  CheckoutRepository(this._dio);

  final Dio _dio;

  /// Creates a PayPal checkout order.
  ///
  /// POST /api/v1/checkout/create → {order_id, approval_url, purchase_id}
  Future<CheckoutCreateResponse> createCheckout(
    String productResultId, {
    String? sessionId,
  }) async {
    final body = CheckoutCreateRequest(
      productResultId: productResultId,
      sessionId: sessionId,
    ).toJson();
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/checkout/create',
      data: body,
    );
    return CheckoutCreateResponse.fromJson(response.data!);
  }

  /// Captures a PayPal payment after the user approves.
  ///
  /// POST /api/v1/checkout/capture → {transaction_id, status, verified}
  Future<CheckoutCaptureResponse> captureCheckout(
    String orderId,
    String purchaseId,
  ) async {
    final body = CheckoutCaptureRequest(
      orderId: orderId,
      purchaseId: purchaseId,
    ).toJson();
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/checkout/capture',
      data: body,
    );
    return CheckoutCaptureResponse.fromJson(response.data!);
  }
}
