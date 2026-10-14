import 'package:freezed_annotation/freezed_annotation.dart';

part 'ranked_product.freezed.dart';
part 'ranked_product.g.dart';

@freezed
abstract class ProductData with _$ProductData {
  const factory ProductData({
    @JsonKey(name: 'channel3_product_id') String? channel3ProductId,
    required String name,
    double? price,
    String? currency,
    String? merchant,
    @JsonKey(name: 'source_url') String? sourceUrl,
    @JsonKey(name: 'image_url') String? imageUrl,
    Map<String, dynamic>? specs,
    @JsonKey(name: 'retrieved_at') String? retrievedAt,
  }) = _ProductData;

  factory ProductData.fromJson(Map<String, dynamic> json) =>
      _$ProductDataFromJson(json);
}

@freezed
abstract class RankedProduct with _$RankedProduct {
  const factory RankedProduct({
    @JsonKey(name: 'product') required ProductData productData,
    @JsonKey(name: 'constraint_results')
    required Map<String, String> constraintResults,
    @JsonKey(name: 'ranking_score') required double rankingScore,
    @JsonKey(name: 'ranking_confidence') required double rankingConfidence,
    String? explanation,
    @JsonKey(name: 'id') String? productResultId,
  }) = _RankedProduct;

  factory RankedProduct.fromJson(Map<String, dynamic> json) =>
      _$RankedProductFromJson(json);
}
