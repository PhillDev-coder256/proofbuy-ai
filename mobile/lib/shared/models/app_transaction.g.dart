// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppTransaction _$AppTransactionFromJson(Map<String, dynamic> json) =>
    _AppTransaction(
      id: json['id'] as String,
      purchaseRecordId: json['purchase_record_id'] as String,
      paypalCaptureId: json['paypal_capture_id'] as String?,
      status: json['status'] as String,
      verifiedAt: json['verified_at'] == null
          ? null
          : DateTime.parse(json['verified_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$AppTransactionToJson(_AppTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'purchase_record_id': instance.purchaseRecordId,
      'paypal_capture_id': instance.paypalCaptureId,
      'status': instance.status,
      'verified_at': instance.verifiedAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
    };
