import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/widgets/shimmer_widgets.dart';
import 'checkout_provider.dart';
import 'checkout_state.dart';

/// Shown when the `proofbuy://checkout/return` deep link returns from PayPal.
///
/// Receives [token] (= PayPal orderId) and [payerId] from the URL query params.
/// Immediately triggers server-side capture and navigates to the result screen.
class CheckoutReturnScreen extends ConsumerStatefulWidget {
  const CheckoutReturnScreen({
    super.key,
    required this.token,
    required this.payerId,
  });

  /// PayPal order ID (passed as `token` query param by PayPal).
  final String token;

  /// PayPal payer ID (passed as `PayerID` query param by PayPal).
  final String payerId;

  @override
  ConsumerState<CheckoutReturnScreen> createState() =>
      _CheckoutReturnScreenState();
}

class _CheckoutReturnScreenState extends ConsumerState<CheckoutReturnScreen> {
  bool _captureCalled = false;

  @override
  void initState() {
    super.initState();
    // Trigger capture on the next frame so providers are ready.
    WidgetsBinding.instance.addPostFrameCallback((_) => _triggerCapture());
  }

  void _triggerCapture() {
    if (_captureCalled) return;
    _captureCalled = true;

    if (widget.token.isEmpty) {
      // No token — buyer may have arrived here manually. Go to brief.
      if (mounted) context.go('/brief');
      return;
    }

    // Get the purchase ID from the stored checkout state.
    final checkoutState = ref.read(checkoutProvider);
    String? purchaseId;

    if (checkoutState is CheckoutAwaitingApproval) {
      purchaseId = checkoutState.purchaseId;
    } else if (checkoutState is CheckoutCapturing) {
      // Already capturing — nothing to do; listener will navigate.
      return;
    } else if (checkoutState is CheckoutSuccess) {
      // Already done.
      if (mounted) context.go('/transaction/${checkoutState.transactionId}');
      return;
    }

    if (purchaseId == null) {
      // State was lost (app restart). Navigate to brief gracefully.
      if (mounted) {
        _showError('Could not find your purchase record. Please try again.');
      }
      return;
    }

    ref.read(checkoutProvider.notifier).captureOrder(widget.token, purchaseId);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: pjs(size: 13, color: Colors.white)),
        backgroundColor: const Color(0xFFEA4335),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.go('/brief');
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen for success → navigate to transaction result.
    ref.listen<CheckoutState>(checkoutProvider, (_, next) {
      if (next is CheckoutSuccess) {
        if (mounted) context.go('/transaction/${next.transactionId}');
      } else if (next is CheckoutFailure) {
        if (mounted) _showError(next.message);
      }
    });

    final state = ref.watch(checkoutProvider);
    final isCapturing = state is CheckoutCapturing || state is CheckoutAwaitingApproval;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: isCapturing ? _CapturingView() : _SuccessView(token: widget.token),
      ),
    );
  }
}

// ── Capturing (shimmer + animated label) ─────────────────────────────────────

class _CapturingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        // Animated header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              _AnimatedPayPalBadge(),
              const SizedBox(height: 24),
              Text(
                'Verifying with PayPal...',
                style: pjs(
                  size: 22,
                  weight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We\'re confirming your payment on PayPal\'s servers.\nThis usually takes a few seconds.',
                textAlign: TextAlign.center,
                style: pjs(
                  size: 14,
                  color: const Color(0xFF475569),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        const Expanded(child: TransactionShimmer()),
      ],
    );
  }
}

class _AnimatedPayPalBadge extends StatefulWidget {
  @override
  State<_AnimatedPayPalBadge> createState() => _AnimatedPayPalBadgeState();
}

class _AnimatedPayPalBadgeState extends State<_AnimatedPayPalBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.95, end: 1.05)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF003087),
          boxShadow: [
            BoxShadow(
              color: const Color(0x400070BA),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          Icons.account_balance_wallet_rounded,
          size: 38,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ── Fallback view when token is present but state lost ────────────────────────

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.token});
  final String token;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFD1FAE5),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 40,
              color: Color(0xFF059669),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Payment Approved!',
            textAlign: TextAlign.center,
            style: pjs(
              size: 22,
              weight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your PayPal approval is confirmed. We\'re finalizing your order.',
            textAlign: TextAlign.center,
            style: pjs(size: 14, color: const Color(0xFF475569), height: 1.5),
          ),
          const SizedBox(height: 8),
          if (token.isNotEmpty)
            Text(
              'Ref: $token',
              textAlign: TextAlign.center,
              style: pjs(size: 11, color: const Color(0xFF9CA3AF)),
            ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => context.go('/brief'),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                color: const Color(0xFF0070BA),
              ),
              child: Center(
                child: Text(
                  'Go to Home',
                  style: pjs(
                    size: 16,
                    weight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
