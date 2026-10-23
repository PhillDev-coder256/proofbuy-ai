import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/theme.dart';
import '../../core/networking/repositories_providers.dart';
import '../../core/widgets/error_widget.dart';
import '../../core/widgets/shimmer_widgets.dart';
import '../../shared/models/ranked_product.dart';
import '../../shared/models/shopping_session.dart';
import '../product_details/selected_product_provider.dart';
import '../product_search/product_search_screen.dart';
import 'product_card.dart';

part 'product_comparison_screen.g.dart';

@riverpod
class ProductComparisonNotifier extends _$ProductComparisonNotifier {
  @override
  Future<List<RankedProduct>> build(String sessionId) async {
    // Use in-memory cache if already populated by ProductSearchNotifier
    final cached = ref.read(cachedProductsProvider);
    if (cached != null && cached.isNotEmpty) return cached;
    return ref.read(productsRepositoryProvider).getProducts(sessionId);
  }
}

// Session provider for results screen
final _sessionForResultsProvider =
    FutureProvider.autoDispose.family<ShoppingSession, String>(
  (ref, id) => ref.read(shoppingRepositoryProvider).getSession(id),
);

// ─────────────────────────────────────────────────────────────────────────────
// ProductComparisonScreen
// ─────────────────────────────────────────────────────────────────────────────

class ProductComparisonScreen extends ConsumerStatefulWidget {
  const ProductComparisonScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  ConsumerState<ProductComparisonScreen> createState() =>
      _ProductComparisonScreenState();
}

