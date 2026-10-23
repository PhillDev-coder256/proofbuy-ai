import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Design tokens
// ─────────────────────────────────────────────────────────────────────────────

const _shimmerBase  = Color(0xFFEFEFF4);
const _shimmerHigh  = Color(0xFFFAFAFF);
const _shimmerDark  = Color(0xFF2A2D4A);   // for dark-bg screens
const _shimmerDarkH = Color(0xFF3A3D5A);

/// Wraps [child] in a shimmer sweep.
///
/// Use [dark] = true on dark-background screens (e.g. the Analyzing screen).
class ProofShimmer extends StatelessWidget {
  const ProofShimmer({super.key, required this.child, this.dark = false});

  final Widget child;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor:  dark ? _shimmerDark  : _shimmerBase,
      highlightColor: dark ? _shimmerDarkH : _shimmerHigh,
      period: const Duration(milliseconds: 1200),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Primitive building blocks
// ─────────────────────────────────────────────────────────────────────────────

/// A rounded rectangle placeholder.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 8,
    this.color,
  });

  final double width;
  final double height;
  final double radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? _shimmerBase,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// A full-width shimmer line.
class ShimmerLine extends StatelessWidget {
  const ShimmerLine({
    super.key,
    this.widthFraction = 1.0,
    this.height = 14,
    this.radius = 6,
  });

  final double widthFraction;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) => ShimmerBox(
        width: c.maxWidth * widthFraction,
        height: height,
        radius: radius,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen-specific shimmer skeletons
// ─────────────────────────────────────────────────────────────────────────────

/// Product comparison list skeleton — 3 horizontal product cards.
class ProductListShimmer extends StatelessWidget {
  const ProductListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ProofShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Requirements chips row
            Row(children: [
              ShimmerBox(width: 80, height: 28, radius: 14),
              const SizedBox(width: 8),
              ShimmerBox(width: 100, height: 28, radius: 14),
              const SizedBox(width: 8),
              ShimmerBox(width: 70, height: 28, radius: 14),
            ]),
            const SizedBox(height: 16),
            // Filter pills
            Row(children: [
              ShimmerBox(width: 110, height: 36, radius: 18),
              const SizedBox(width: 8),
              ShimmerBox(width: 70, height: 36, radius: 18),
              const SizedBox(width: 8),
              ShimmerBox(width: 70, height: 36, radius: 18),
            ]),
            const SizedBox(height: 20),
            _ProductCardSkeleton(),
            _ProductCardSkeleton(),
            _ProductCardSkeleton(),
          ],
        ),
      ),
    );
  }
}

class _ProductCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: const Color(0x08000000), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ShimmerBox(width: 80, height: 80, radius: 12),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerLine(widthFraction: 0.85, height: 15),
                    const SizedBox(height: 8),
                    const ShimmerLine(widthFraction: 0.65, height: 12),
                    const SizedBox(height: 8),
                    const ShimmerLine(widthFraction: 0.45, height: 12),
                    const SizedBox(height: 10),
                    Row(children: [
                      ShimmerBox(width: 70, height: 24, radius: 12),
                      const SizedBox(width: 8),
                      ShimmerBox(width: 70, height: 24, radius: 12),
                    ]),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Explanation strip
          ShimmerBox(width: double.infinity, height: 44, radius: 10),
        ],
      ),
    );
  }
}

