import 'package:freezed_annotation/freezed_annotation.dart';

part 'checkout_models.freezed.dart';
part 'checkout_models.g.dart';

@freezed
abstract class CheckoutCreateRequest with _$CheckoutCreateRequest {
  const factory CheckoutCreateRequest({
    @JsonKey(name: 'product_result_id') required String productResultId,
    @JsonKey(name: 'session_id') String? sessionId,
  }) = _CheckoutCreateRequest;

  factory CheckoutCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$CheckoutCreateRequestFromJson(json);
}

@freezed
abstract class CheckoutCreateResponse with _$CheckoutCreateResponse {
  const factory CheckoutCreateResponse({
    @JsonKey(name: 'order_id') required String orderId,
    @JsonKey(name: 'approval_url') required String approvalUrl,
    @JsonKey(name: 'purchase_id') required String purchaseId,
  }) = _CheckoutCreateResponse;

  factory CheckoutCreateResponse.fromJson(Map<String, dynamic> json) =>
      _$CheckoutCreateResponseFromJson(json);
}

@freezed
abstract class CheckoutCaptureRequest with _$CheckoutCaptureRequest {
  const factory CheckoutCaptureRequest({
    @JsonKey(name: 'order_id') required String orderId,
    @JsonKey(name: 'purchase_id') required String purchaseId,
  }) = _CheckoutCaptureRequest;

  factory CheckoutCaptureRequest.fromJson(Map<String, dynamic> json) =>
      _$CheckoutCaptureRequestFromJson(json);
}

@freezed
abstract class CheckoutCaptureResponse with _$CheckoutCaptureResponse {
  const factory CheckoutCaptureResponse({
    @JsonKey(name: 'transaction_id') required String transactionId,
    required String status,
    required bool verified,
  }) = _CheckoutCaptureResponse;

  factory CheckoutCaptureResponse.fromJson(Map<String, dynamic> json) =>
      _$CheckoutCaptureResponseFromJson(json);
}