class _ProductComparisonScreenState
    extends ConsumerState<ProductComparisonScreen> {
  final Set<String> _selectedIds = {};
  String _activeFilter = 'Top Matches';

  @override
  Widget build(BuildContext context) {
    final productsAsync =
        ref.watch(productComparisonProvider(widget.sessionId));
    final sessionAsync =
        ref.watch(_sessionForResultsProvider(widget.sessionId));

    // Show loading if products are loading
    if (productsAsync.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F6FF),
        body: SafeArea(child: ProductListShimmer()),
      );
    }

    // Show error from products (primary)
    if (productsAsync.hasError) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F6FF),
        body: ProofBuyErrorWidget(
          message: productsAsync.error.toString(),
          onRetry: () =>
              ref.invalidate(productComparisonProvider(widget.sessionId)),
        ),
      );
    }

    final products = productsAsync.value ?? [];
    final session = sessionAsync.value;

    // Sort
    List<RankedProduct> sorted;
    if (_activeFilter == 'Price') {
      sorted = [...products]
        ..sort((a, b) => (a.productData.price ?? 0)
            .compareTo(b.productData.price ?? 0));
    } else {
      sorted = [...products]
        ..sort((a, b) => b.rankingScore.compareTo(a.rankingScore));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FF),
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App bar row
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0A000000),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: Color(0xFF0A0E2E),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Product ',
                              style: pjs(
                                size: 22,
                                weight: FontWeight.bold,
                                color: const Color(0xFF0A0E2E),
                              ),
                            ),
                            TextSpan(
                              text: 'Results',
                              style: pjs(
                                size: 22,
                                weight: FontWeight.bold,
                                color: const Color(0xFF6C47FF),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Compare button
                      GestureDetector(
                        onTap: _selectedIds.length >= 2
                            ? () {
                                // Compare action placeholder
                              }
                            : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedIds.length >= 2
                                ? const Color(0xFF6C47FF)
                                : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.compare_arrows_rounded,
                                size: 14,
                                color: _selectedIds.length >= 2
                                    ? Colors.white
                                    : const Color(0xFF9CA3AF),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _selectedIds.isEmpty
                                    ? 'Compare'
                                    : '${_selectedIds.length} selected',
                                style: pjs(
                                  size: 12,
                                  weight: FontWeight.w600,
                                  color: _selectedIds.length >= 2
                                      ? Colors.white
                                      : const Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '${products.length} product${products.length == 1 ? '' : 's'} found for you',
                    style: pjs(
                        size: 13, color: const Color(0xFF6B7280)),
                  ),
                ),

                const SizedBox(height: 8),

                // Requirements chips from session
                if (session != null) ...[
                  SizedBox(
                    height: 36,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          ..._buildRequirementChips(session),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => context.go(
                                '/review-requirements/${widget.sessionId}'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color(0xFF6C47FF)),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.edit_outlined,
                                      size: 12,
                                      color: Color(0xFF6C47FF)),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Edit',
                                    style: pjs(
                                      size: 12,
                                      color: const Color(0xFF6C47FF),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // Filter pills
                SizedBox(
                  height: 36,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: ['Top Matches', 'Price', 'Brand', 'RAM', 'More']
                          .map((f) => _FilterPill(
                                label: f,
                                active: _activeFilter == f,
                                onTap: () =>
                                    setState(() => _activeFilter = f),
                              ))
                          .toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),

          // Product list
          Expanded(
            child: sorted.isEmpty
                ? Center(
                    child: Text(
                      'No products found.',
                      style:
                          pjs(size: 15, color: const Color(0xFF6B7280)),
                    ),
                  )
                : ListView(
                    children: sorted.asMap().entries.map((entry) {
                      final index = entry.key;
                      final product = entry.value;
                      final productId = product.productResultId ??
                          product.productData.channel3ProductId ??
                          index.toString();
                      return ProductCard(
                        product: product,
                        onTap: () {
                          ref.read(selectedProductProvider.notifier).select(product);
                          context.go(
                            '/product/$productId',
                            extra: product,
                          );
                        },
                      );
                    }).toList(),
                  ),
          ),

          // Bottom compare bar
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Text(
                  _selectedIds.isEmpty
                      ? 'Select products to compare'
                      : '${_selectedIds.length} selected',
                  style: pjs(
                    size: 13,
                    color: _selectedIds.isEmpty
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF0A0E2E),
                    weight: _selectedIds.isEmpty
                        ? FontWeight.w400
                        : FontWeight.w600,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _selectedIds.length >= 2 ? () {} : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: _selectedIds.length >= 2
                          ? ProofBuyGradients.button
                          : null,
                      color: _selectedIds.length < 2
                          ? const Color(0xFFF3F4F6)
                          : null,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Compare',
                      style: pjs(
                        size: 13,
                        weight: FontWeight.w600,
                        color: _selectedIds.length >= 2
                            ? Colors.white
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          _BottomNav(
            currentIndex: 1,
            sessionId: widget.sessionId,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRequirementChips(ShoppingSession session) {
    final reqs = session.requirementsJson ?? {};
    final chips = <Widget>[];

    for (final entry in reqs.entries.take(4)) {
      final val = entry.value;
      if (val == null) continue;
      chips.add(
        Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F3FF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${entry.key}: $val',
            style: pjs(size: 11, color: const Color(0xFF6C47FF)),
          ),
        ),
      );
    }
    return chips;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter pill
// ─────────────────────────────────────────────────────────────────────────────

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color:
              active ? const Color(0xFF6C47FF) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: active
              ? null
              : Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Text(
          label,
          style: pjs(
            size: 12,
            weight: FontWeight.w600,
            color: active ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom navigation bar
// ─────────────────────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex, required this.sessionId});

  final int currentIndex;
  final String sessionId;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_rounded, 'Home'),
      (Icons.search_rounded, 'Search'),
      (Icons.receipt_long_rounded, 'Orders'),
      (Icons.person_rounded, 'Profile'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(items.length, (i) {
            final (icon, label) = items[i];
            final active = i == currentIndex;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  switch (i) {
                    case 0:
                      context.go('/brief');
                      break;
                    case 1:
                      // Stay
                      break;
                    case 2:
                      context.go('/history');
                      break;
                    case 3:
                      context.go('/settings');
                      break;
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 22,
                        color: active
                            ? const Color(0xFF6C47FF)
                            : const Color(0xFF9CA3AF),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        label,
                        style: pjs(
                          size: 10,
                          weight: active
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: active
                              ? const Color(0xFF6C47FF)
                              : const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
