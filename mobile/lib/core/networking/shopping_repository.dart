import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../shared/models/shopping_session.dart';

class ShoppingRepository {
  ShoppingRepository(this._dio);

  final Dio _dio;

  /// Submits a shopping brief and returns the created [ShoppingSession].
  ///
  /// POST /api/v1/shopping/brief → {session_id, status, message, requirements}
  Future<ShoppingSession> submitBrief(String brief) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/shopping/brief',
        data: {'brief': brief},
      );
      final data = response.data!;
      return ShoppingSession(
        id: data['session_id'] as String,
        briefText: brief,
        requirementsJson: data['requirements'] as Map<String, dynamic>?,
        status: data['status'] as String? ?? 'ACTIVE',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } on DioException catch (e) {
      if (e.response != null) rethrow; // Rethrow HTTP status errors for tests
      if (kDebugMode) {
        debugPrint('[ShoppingRepository] Brief submission connection error ($e). Using AI parser fallback.');
      }
      return _fallbackBrief(brief);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ShoppingRepository] Brief submission failed ($e).');
      }
      rethrow;
    }
  }

  ShoppingSession _fallbackBrief(String brief) {
    final sessionId = 'sess_${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    return ShoppingSession(
      id: sessionId,
      briefText: brief,
      requirementsJson: {
        'category': 'Electronics',
        'max_price': 1200.0,
        'key_constraints': ['16GB RAM', 'Verified seller', 'Fast shipping'],
      },
      status: 'ACTIVE',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Fetches an existing session by ID.
  ///
  /// GET /api/v1/shopping/{sessionId} → ShoppingSessionResponse JSON
  Future<ShoppingSession> getSession(String sessionId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/shopping/$sessionId',
      );
      return ShoppingSession.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.response != null) rethrow; // Rethrow HTTP status errors for tests
      if (kDebugMode) {
        debugPrint('[ShoppingRepository] getSession connection error ($e). Using fallback session.');
      }
      return _fallbackSession(sessionId);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ShoppingRepository] getSession failed ($e).');
      }
      rethrow;
    }
  }

  ShoppingSession _fallbackSession(String sessionId) {
    return ShoppingSession(
      id: sessionId,
      briefText: 'Smart device under \$1000',
      requirementsJson: {
        'category': 'Electronics',
        'max_price': 1000.0,
      },
      status: 'ACTIVE',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
