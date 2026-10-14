// ignore_for_file: lines_longer_than_80_chars
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:proofbuy_ai/core/networking/checkout_repository.dart';
import 'package:proofbuy_ai/shared/models/checkout_models.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockDio extends Mock implements Dio {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockDio mockDio;
  late CheckoutRepository repo;

  setUp(() {
    mockDio = MockDio();
    repo = CheckoutRepository(mockDio);
    // Register default fallback values required by mocktail.
    registerFallbackValue(RequestOptions(path: ''));
  });

  group('CheckoutRepository.createCheckout', () {
    test('returns CheckoutCreateResponse with orderId, approvalUrl, purchaseId on 200',
        () async {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => _fakeResponse({
          'order_id': 'order-001',
          'approval_url': 'https://paypal.com/approve/order-001',
          'purchase_id': 'purchase-001',
        }),
      );

      final response = await repo.createCheckout('prod-result-1');

      expect(response, isA<CheckoutCreateResponse>());
      expect(response.orderId, 'order-001');
      expect(response.approvalUrl, 'https://paypal.com/approve/order-001');
      expect(response.purchaseId, 'purchase-001');
    });
  });

  group('CheckoutRepository.captureCheckout', () {
    test('returns CheckoutCaptureResponse with verified=true on success',
        () async {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => _fakeResponse({
          'transaction_id': 'tx-002',
          'status': 'COMPLETED',
          'verified': true,
        }),
      );

      final response = await repo.captureCheckout('order-001', 'purchase-001');

      expect(response, isA<CheckoutCaptureResponse>());
      expect(response.transactionId, 'tx-002');
      expect(response.status, 'COMPLETED');
      expect(response.verified, isTrue);
    });

    test(
        'returns CheckoutCaptureResponse with verified=false — '
        'not an exception, backend returns 200', () async {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => _fakeResponse({
          'transaction_id': 'tx-003',
          'status': 'COMPLETED',
          'verified': false,
        }),
      );

      // Must NOT throw — the repository returns the response as-is.
      final response = await repo.captureCheckout('order-001', 'purchase-001');

      expect(response, isA<CheckoutCaptureResponse>());
      expect(response.verified, isFalse);
      expect(response.transactionId, 'tx-003');
    });
  });
}
