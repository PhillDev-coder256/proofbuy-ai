import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
      appBar: AppBar(title: const Text('Payment Verified')),
      body: asyncTx.when(
        loading: () => const LoadingWidget(message: 'Loading transaction…'),
        error: (error, _) => ProofBuyErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(transactionResultProvider(purchaseId)),
        ),
        data: (tx) => _TransactionSuccessView(transaction: tx),
      ),
    );
  }
}

class _TransactionSuccessView extends StatelessWidget {
  const _TransactionSuccessView({required this.transaction});

  final AppTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final verifiedAtText = transaction.verifiedAt != null
        ? DateFormat.yMMMMd().add_jm().format(transaction.verifiedAt!)
        : '—';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Success icon
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 80,
          ),
          const SizedBox(height: 16),

          // Heading
          Text(
            'Payment Verified!',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Transaction details card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailRow(
                    label: 'Transaction ID',
                    value: transaction.id,
                  ),
                  const Divider(height: 20),
                  _DetailRow(
                    label: 'Status',
                    value: transaction.status.toUpperCase(),
                  ),
                  const Divider(height: 20),
                  _DetailRow(
                    label: 'Verified at',
                    value: verifiedAtText,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // View History button
          ElevatedButton(
            onPressed: () => context.go('/history'),
            child: const Text('View History'),
          ),
          const SizedBox(height: 12),

          // Back to Shopping button
          TextButton(
            onPressed: () => context.go('/brief'),
            child: const Text('Back to Shopping'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: Colors.grey[600]),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
