// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ranked_product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductData _$ProductDataFromJson(Map<String, dynamic> json) => _ProductData(
  channel3ProductId: json['channel3_product_id'] as String?,
  name: json['name'] as String,
  price: (json['price'] as num?)?.toDouble(),
  currency: json['currency'] as String?,
  merchant: json['merchant'] as String?,
  sourceUrl: json['source_url'] as String?,
  imageUrl: json['image_url'] as String?,
  specs: json['specs'] as Map<String, dynamic>?,
  retrievedAt: json['retrieved_at'] as String?,
);

Map<String, dynamic> _$ProductDataToJson(_ProductData instance) =>
    <String, dynamic>{
      'channel3_product_id': instance.channel3ProductId,
      'name': instance.name,
      'price': instance.price,
      'currency': instance.currency,
      'merchant': instance.merchant,
      'source_url': instance.sourceUrl,
      'image_url': instance.imageUrl,
      'specs': instance.specs,
      'retrieved_at': instance.retrievedAt,
    };

_RankedProduct _$RankedProductFromJson(Map<String, dynamic> json) =>
    _RankedProduct(
      productData: ProductData.fromJson(
        json['product'] as Map<String, dynamic>,
      ),
      constraintResults: Map<String, String>.from(
        json['constraint_results'] as Map,
      ),
      rankingScore: (json['ranking_score'] as num).toDouble(),
      rankingConfidence: (json['ranking_confidence'] as num).toDouble(),
      explanation: json['explanation'] as String?,
      productResultId: json['id'] as String?,
    );

Map<String, dynamic> _$RankedProductToJson(_RankedProduct instance) =>
    <String, dynamic>{
      'product': instance.productData,
      'constraint_results': instance.constraintResults,
      'ranking_score': instance.rankingScore,
      'ranking_confidence': instance.rankingConfidence,
      'explanation': instance.explanation,
      'id': instance.productResultId,
    };
