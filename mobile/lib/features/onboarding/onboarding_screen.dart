import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();

    // Force dark status bar icons on the gradient background
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: ProofBuyColors.gradientTop,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Stack(
          children: [
            // ── Background gradient ───────────────────────────────────────
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: ProofBuyGradients.screen,
                ),
              ),
            ),

            // ── Ambient glow blobs ────────────────────────────────────────
            Positioned(
              top: size.height * 0.18,
              left: -60,
              child: _GlowBlob(
                color: const Color(0x40A855F7),
                size: 220,
              ),
            ),
            Positioned(
              top: size.height * 0.28,
              right: -40,
              child: _GlowBlob(
                color: const Color(0x304285F4),
                size: 180,
              ),
            ),

            // ── Main content ──────────────────────────────────────────────
            SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.sizeOf(context).height -
                        MediaQuery.paddingOf(context).top -
                        MediaQuery.paddingOf(context).bottom,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Skip button
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8, right: 20),
                      child: TextButton(
                        onPressed: () => context.go('/brief'),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Skip',
                          style: ProofBuyTextStyles.skipLabel,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Hero area ─────────────────────────────────────────
                  FadeTransition(
                    opacity: _fadeIn,
                    child: SlideTransition(
                      position: _slideUp,
                      child: Column(
                        children: [
                          // Logo
                          _LogoBadge(size: size.height * 0.11),

                          const SizedBox(height: 20),

                          // Brand name
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'ProofBuy ',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                TextSpan(
                                  text: 'AI',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF5B8EFF),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            'Smarter Shopping. Real Evidence.\nSecure with PayPal.',
                            textAlign: TextAlign.center,
                            style: ProofBuyTextStyles.heroSubtitle,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Product showcase ──────────────────────────────────
                  FadeTransition(
                    opacity: _fadeIn,
                    child: _ProductShowcase(height: size.height * 0.24),
                  ),

                  const SizedBox(height: 20),

                  // ── Feature rows ──────────────────────────────────────
                  FadeTransition(
                    opacity: _fadeIn,
                    child: SlideTransition(
                      position: _slideUp,
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            _FeatureRow(
                              icon: Icons.auto_awesome_rounded,
                              iconColor: const Color(0xFF818CF8),
                              title: 'AI-Powered Recommendations',
                              subtitle:
                                  'Find the right products for your needs',
                            ),
                            const SizedBox(height: 12),
                            _FeatureRow(
                              icon: Icons.fact_check_outlined,
                              iconColor: const Color(0xFF34D399),
                              title: 'Real Product Evidence',
                              subtitle:
                                  'Verified specs, prices and sources',
                            ),
                            const SizedBox(height: 12),
                            _FeatureRow(
                              icon: Icons.shield_outlined,
                              iconColor: const Color(0xFF38BDF8),
                              title: 'Secure Checkout with PayPal',
                              subtitle: 'Buy confidently and safely',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // ── CTA ───────────────────────────────────────────────
                  FadeTransition(
                    opacity: _fadeIn,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          _GradientButton(
                            label: 'Get Started',
                            onPressed: () => context.go('/brief'),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.55),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.go('/brief'),
                                child: const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF5B8EFF),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
                    ),  // Column
                  ),  // IntrinsicHeight
                ),  // ConstrainedBox
              ),  // SingleChildScrollView
            ),  // SafeArea
          ],
        ),
      ),
    );
  }
}// ─────────────────────────────────────────────────────────────────────────────

class _LogoBadge extends StatelessWidget {
  const _LogoBadge({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Outer glow ring
        Container(
          width: size + 16,
          height: size + 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0x60A855F7),
                blurRadius: 40,
                spreadRadius: 8,
              ),
            ],
          ),
        ),
        // White circular container
        Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/logo.png',
              width: size,
              height: size,
              fit: BoxFit.cover,
              // Graceful fallback if asset not found
              errorBuilder: (_, __, ___) => Container(
                width: size,
                height: size,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF5B8EFF), Color(0xFF9333EA)],
                  ),
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.white,
                  size: size * 0.5,
                ),
              ),
            ),
          ),
        ),
        // Blue verified checkmark badge
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Product showcase — platform with product images on a lit stage
// ─────────────────────────────────────────────────────────────────────────────

class _ProductShowcase extends StatelessWidget {
  const _ProductShowcase({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Stage platform glow
          Positioned(
            bottom: 0,
            child: Container(
              width: 280,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x80A855F7),
                    blurRadius: 30,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          // Stage ellipse
          Positioned(
            bottom: 4,
            child: Container(
              width: 260,
              height: 18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                ),
              ),
            ),
          ),

          // Product icons arranged in an arc
          // Left: headphones
          Positioned(
            left: 20,
            bottom: 18,
            child: _ProductIcon(
              icon: Icons.headphones_rounded,
              size: height * 0.58,
              rotation: -0.15,
              color: const Color(0xFF1E293B),
            ),
          ),
          // Centre: laptop
          Positioned(
            bottom: 22,
            child: _ProductIcon(
              icon: Icons.laptop_mac_rounded,
              size: height * 0.72,
              rotation: 0,
              color: const Color(0xFF1E293B),
            ),
          ),
          // Right: smartwatch
          Positioned(
            right: 60,
            bottom: 30,
            child: _ProductIcon(
              icon: Icons.watch_rounded,
              size: height * 0.45,
              rotation: 0.1,
              color: const Color(0xFF1E293B),
            ),
          ),
          // Far right: shoe
          Positioned(
            right: 10,
            bottom: 18,
            child: _ProductIcon(
              icon: Icons.sports_basketball_rounded,
              size: height * 0.38,
              rotation: 0.18,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductIcon extends StatelessWidget {
  const _ProductIcon({
    required this.icon,
    required this.size,
    required this.color,
    this.rotation = 0,
  });

  final IconData icon;
  final double size;
  final Color color;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.18),
          color: color,
          boxShadow: [
            BoxShadow(
              color: const Color(0x40000000),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.9),
              color,
            ],
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.85),
          size: size * 0.55,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Feature row — icon badge + title + subtitle
// ─────────────────────────────────────────────────────────────────────────────

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title. $subtitle',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: ProofBuyGradients.card,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.07),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: iconColor.withValues(alpha: 0.15),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),

            const SizedBox(width: 14),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: ProofBuyTextStyles.featureTitle),
                  const SizedBox(height: 2),
                  Text(subtitle, style: ProofBuyTextStyles.featureSubtitle),
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
// Gradient CTA button
// ─────────────────────────────────────────────────────────────────────────────

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: ProofBuyGradients.button,
            boxShadow: [
              BoxShadow(
                color: const Color(0x609333EA),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Get Started', style: ProofBuyTextStyles.buttonLabel),
              const SizedBox(width: 10),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Glow blob — ambient light effect
// ─────────────────────────────────────────────────────────────────────────────

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}
