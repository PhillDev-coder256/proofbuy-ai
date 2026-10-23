import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/theme.dart';
import '../../core/networking/repositories_providers.dart';
import '../../core/widgets/error_widget.dart';
import '../../core/widgets/shimmer_widgets.dart';
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

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _filter = 'All';

  static const _filters = ['All', 'Completed', 'Pending', 'Failed'];

  List<HistoryItem> _applyFilter(List<HistoryItem> items) {
    if (_filter == 'All') return items;
    final statusMap = {
      'Completed': 'captured',
      'Pending': 'pending',
      'Failed': 'failed',
    };
    final status = statusMap[_filter] ?? '';
    return items
        .where((item) => item.purchaseRecord.status == status)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(_historyProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Orders',
          style: pjs(
            size: 18,
            weight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: historyAsync.when(
        loading: () => const HistoryShimmer(),
        error: (error, _) => ProofBuyErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(_historyProvider),
        ),
        data: (items) {
          final filtered = _applyFilter(items);
          return Column(
            children: [
              // Filter chips
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.map((label) {
                      final active = _filter == label;
                      return GestureDetector(
                        onTap: () => setState(() => _filter = label),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 7),
                          decoration: BoxDecoration(
                            color: active
                                ? const Color(0xFF1D4ED8)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: active
                                ? null
                                : Border.all(
                                    color: const Color(0xFFE5E7EB)),
                          ),
                          child: Text(
                            label,
                            style: pjs(
                              size: 13,
                              weight: FontWeight.w600,
                              color: active
                                  ? Colors.white
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // List
              Expanded(
                child: filtered.isEmpty
                    ? _EmptyState(onShop: () => context.go('/brief'))
                    : RefreshIndicator(
                        onRefresh: () async =>
                            ref.invalidate(_historyProvider),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            return _OrderCard(item: filtered[index]);
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Order card
// ---------------------------------------------------------------------------

class _OrderCard extends ConsumerWidget {
  const _OrderCard({required this.item});

  final HistoryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final record = item.purchaseRecord;
    final status = record.status;
    final productName = item.product?.name ?? 'Unknown product';
    final merchant = item.product?.merchant ?? '';
    final imageUrl = item.product?.imageUrl;
    final formattedDate =
        DateFormat('MMM d, y').format(record.createdAt.toLocal());
    final formattedAmount =
        '${record.amount.toStringAsFixed(2)} ${record.currency}';

    // Status badge colours
    final Color badgeBg;
    final Color badgeText;
    final String badgeLabel;
    switch (status) {
      case 'captured':
        badgeBg = const Color(0xFFDCFCE7);
        badgeText = const Color(0xFF16A34A);
        badgeLabel = 'Completed';
      case 'failed':
        badgeBg = const Color(0xFFFEE2E2);
        badgeText = const Color(0xFFDC2626);
        badgeLabel = 'Failed';
      default:
        badgeBg = const Color(0xFFFEF9C3);
        badgeText = const Color(0xFFD97706);
        badgeLabel = 'Pending';
    }

    return GestureDetector(
      onTap: status == 'captured'
          ? () => context.go('/transaction/${record.id}')
          : null,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 12,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorWidget: (ctx, _, __) => _ImageFallback(),
                    )
                  : _ImageFallback(),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: pjs(
                      size: 14,
                      weight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (merchant.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      merchant,
                      style: pjs(
                          size: 12, color: const Color(0xFF94A3B8)),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: pjs(
                        size: 11, color: const Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Amount + badge + arrow
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formattedAmount,
                  style: pjs(
                    size: 14,
                    weight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badgeLabel,
                    style: pjs(
                      size: 11,
                      weight: FontWeight.w700,
                      color: badgeText,
                    ),
                  ),
                ),
                if (status == 'captured') ...[
                  const SizedBox(height: 4),
                  const Icon(Icons.chevron_right_rounded,
                      size: 18, color: Color(0xFF9CA3AF)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.shopping_bag_outlined,
          size: 28, color: Color(0xFF94A3B8)),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onShop});

  final VoidCallback onShop;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Color(0xFFD1D5DB),
          ),
          const SizedBox(height: 16),
          Text(
            'No orders yet',
            style: pjs(
              size: 18,
              weight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start shopping to see your orders here.',
            style: pjs(size: 14, color: const Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onShop,
            child: Text(
              'Start Shopping',
              style: pjs(
                  size: 15,
                  weight: FontWeight.w700,
                  color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
