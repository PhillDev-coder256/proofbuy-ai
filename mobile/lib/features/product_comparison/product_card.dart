import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../shared/models/ranked_product.dart';
import 'constraint_badge.dart';

/// A card displaying summary information about a [RankedProduct].
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  final RankedProduct product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final data = product.productData;
    final theme = Theme.of(context);

    // Format price string.
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

    // Take up to the first 3 constraint results.
    final badges = product.constraintResults.entries.take(3).toList();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: data.imageUrl != null && data.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: data.imageUrl!,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _ImagePlaceholder(),
                      errorWidget: (context, url, error) =>
                          _ImagePlaceholder(),
                    )
                  : _ImagePlaceholder(),
            ),
            const SizedBox(height: 12),

            // Product name
            Text(
              data.name,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // Merchant
            if (data.merchant != null && data.merchant!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                data.merchant!,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: Colors.grey[600]),
              ),
            ],

            // Price
            if (priceText.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                priceText,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],

            const SizedBox(height: 8),

            // Ranking score bar
            Row(
              children: [
                Text(
                  'Match score:',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: LinearProgressIndicator(
                    value: product.rankingScore.clamp(0.0, 1.0),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(product.rankingScore * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),

            // Constraint badges
            if (badges.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: badges
                    .map((e) => ConstraintBadge(
                          attribute: e.key,
                          result: e.value,
                        ))
                    .toList(),
              ),
            ],

            // View details button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onTap,
                child: const Text('View Details'),
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
      height: 160,
      width: double.infinity,
      color: Colors.grey[200],
      child: const Icon(Icons.shopping_bag, size: 48, color: Colors.grey),
    );
  }
}
