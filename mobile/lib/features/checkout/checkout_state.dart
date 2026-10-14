import 'package:freezed_annotation/freezed_annotation.dart';

part 'checkout_state.freezed.dart';

/// State machine for the PayPal checkout flow.
///
/// Transitions:
///   idle → creatingOrder → awaitingApproval → capturing → success / failure
@freezed
sealed class CheckoutState with _$CheckoutState {
  /// Initial state before any action is taken.
  const factory CheckoutState.idle() = CheckoutIdle;

  /// POST /checkout/create is in-flight.
  const factory CheckoutState.creatingOrder() = CheckoutCreatingOrder;

  /// Order created; waiting for user to approve in PayPal then tap confirm.
  const factory CheckoutState.awaitingApproval({
    required String orderId,
    required String approvalUrl,
    required String purchaseId,
  }) = CheckoutAwaitingApproval;

  /// POST /checkout/capture is in-flight.
  const factory CheckoutState.capturing({
    required String orderId,
    required String purchaseId,
  }) = CheckoutCapturing;

  /// Backend returned verified == true.
  const factory CheckoutState.success({
    required String transactionId,
  }) = CheckoutSuccess;

  /// Any failure — network, server, or verified == false.
  const factory CheckoutState.failure({
    required String message,
  }) = CheckoutFailure;
}
