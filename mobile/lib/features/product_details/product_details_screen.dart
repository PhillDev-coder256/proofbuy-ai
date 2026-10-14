import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../features/product_comparison/constraint_badge.dart';
import '../../shared/models/ranked_product.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({
    super.key,
    required this.productResultId,
  });

  /// The ProductResult DB id (used as fallback if extra is unavailable).
  final String productResultId;

  @override
  Widget build(BuildContext context) {
    // RankedProduct is passed via GoRouter extras.
    final product = GoRouterState.of(context).extra as RankedProduct?;

    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product Details')),
        body: const Center(child: Text('Product not found.')),
      );
    }

    return _ProductDetailsView(
      product: product,
      productResultId:
          product.productResultId ?? productResultId,
    );
  }
}

class _ProductDetailsView extends StatelessWidget {
  const _ProductDetailsView({
    required this.product,
    required this.productResultId,
  });

  final RankedProduct product;
  final String productResultId;

  @override
  Widget build(BuildContext context) {
    final data = product.productData;
    final theme = Theme.of(context);

    // Format price.
    String priceText = '';
    if (data.price != null) {
      final currency = data.currency ?? 'USD';
      try {
        final fmt = NumberFormat.currency(symbol: currency, decimalDigits: 2);
        priceText = fmt.format(data.price);
      } catch (_) {
        priceText = '${data.currency ?? ''} ${data.price}'.trim();
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(data.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: data.imageUrl != null && data.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: data.imageUrl!,
                      height: 200,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _ImagePlaceholder(),
                      errorWidget: (context, url, error) =>
                          _ImagePlaceholder(),
                    )
                  : _ImagePlaceholder(),
            ),
            const SizedBox(height: 16),

            // Product name
            Text(
              data.name,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Price
            if (priceText.isNotEmpty)
              Text(
                priceText,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),

            // Merchant
            if (data.merchant != null && data.merchant!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Sold by ${data.merchant}',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: Colors.grey[700]),
              ),
            ],

            const SizedBox(height: 16),

            // Confidence
            Text(
              'Confidence: ${(product.rankingConfidence * 100).toStringAsFixed(0)}%',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: Colors.grey[700]),
            ),

            const SizedBox(height: 16),

            // AI Explanation card
            if (product.explanation != null &&
                product.explanation!.isNotEmpty) ...[
              Card(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Analysis',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.explanation!,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Evidence section
            if (product.constraintResults.isNotEmpty) ...[
              Text(
                'Evidence',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...product.constraintResults.entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Expanded(child: Text(e.key)),
                      ConstraintBadge(
                        attribute: e.key,
                        result: e.value,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Specifications expansion tile
            if (data.specs != null && data.specs!.isNotEmpty)
              ExpansionTile(
                title: const Text('Specifications'),
                children: data.specs!.entries
                    .map(
                      (e) => ListTile(
                        dense: true,
                        title: Text(e.key.toString()),
                        trailing: Text(
                          e.value.toString(),
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    )
                    .toList(),
              ),

            const SizedBox(height: 24),

            // Buy with PayPal button
            ElevatedButton.icon(
              onPressed: () => context.go('/review/$productResultId'),
              icon: const Icon(Icons.payment),
              label: const Text('Buy with PayPal'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF003087), // PayPal blue
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      color: Colors.grey[200],
      child: const Icon(Icons.shopping_bag, size: 64, color: Colors.grey),
    );
  }
}
