import 'package:dio/dio.dart';

import '../../shared/models/app_transaction.dart';
import '../../shared/models/history_item.dart';

class TransactionsRepository {
  TransactionsRepository(this._dio);

  final Dio _dio;

  /// Fetches a single transaction by purchase ID.
  ///
  /// GET /api/v1/transactions/{purchaseId} → AppTransaction
  Future<AppTransaction> getTransaction(String purchaseId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/transactions/$purchaseId',
    );
    return AppTransaction.fromJson(response.data!);
  }

  /// Fetches the full purchase history.
  ///
  /// GET /api/v1/history → list of HistoryItem
  Future<List<HistoryItem>> getHistory() async {
    final response = await _dio.get<List<dynamic>>('/api/v1/history');
    final list = response.data ?? [];
    return list
        .map((item) => HistoryItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
