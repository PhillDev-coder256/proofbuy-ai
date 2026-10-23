import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/errors/app_exception.dart';
import '../../core/networking/repositories_providers.dart';
import 'checkout_state.dart';

part 'checkout_provider.g.dart';

/// Drives the PayPal checkout state machine.
///
/// SECURITY INVARIANT: [CheckoutState.success] is ONLY set when the backend
/// capture response has `verified == true`. A `verified == false` response
/// always transitions to [CheckoutState.failure].
@riverpod
class CheckoutNotifier extends _$CheckoutNotifier {
  @override
  CheckoutState build() => const CheckoutState.idle();

  /// Creates a PayPal order for the given [productResultId].
  Future<void> createOrder(String productResultId) async {
    state = const CheckoutState.creatingOrder();
    try {
      final response = await ref
          .read(checkoutRepositoryProvider)
          .createCheckout(productResultId);
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

      if (response.verified == true) {
        state = CheckoutState.success(transactionId: response.transactionId);
      } else {
        state = const CheckoutState.failure(
          message: 'Payment could not be verified. Please contact support.',
        );
      }
    } on AppException catch (e) {
      // If payment is not yet approved in PayPal, revert to awaiting approval state with message
      final msg = _messageFor(e);
      if (e is ValidationException || msg.contains('422') || msg.contains('UNPROCESSABLE')) {
        if (currentState is CheckoutAwaitingApproval) {
          state = currentState; // Keep awaiting approval UI active
        } else {
          state = CheckoutState.failure(message: 'PayPal payment not yet approved. Please open PayPal to approve.');
        }
      } else {
        state = CheckoutState.failure(message: msg);
      }
    } catch (e) {
      state = CheckoutState.failure(message: e.toString());
    }
  }

  String _messageFor(AppException e) => switch (e) {
        NetworkException(:final message) => message,
        ServerException(:final message) => message,
        NotFoundException(:final message) => message,
        ValidationException(:final message) =>
          'Payment not yet approved in PayPal. Please click "Open PayPal to Approve" first.',
        PaymentException(:final message) => message,
      };
}
