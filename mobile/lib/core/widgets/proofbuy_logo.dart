import 'package:flutter/material.dart';

/// Reusable ProofBuy AI logo widget.
///
/// Usage:
/// ```dart
/// // App bar (40px)
/// ProofBuyLogo(size: 40)
///
/// // Onboarding hero (120px)
/// ProofBuyLogo(size: 120, showGlow: true)
///
/// // Small inline (24px)
/// ProofBuyLogo(size: 24, showBadge: false)
/// ```
class ProofBuyLogo extends StatelessWidget {
  const ProofBuyLogo({
    super.key,
    this.size = 40,
    this.showBadge = true,
    this.showGlow = false,
  });

  /// Logical pixel size of the logo square.
  final double size;

  /// Whether to show the blue ✓ verification badge (bottom-right).
  final bool showBadge;

  /// Whether to add a purple ambient glow behind the logo.
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'ProofBuy AI logo',
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // Glow ring
          if (showGlow)
            Container(
              width: size + 20,
              height: size + 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x50A855F7),
                    blurRadius: 36,
                    spreadRadius: 6,
                  ),
                ],
              ),
            ),

          // Logo image — falls back to icon if asset missing
          Image.asset(
            'assets/images/logo.png',
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _FallbackLogo(size: size),
          ),

          // Blue verified badge
          if (showBadge)
            Container(
              width: size * 0.28,
              height: size * 0.28,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF2563EB),
              ),
              child: Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: size * 0.17,
              ),
            ),
        ],
      ),
    );
  }
}

/// Fallback shown when the logo asset can't be loaded.
class _FallbackLogo extends StatelessWidget {
  const _FallbackLogo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5B8EFF), Color(0xFF9333EA)],
        ),
      ),
      child: Icon(
        Icons.shopping_bag_outlined,
        color: Colors.white,
        size: size * 0.55,
      ),
    );
  }
}

/// Compact app bar title row — small logo + "ProofBuy AI" wordmark.
class ProofBuyAppBarTitle extends StatelessWidget {
  const ProofBuyAppBarTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const ProofBuyLogo(size: 28, showBadge: false, showGlow: false),
        const SizedBox(width: 8),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'ProofBuy ',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: 'AI',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF5B8EFF),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
