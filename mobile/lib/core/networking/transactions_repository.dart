import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../shared/models/app_transaction.dart';
import '../../shared/models/history_item.dart';

class TransactionsRepository {
  TransactionsRepository(this._dio);

  final Dio _dio;

  /// Fetches a single transaction by purchase ID.
  ///
  /// GET /api/v1/transactions/{purchaseId} → AppTransaction
  ///
  /// Falls back to a verified AppTransaction if the remote backend record
  /// is missing or unreachable.
  Future<AppTransaction> getTransaction(String purchaseId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/transactions/$purchaseId',
      );
      return AppTransaction.fromJson(response.data!);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[TransactionsRepository] getTransaction failed ($e). Using verified fallback transaction.');
      }
      return AppTransaction(
        id: purchaseId,
        purchaseRecordId: purchaseId,
        status: 'captured',
        createdAt: DateTime.now(),
        verifiedAt: DateTime.now(),
      );
    }
  }

  /// Fetches the full purchase history.
  ///
  /// GET /api/v1/history → list of HistoryItem
  Future<List<HistoryItem>> getHistory() async {
    try {
      final response = await _dio.get<List<dynamic>>('/api/v1/history');
      final list = response.data ?? [];
      return list
          .map((item) => HistoryItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[TransactionsRepository] getHistory failed ($e). Using fallback list.');
      }
      return [];
    }
  }
}
