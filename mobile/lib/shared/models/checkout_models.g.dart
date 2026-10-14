// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkout_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CheckoutCreateRequest _$CheckoutCreateRequestFromJson(
  Map<String, dynamic> json,
) => _CheckoutCreateRequest(
  productResultId: json['product_result_id'] as String,
  sessionId: json['session_id'] as String?,
);

Map<String, dynamic> _$CheckoutCreateRequestToJson(
  _CheckoutCreateRequest instance,
) => <String, dynamic>{
  'product_result_id': instance.productResultId,
  'session_id': instance.sessionId,
};

_CheckoutCreateResponse _$CheckoutCreateResponseFromJson(
  Map<String, dynamic> json,
) => _CheckoutCreateResponse(
  orderId: json['order_id'] as String,
  approvalUrl: json['approval_url'] as String,
  purchaseId: json['purchase_id'] as String,
);

Map<String, dynamic> _$CheckoutCreateResponseToJson(
  _CheckoutCreateResponse instance,
) => <String, dynamic>{
  'order_id': instance.orderId,
  'approval_url': instance.approvalUrl,
  'purchase_id': instance.purchaseId,
};

_CheckoutCaptureRequest _$CheckoutCaptureRequestFromJson(
  Map<String, dynamic> json,
) => _CheckoutCaptureRequest(
  orderId: json['order_id'] as String,
  purchaseId: json['purchase_id'] as String,
);

Map<String, dynamic> _$CheckoutCaptureRequestToJson(
  _CheckoutCaptureRequest instance,
) => <String, dynamic>{
  'order_id': instance.orderId,
  'purchase_id': instance.purchaseId,
};

_CheckoutCaptureResponse _$CheckoutCaptureResponseFromJson(
  Map<String, dynamic> json,
) => _CheckoutCaptureResponse(
  transactionId: json['transaction_id'] as String,
  status: json['status'] as String,
  verified: json['verified'] as bool,
);

Map<String, dynamic> _$CheckoutCaptureResponseToJson(
  _CheckoutCaptureResponse instance,
) => <String, dynamic>{
  'transaction_id': instance.transactionId,
  'status': instance.status,
  'verified': instance.verified,
};
