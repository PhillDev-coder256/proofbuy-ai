import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme.dart';
import '../../core/widgets/error_widget.dart';
import '../../core/widgets/loading_widget.dart';
import '../../shared/models/ranked_product.dart';
import '../product_details/selected_product_provider.dart';
import 'checkout_provider.dart';
import 'checkout_state.dart';

/// Drives the PayPal checkout flow.
///
/// On mount it immediately calls [CheckoutNotifier.createOrder] using the
/// [productResultId] extracted from [GoRouterState.extra] or [selectedProductProvider].
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({
    super.key,
    required this.purchaseId,
    required this.orderId,
  });

  final String purchaseId;
  final String orderId;

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _orderCreated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_orderCreated) {
      _orderCreated = true;
      final extraProduct = GoRouterState.of(context).extra as RankedProduct?;
      final storedProduct = ref.read(selectedProductProvider);
      final product = extraProduct ?? storedProduct;
      final productResultId =
          product?.productResultId ?? widget.purchaseId;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(checkoutProvider.notifier).createOrder(productResultId);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<CheckoutState>(checkoutProvider, (_, next) {
      if (next is CheckoutSuccess) {
        context.go('/transaction/${next.transactionId}');
      }
    });

    final state = ref.watch(checkoutProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'PayPal Checkout',
          style: pjs(
            size: 18,
            weight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: _buildBody(context, ref, state),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, CheckoutState state) {
    return switch (state) {
      CheckoutIdle() || CheckoutCreatingOrder() =>
        const LoadingWidget(message: 'Creating PayPal Sandbox order…'),

      CheckoutAwaitingApproval(:final orderId, :final approvalUrl, :final purchaseId) =>
        _AwaitingApprovalView(
          orderId: orderId,
          approvalUrl: approvalUrl,
          purchaseId: purchaseId,
        ),

      CheckoutCapturing() =>
        const LoadingWidget(message: 'Verifying payment on PayPal servers…'),

      CheckoutSuccess() =>
        const LoadingWidget(message: 'Payment verified! Navigating…'),

      CheckoutFailure(:final message) => ProofBuyErrorWidget(
          message: message,
          onRetry: () {
            final extraProduct =
                GoRouterState.of(context).extra as RankedProduct?;
            final storedProduct = ref.read(selectedProductProvider);
            final product = extraProduct ?? storedProduct;
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

  Future<void> _launchPayPalUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      try {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Please authorize in browser: $url',
                style: pjs(size: 12, color: Colors.white),
              ),
              backgroundColor: const Color(0xFF0070BA),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),

          // PayPal Banner Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // PayPal Badge Icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFDBEAFE)),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 32,
                    color: Color(0xFF0070BA),
                  ),
                ),
                const SizedBox(height: 18),

                Text(
                  'Complete Payment with PayPal',
                  textAlign: TextAlign.center,
                  style: pjs(
                    size: 20,
                    weight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'Tap below to open PayPal Sandbox, log in, and authorize your purchase securely.',
                  textAlign: TextAlign.center,
                  style: pjs(
                    size: 13.5,
                    color: const Color(0xFF475569),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),

                // Order ID Tag
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    'Order Ref: $orderId',
                    style: pjs(
                      size: 12,
                      weight: FontWeight.w600,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Primary Open PayPal Button
          GestureDetector(
            onTap: () => _launchPayPalUrl(context, approvalUrl),
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(27),
                color: const Color(0xFF0070BA), // Official PayPal Blue
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x300070BA),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.open_in_new_rounded,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Open PayPal to Approve',
                    style: pjs(
                      size: 16,
                      weight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Secondary Confirm Payment Button
          OutlinedButton(
            onPressed: () => ref
                .read(checkoutProvider.notifier)
                .captureOrder(orderId, purchaseId),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              "I've completed payment",
              style: pjs(
                size: 15,
                weight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Security Shield Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shield_outlined,
                  size: 16, color: Color(0xFF059669)),
              const SizedBox(width: 6),
              Text(
                'Server-Side Verification • PayPal Protection',
                style: pjs(
                  size: 12,
                  weight: FontWeight.w600,
                  color: const Color(0xFF059669),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
