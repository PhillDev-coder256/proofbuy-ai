import 'package:freezed_annotation/freezed_annotation.dart';

part 'purchase_record.freezed.dart';
part 'purchase_record.g.dart';

@freezed
abstract class PurchaseRecord with _$PurchaseRecord {
  const factory PurchaseRecord({
    required String id,
    @JsonKey(name: 'session_id') required String sessionId,
    @JsonKey(name: 'product_result_id') required String productResultId,
    required double amount,
    required String currency,
    required String status,
    @JsonKey(name: 'paypal_order_id') String? paypalOrderId,
    @JsonKey(name: 'idempotency_key') String? idempotencyKey,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _PurchaseRecord;

  factory PurchaseRecord.fromJson(Map<String, dynamic> json) =>
      _$PurchaseRecordFromJson(json);
}
