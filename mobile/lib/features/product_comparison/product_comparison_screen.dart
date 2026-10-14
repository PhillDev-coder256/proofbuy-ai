import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/networking/repositories_providers.dart';
import '../../core/widgets/error_widget.dart';
import '../../core/widgets/loading_widget.dart';
import '../../shared/models/ranked_product.dart';
import 'product_card.dart';

part 'product_comparison_screen.g.dart';

@riverpod
class ProductComparisonNotifier extends _$ProductComparisonNotifier {
  @override
  Future<List<RankedProduct>> build(String sessionId) async {
    return ref.read(productsRepositoryProvider).getProducts(sessionId);
  }
}

class ProductComparisonScreen extends ConsumerWidget {
  const ProductComparisonScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productComparisonProvider(sessionId));

    return Scaffold(
      appBar: AppBar(title: const Text('Product Results')),
      body: state.when(
        loading: () => const LoadingWidget(message: 'Loading products...'),
        error: (error, _) => ProofBuyErrorWidget(
          message: error.toString(),
          onRetry: () => ref
              .invalidate(productComparisonProvider(sessionId)),
        ),
        data: (products) {
          if (products.isEmpty) {
            return const Center(child: Text('No products found.'));
          }
          // Sort by rankingScore descending.
          final sorted = [...products]
            ..sort((a, b) => b.rankingScore.compareTo(a.rankingScore));

          return ListView.builder(
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final product = sorted[index];
              return ProductCard(
                product: product,
                onTap: () => context.go(
                  '/product/${product.productResultId ?? product.productData.channel3ProductId ?? index.toString()}',
                  extra: product,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
