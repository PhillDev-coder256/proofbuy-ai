// ignore_for_file: lines_longer_than_80_chars
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:proofbuy_ai/core/networking/checkout_repository.dart';
import 'package:proofbuy_ai/core/networking/repositories_providers.dart';
import 'package:proofbuy_ai/core/widgets/error_widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:proofbuy_ai/features/checkout/checkout_provider.dart';
import 'package:proofbuy_ai/features/checkout/checkout_screen.dart';
import 'package:proofbuy_ai/features/checkout/checkout_state.dart';
import 'package:proofbuy_ai/shared/models/checkout_models.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockCheckoutRepository extends Mock implements CheckoutRepository {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Wraps a widget with the minimal scaffolding CheckoutScreen needs:
/// a [ProviderScope] with repository override and a minimal [GoRouter] so
/// that `GoRouterState.of(context)` resolves without throwing.
Widget buildCheckoutWidget({
  required MockCheckoutRepository repo,
  String purchaseId = 'prod-123',
  String orderId = '',
}) {
  // A minimal GoRouter pointing to the checkout screen so that
  // GoRouterState.of(context) is available in the widget tree.
  final router = GoRouter(
    initialLocation: '/checkout/$purchaseId',
    routes: [
      GoRoute(
        path: '/checkout/:purchaseId',
        builder: (context, state) => CheckoutScreen(
          purchaseId: state.pathParameters['purchaseId']!,
          orderId: state.uri.queryParameters['orderId'] ?? '',
        ),
      ),
      GoRoute(
        path: '/transaction/:transactionId',
        builder: (context, state) =>
            Scaffold(body: Text('Transaction ${state.pathParameters['transactionId']}')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      checkoutRepositoryProvider.overrideWithValue(repo),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockCheckoutRepository mockRepo;

  setUp(() {
    mockRepo = MockCheckoutRepository();
  });

  // ----- 1. Loading state while createOrder is in-flight -------------------

  group('CheckoutScreen — createOrder', () {
    testWidgets('shows LoadingWidget while creating order', (tester) async {
      final completer = Completer<CheckoutCreateResponse>();
      when(() => mockRepo.createCheckout(any()))
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(buildCheckoutWidget(repo: mockRepo));
      await tester.pump(); // one frame — state is CheckoutCreatingOrder

      expect(find.byType(Shimmer), findsOneWidget);

      // Complete so the widget tree can dispose cleanly.
      completer.complete(
        const CheckoutCreateResponse(
          orderId: 'order-1',
          approvalUrl: 'https://paypal.com/approve',
          purchaseId: 'purchase-1',
        ),
      );
      await tester.pumpAndSettle();
    });
  });

  // ----- 2. AwaitingApproval shows both buttons ----------------------------

  group('CheckoutScreen — AwaitingApproval', () {
    testWidgets('shows approval button and confirm button', (tester) async {
      when(() => mockRepo.createCheckout(any())).thenAnswer(
        (_) async => const CheckoutCreateResponse(
          orderId: 'order-2',
          approvalUrl: 'https://paypal.com/approve',
          purchaseId: 'purchase-2',
        ),
      );

      // Return a never-resolving future for capture so we stay in
      // AwaitingApproval and the test doesn't accidentally advance.
      when(() => mockRepo.captureCheckout(any(), any()))
          .thenAnswer((_) => Completer<CheckoutCaptureResponse>().future);

      await tester.pumpWidget(buildCheckoutWidget(repo: mockRepo));
      await tester.pumpAndSettle();

      expect(find.text('Open PayPal to Approve'), findsOneWidget);
      expect(find.text("I've completed payment"), findsOneWidget);
    });
  });

  // ----- 3. verified=false → CheckoutFailure (not success) ----------------

  group('CheckoutNotifier — captureOrder security invariant', () {
    test('verified=false sets CheckoutFailure, not CheckoutSuccess', () async {
      when(() => mockRepo.createCheckout(any())).thenAnswer(
        (_) async => const CheckoutCreateResponse(
          orderId: 'order-3',
          approvalUrl: 'https://paypal.com/approve',
          purchaseId: 'purchase-3',
        ),
      );
      when(() => mockRepo.captureCheckout(any(), any())).thenAnswer(
        (_) async => const CheckoutCaptureResponse(
          transactionId: 'tx-3',
          status: 'COMPLETED',
          verified: false, // <-- must NOT produce CheckoutSuccess
        ),
      );

      final container = ProviderContainer(
        overrides: [checkoutRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(checkoutProvider.notifier);
      await notifier.createOrder('prod-3');

      // Should be awaiting approval after createOrder.
      expect(container.read(checkoutProvider), isA<CheckoutAwaitingApproval>());

      await notifier.captureOrder('order-3', 'purchase-3');

      final state = container.read(checkoutProvider);
      // CRITICAL: verified=false must NEVER produce CheckoutSuccess.
      expect(state, isNot(isA<CheckoutSuccess>()),
          reason: 'verified=false must not produce CheckoutSuccess');
      expect(state, isA<CheckoutFailure>());
      final failure = state as CheckoutFailure;
      expect(failure.message,
          'Payment could not be verified. Please contact support.');
    });

    // ----- 4. verified=true → CheckoutSuccess ----------------------------

    test('verified=true sets CheckoutSuccess', () async {
      when(() => mockRepo.createCheckout(any())).thenAnswer(
        (_) async => const CheckoutCreateResponse(
          orderId: 'order-4',
          approvalUrl: 'https://paypal.com/approve',
          purchaseId: 'purchase-4',
        ),
      );
      when(() => mockRepo.captureCheckout(any(), any())).thenAnswer(
        (_) async => const CheckoutCaptureResponse(
          transactionId: 'tx-4',
          status: 'COMPLETED',
          verified: true, // <-- must produce CheckoutSuccess
        ),
      );

      final container = ProviderContainer(
        overrides: [checkoutRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(checkoutProvider.notifier);
      await notifier.createOrder('prod-4');
      await notifier.captureOrder('order-4', 'purchase-4');

      final state = container.read(checkoutProvider);
      expect(state, isA<CheckoutSuccess>());
      expect((state as CheckoutSuccess).transactionId, 'tx-4');
    });
  });

  // ----- 5. CheckoutSuccess triggers navigation via ref.listen -------------

  group('CheckoutScreen — navigation', () {
    testWidgets(
        'navigates to /transaction/:id when CheckoutSuccess state is reached',
        (tester) async {
      when(() => mockRepo.createCheckout(any())).thenAnswer(
        (_) async => const CheckoutCreateResponse(
          orderId: 'order-5',
          approvalUrl: 'https://paypal.com/approve',
          purchaseId: 'purchase-5',
        ),
      );
      when(() => mockRepo.captureCheckout(any(), any())).thenAnswer(
        (_) async => const CheckoutCaptureResponse(
          transactionId: 'tx-5',
          status: 'COMPLETED',
          verified: true,
        ),
      );

      await tester.pumpWidget(buildCheckoutWidget(repo: mockRepo));
      await tester.pumpAndSettle(); // reaches AwaitingApproval

      // Tap 'I've completed payment' to trigger capture.
      await tester.tap(find.text("I've completed payment"));
      await tester.pumpAndSettle(); // capture completes → CheckoutSuccess → navigate

      // After navigation the transaction screen shows the tx id.
      expect(find.text('Transaction tx-5'), findsOneWidget);
      // The LoadingWidget from CheckoutScreen is gone.
      expect(find.byType(Shimmer), findsNothing);
    });

    testWidgets(
        'CheckoutFailure does NOT navigate to transaction screen',
        (tester) async {
      when(() => mockRepo.createCheckout(any())).thenAnswer(
        (_) async => const CheckoutCreateResponse(
          orderId: 'order-6',
          approvalUrl: 'https://paypal.com/approve',
          purchaseId: 'purchase-6',
        ),
      );
      when(() => mockRepo.captureCheckout(any(), any())).thenAnswer(
        (_) async => const CheckoutCaptureResponse(
          transactionId: 'tx-6',
          status: 'COMPLETED',
          verified: false, // failure path
        ),
      );

      await tester.pumpWidget(buildCheckoutWidget(repo: mockRepo));
      await tester.pumpAndSettle(); // reaches AwaitingApproval

      await tester.tap(find.text("I've completed payment"));
      await tester.pumpAndSettle();

      // Must stay on CheckoutScreen showing an error, NOT navigate away.
      expect(find.byType(ProofBuyErrorWidget), findsOneWidget);
      expect(find.textContaining('Transaction'), findsNothing);
    });
  });
}
