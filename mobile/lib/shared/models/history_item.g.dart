// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HistoryItem _$HistoryItemFromJson(Map<String, dynamic> json) => _HistoryItem(
  purchaseRecord: PurchaseRecord.fromJson(
    json['purchase_record'] as Map<String, dynamic>,
  ),
  product: json['product'] == null
      ? null
      : ProductData.fromJson(json['product'] as Map<String, dynamic>),
  session: json['session'] == null
      ? null
      : ShoppingSession.fromJson(json['session'] as Map<String, dynamic>),
);

Map<String, dynamic> _$HistoryItemToJson(_HistoryItem instance) =>
    <String, dynamic>{
      'purchase_record': instance.purchaseRecord,
      'product': instance.product,
      'session': instance.session,
    };
