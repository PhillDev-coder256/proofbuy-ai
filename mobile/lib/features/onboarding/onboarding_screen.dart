import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Page data
// ─────────────────────────────────────────────────────────────────────────────

class _OnboardPage {
  const _OnboardPage({
    required this.titlePlain,
    required this.titleHighlight,
    required this.titleHighlightAtEnd,
    required this.subtitle,
    required this.imageAsset,
    required this.features,
  });

  final String titlePlain;
  final String titleHighlight;
  final bool titleHighlightAtEnd;
  final String subtitle;
  final String imageAsset;
  final List<_Feature> features;
}

class _Feature {
  const _Feature({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String subtitle;
}

const _pages = [
  _OnboardPage(
    titlePlain: 'Shop Smarter\nwith ',
    titleHighlight: 'AI',
    titleHighlightAtEnd: true,
    subtitle:
        'Tell us what you need, and let ProofBuy AI\nfind the best products with real evidence\nand secure PayPal checkout.',
    imageAsset: 'assets/images/onboarder-image.png',
    features: [
      _Feature(
        icon: Icons.auto_awesome_rounded,
        iconBgColor: Color(0xFFE0E7FF),
        iconColor: Color(0xFF2563EB),
        title: 'AI-Powered Recommendations',
        subtitle: 'Describe what you need in natural language.',
      ),
      _Feature(
        icon: Icons.fact_check_outlined,
        iconBgColor: Color(0xFFDBEAFE),
        iconColor: Color(0xFF1D4ED8),
        title: 'Real Product Evidence',
        subtitle: 'Compare specifications, prices and sources.',
      ),
      _Feature(
        icon: Icons.shield_outlined,
        iconBgColor: Color(0xFFD1FAE5),
        iconColor: Color(0xFF059669),
        title: 'Secure Checkout with PayPal',
        subtitle: 'Buy confidently with trusted payments.',
      ),
    ],
  ),
  _OnboardPage(
    titlePlain: 'Evidence-\nBacked ',
    titleHighlight: 'Proof',
    titleHighlightAtEnd: true,
    subtitle:
        'Every recommendation shows exactly why it\nmatches your needs — verified specs, live\nprices, and source links.',
    imageAsset: 'assets/images/onboarder-image.png',
    features: [
      _Feature(
        icon: Icons.verified_outlined,
        iconBgColor: Color(0xFFE0E7FF),
        iconColor: Color(0xFF2563EB),
        title: 'Verified Constraints',
        subtitle: 'PASS, FAIL, or UNKNOWN — never guessed.',
      ),
      _Feature(
        icon: Icons.link_rounded,
        iconBgColor: Color(0xFFDBEAFE),
        iconColor: Color(0xFF1D4ED8),
        title: 'Source Attribution',
        subtitle: 'Every spec links back to the original listing.',
      ),
      _Feature(
        icon: Icons.refresh_rounded,
        iconBgColor: Color(0xFFD1FAE5),
        iconColor: Color(0xFF059669),
        title: 'Live Product Data',
        subtitle: 'Prices and availability updated in real time.',
      ),
    ],
  ),
  _OnboardPage(
    titlePlain: 'Pay with ',
    titleHighlight: 'PayPal',
    titleHighlightAtEnd: true,
    subtitle:
        'Complete your purchase through a verified\nPayPal checkout — server-confirmed, never\nsimulated.',
    imageAsset: 'assets/images/onboarder-image.png',
    features: [
      _Feature(
        icon: Icons.lock_outline_rounded,
        iconBgColor: Color(0xFFE0E7FF),
        iconColor: Color(0xFF2563EB),
        title: 'Server-Side Verification',
        subtitle: 'Payment confirmed before we show success.',
      ),
      _Feature(
        icon: Icons.receipt_long_outlined,
        iconBgColor: Color(0xFFDBEAFE),
        iconColor: Color(0xFF1D4ED8),
        title: 'Full Transaction History',
        subtitle: 'Every purchase stored and reviewable.',
      ),
      _Feature(
        icon: Icons.cancel_outlined,
        iconBgColor: Color(0xFFFEF3C7),
        iconColor: Color(0xFFD97706),
        title: 'Safe Cancellation',
        subtitle: 'Cancel any time before capture is confirmed.',
      ),
    ],
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    } else {
      context.go('/signup');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: Column(
            children: [
              // ── Top bar: dots + Skip ───────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _PageDots(
                      count: _pages.length,
                      current: _currentPage,
                    ),
                    TextButton(
                      onPressed: () => context.go('/signup'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Skip',
                        style: pjs(
                          size: 15,
                          weight: FontWeight.w600,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Page content ───────────────────────────────────────────
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (_, i) => _PageContent(page: _pages[i]),
                ),
              ),

              // ── Bottom: Next button + page indicator ───────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Column(
                  children: [
                    _NextButton(
                      label: isLast ? 'Get Started' : 'Next',
                      onPressed: _next,
                    ),
                    const SizedBox(height: 16),
                    _BottomDots(
                      count: _pages.length,
                      current: _currentPage,
                    ),
                    const SizedBox(height: 4),
                  ],
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
// Page content
// ─────────────────────────────────────────────────────────────────────────────

class _PageContent extends StatelessWidget {
  const _PageContent({required this.page});
  final _OnboardPage page;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8),

          // Title
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: page.titlePlain,
                  style: pjs(
                    size: 30,
                    weight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    height: 1.18,
                    letterSpacing: -0.5,
                  ),
                ),
                TextSpan(
                  text: page.titleHighlight,
                  style: pjs(
                    size: 30,
                    weight: FontWeight.w800,
                    color: const Color(0xFF2563EB),
                    height: 1.18,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Subtitle
          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: pjs(
              size: 14,
              weight: FontWeight.w400,
              color: const Color(0xFF475569),
              height: 1.6,
            ),
          ),

          const SizedBox(height: 24),

          // Hero image
          _HeroImage(asset: page.imageAsset),

          const SizedBox(height: 28),

          // Feature rows
          ...page.features.asMap().entries.map((e) => Padding(
                padding: EdgeInsets.only(
                    bottom: e.key < page.features.length - 1 ? 12 : 0),
                child: _FeatureRow(feature: e.value),
              )),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero image
// ─────────────────────────────────────────────────────────────────────────────

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.asset});
  final String asset;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Container(
      width: screenWidth,
      height: screenWidth * 0.72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        asset,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder: (_, __, ___) => const _ImageFallback(),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F5F9),
      child: const Center(
        child: Icon(
          Icons.smart_toy_outlined,
          size: 80,
          color: Color(0xFF2563EB),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Feature row (clean card style with 1px border)
// ─────────────────────────────────────────────────────────────────────────────

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.feature});
  final _Feature feature;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${feature.title}. ${feature.subtitle}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon badge
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: feature.iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(feature.icon, color: feature.iconColor, size: 22),
            ),

            const SizedBox(width: 14),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feature.title,
                    style: pjs(
                      size: 14,
                      weight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    feature.subtitle,
                    style: pjs(
                      size: 12,
                      weight: FontWeight.w400,
                      color: const Color(0xFF64748B),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Chevron
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFCBD5E1),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Next / Get Started button
// ─────────────────────────────────────────────────────────────────────────────

class _NextButton extends StatelessWidget {
  const _NextButton({required this.label, required this.onPressed});
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
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x252563EB),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: pjs(
                  size: 16,
                  weight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 15,
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
// Pagination indicators
// ─────────────────────────────────────────────────────────────────────────────

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.current});
  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeInOut,
          width: active ? 24 : 8,
          height: 4,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFF2563EB)
                : const Color(0xFFCBD5E1),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _BottomDots extends StatelessWidget {
  const _BottomDots({required this.count, required this.current});
  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeInOut,
          width: active ? 20 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFF2563EB)
                : const Color(0xFFCBD5E1),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
