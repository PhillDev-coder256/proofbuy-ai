import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/theme.dart';
import '../../shared/models/ranked_product.dart';
import 'constraint_badge.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  final RankedProduct product;
  final VoidCallback onTap;

  static const _symbols = {
    'USD': '\$', 'EUR': '€', 'GBP': '£', 'JPY': '¥',
    'CAD': 'CA\$', 'AUD': 'A\$', 'KES': 'KSh', 'NGN': '₦',
    'GHS': '₵', 'ZAR': 'R', 'INR': '₹', 'CNY': '¥',
  };

  String _formatPrice(double price, String? currency) {
    final code = (currency ?? 'USD').toUpperCase();
    final symbol = _symbols[code] ?? '$code ';
    if (price >= 1000) {
      return '$symbol${NumberFormat('#,##0.00').format(price)}';
    }
    return '$symbol${price.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final data = product.productData;
    final allConstraints = product.constraintResults.entries.toList();
    final passes = allConstraints.where((e) => e.value == 'PASS').length;
    final fails = allConstraints.where((e) => e.value == 'FAIL').length;
    final unknowns = allConstraints.where((e) => e.value == 'UNKNOWN').length;

    final priceText = data.price != null
        ? _formatPrice(data.price!, data.currency)
        : null;

    final specs = data.specs ?? {};
    final description = specs['description'] as String?;
    final features = specs['features'];
    final featureList = features is List
        ? features.cast<String>().take(4).toList()
        : <String>[];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
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
            // ── Product image ─────────────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: _ProductImage(imageUrl: data.imageUrl),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Name + merchant ─────────────────────────────────────
                  Text(
                    data.name,
                    style: pjs(
                      size: 16,
                      weight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (data.merchant != null && data.merchant!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.store_outlined,
                            size: 13, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            data.merchant!,
                            style: pjs(
                              size: 12,
                              color: const Color(0xFF64748B),
                              weight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 12),

                  // ── Price + match score ─────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (priceText != null)
                        Text(
                          priceText,
                          style: pjs(
                            size: 20,
                            weight: FontWeight.w800,
                            color: const Color(0xFF2563EB),
                            letterSpacing: -0.3,
                          ),
                        ),
                      const Spacer(),
                      _MatchScorePill(score: product.rankingScore),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── Constraint summary chips ────────────────────────────
                  if (allConstraints.isNotEmpty) ...[
                    Row(
                      children: [
                        if (passes > 0) _SummaryChip(
                          count: passes,
                          label: 'Passed',
                          color: ProofBuyColors.pass,
                          icon: Icons.check_circle_rounded,
                        ),
                        if (fails > 0) ...[
                          const SizedBox(width: 6),
                          _SummaryChip(
                            count: fails,
                            label: 'Failed',
                            color: ProofBuyColors.fail,
                            icon: Icons.cancel_rounded,
                          ),
                        ],
                        if (unknowns > 0) ...[
                          const SizedBox(width: 6),
                          _SummaryChip(
                            count: unknowns,
                            label: 'Unknown',
                            color: ProofBuyColors.unknown,
                            icon: Icons.help_outline_rounded,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Detail badges
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: allConstraints
                          .map((e) => ConstraintBadge(
                                attribute: e.key,
                                result: e.value,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // ── Description ─────────────────────────────────────────
                  if (description != null && description.isNotEmpty) ...[
                    Text(
                      description,
                      style: pjs(
                        size: 12.5,
                        color: const Color(0xFF475569),
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                  ],

                  // ── Key features ────────────────────────────────────────
                  if (featureList.isNotEmpty) ...[
                    Text(
                      'Key Features',
                      style: pjs(
                        size: 12,
                        weight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...featureList.map((f) => Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 6),
                                child: Icon(Icons.circle,
                                    size: 4, color: Color(0xFF2563EB)),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  f,
                                  style: pjs(
                                    size: 12,
                                    color: const Color(0xFF475569),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 10),
                  ],

                  // ── AI explanation ──────────────────────────────────────
                  if (product.explanation != null &&
                      product.explanation!.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFDBEAFE)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.auto_awesome_rounded,
                              size: 14, color: Color(0xFF2563EB)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              product.explanation!,
                              style: pjs(
                                size: 11.5,
                                color: const Color(0xFF1E293B),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // ── View Details button ─────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: onTap,
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(23),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'View Specs & Purchase',
                              style: pjs(
                                size: 14,
                                weight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward_rounded,
                                size: 16, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Product image
// ─────────────────────────────────────────────────────────────────────────────

class _ProductImage extends StatelessWidget {
  const _ProductImage({this.imageUrl});
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _Fallback();
    }
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      height: 200,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(
        height: 200,
        color: const Color(0xFFF1F5F9),
        child: const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF2563EB),
            ),
          ),
        ),
      ),
      errorWidget: (_, __, ___) => _Fallback(),
    );
  }
}

class _Fallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      color: const Color(0xFFF1F5F9),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_bag_outlined,
              size: 48, color: Color(0xFF94A3B8)),
          const SizedBox(height: 6),
          Text(
            'Product Preview',
            style: pjs(size: 11, color: const Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}

class _MatchScorePill extends StatelessWidget {
  const _MatchScorePill({required this.score});
  final double score;

  Color get _color {
    if (score >= 0.75) return ProofBuyColors.pass;
    if (score >= 0.45) return ProofBuyColors.unknown;
    return ProofBuyColors.fail;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 12, color: _color),
          const SizedBox(width: 3),
          Text(
            '${(score * 100).toStringAsFixed(0)}% match',
            style: pjs(
              size: 11,
              weight: FontWeight.w700,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.count,
    required this.label,
    required this.color,
    required this.icon,
  });
  final int count;
  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            '$count $label',
            style: pjs(size: 11, weight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}
