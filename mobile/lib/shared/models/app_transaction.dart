import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_transaction.freezed.dart';
part 'app_transaction.g.dart';

@freezed
abstract class AppTransaction with _$AppTransaction {
  const factory AppTransaction({
    required String id,
    @JsonKey(name: 'purchase_record_id') required String purchaseRecordId,
    @JsonKey(name: 'paypal_capture_id') String? paypalCaptureId,
    required String status,
    @JsonKey(name: 'verified_at') DateTime? verifiedAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _AppTransaction;

  factory AppTransaction.fromJson(Map<String, dynamic> json) =>
      _$AppTransactionFromJson(json);
}
