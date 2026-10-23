// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ranked_product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductImage _$ProductImageFromJson(Map<String, dynamic> json) =>
    _ProductImage(
      url: json['url'] as String,
      cleanedUrl: json['cleaned_url'] as String?,
      isMainImage: json['is_main_image'] as bool? ?? false,
      shotType: json['shot_type'] as String?,
      altText: json['alt_text'] as String?,
    );

Map<String, dynamic> _$ProductImageToJson(_ProductImage instance) =>
    <String, dynamic>{
      'url': instance.url,
      'cleaned_url': instance.cleanedUrl,
      'is_main_image': instance.isMainImage,
      'shot_type': instance.shotType,
      'alt_text': instance.altText,
    };

_ProductOffer _$ProductOfferFromJson(Map<String, dynamic> json) =>
    _ProductOffer(
      url: json['url'] as String,
      domain: json['domain'] as String,
      price: (json['price'] as num).toDouble(),
      compareAtPrice: (json['compare_at_price'] as num?)?.toDouble(),
      currency: json['currency'] as String,
      availability: json['availability'] as String,
      condition: json['condition'] as String?,
    );

Map<String, dynamic> _$ProductOfferToJson(_ProductOffer instance) =>
    <String, dynamic>{
      'url': instance.url,
      'domain': instance.domain,
      'price': instance.price,
      'compare_at_price': instance.compareAtPrice,
      'currency': instance.currency,
      'availability': instance.availability,
      'condition': instance.condition,
    };

_ProductRatings _$ProductRatingsFromJson(Map<String, dynamic> json) =>
    _ProductRatings(
      value: (json['value'] as num).toDouble(),
      count: (json['count'] as num).toInt(),
      sourceCount: (json['source_count'] as num).toInt(),
    );

Map<String, dynamic> _$ProductRatingsToJson(_ProductRatings instance) =>
    <String, dynamic>{
      'value': instance.value,
      'count': instance.count,
      'source_count': instance.sourceCount,
    };

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
  allImages:
      (json['all_images'] as List<dynamic>?)
          ?.map((e) => ProductImage.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  allOffers:
      (json['all_offers'] as List<dynamic>?)
          ?.map((e) => ProductOffer.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  ratings: json['ratings'] == null
      ? null
      : ProductRatings.fromJson(json['ratings'] as Map<String, dynamic>),
  materials: (json['materials'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  keyFeatures: (json['key_features'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  structuredAttributes: json['structured_attributes'] as Map<String, dynamic>?,
  categoryTitle: json['category_title'] as String?,
  description: json['description'] as String?,
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
      'all_images': instance.allImages,
      'all_offers': instance.allOffers,
      'ratings': instance.ratings,
      'materials': instance.materials,
      'key_features': instance.keyFeatures,
      'structured_attributes': instance.structuredAttributes,
      'category_title': instance.categoryTitle,
      'description': instance.description,
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
