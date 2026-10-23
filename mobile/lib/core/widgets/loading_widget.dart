import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../app/theme.dart';
import 'shimmer_widgets.dart';

/// Generic full-screen loading widget.
///
/// Shows a labelled shimmer skeleton. The [type] controls which skeleton is
/// rendered. Defaults to [LoadingType.generic] for backwards compatibility.
enum LoadingType {
  generic,
  productList,
  productDetails,
  history,
  checkout,
  transaction,
  reviewRequirements,
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
    this.message,
    this.type = LoadingType.generic,
  });

  final String? message;
  final LoadingType type;

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      LoadingType.productList => const ProductListShimmer(),
      LoadingType.productDetails => const ProductDetailsShimmer(),
      LoadingType.history => const HistoryShimmer(),
      LoadingType.checkout => const CheckoutShimmer(),
      LoadingType.transaction => const TransactionShimmer(),
      LoadingType.reviewRequirements => const ReviewRequirementsShimmer(),
      LoadingType.generic => _GenericShimmer(message: message),
    };
  }
}

/// Generic shimmer: a simple card-list skeleton + optional message.
class _GenericShimmer extends StatelessWidget {
  const _GenericShimmer({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message != null) ...[
            // Animated label
            _PulsingLabel(message: message!),
            const SizedBox(height: 24),
          ],
          Shimmer.fromColors(
            baseColor: const Color(0xFFEFEFF4),
            highlightColor: const Color(0xFFFAFAFF),
            period: const Duration(milliseconds: 1200),
            child: Column(
              children: [
                _shimmerCard(height: 80),
                const SizedBox(height: 14),
                _shimmerCard(height: 80),
                const SizedBox(height: 14),
                _shimmerCard(height: 80),
                const SizedBox(height: 14),
                _shimmerCard(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerCard({required double height}) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

/// Animated "processing" label with a pulsing dots indicator.
class _PulsingLabel extends StatefulWidget {
  const _PulsingLabel({required this.message});
  final String message;

  @override
  State<_PulsingLabel> createState() => _PulsingLabelState();
}

class _PulsingLabelState extends State<_PulsingLabel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFEEEBFF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                size: 18, color: Color(0xFF6C47FF)),
          ),
          const SizedBox(width: 12),
          Text(
            widget.message,
            style: pjs(
              size: 14,
              weight: FontWeight.w600,
              color: const Color(0xFF6C47FF),
            ),
          ),
        ],
      ),
    );
  }
}
