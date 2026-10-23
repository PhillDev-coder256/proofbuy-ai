import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/theme.dart';
import '../../features/product_comparison/constraint_badge.dart';
import '../../shared/models/ranked_product.dart';
import '../product_details/selected_product_provider.dart';

/// Shows a summary of the selected [RankedProduct] before committing
/// to a verified PayPal payment.
class PurchaseReviewScreen extends ConsumerWidget {
  const PurchaseReviewScreen({
    super.key,
    required this.productResultId,
  });

  final String productResultId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final extraProduct = GoRouterState.of(context).extra as RankedProduct?;
    final storedProduct = ref.watch(selectedProductProvider);
    final product = extraProduct ?? storedProduct;

    if (product == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            'Purchase Review',
            style: pjs(
              size: 18,
              weight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Center(
          child: Text(
            'Product details unavailable.',
            style: pjs(size: 15, color: const Color(0xFF64748B)),
          ),
        ),
      );
    }

    return _PurchaseReviewView(
      product: product,
      productResultId: product.productResultId ?? productResultId,
    );
  }
}

class _PurchaseReviewView extends ConsumerWidget {
  const _PurchaseReviewView({
    required this.product,
    required this.productResultId,
  });

  final RankedProduct product;
  final String productResultId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = product.productData;

    // Format price
    String priceText = '';
    if (data.price != null) {
      try {
        final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
        priceText = fmt.format(data.price);
      } catch (_) {
        priceText = '\$${data.price}'.trim();
      }
    }

    // Collect UNKNOWN constraints
    final unknownKeys = product.constraintResults.entries
        .where((e) => e.value.toUpperCase() == 'UNKNOWN')
        .map((e) => e.key)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Purchase Review',
          style: pjs(
            size: 18,
            weight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Unverified Warning Banner
              if (unknownKeys.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Color(0xFFD97706), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Unverified attributes: ${unknownKeys.join(', ')}. Review before confirming.',
                          style: pjs(
                            size: 12.5,
                            color: const Color(0xFF92400E),
                            height: 1.4,
                            weight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Product Card Summary
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.name,
                      style: pjs(
                        size: 18,
                        weight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),

                    if (priceText.isNotEmpty)
                      Text(
                        priceText,
                        style: pjs(
                          size: 24,
                          weight: FontWeight.w800,
                          color: const Color(0xFF2563EB),
                          letterSpacing: -0.5,
                        ),
                      ),

                    if (data.merchant != null && data.merchant!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.store_outlined,
                              size: 14, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Text(
                            'Sold & verified by ${data.merchant}',
                            style: pjs(
                              size: 12.5,
                              color: const Color(0xFF64748B),
                              weight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Constraint Verification
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Constraint Verification',
                      style: pjs(
                        size: 15,
                        weight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...product.constraintResults.entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                e.key,
                                style: pjs(
                                  size: 13,
                                  color: const Color(0xFF334155),
                                  weight: FontWeight.w500,
                                ),
                              ),
                            ),
                            ConstraintBadge(attribute: e.key, result: e.value),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Total Summary
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFDBEAFE)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Estimated Total',
                      style: pjs(
                        size: 15,
                        weight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      priceText.isNotEmpty ? priceText : '—',
                      style: pjs(
                        size: 20,
                        weight: FontWeight.w800,
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Confirm and Pay button
              GestureDetector(
                onTap: () {
                  ref.read(selectedProductProvider.notifier).select(product);
                  context.go(
                    '/checkout/$productResultId',
                    extra: product,
                  );
                },
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(27),
                    color: const Color(0xFF0070BA), // Official PayPal Blue
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x300070BA),
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.payment_rounded,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        'Confirm & Pay with PayPal',
                        style: pjs(
                          size: 16,
                          weight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () => context.pop(),
                child: Text(
                  'Cancel',
                  style: pjs(
                    size: 14,
                    weight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
