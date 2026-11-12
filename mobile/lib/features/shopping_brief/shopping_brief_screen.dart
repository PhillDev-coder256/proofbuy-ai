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
    required this.icon,
    required this.query,
    required this.iconBg,
    required this.iconColor,
  });
  final IconData icon;
  final String query;
  final Color iconBg;
  final Color iconColor;
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
  _QuickCategory(icon: Icons.watch_rounded, label: 'Watch'),
];

const _examples = [
  _ExampleSearch(
    icon: Icons.laptop_mac_rounded,
    query: 'M3 MacBook Pro under \$1500 with 16GB RAM',
    iconBg: Color(0xFFEFF6FF),
    iconColor: Color(0xFF2563EB),
  ),
  _ExampleSearch(
    icon: Icons.headphones_rounded,
    query: 'Sony WH-1000XM5 noise cancelling headphones',
    iconBg: Color(0xFFE0F2FE),
    iconColor: Color(0xFF0284C7),
  ),
  _ExampleSearch(
    icon: Icons.smartphone_rounded,
    query: 'Sony Alpha mirrorless camera kit under \$1000',
    iconBg: Color(0xFFECFDF5),
    iconColor: Color(0xFF059669),
  ),
];

const _featured = [
  _FeaturedCategory(
    icon: Icons.laptop_mac_rounded,
    label: 'Laptops',
    bgColor: Color(0xFFEFF6FF),
    iconColor: Color(0xFF2563EB),
  ),
  _FeaturedCategory(
    icon: Icons.smartphone_rounded,
    label: 'Phones',
    bgColor: Color(0xFFDBEAFE),
    iconColor: Color(0xFF1D4ED8),
  ),
  _FeaturedCategory(
    icon: Icons.headphones_rounded,
    label: 'Headphones',
    bgColor: Color(0xFFE0F2FE),
    iconColor: Color(0xFF0284C7),
  ),
  _FeaturedCategory(
    icon: Icons.camera_alt_outlined,
    label: 'Cameras',
    bgColor: Color(0xFFFEF3C7),
    iconColor: Color(0xFFD97706),
  ),
  _FeaturedCategory(
    icon: Icons.watch_rounded,
    label: 'Smartwatches',
    bgColor: Color(0xFFD1FAE5),
    iconColor: Color(0xFF059669),
  ),
  _FeaturedCategory(
    icon: Icons.cable_rounded,
    label: 'Accessories',
    bgColor: Color(0xFFF1F5F9),
    iconColor: Color(0xFF475569),
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
    if (text.length < 3) return;
    _focusNode.unfocus();
    if (override != null) _controller.text = override;
    ref.read(shoppingBriefProvider.notifier).submitBrief(text);
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'Notifications',
                  style: pjs(
                    size: 18,
                    weight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _NotificationItem(
              title: 'PayPal Sandbox Live',
              subtitle: 'App "payproof ai" connected to sandbox successfully.',
              time: 'Just now',
              icon: Icons.account_balance_wallet_rounded,
              color: const Color(0xFF0070BA),
            ),
            const Divider(height: 20),
            _NotificationItem(
              title: 'AI Product Evidence Ready',
              subtitle: 'Last search successfully ranked with 96% confidence.',
              time: '2m ago',
              icon: Icons.auto_awesome_rounded,
              color: const Color(0xFF2563EB),
            ),
            const Divider(height: 20),
            _NotificationItem(
              title: 'Hackathon Submission Active',
              subtitle: 'Deadline: Nov 12, 2026. \$67,500+ in prizes.',
              time: '1h ago',
              icon: Icons.emoji_events_rounded,
              color: const Color(0xFF059669),
            ),
          ],
        ),
      ),
    );
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
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: Column(
            children: [
              // ── App bar ─────────────────────────────────────────────────
              _HomeAppBar(
                firstName: firstName,
                onNotificationTap: () => _showNotifications(context),
              ),

              // ── Scrollable content ──────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),

                      // ── Hackathon Demo Banner ──────────────────────────
                      _HackathonBadgeCard(),
                      const SizedBox(height: 16),

                      // ── Hero header ──────────────────────────────────────
                      _HeroRow(firstName: firstName),
                      const SizedBox(height: 20),

                      // ── Search input box ───────────────────────────────
                      _SearchBox(
                        controller: _controller,
                        focusNode: _focusNode,
                        isLoading: isLoading,
                        onSubmit: _submit,
                      ),
                      const SizedBox(height: 16),

                      // ── Quick category chips ────────────────────────────
                      _QuickCategories(
                        onTap: (label) {
                          _submit('Top rated $label with verified specs under \$1000');
                        },
                      ),
                      const SizedBox(height: 28),

                      // ── Try an example (Responsive Horizontal Carousel) ──
                      _SectionHeader(
                        title: '⚡ Hackathon Demo Briefs',
                        actionLabel: 'Focus Search',
                        onAction: () => _focusNode.requestFocus(),
                      ),
                      const SizedBox(height: 12),
                      _ExampleCards(onTap: _submit),
                      const SizedBox(height: 28),

                      // ── Featured categories ────────────────────────────
                      _SectionHeader(
                        title: 'Featured Categories',
                        actionLabel: 'Clear',
                        onAction: () => _controller.clear(),
                      ),
                      const SizedBox(height: 12),
                      _FeaturedGrid(
                        onTap: (label) {
                          _submit('Best selling $label with verified warranty and fast shipping');
                        },
                      ),
                      const SizedBox(height: 28),

                      // ── Why ProofBuy AI (Responsive Cards) ──────────────
                      _WhySection(),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),

              // ── Bottom Navigation Bar ───────────────────────────────────
              _BottomNav(
                currentIndex: _navIndex,
                onTap: (i) {
                  setState(() => _navIndex = i);
                  if (i == 1) {
                    _focusNode.requestFocus();
                  }
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
// Notification Item
// ─────────────────────────────────────────────────────────────────────────────

class _NotificationItem extends StatelessWidget {
  const _NotificationItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: pjs(
                  size: 14,
                  weight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: pjs(size: 12, color: const Color(0xFF64748B)),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: pjs(size: 11, color: const Color(0xFF94A3B8)),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hackathon Demo Badge Card
// ─────────────────────────────────────────────────────────────────────────────

class _HackathonBadgeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF003087), Color(0xFF0070BA)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x200070BA),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.emoji_events_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PayPal AI Hackathon • Sandbox Live',
                  style: pjs(
                    size: 13,
                    weight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'App: payproof ai • Verified Sandbox API',
                  style: pjs(
                    size: 11,
                    color: Colors.white70,
                    weight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'LIVE',
              style: pjs(
                size: 10,
                weight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App bar
// ─────────────────────────────────────────────────────────────────────────────

class _HomeAppBar extends StatelessWidget {
  const _HomeAppBar({
    required this.firstName,
    required this.onNotificationTap,
  });
  final String firstName;
  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    final initials = firstName.isNotEmpty
        ? firstName.substring(0, 1).toUpperCase()
        : '?';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Image.asset(
            'assets/images/logo.png',
            width: 36,
            height: 36,
            errorBuilder: (_, __, ___) => Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFF2563EB),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
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
                      size: 17,
                      weight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  TextSpan(
                    text: 'AI',
                    style: pjs(
                      size: 17,
                      weight: FontWeight.w800,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ]),
              ),
              Text(
                'Shop Smarter. Real Evidence.',
                style: pjs(
                  size: 11,
                  color: const Color(0xFF64748B),
                  weight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Notification bell
          GestureDetector(
            onTap: onNotificationTap,
            child: Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x06000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    size: 20,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // User avatar
          GestureDetector(
            onTap: () => context.go('/settings'),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                ),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: pjs(
                    size: 15,
                    weight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero Header Row (Responsive)
// ─────────────────────────────────────────────────────────────────────────────

class _HeroRow extends StatelessWidget {
  const _HeroRow({required this.firstName});
  final String firstName;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;
        final illustrationSize = isCompact ? 80.0 : 96.0;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: 'Hello, $firstName',
                        style: pjs(
                          size: isCompact ? 20 : 23,
                          weight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                          height: 1.2,
                          letterSpacing: -0.4,
                        ),
                      ),
                      TextSpan(
                        text: '!',
                        style: pjs(
                          size: isCompact ? 20 : 23,
                          weight: FontWeight.w800,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Tell me what you want to buy, and I'll find the best products with real evidence and secure PayPal checkout.",
                    style: pjs(
                      size: isCompact ? 12 : 13.5,
                      color: const Color(0xFF475569),
                      height: 1.55,
                      weight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: illustrationSize,
              height: illustrationSize,
              child: Image.asset(
                'assets/images/home-image.png',
                width: illustrationSize,
                height: illustrationSize,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  width: illustrationSize,
                  height: illustrationSize,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFDBEAFE)),
                  ),
                  child: const Icon(
                    Icons.smart_toy_outlined,
                    size: 40,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search Input Box
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
    final hasText = widget.controller.text.trim().length >= 3;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 2),
            child: Text(
              'What would you like to shop for?',
              style: pjs(
                size: 12,
                weight: FontWeight.w600,
                color: const Color(0xFF475569),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  minLines: 2,
                  maxLines: 4,
                  maxLength: 500,
                  style: pjs(
                    size: 14,
                    color: const Color(0xFF0F172A),
                    weight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        'e.g. "M3 MacBook Pro under \$1500 with 16GB RAM"',
                    hintStyle: pjs(
                      size: 13,
                      color: const Color(0xFF94A3B8),
                      height: 1.45,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.fromLTRB(16, 4, 8, 12),
                    counterText: '',
                  ),
                  enabled: !widget.isLoading,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => widget.onSubmit(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12, bottom: 12),
                child: Row(
                  children: [
                    _CircleIconBtn(
                      icon: Icons.mic_outlined,
                      color: const Color(0xFF64748B),
                      bgColor: const Color(0xFFF1F5F9),
                      size: 38,
                      onTap: () {
                        widget.controller.text =
                            'M3 MacBook Pro under \$1500 with 16GB RAM';
                        widget.onSubmit();
                      },
                    ),
                    const SizedBox(width: 8),
                    _CircleIconBtn(
                      icon: widget.isLoading
                          ? Icons.hourglass_empty_rounded
                          : Icons.arrow_forward_rounded,
                      color: Colors.white,
                      bgColor: hasText
                          ? const Color(0xFF2563EB)
                          : const Color(0xFFCBD5E1),
                      size: 42,
                      onTap: hasText && !widget.isLoading
                          ? () => widget.onSubmit()
                          : null,
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bgColor,
        ),
        child: Icon(icon, color: color, size: size * 0.46),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick Category Chips
// ─────────────────────────────────────────────────────────────────────────────

class _QuickCategories extends StatelessWidget {
  const _QuickCategories({required this.onTap});
  final void Function(String label) onTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _quickCategories.map((c) {
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => onTap(c.label),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(c.icon, size: 15, color: const Color(0xFF2563EB)),
                    const SizedBox(width: 6),
                    Text(
                      c.label,
                      style: pjs(
                        size: 13,
                        weight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
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

// ─────────────────────────────────────────────────────────────────────────────
// Section Header
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
        Text(
          title,
          style: pjs(
            size: 16,
            weight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        GestureDetector(
          onTap: onAction,
          child: Row(
            children: [
              Text(
                actionLabel,
                style: pjs(
                  size: 13,
                  weight: FontWeight.w600,
                  color: const Color(0xFF2563EB),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: Color(0xFF2563EB),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Example Search Cards
// ─────────────────────────────────────────────────────────────────────────────

class _ExampleCards extends StatelessWidget {
  const _ExampleCards({required this.onTap});
  final void Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _examples.asMap().entries.map((e) {
          final item = e.value;
          final isLast = e.key == _examples.length - 1;

          return Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 12),
            child: GestureDetector(
              onTap: () => onTap(item.query),
              child: Container(
                width: 230,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: item.iconBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        item.icon,
                        size: 22,
                        color: item.iconColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 52,
                      child: Text(
                        item.query,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: pjs(
                          size: 12.5,
                          weight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFEFF6FF),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 13,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ],
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

// ─────────────────────────────────────────────────────────────────────────────
// Featured Categories Grid
// ─────────────────────────────────────────────────────────────────────────────

class _FeaturedGrid extends StatelessWidget {
  const _FeaturedGrid({required this.onTap});
  final void Function(String label) onTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _featured.asMap().entries.map((e) {
          final c = e.value;
          final isLast = e.key == _featured.length - 1;

          return Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 12),
            child: GestureDetector(
              onTap: () => onTap(c.label),
              child: Column(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: c.bgColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Icon(c.icon, size: 26, color: c.iconColor),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    c.label,
                    style: pjs(
                      size: 11.5,
                      weight: FontWeight.w600,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Why Choose ProofBuy AI
// ─────────────────────────────────────────────────────────────────────────────

class _WhySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Why choose ProofBuy AI?',
          style: pjs(
            size: 16,
            weight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: const [
              _WhyCard(
                icon: Icons.auto_awesome_rounded,
                iconBg: Color(0xFFEFF6FF),
                iconColor: Color(0xFF2563EB),
                title: 'AI-Powered\nRecommendations',
                subtitle: 'Find the right products based on your exact needs.',
              ),
              SizedBox(width: 12),
              _WhyCard(
                icon: Icons.fact_check_outlined,
                iconBg: Color(0xFFE0F2FE),
                iconColor: Color(0xFF0284C7),
                title: 'Real Product\nEvidence',
                subtitle: 'Compare specifications, prices, and sources.',
              ),
              SizedBox(width: 12),
              _WhyCard(
                icon: Icons.shield_outlined,
                iconBg: Color(0xFFD1FAE5),
                iconColor: Color(0xFF059669),
                title: 'Secure Checkout\nwith PayPal',
                subtitle: 'Buy confidently with verified protection.',
              ),
            ],
          ),
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
      width: 180,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(height: 10),
          Text(
            title,
            style: pjs(
              size: 12,
              weight: FontWeight.w700,
              color: const Color(0xFF0F172A),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: pjs(
              size: 11,
              color: const Color(0xFF64748B),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Navigation Bar
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
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
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
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF64748B),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.$3,
                      style: pjs(
                        size: 11,
                        weight: active ? FontWeight.w600 : FontWeight.w500,
                        color: active
                            ? const Color(0xFF2563EB)
                            : const Color(0xFF64748B),
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
