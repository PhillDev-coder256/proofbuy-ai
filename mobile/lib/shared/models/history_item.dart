import 'package:freezed_annotation/freezed_annotation.dart';

import 'purchase_record.dart';
import 'ranked_product.dart';
import 'shopping_session.dart';

part 'history_item.freezed.dart';
part 'history_item.g.dart';

@freezed
abstract class HistoryItem with _$HistoryItem {
  const factory HistoryItem({
    @JsonKey(name: 'purchase_record') required PurchaseRecord purchaseRecord,
    ProductData? product,
    ShoppingSession? session,
  }) = _HistoryItem;

  factory HistoryItem.fromJson(Map<String, dynamic> json) =>
      _$HistoryItemFromJson(json);
}
