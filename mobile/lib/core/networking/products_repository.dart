import 'package:dio/dio.dart';

import '../../shared/models/ranked_product.dart';

class ProductsRepository {
  ProductsRepository(this._dio);

  final Dio _dio;

  /// Fetches ranked products for a given session.
  ///
  /// GET /api/v1/products/{sessionId} → list of RankedProduct
  Future<List<RankedProduct>> getProducts(String sessionId) async {
    final response = await _dio.get<List<dynamic>>(
      '/api/v1/products/$sessionId',
    );
    final list = response.data ?? [];
    return list
        .map((item) => RankedProduct.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
