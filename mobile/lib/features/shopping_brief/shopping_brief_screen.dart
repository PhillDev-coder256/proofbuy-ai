import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../features/auth/auth_repository.dart';
import 'shopping_brief_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data
// ─────────────────────────────────────────────────────────────────────────────

class _QuickCategory {
  const _QuickCategory({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class _ExampleSearch {
  const _ExampleSearch({
    required this.image,
    required this.query,
    required this.bgColor,
  });
  final IconData image;
  final String query;
  final Color bgColor;
}

class _FeaturedCategory {
  const _FeaturedCategory({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.iconColor,
  });
  final IconData icon;
  final String label;
  final Color bgColor;
  final Color iconColor;
}

const _quickCategories = [
  _QuickCategory(icon: Icons.laptop_mac_rounded, label: 'Laptop'),
  _QuickCategory(icon: Icons.smartphone_rounded, label: 'Phone'),
  _QuickCategory(icon: Icons.headphones_rounded, label: 'Headphones'),
  _QuickCategory(icon: Icons.camera_alt_outlined, label: 'Camera'),
  _QuickCategory(icon: Icons.more_horiz_rounded, label: 'More'),
];

const _examples = [
  _ExampleSearch(
    image: Icons.laptop_mac_rounded,
    query: 'A gaming laptop under \$1200 with 16GB RAM',
    bgColor: Color(0xFFEEEBFF),
  ),
  _ExampleSearch(
    image: Icons.headphones_rounded,
    query: 'Noise cancelling headphones for travel',
    bgColor: Color(0xFFF0F9FF),
  ),
  _ExampleSearch(
    image: Icons.smartphone_rounded,
    query: 'A good smartphone for photography under \$800',
    bgColor: Color(0xFFFFF7ED),
  ),
];

const _featured = [
  _FeaturedCategory(
    icon: Icons.laptop_mac_rounded,
    label: 'Laptops',
    bgColor: Color(0xFFEEEBFF),
    iconColor: Color(0xFF6C47FF),
  ),
  _FeaturedCategory(
    icon: Icons.smartphone_rounded,
    label: 'Phones',
    bgColor: Color(0xFFE8F4FF),
    iconColor: Color(0xFF1A73E8),
  ),
  _FeaturedCategory(
    icon: Icons.headphones_rounded,
    label: 'Headphones',
    bgColor: Color(0xFFF0F9FF),
    iconColor: Color(0xFF0EA5E9),
  ),
  _FeaturedCategory(
    icon: Icons.camera_alt_outlined,
    label: 'Cameras',
    bgColor: Color(0xFFFFF7ED),
    iconColor: Color(0xFFEA6335),
  ),
  _FeaturedCategory(
    icon: Icons.watch_rounded,
    label: 'Smartwatches',
    bgColor: Color(0xFFE6F9F0),
    iconColor: Color(0xFF16A34A),
  ),
  _FeaturedCategory(
    icon: Icons.cable_rounded,
    label: 'Accessories',
    bgColor: Color(0xFFF5F5F5),
    iconColor: Color(0xFF6B7280),
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class ShoppingBriefScreen extends ConsumerStatefulWidget {
  const ShoppingBriefScreen({super.key});

  @override
  ConsumerState<ShoppingBriefScreen> createState() =>
      _ShoppingBriefScreenState();
}

class _ShoppingBriefScreenState extends ConsumerState<ShoppingBriefScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit([String? override]) {
    final text = override ?? _controller.text.trim();
    if (text.length < 10) return;
    _focusNode.unfocus();
    if (override != null) _controller.text = override;
    ref.read(shoppingBriefProvider.notifier).submitBrief(text);
  }

  @override
  Widget build(BuildContext context) {
    final notifierState = ref.watch(shoppingBriefProvider);
    final isLoading = notifierState is AsyncLoading;
    final user = ref.watch(currentUserProvider);
    final firstName = user?.fullName.split(' ').first ?? 'there';

    ref.listen<AsyncValue<dynamic>>(shoppingBriefProvider, (_, next) {
      next.whenOrNull(
        data: (session) {
          if (session != null) {
            _controller.clear();
            context.go('/loading/${session.id}');
          }
        },
        error: (e, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString(),
                  style: pjs(size: 13, color: Colors.white)),
              backgroundColor: const Color(0xFFEA4335),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FF),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: Column(
            children: [
              // ── App bar ─────────────────────────────────────────────────
              _HomeAppBar(firstName: firstName),

              // ── Scrollable content ──────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // ── Hero row ───────────────────────────────────────
                      _HeroRow(firstName: firstName),
                      const SizedBox(height: 24),

                      // ── Search box ─────────────────────────────────────
                      _SearchBox(
                        controller: _controller,
                        focusNode: _focusNode,
                        isLoading: isLoading,
                        onSubmit: _submit,
                      ),
                      const SizedBox(height: 20),

                      // ── Quick categories ───────────────────────────────
                      _QuickCategories(
                        onTap: (label) {
                          _controller.text = '$label ';
                          _focusNode.requestFocus();
                        },
                      ),
                      const SizedBox(height: 28),

                      // ── Try an example ─────────────────────────────────
                      _SectionHeader(
                        title: 'Try an example',
                        actionLabel: 'See more',
                        onAction: () {},
                      ),
                      const SizedBox(height: 12),
                      _ExampleCards(onTap: _submit),
                      const SizedBox(height: 28),

                      // ── Featured categories ────────────────────────────
                      _SectionHeader(
                        title: 'Featured Categories',
                        actionLabel: 'View all',
                        onAction: () {},
                      ),
                      const SizedBox(height: 12),
                      _FeaturedGrid(),
                      const SizedBox(height: 28),

                      // ── Why ProofBuy AI ────────────────────────────────
                      _WhySection(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // ── Bottom nav ──────────────────────────────────────────────
              _BottomNav(
                currentIndex: _navIndex,
                onTap: (i) {
                  setState(() => _navIndex = i);
                  if (i == 1) context.go('/results/search');
                  if (i == 2) context.go('/history');
                  if (i == 3) context.go('/settings');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App bar
// ─────────────────────────────────────────────────────────────────────────────

class _HomeAppBar extends StatelessWidget {
  const _HomeAppBar({required this.firstName});
  final String firstName;

  @override
  Widget build(BuildContext context) {
    final initials = firstName.isNotEmpty
        ? firstName.substring(0, 1).toUpperCase()
        : '?';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Logo + wordmark
          Image.asset('assets/images/logo.png', width: 36, height: 36,
              errorBuilder: (_, __, ___) => Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFF6C47FF),
                    ),
                    child: const Icon(Icons.shopping_bag_outlined,
                        color: Colors.white, size: 20),
                  )),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: 'ProofBuy ',
                      style: pjs(
                          size: 16,
                          weight: FontWeight.w800,
                          color: const Color(0xFF0A0E2E))),
                  TextSpan(
                      text: 'AI',
                      style: pjs(
                          size: 16,
                          weight: FontWeight.w800,
                          color: const Color(0xFF6C47FF))),
                ]),
              ),
              Text('Shop Smarter. Real Evidence.',
                  style: pjs(
                      size: 10,
                      color: const Color(0xFF9CA3AF),
                      weight: FontWeight.w400)),
            ],
          ),

          const Spacer(),

          // Notification bell
          Stack(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 6,
                        offset: Offset(0, 2))
                  ],
                ),
                child: const Icon(Icons.notifications_outlined,
                    size: 20, color: Color(0xFF0A0E2E)),
              ),
              Positioned(
                top: 7,
                right: 7,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFEA4335),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 10),

          // Avatar
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF6C47FF), Color(0xFF9F6EFF)],
              ),
            ),
            child: Center(
              child: Text(initials,
                  style: pjs(
                      size: 14,
                      weight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero row
// ─────────────────────────────────────────────────────────────────────────────

class _HeroRow extends StatelessWidget {
  const _HeroRow({required this.firstName});
  final String firstName;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text block — takes remaining space
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Give the text enough vertical room to not fight the image
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: 'Hello, $firstName! ',
                    style: pjs(
                      size: 22,
                      weight: FontWeight.w800,
                      color: const Color(0xFF0A0E2E),
                      height: 1.25,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const TextSpan(
                    text: '👋',
                    style: TextStyle(fontSize: 20),
                  ),
                ]),
              ),
              const SizedBox(height: 8),
              Text(
                "Tell me what you want to buy, and I'll\nfind the best products with real evidence\nand secure PayPal checkout.",
                style: pjs(
                    size: 13,
                    color: const Color(0xFF6B7280),
                    height: 1.6),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Robot illustration — fixed size, right-aligned
        SizedBox(
          width: 100,
          height: 100,
          child: Image.asset(
            'assets/images/home-image.png',
            width: 100,
            height: 100,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFEEEBFF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.smart_toy_outlined,
                  size: 48, color: Color(0xFF6C47FF)),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search box
// ─────────────────────────────────────────────────────────────────────────────

class _SearchBox extends StatefulWidget {
  const _SearchBox({
    required this.controller,
    required this.focusNode,
    required this.isLoading,
    required this.onSubmit,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLoading;
  final void Function([String?]) onSubmit;

  @override
  State<_SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<_SearchBox> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.trim().length >= 10;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A6C47FF),
              blurRadius: 16,
              offset: Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 2),
            child: Text('What would you like to shop for?',
                style: pjs(
                    size: 11,
                    weight: FontWeight.w500,
                    color: const Color(0xFF9CA3AF))),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  minLines: 1,
                  maxLines: 4,
                  maxLength: 500,
                  style: pjs(
                      size: 14,
                      color: const Color(0xFF0A0E2E),
                      weight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText:
                        'e.g. "A laptop for video editing under \$1000\nwith 16GB RAM and good battery life"',
                    hintStyle: pjs(
                        size: 13, color: const Color(0xFFD1D5DB), height: 1.5),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 14),
                    counterText: '',
                  ),
                  enabled: !widget.isLoading,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => widget.onSubmit(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10, bottom: 10),
                child: Row(
                  children: [
                    // Mic button
                    _CircleIconBtn(
                      icon: Icons.mic_outlined,
                      color: const Color(0xFF9CA3AF),
                      bgColor: const Color(0xFFF5F5F5),
                      size: 38,
                      onTap: () {},
                    ),
                    const SizedBox(width: 8),
                    // Send button
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: _CircleIconBtn(
                        icon: widget.isLoading
                            ? Icons.hourglass_empty_rounded
                            : Icons.arrow_forward_rounded,
                        color: Colors.white,
                        bgColor: hasText
                            ? const Color(0xFF6C47FF)
                            : const Color(0xFFD1D5DB),
                        size: 42,
                        onTap: hasText && !widget.isLoading
                            ? () => widget.onSubmit()
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleIconBtn extends StatelessWidget {
  const _CircleIconBtn({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.size,
    this.onTap,
  });
  final IconData icon;
  final Color color;
  final Color bgColor;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
        child: Icon(icon, color: color, size: size * 0.45),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick category chips
// ─────────────────────────────────────────────────────────────────────────────

class _QuickCategories extends StatelessWidget {
  const _QuickCategories({required this.onTap});
  final void Function(String label) onTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _quickCategories.map((c) {
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => onTap(c.label),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x08000000),
                        blurRadius: 4,
                        offset: Offset(0, 2))
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(c.icon, size: 15, color: const Color(0xFF6C47FF)),
                    const SizedBox(width: 6),
                    Text(c.label,
                        style: pjs(
                            size: 13,
                            weight: FontWeight.w500,
                            color: const Color(0xFF374151))),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section header
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: pjs(
                size: 16,
                weight: FontWeight.w700,
                color: const Color(0xFF0A0E2E))),
        GestureDetector(
          onTap: onAction,
          child: Row(
            children: [
              Text(actionLabel,
                  style: pjs(
                      size: 13,
                      weight: FontWeight.w500,
                      color: const Color(0xFF6C47FF))),
              const Icon(Icons.chevron_right_rounded,
                  size: 16, color: Color(0xFF6C47FF)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Example search cards
// ─────────────────────────────────────────────────────────────────────────────

class _ExampleCards extends StatelessWidget {
  const _ExampleCards({required this.onTap});
  final void Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _examples.asMap().entries.map((e) {
        final item = e.value;
        final isLast = e.key == _examples.length - 1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 10),
            child: GestureDetector(
              onTap: () => onTap(item.query),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: item.bgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 6,
                              offset: Offset(0, 2))
                        ],
                      ),
                      child: Icon(item.image,
                          size: 24, color: const Color(0xFF374151)),
                    ),
                    const SizedBox(height: 10),
                    Text(item.query,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: pjs(
                            size: 12,
                            weight: FontWeight.w500,
                            color: const Color(0xFF374151),
                            height: 1.4)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                          child: const Icon(Icons.chevron_right_rounded,
                              size: 14, color: Color(0xFF6C47FF)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Featured categories grid
// ─────────────────────────────────────────────────────────────────────────────

class _FeaturedGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _featured.asMap().entries.map((e) {
          final c = e.value;
          final isLast = e.key == _featured.length - 1;
          return Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 12),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: c.bgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(c.icon, size: 26, color: c.iconColor),
                ),
                const SizedBox(height: 6),
                Text(c.label,
                    style: pjs(
                        size: 11,
                        weight: FontWeight.w500,
                        color: const Color(0xFF374151))),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Why ProofBuy AI
// ─────────────────────────────────────────────────────────────────────────────

class _WhySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Why choose ProofBuy AI?',
            style: pjs(
                size: 16,
                weight: FontWeight.w700,
                color: const Color(0xFF0A0E2E))),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _WhyCard(
                icon: Icons.auto_awesome_rounded,
                iconBg: const Color(0xFFEEEBFF),
                iconColor: const Color(0xFF6C47FF),
                title: 'AI-Powered\nRecommendations',
                subtitle: 'Find the right products based on your needs.',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _WhyCard(
                icon: Icons.fact_check_outlined,
                iconBg: const Color(0xFFE8F4FF),
                iconColor: const Color(0xFF1A73E8),
                title: 'Real Product\nEvidence',
                subtitle: 'Compare specifications, prices and trusted sources.',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _WhyCard(
                icon: Icons.shield_outlined,
                iconBg: const Color(0xFFE6F9F0),
                iconColor: const Color(0xFF16A34A),
                title: 'Secure Checkout\nwith PayPal',
                subtitle: 'Buy confidently and safely.',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WhyCard extends StatelessWidget {
  const _WhyCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(title,
              textAlign: TextAlign.center,
              style: pjs(
                  size: 11,
                  weight: FontWeight.w700,
                  color: const Color(0xFF0A0E2E),
                  height: 1.3)),
          const SizedBox(height: 4),
          Text(subtitle,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: pjs(
                  size: 10,
                  color: const Color(0xFF6B7280),
                  height: 1.4)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom nav bar
// ─────────────────────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex, required this.onTap});
  final int currentIndex;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_rounded, Icons.home_outlined, 'Home'),
      (Icons.search_rounded, Icons.search_outlined, 'Search'),
      (Icons.inventory_2_rounded, Icons.inventory_2_outlined, 'Orders'),
      (Icons.person_rounded, Icons.person_outlined, 'Profile'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Color(0x10000000), blurRadius: 12, offset: Offset(0, -2))
        ],
      ),
      child: Row(
        children: items.asMap().entries.map((e) {
          final i = e.key;
          final item = e.value;
          final active = i == currentIndex;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(i),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      active ? item.$1 : item.$2,
                      size: 24,
                      color: active
                          ? const Color(0xFF6C47FF)
                          : const Color(0xFF9CA3AF),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.$3,
                      style: pjs(
                        size: 11,
                        weight: active ? FontWeight.w600 : FontWeight.w400,
                        color: active
                            ? const Color(0xFF6C47FF)
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
