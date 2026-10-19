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

  // ── Currency symbol map ─────────────────────────────────────────────────
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

    // Description from specs
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
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
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
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Name + merchant ─────────────────────────────────────
                  Text(
                    data.name,
                    style: pjs(
                      size: 15,
                      weight: FontWeight.w700,
                      color: const Color(0xFF0A0E2E),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (data.merchant != null && data.merchant!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.store_outlined,
                            size: 12, color: Color(0xFF9CA3AF)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            data.merchant!,
                            style: pjs(
                                size: 12, color: const Color(0xFF9CA3AF)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 10),

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
                            color: const Color(0xFF6C47FF),
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
                          size: 12,
                          color: const Color(0xFF6B7280),
                          height: 1.5),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                  ],

                  // ── Key features ────────────────────────────────────────
                  if (featureList.isNotEmpty) ...[
                    Text('Key Features',
                        style: pjs(
                            size: 12,
                            weight: FontWeight.w700,
                            color: const Color(0xFF374151))),
                    const SizedBox(height: 6),
                    ...featureList.map((f) => Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 5),
                                child: Icon(Icons.circle,
                                    size: 5, color: Color(0xFF6C47FF)),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(f,
                                    style: pjs(
                                        size: 12,
                                        color: const Color(0xFF4B5563),
                                        height: 1.4)),
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
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F3FF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFFDDD6FE), width: 1),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.auto_awesome_rounded,
                              size: 14, color: Color(0xFF6C47FF)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              product.explanation!,
                              style: pjs(
                                  size: 11,
                                  color: const Color(0xFF4B5563),
                                  height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // ── Confidence indicator ────────────────────────────────
                  Row(
                    children: [
                      Text('Confidence:',
                          style: pjs(
                              size: 11, color: const Color(0xFF9CA3AF))),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: product.rankingConfidence.clamp(0.0, 1.0),
                            minHeight: 5,
                            backgroundColor: const Color(0xFFE5E7EB),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              product.rankingConfidence >= 0.7
                                  ? ProofBuyColors.pass
                                  : product.rankingConfidence >= 0.4
                                      ? ProofBuyColors.unknown
                                      : ProofBuyColors.fail,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(product.rankingConfidence * 100).toStringAsFixed(0)}%',
                        style: pjs(
                            size: 11,
                            weight: FontWeight.w600,
                            color: const Color(0xFF6B7280)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── View Details button ─────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: onTap,
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6C47FF), Color(0xFF9F6EFF)],
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('View Details',
                                style: pjs(
                                    size: 14,
                                    weight: FontWeight.w600,
                                    color: Colors.white)),
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
// Product image with loading + fallback
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
        color: const Color(0xFFF3F4F6),
        child: const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF6C47FF),
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
      color: const Color(0xFFF3F4F6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_bag_outlined,
              size: 48, color: Color(0xFFD1D5DB)),
          const SizedBox(height: 6),
          Text('No image',
              style: pjs(size: 11, color: const Color(0xFF9CA3AF))),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Match score pill
// ─────────────────────────────────────────────────────────────────────────────

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
                weight: FontWeight.w600,
                color: _color),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary chip (X Passed / X Failed / X Unknown)
// ─────────────────────────────────────────────────────────────────────────────

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
          Text('$count $label',
              style: pjs(
                  size: 11, weight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
