import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../features/product_comparison/constraint_badge.dart';
import '../../shared/models/ranked_product.dart';

/// Shows a summary of the selected [RankedProduct] before the user commits
/// to a PayPal payment.
///
/// The [RankedProduct] is retrieved from [GoRouterState.extra].  If it is
/// unavailable, a short error message is displayed instead.
class PurchaseReviewScreen extends StatelessWidget {
  const PurchaseReviewScreen({
    super.key,
    required this.productResultId,
  });

  final String productResultId;

  @override
  Widget build(BuildContext context) {
    final product = GoRouterState.of(context).extra as RankedProduct?;

    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Purchase Review')),
        body: const Center(child: Text('Product details unavailable.')),
      );
    }

    return _PurchaseReviewView(
      product: product,
      productResultId: product.productResultId ?? productResultId,
    );
  }
}

class _PurchaseReviewView extends StatelessWidget {
  const _PurchaseReviewView({
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

    // Collect UNKNOWN constraints for the warning banner.
    final unknownKeys = product.constraintResults.entries
        .where((e) => e.value.toUpperCase() == 'UNKNOWN')
        .map((e) => e.key)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Purchase Review')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // UNKNOWN warning banner
            if (unknownKeys.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'The following attributes could not be verified: '
                        '${unknownKeys.join(', ')}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),

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

            const SizedBox(height: 24),

            // Constraint verification section
            Text(
              'Constraint Verification',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...product.constraintResults.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: Text(e.key)),
                    ConstraintBadge(attribute: e.key, result: e.value),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Estimated total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Estimated Total',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  priceText.isNotEmpty ? priceText : '—',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Confirm and Pay button
            ElevatedButton(
              onPressed: () => context.go(
                '/checkout/$productResultId',
                extra: product,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003087), // PayPal blue
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Confirm and Pay with PayPal'),
            ),
            const SizedBox(height: 12),

            // Cancel button
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
