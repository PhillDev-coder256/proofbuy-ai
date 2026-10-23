import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme.dart';
import '../../features/product_comparison/constraint_badge.dart';
import '../../shared/models/ranked_product.dart';
import 'selected_product_provider.dart';

class ProductDetailsScreen extends ConsumerWidget {
  const ProductDetailsScreen({
    super.key,
    required this.productResultId,
  });

  final String productResultId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check GoRouter extra first, fall back to Riverpod selectedProductProvider
    final extraProduct = GoRouterState.of(context).extra as RankedProduct?;
    final storedProduct = ref.watch(selectedProductProvider);
    final product = extraProduct ?? storedProduct;

    if (product == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            'Product Details',
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

    return _ProductDetailsView(
      product: product,
      productResultId: product.productResultId ?? productResultId,
    );
  }
}

class _ProductDetailsView extends ConsumerWidget {
  const _ProductDetailsView({
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

    final specs = data.specs;
    final description = specs != null && specs['description'] is String
        ? specs['description'] as String
        : null;
    final features = specs != null && specs['features'] is List
        ? (specs['features'] as List).map((e) => e.toString()).toList()
        : <String>[];
    final techSpecs = specs != null
        ? specs.entries
            .where((e) => e.key != 'description' && e.key != 'features')
            .toList()
        : <MapEntry<String, dynamic>>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          data.name,
          style: pjs(
            size: 17,
            weight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero product image
              Container(
                decoration: BoxDecoration(
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: data.imageUrl != null && data.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: data.imageUrl!,
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => _ImagePlaceholder(),
                          errorWidget: (context, url, error) =>
                              _ImagePlaceholder(),
                        )
                      : _ImagePlaceholder(),
                ),
              ),
              const SizedBox(height: 20),

              // Product info card
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
                    // Product name 24px w800
                    Text(
                      data.name,
                      style: pjs(
                        size: 24,
                        weight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Price 22px w800 PayPal blue
                    if (priceText.isNotEmpty)
                      Text(
                        priceText,
                        style: pjs(
                          size: 22,
                          weight: FontWeight.w800,
                          color: const Color(0xFF2563EB),
                          letterSpacing: -0.3,
                        ),
                      ),

                    // Merchant row
                    if (data.merchant != null && data.merchant!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.store_outlined,
                              size: 14, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Text(
                            'Sold by ${data.merchant}',
                            style: pjs(
                              size: 12.5,
                              color: const Color(0xFF64748B),
                              weight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 14),

                    // Confidence bar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'AI Match Confidence',
                              style: pjs(
                                  size: 12, color: const Color(0xFF64748B)),
                            ),
                            Text(
                              '${(product.rankingConfidence * 100).toStringAsFixed(0)}%',
                              style: pjs(
                                size: 12,
                                weight: FontWeight.w700,
                                color: const Color(0xFF2563EB),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: product.rankingConfidence,
                            minHeight: 6,
                            backgroundColor: const Color(0xFFE2E8F0),
                            color: ProofBuyColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // AI Analysis Card
              if (product.explanation != null &&
                  product.explanation!.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFDBEAFE)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome_rounded,
                              size: 16, color: Color(0xFF2563EB)),
                          const SizedBox(width: 6),
                          Text(
                            'AI Match Analysis',
                            style: pjs(
                              size: 13,
                              weight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.explanation!,
                        style: pjs(
                          size: 12.5,
                          color: const Color(0xFF1E293B),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Description block
              if (description != null && description.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description',
                        style: pjs(
                          size: 13,
                          weight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: pjs(
                          size: 13,
                          color: const Color(0xFF475569),
                          height: 1.55,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Features list
              if (features.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Key Features',
                        style: pjs(
                          size: 13,
                          weight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...features.map(
                        (f) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.check_circle_outline_rounded,
                                size: 15,
                                color: Color(0xFF10B981),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  f,
                                  style: pjs(
                                    size: 13,
                                    color: const Color(0xFF334155),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Evidence Constraint Verification
              if (product.constraintResults.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verified Evidence Specs',
                        style: pjs(
                          size: 14,
                          weight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...product.constraintResults.entries.map(
                        (e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  e.key,
                                  style: pjs(
                                    size: 12.5,
                                    color: const Color(0xFF334155),
                                    weight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              ConstraintBadge(
                                attribute: e.key,
                                result: e.value,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Technical Specifications (expandable)
              if (techSpecs.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      'Technical Specifications',
                      style: pjs(
                        size: 14,
                        weight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: techSpecs.map((entry) {
                            return Container(
                              width: (MediaQuery.of(context).size.width -
                                      72) /
                                  2,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.key,
                                    style: pjs(
                                      size: 11,
                                      color: const Color(0xFF94A3B8),
                                      weight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    entry.value?.toString() ?? '—',
                                    style: pjs(
                                      size: 13,
                                      weight: FontWeight.w700,
                                      color: const Color(0xFF0F172A),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 28),

              // Buy with PayPal button
              GestureDetector(
                onTap: () {
                  ref.read(selectedProductProvider.notifier).select(product);
                  context.go('/review/$productResultId', extra: product);
                },
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(27),
                    color: const Color(0xFF0070BA), // PayPal Blue
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
                        'Buy with PayPal',
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

              // View on retailer site button
              if (data.sourceUrl != null && data.sourceUrl!.isNotEmpty) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final uri = Uri.parse(data.sourceUrl!);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: Text(
                    'View on retailer site',
                    style: pjs(size: 14, weight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      color: const Color(0xFFF1F5F9),
      child: const Center(
        child: Icon(Icons.shopping_bag_outlined,
            size: 56, color: Color(0xFF94A3B8)),
      ),
    );
  }
}