/// Product details screen skeleton.
class ProductDetailsShimmer extends StatelessWidget {
  const ProductDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ProofShimmer(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image
            ShimmerBox(width: double.infinity, height: 250, radius: 0),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  const ShimmerLine(widthFraction: 0.9, height: 22),
                  const SizedBox(height: 8),
                  const ShimmerLine(widthFraction: 0.6, height: 18),
                  const SizedBox(height: 16),
                  // Price + merchant row
                  Row(children: [
                    ShimmerBox(width: 100, height: 32, radius: 8),
                    const SizedBox(width: 12),
                    ShimmerBox(width: 120, height: 24, radius: 12),
                  ]),
                  const SizedBox(height: 24),
                  // Specs grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 3.5,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: List.generate(
                      6,
                      (_) => ShimmerBox(width: double.infinity, height: 40, radius: 10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Description lines
                  const ShimmerLine(widthFraction: 1.0),
                  const SizedBox(height: 6),
                  const ShimmerLine(widthFraction: 0.95),
                  const SizedBox(height: 6),
                  const ShimmerLine(widthFraction: 0.8),
                  const SizedBox(height: 24),
                  // Buy button
                  ShimmerBox(width: double.infinity, height: 54, radius: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Home / shopping brief hero skeleton shown while first load.
class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ProofShimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(width: 200, height: 28, radius: 8),
                      const SizedBox(height: 8),
                      ShimmerBox(width: 160, height: 20, radius: 8),
                      const SizedBox(height: 8),
                      const ShimmerLine(widthFraction: 0.9, height: 13),
                      const SizedBox(height: 4),
                      const ShimmerLine(widthFraction: 0.75, height: 13),
                    ],
                  ),
                ),
                ShimmerBox(width: 100, height: 100, radius: 20),
              ],
            ),
            const SizedBox(height: 20),
            ShimmerBox(width: double.infinity, height: 90, radius: 20),
            const SizedBox(height: 20),
            Row(
              children: List.generate(
                4,
                (i) => Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ShimmerBox(width: 85, height: 36, radius: 18),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                ShimmerBox(width: 120, height: 18, radius: 6),
                const Spacer(),
                ShimmerBox(width: 70, height: 18, radius: 6),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: List.generate(
                3,
                (_) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ShimmerBox(width: double.infinity, height: 130, radius: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// History / orders list skeleton.
class HistoryShimmer extends StatelessWidget {
  const HistoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ProofShimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Filter chips
            Row(children: [
              ShimmerBox(width: 50, height: 32, radius: 16),
              const SizedBox(width: 8),
              ShimmerBox(width: 90, height: 32, radius: 16),
              const SizedBox(width: 8),
              ShimmerBox(width: 70, height: 32, radius: 16),
              const SizedBox(width: 8),
              ShimmerBox(width: 60, height: 32, radius: 16),
            ]),
            const SizedBox(height: 16),
            ...[1, 2, 3, 4].map((_) => _HistoryCardSkeleton()),
          ],
        ),
      ),
    );
  }
}

class _HistoryCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: const Color(0x08000000), blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          ShimmerBox(width: 60, height: 60, radius: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerLine(widthFraction: 0.75, height: 14),
                const SizedBox(height: 6),
                const ShimmerLine(widthFraction: 0.5, height: 12),
                const SizedBox(height: 6),
                Row(children: [
                  ShimmerBox(width: 70, height: 22, radius: 11),
                  const SizedBox(width: 8),
                  ShimmerBox(width: 80, height: 14, radius: 6),
                ]),
              ],
            ),
          ),
          ShimmerBox(width: 24, height: 24, radius: 12),
        ],
      ),
    );
  }
}

/// PayPal checkout creating-order skeleton.
class CheckoutShimmer extends StatelessWidget {
  const CheckoutShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ProofShimmer(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 12),
            ShimmerBox(width: double.infinity, height: 180, radius: 20),
            const SizedBox(height: 24),
            ShimmerBox(width: double.infinity, height: 54, radius: 27),
            const SizedBox(height: 16),
            ShimmerBox(width: double.infinity, height: 50, radius: 25),
            const SizedBox(height: 28),
            ShimmerBox(width: 220, height: 16, radius: 8),
          ],
        ),
      ),
    );
  }
}

/// Transaction result screen loading skeleton.
class TransactionShimmer extends StatelessWidget {
  const TransactionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ProofShimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShimmerBox(width: 96, height: 96, radius: 48),
            const SizedBox(height: 24),
            ShimmerBox(width: 240, height: 28, radius: 10),
            const SizedBox(height: 12),
            ShimmerBox(width: 280, height: 16, radius: 8),
            const SizedBox(height: 32),
            ShimmerBox(width: double.infinity, height: 120, radius: 20),
            const SizedBox(height: 24),
            ShimmerBox(width: double.infinity, height: 54, radius: 16),
            const SizedBox(height: 12),
            ShimmerBox(width: double.infinity, height: 50, radius: 16),
          ],
        ),
      ),
    );
  }
}

/// Review requirements screen loading skeleton.
class ReviewRequirementsShimmer extends StatelessWidget {
  const ReviewRequirementsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ProofShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            ShimmerBox(width: double.infinity, height: 70, radius: 16),
            const SizedBox(height: 24),
            ShimmerBox(width: 180, height: 20, radius: 8),
            const SizedBox(height: 12),
            ...[1, 2, 3, 4, 5].map((_) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ShimmerBox(width: double.infinity, height: 58, radius: 14),
            )),
            const SizedBox(height: 20),
            ShimmerBox(width: double.infinity, height: 54, radius: 30),
          ],
        ),
      ),
    );
  }
}
