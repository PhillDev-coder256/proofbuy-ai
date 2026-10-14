// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PurchaseRecord _$PurchaseRecordFromJson(Map<String, dynamic> json) =>
    _PurchaseRecord(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      productResultId: json['product_result_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      status: json['status'] as String,
      paypalOrderId: json['paypal_order_id'] as String?,
      idempotencyKey: json['idempotency_key'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$PurchaseRecordToJson(_PurchaseRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'session_id': instance.sessionId,
      'product_result_id': instance.productResultId,
      'amount': instance.amount,
      'currency': instance.currency,
      'status': instance.status,
      'paypal_order_id': instance.paypalOrderId,
      'idempotency_key': instance.idempotencyKey,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
