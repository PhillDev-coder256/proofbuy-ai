import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/networking/repositories_providers.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/error_widget.dart';
import '../../core/widgets/loading_widget.dart';
import '../../shared/models/history_item.dart';

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final _historyProvider = FutureProvider<List<HistoryItem>>((ref) {
  return ref.watch(transactionsRepositoryProvider).getHistory();
});

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(_historyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Purchase History')),
      body: historyAsync.when(
        loading: () => const LoadingWidget(),
        error: (error, _) => ProofBuyErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(_historyProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.receipt_long,
              message: 'No purchases yet',
            );
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _HistoryListTile(item: items[index]);
            },
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// List tile
// ---------------------------------------------------------------------------

class _HistoryListTile extends StatelessWidget {
  const _HistoryListTile({required this.item});

  final HistoryItem item;

  @override
  Widget build(BuildContext context) {
    final record = item.purchaseRecord;
    final status = record.status;

    final Icon statusIcon;
    switch (status) {
      case 'captured':
        statusIcon = const Icon(Icons.check_circle, color: Colors.green);
      case 'failed':
        statusIcon = const Icon(Icons.cancel, color: Colors.red);
      default:
        statusIcon = const Icon(Icons.hourglass_empty, color: Colors.amber);
    }

    final productName = item.product?.name ?? 'Unknown product';
    final formattedDate =
        DateFormat('MMM d, y').format(record.createdAt.toLocal());
    final formattedAmount =
        '${record.amount.toStringAsFixed(2)} ${record.currency}';

    return ListTile(
      leading: statusIcon,
      title: Text(productName),
      subtitle: Text(formattedDate),
      trailing: Text(formattedAmount),
      onTap: status == 'captured'
          ? () => context.go('/transaction/${record.id}')
          : null,
    );
  }
}
