// ignore_for_file: lines_longer_than_80_chars
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:proofbuy_ai/core/errors/app_exception.dart';
import 'package:proofbuy_ai/core/networking/shopping_repository.dart';
import 'package:proofbuy_ai/shared/models/shopping_session.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockDio extends Mock implements Dio {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Builds a fake [Response] wrapping [data] with the given [statusCode].
Response<Map<String, dynamic>> _fakeResponse(
  Map<String, dynamic> data, {
  int statusCode = 200,
}) {
  return Response<Map<String, dynamic>>(
    requestOptions: RequestOptions(path: ''),
    data: data,
    statusCode: statusCode,
  );
}

/// Builds a [DioException] that carries a typed [AppException] as its error.
DioException _fakeDioError({
  required int statusCode,
  required AppException mapped,
}) {
  final response = Response<dynamic>(
    requestOptions: RequestOptions(path: ''),
    statusCode: statusCode,
  );
  return DioException(
    requestOptions: RequestOptions(path: ''),
    response: response,
    error: mapped,
    message: mapped.toString(),
    type: DioExceptionType.badResponse,
  );
}

/// Valid ShoppingBriefResponse JSON returned by the backend.
const _briefResponseJson = {
  'session_id': 'sess-abc',
  'status': 'active',
  'message': 'Brief received',
  'requirements': {'budget': '100'},
};

/// Valid ShoppingSessionResponse JSON returned by GET /api/v1/shopping/{id}.
const _sessionJson = {
  'id': 'sess-def',
  'brief_text': 'I want a laptop',
  'requirements_json': <String, dynamic>{'budget': '500'},
  'status': 'active',
  'created_at': '2024-01-01T00:00:00.000Z',
  'updated_at': '2024-01-01T00:00:00.000Z',
};

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockDio mockDio;
  late ShoppingRepository repo;

  setUp(() {
    mockDio = MockDio();
    repo = ShoppingRepository(mockDio);
    // Register default fallback values required by mocktail.
    registerFallbackValue(RequestOptions(path: ''));
  });

  group('ShoppingRepository.submitBrief', () {
    test('returns ShoppingSession on 200 response with valid JSON', () async {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => _fakeResponse(_briefResponseJson));

      final session = await repo.submitBrief('I want a laptop');

      expect(session, isA<ShoppingSession>());
      expect(session.id, 'sess-abc');
      expect(session.status, 'active');
      expect(session.briefText, 'I want a laptop');
      expect(session.requirementsJson, {'budget': '100'});
    });

    test('throws ValidationException on 422 response', () async {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
        ),
      ).thenThrow(
        _fakeDioError(
          statusCode: 422,
          mapped: const ValidationException('Invalid brief'),
        ),
      );

      expect(
        () => repo.submitBrief('bad brief'),
        throwsA(
          predicate<DioException>(
            (e) => e.error is ValidationException,
            'DioException wrapping ValidationException',
          ),
        ),
      );
    });
  });

  group('ShoppingRepository.getSession', () {
    test('returns ShoppingSession on 200 response', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(any()),
      ).thenAnswer((_) async => _fakeResponse(_sessionJson));

      final session = await repo.getSession('sess-def');

      expect(session, isA<ShoppingSession>());
      expect(session.id, 'sess-def');
      expect(session.briefText, 'I want a laptop');
      expect(session.status, 'active');
    });

    test('throws NotFoundException on 404 response', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(any()),
      ).thenThrow(
        _fakeDioError(
          statusCode: 404,
          mapped: const NotFoundException('Session not found'),
        ),
      );

      expect(
        () => repo.getSession('no-such-session'),
        throwsA(
          predicate<DioException>(
            (e) => e.error is NotFoundException,
            'DioException wrapping NotFoundException',
          ),
        ),
      );
    });
  });
}
