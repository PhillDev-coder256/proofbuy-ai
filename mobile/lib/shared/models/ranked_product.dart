import 'package:freezed_annotation/freezed_annotation.dart';

part 'ranked_product.freezed.dart';
part 'ranked_product.g.dart';

@freezed
abstract class ProductImage with _$ProductImage {
  const factory ProductImage({
    required String url,
    @JsonKey(name: 'cleaned_url') String? cleanedUrl,
    @JsonKey(name: 'is_main_image') @Default(false) bool isMainImage,
    @JsonKey(name: 'shot_type') String? shotType,
    @JsonKey(name: 'alt_text') String? altText,
  }) = _ProductImage;

  factory ProductImage.fromJson(Map<String, dynamic> json) =>
      _$ProductImageFromJson(json);
}

@freezed
abstract class ProductOffer with _$ProductOffer {
  const factory ProductOffer({
    required String url,
    required String domain,
    required double price,
    @JsonKey(name: 'compare_at_price') double? compareAtPrice,
    required String currency,
    required String availability,
    String? condition,
  }) = _ProductOffer;

  factory ProductOffer.fromJson(Map<String, dynamic> json) =>
      _$ProductOfferFromJson(json);
}

@freezed
abstract class ProductRatings with _$ProductRatings {
  const factory ProductRatings({
    required double value,
    required int count,
    @JsonKey(name: 'source_count') required int sourceCount,
  }) = _ProductRatings;

  factory ProductRatings.fromJson(Map<String, dynamic> json) =>
      _$ProductRatingsFromJson(json);
}

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
    @JsonKey(name: 'all_images') @Default([]) List<ProductImage> allImages,
    @JsonKey(name: 'all_offers') @Default([]) List<ProductOffer> allOffers,
    ProductRatings? ratings,
    List<String>? materials,
    @JsonKey(name: 'key_features') List<String>? keyFeatures,
    @JsonKey(name: 'structured_attributes') Map<String, dynamic>? structuredAttributes,
    @JsonKey(name: 'category_title') String? categoryTitle,
    String? description,
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
