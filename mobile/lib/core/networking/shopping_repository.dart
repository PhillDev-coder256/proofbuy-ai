import 'package:dio/dio.dart';

import '../../shared/models/shopping_session.dart';

class ShoppingRepository {
  ShoppingRepository(this._dio);

  final Dio _dio;

  /// Submits a shopping brief and returns the created [ShoppingSession].
  ///
  /// POST /api/v1/shopping/brief → {session_id, status, message, requirements}
  Future<ShoppingSession> submitBrief(String brief) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/shopping/brief',
      data: {'brief': brief},
    );
    final data = response.data!;
    // Map ShoppingBriefResponse → ShoppingSession
    return ShoppingSession(
      id: data['session_id'] as String,
      briefText: brief,
      requirementsJson: data['requirements'] as Map<String, dynamic>?,
      status: data['status'] as String,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Fetches an existing session by ID.
  ///
  /// GET /api/v1/shopping/{sessionId} → ShoppingSessionResponse JSON
  Future<ShoppingSession> getSession(String sessionId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/shopping/$sessionId',
    );
    return ShoppingSession.fromJson(response.data!);
  }
}
