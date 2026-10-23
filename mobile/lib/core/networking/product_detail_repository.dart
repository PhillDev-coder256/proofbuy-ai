import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../shared/models/ranked_product.dart';

class ProductDetailRepository {
  ProductDetailRepository(this._dio);

  final Dio _dio;

  /// Fetches full product detail for a given Channel3 product ID.
  ///
  /// GET /api/v1/products/detail/{channel3ProductId} → ProductData
  Future<ProductData?> getProductDetail(String channel3ProductId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/products/detail/$channel3ProductId',
      );
      if (response.data == null) return null;
      return ProductData.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      if (kDebugMode) {
        debugPrint('[ProductDetailRepository] error: $e');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ProductDetailRepository] error: $e');
      }
      return null;
    }
  }
}
