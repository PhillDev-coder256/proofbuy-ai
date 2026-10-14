import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/widgets/error_widget.dart';
import '../../core/widgets/loading_widget.dart';
import '../../shared/models/ranked_product.dart';
import 'checkout_provider.dart';
import 'checkout_state.dart';

/// Drives the PayPal checkout flow.
///
/// On mount it immediately calls [CheckoutNotifier.createOrder] using the
/// [productResultId] extracted from [GoRouterState.extra].  Navigation to
/// the transaction result screen only happens from [CheckoutSuccess].
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({
    super.key,
    required this.purchaseId,
    required this.orderId,
  });

  /// The product-result id used to create the PayPal order.
  /// Kept for route compatibility; the real value comes from extras.
  final String purchaseId;

  /// Unused at construction time — the order is created by the notifier.
  final String orderId;

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  /// Whether [CheckoutNotifier.createOrder] has been called for this mount.
  bool _orderCreated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_orderCreated) {
      _orderCreated = true;
      // productResultId comes from GoRouter extras (a RankedProduct).
      final product = GoRouterState.of(context).extra as RankedProduct?;
      final productResultId =
          product?.productResultId ?? widget.purchaseId;
      // Defer provider modification until after the current build phase.
      // Riverpod 3.x disallows modifying providers inside lifecycle callbacks
      // that fire during the widget tree build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(checkoutProvider.notifier).createOrder(productResultId);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for success state and navigate to the transaction result screen.
    ref.listen<CheckoutState>(checkoutProvider, (_, next) {
      if (next is CheckoutSuccess) {
        context.go('/transaction/${next.transactionId}');
      }
    });

    final state = ref.watch(checkoutProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: _buildBody(context, ref, state),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, CheckoutState state) {
    return switch (state) {
      CheckoutIdle() || CheckoutCreatingOrder() =>
        const LoadingWidget(message: 'Creating PayPal order…'),

      CheckoutAwaitingApproval(:final orderId, :final approvalUrl, :final purchaseId) =>
        _AwaitingApprovalView(
          orderId: orderId,
          approvalUrl: approvalUrl,
          purchaseId: purchaseId,
        ),

      CheckoutCapturing() =>
        const LoadingWidget(message: 'Verifying payment…'),

      // Navigation is handled in ref.listen; render a brief loading state
      // to avoid a flash of empty content before the route change.
      CheckoutSuccess() =>
        const LoadingWidget(message: 'Payment verified!'),

      CheckoutFailure(:final message) => ProofBuyErrorWidget(
          message: message,
          onRetry: () {
            final product =
                GoRouterState.of(context).extra as RankedProduct?;
            final productResultId =
                product?.productResultId ?? widget.purchaseId;
            ref
                .read(checkoutProvider.notifier)
                .createOrder(productResultId);
          },
        ),
    };
  }
}

// ---------------------------------------------------------------------------
// Sub-widget: awaiting PayPal approval
// ---------------------------------------------------------------------------

class _AwaitingApprovalView extends ConsumerWidget {
  const _AwaitingApprovalView({
    required this.orderId,
    required this.approvalUrl,
    required this.purchaseId,
  });

  final String orderId;
  final String approvalUrl;
  final String purchaseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.payment, size: 64, color: Color(0xFF003087)),
          const SizedBox(height: 24),
          const Text(
            'Complete your payment in PayPal',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the button below to open PayPal and approve your purchase.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),

          // Open PayPal button
          ElevatedButton.icon(
            onPressed: () => launchUrl(
              Uri.parse(approvalUrl),
              mode: LaunchMode.externalApplication,
            ),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open PayPal to Approve'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF003087),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 16),

          // Confirm payment button — waits for explicit user tap.
          TextButton(
            onPressed: () => ref
                .read(checkoutProvider.notifier)
                .captureOrder(orderId, purchaseId),
            child: const Text("I've completed payment"),
          ),
        ],
      ),
    );
  }
}
