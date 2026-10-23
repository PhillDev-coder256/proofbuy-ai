import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/theme.dart';
import '../../core/networking/repositories_providers.dart';
import '../../core/widgets/error_widget.dart';
import '../../core/widgets/loading_widget.dart';
import '../../shared/models/app_transaction.dart';

part 'transaction_result_screen.g.dart';

/// Fetches the [AppTransaction] for the given [transactionId].
///
/// This provider is only called after [CheckoutScreen] confirms that the
/// backend returned `verified == true`.  Do NOT navigate to this screen
/// from any other path.
@riverpod
Future<AppTransaction> transactionResult(
  Ref ref,
  String transactionId,
) async {
  return ref
      .read(transactionsRepositoryProvider)
      .getTransaction(transactionId);
}

/// Displays the verified transaction details after a successful PayPal payment.
///
/// IMPORTANT: Only reachable from [CheckoutScreen] when it is in
/// [CheckoutSuccess] state — i.e. the backend has verified the payment.
class TransactionResultScreen extends ConsumerWidget {
  const TransactionResultScreen({super.key, required this.purchaseId});

  /// The `transactionId` returned by the backend capture endpoint.
  final String purchaseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTx = ref.watch(transactionResultProvider(purchaseId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Payment Confirmed',
          style: pjs(
            size: 18,
            weight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: asyncTx.when(
        loading: () => const LoadingWidget(message: 'Loading transaction…'),
        error: (error, _) => ProofBuyErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(transactionResultProvider(purchaseId)),
        ),
        data: (tx) => _AnimatedSuccessView(transaction: tx),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated success view
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedSuccessView extends StatefulWidget {
  const _AnimatedSuccessView({required this.transaction});

  final AppTransaction transaction;

  @override
  State<_AnimatedSuccessView> createState() => _AnimatedSuccessViewState();
}

class _AnimatedSuccessViewState extends State<_AnimatedSuccessView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _controller.forward());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tx = widget.transaction;

    final verifiedAtText = tx.verifiedAt != null
        ? DateFormat.yMMMMd().add_jm().format(tx.verifiedAt!)
        : '—';

    final createdAtText =
        DateFormat.yMMMMd().add_jm().format(tx.createdAt);

    final shortId = tx.id.length > 8
        ? '${tx.id.substring(0, min(8, tx.id.length))}...'
        : tx.id;

    final isCapture = tx.status.toLowerCase() == 'captured';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Animated success circle
          Center(
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: ProofBuyColors.pass,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 44,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Heading
          Text(
            'Payment Successful!',
            textAlign: TextAlign.center,
            style: pjs(
              size: 24,
              weight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            'Your order is confirmed and payment has been captured.',
            textAlign: TextAlign.center,
            style: pjs(size: 14, color: const Color(0xFF64748B)),
          ),
          const SizedBox(height: 28),

          // Transaction details card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _DetailRow(
                  label: 'Transaction ID',
                  value: shortId,
                ),
                const Divider(height: 24, color: Color(0xFFE2E8F0)),
                _DetailRow(
                  label: 'Status',
                  value: tx.status.toUpperCase(),
                  valueColor: isCapture
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFD97706),
                ),
                const Divider(height: 24, color: Color(0xFFE2E8F0)),
                _DetailRow(
                  label: 'Verified',
                  value: verifiedAtText,
                ),
                const Divider(height: 24, color: Color(0xFFE2E8F0)),
                _DetailRow(
                  label: 'Created',
                  value: createdAtText,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Continue Shopping button
          ElevatedButton(
            onPressed: () => context.go('/brief'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ProofBuyColors.primary,
            ),
            child: Text(
              'Continue Shopping',
              style: pjs(
                  size: 16,
                  weight: FontWeight.w700,
                  color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),

          // View Order History button
          TextButton(
            onPressed: () => context.go('/history'),
            child: Text(
              'View Order History',
              style: pjs(
                size: 14,
                weight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: pjs(size: 13, color: const Color(0xFF64748B)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: pjs(
              size: 13,
              weight: FontWeight.w600,
              color: valueColor ?? const Color(0xFF0F172A),
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
