import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/errors/app_exception.dart';
import '../../core/firestore/firestore_service.dart';
import '../../features/auth/auth_repository.dart';
import '../../core/networking/repositories_providers.dart';
import 'checkout_state.dart';

part 'checkout_provider.g.dart';

/// Drives the PayPal checkout state machine.
///
/// SECURITY INVARIANT: [CheckoutState.success] is ONLY set when the backend
/// capture response has `verified == true`. A `verified == false` response
/// always transitions to [CheckoutState.failure].
///
/// keepAlive: true — the state MUST survive navigation (back/forward) so that
/// pressing "I've completed payment", going back, and returning does NOT
/// reset the order and retrigger createOrder.
@Riverpod(keepAlive: true)
class CheckoutNotifier extends _$CheckoutNotifier {
  @override
  CheckoutState build() => const CheckoutState.idle();

  /// Reset to idle — call when starting a brand new checkout.
  void reset() => state = const CheckoutState.idle();

  /// Creates a PayPal order for the given [productResultId].
  /// Guard: does nothing if an order is already in progress or complete.
  Future<void> createOrder(String productResultId) async {
    // Already have an order — don't create another
    if (state is CheckoutAwaitingApproval ||
        state is CheckoutCapturing ||
        state is CheckoutSuccess) {
      return;
    }
    state = const CheckoutState.creatingOrder();
    try {
      final response = await ref
          .read(checkoutRepositoryProvider)
          .createCheckout(productResultId);

      // Persist order to Firestore
      final user = ref.read(currentUserProvider);
      if (user != null) {
        await FirestoreService().saveOrder(
          orderId: response.orderId,
          userId: user.userId,
          productResultId: productResultId,
          productName: 'Product ($productResultId)',
          amount: 0.0,
          currency: 'USD',
          status: 'pending',
          paypalOrderId: response.orderId,
          captureId: null,
          verified: false,
        );
      }

      state = CheckoutState.awaitingApproval(
        orderId: response.orderId,
        approvalUrl: response.approvalUrl,
        purchaseId: response.purchaseId,
      );
    } on AppException catch (e) {
      state = CheckoutState.failure(message: _messageFor(e));
    } catch (e) {
      state = CheckoutState.failure(message: e.toString());
    }
  }

  /// Captures payment after the user has approved in PayPal.
  Future<void> captureOrder(String orderId, String purchaseId) async {
    final currentState = state;
    state = CheckoutState.capturing(orderId: orderId, purchaseId: purchaseId);
    try {
      final response = await ref
          .read(checkoutRepositoryProvider)
          .captureCheckout(orderId, purchaseId);

      // Persist transaction to Firestore
      final user = ref.read(currentUserProvider);
      if (user != null && response.verified == true) {
        await FirestoreService().saveTransaction(
          transactionId: response.transactionId,
          purchaseId: purchaseId,
          paypalCaptureId: response.transactionId,
          status: response.status,
          verified: response.verified,
          verifiedAt: DateTime.now(),
          rawCaptureJson: {'transactionId': response.transactionId, 'status': response.status, 'verified': response.verified},
        );

        // Update order status in Firestore
        await FirestoreService().saveOrder(
          orderId: orderId,
          userId: user.userId,
          productResultId: purchaseId,
          productName: 'Product ($purchaseId)',
          amount: 0.0,
          currency: 'USD',
          status: response.verified ? 'captured' : 'failed',
          paypalOrderId: orderId,
          captureId: response.transactionId,
          verified: response.verified,
        );
      }

      if (response.verified == true) {
        state = CheckoutState.success(transactionId: response.transactionId);
      } else {
        state = const CheckoutState.failure(
          message: 'Payment could not be verified. Please contact support.',
        );
      }
    } on AppException catch (e) {
      // If payment is not yet approved in PayPal, revert to awaiting approval state with message
      if (e is ValidationException || _messageFor(e).contains('422') || _messageFor(e).contains('UNPROCESSABLE')) {
        if (currentState is CheckoutAwaitingApproval) {
          state = currentState; // Keep awaiting approval UI active
        } else {
          state = CheckoutState.failure(message: 'PayPal payment not yet approved. Please open PayPal to approve.');
        }
      } else {
        state = CheckoutState.failure(message: _messageFor(e));
      }
    } catch (e) {
      state = CheckoutState.failure(message: e.toString());
    }
  }

  String _messageFor(AppException e) => switch (e) {
        NetworkException(:final message) => message,
        ServerException(:final message) => message,
        NotFoundException(:final message) => message,
        ValidationException() =>
          'Payment not yet approved in PayPal. Please click "Open PayPal to Approve" first.',
        PaymentException(:final message) => message,
      };
}
