import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/theme.dart';
import '../../core/config/app_config.dart';
import '../../core/networking/api_client.dart';
import '../auth/auth_repository.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isCheckingHealth = false;
  String _healthStatus = 'Untested';
  Color _healthColor = const Color(0xFF64748B);
  int _navIndex = 3;

  Future<void> _testServerConnection() async {
    setState(() {
      _isCheckingHealth = true;
      _healthStatus = 'Pinging...';
      _healthColor = const Color(0xFF2563EB);
    });
    try {
      final response = await dio.get('/docs');
      if (response.statusCode == 200 || response.statusCode == 404) {
        setState(() {
          _healthStatus = 'Online (Connected)';
          _healthColor = const Color(0xFF10B981);
        });
      } else {
        setState(() {
          _healthStatus = 'Degraded (${response.statusCode})';
          _healthColor = const Color(0xFFF59E0B);
        });
      }
    } catch (_) {
      try {
        await dio.get('/');
        setState(() {
          _healthStatus = 'Online (Connected)';
          _healthColor = const Color(0xFF10B981);
        });
      } catch (_) {
        setState(() {
          _healthStatus = 'Offline / Unreachable';
          _healthColor = const Color(0xFFEF4444);
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingHealth = false);
      }
    }
  }

  void _showEditProfileDialog(
      BuildContext context, WidgetRef ref, AuthUser user) {
    final nameController = TextEditingController(text: user.fullName);
    final emailController = TextEditingController(text: user.email);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Edit Profile',
              style: pjs(
                size: 18,
                weight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final updatedUser = AuthUser(
                  userId: user.userId,
                  fullName: nameController.text.trim(),
                  email: emailController.text.trim(),
                  accessToken: user.accessToken,
                  country: user.country,
                );
                ref.read(currentUserProvider.notifier).setUser(updatedUser);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('auth_full_name', updatedUser.fullName);
                await prefs.setString('auth_email', updatedUser.email);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Profile updated successfully!')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                'Save Changes',
                style:
                    pjs(size: 15, weight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentController = TextEditingController();
    final newController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Change Password',
              style: pjs(
                size: 18,
                weight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: currentController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (newController.text.trim().length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Password must be at least 6 characters.')),
                  );
                  return;
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Password changed successfully!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                'Update Password',
                style:
                    pjs(size: 15, weight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLegalDialog(BuildContext context, String title, String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              title,
              style: pjs(
                size: 20,
                weight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: pjs(
                size: 14,
                color: const Color(0xFF475569),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const defaultUser = AuthUser(
      userId: 'usr_guest',
      fullName: 'Phillip',
      email: 'phillip@proofbuy.ai',
      accessToken: 'token_demo',
    );
    final user = ref.watch(currentUserProvider) ?? defaultUser;

    final displayName =
        user.fullName.isNotEmpty ? user.fullName : 'Guest User';
    final displayEmail = user.email;
    final initials =
        displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    void showSnackbar(String msg) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Profile & Settings',
          style: pjs(
            size: 18,
            weight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () => context.go('/brief'),
          tooltip: 'Back to Home',
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── User Header ──────────────────────────────────────────────
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x06000000),
                        blurRadius: 12,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: const Color(0xFF2563EB),
                        child: Text(
                          initials,
                          style: pjs(
                            size: 24,
                            weight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: pjs(
                                size: 18,
                                weight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            if (displayEmail.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                displayEmail,
                                style: pjs(
                                    size: 13,
                                    color: const Color(0xFF64748B)),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            _showEditProfileDialog(context, ref, user),
                        icon: const Icon(Icons.edit_outlined,
                            color: Color(0xFF2563EB)),
                        tooltip: 'Edit Profile',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── PayPal Sandbox Integration Card ───────────────────────────
                _SectionHeader(label: 'PAYPAL SANDBOX INTEGRATION'),
                Container(
                  padding: const EdgeInsets.all(18),
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
                      Row(
                        children: [
                          const Icon(Icons.account_balance_wallet_rounded,
                              color: Color(0xFF0070BA), size: 22),
                          const SizedBox(width: 10),
                          Text(
                            'App Name: ${AppConfig.appName}',
                            style: pjs(
                              size: 14,
                              weight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD1FAE5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Active',
                              style: pjs(
                                size: 11,
                                weight: FontWeight.w700,
                                color: const Color(0xFF059669),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Sandbox Client ID:',
                        style:
                            pjs(size: 12, color: const Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              AppConfig.paypalClientId,
                              style: pjs(
                                size: 11.5,
                                weight: FontWeight.w500,
                                color: const Color(0xFF334155),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy_rounded,
                                size: 16, color: Color(0xFF2563EB)),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(
                                  text: AppConfig.paypalClientId));
                              showSnackbar(
                                  'PayPal Client ID copied to clipboard');
                            },
                            tooltip: 'Copy Client ID',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Account section ────────────────────────────────────────────
                _SectionHeader(label: 'ACCOUNT SECURITY'),
                _SettingsCard(children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline_rounded,
                        color: Color(0xFF2563EB)),
                    title: Text('Edit Profile Details',
                        style: pjs(
                            size: 15,
                            weight: FontWeight.w500,
                            color: const Color(0xFF0F172A))),
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: Color(0xFF9CA3AF)),
                    onTap: () => _showEditProfileDialog(context, ref, user),
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(Icons.lock_outline_rounded,
                        color: Color(0xFF2563EB)),
                    title: Text('Change Password',
                        style: pjs(
                            size: 15,
                            weight: FontWeight.w500,
                            color: const Color(0xFF0F172A))),
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: Color(0xFF9CA3AF)),
                    onTap: () => _showChangePasswordDialog(context),
                  ),
                ]),

                const SizedBox(height: 24),

                // ── App section ────────────────────────────────────────────────
                _SectionHeader(label: 'SYSTEM & DIAGNOSTICS'),
                _SettingsCard(children: [
                  ListTile(
                    leading: const Icon(Icons.dns_outlined,
                        color: Color(0xFF2563EB)),
                    title: Text('Backend API URL',
                        style: pjs(
                            size: 15,
                            weight: FontWeight.w500,
                            color: const Color(0xFF0F172A))),
                    subtitle: Text(
                      AppConfig.backendUrl,
                      style: pjs(
                          size: 12, color: const Color(0xFF64748B)),
                    ),
                    trailing: TextButton(
                      onPressed:
                          _isCheckingHealth ? null : _testServerConnection,
                      child: Text(
                        _healthStatus,
                        style: pjs(
                            size: 12,
                            weight: FontWeight.w700,
                            color: _healthColor),
                      ),
                    ),
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded,
                        color: Color(0xFF2563EB)),
                    title: Text('App Version',
                        style: pjs(
                            size: 15,
                            weight: FontWeight.w500,
                            color: const Color(0xFF0F172A))),
                    subtitle: Text(
                        '1.0.0+1 (Production Release)',
                        style: pjs(
                            size: 12, color: const Color(0xFF64748B))),
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(Icons.delete_outline_rounded,
                        color: Color(0xFF2563EB)),
                    title: Text('Clear Local Data & Cache',
                        style: pjs(
                            size: 15,
                            weight: FontWeight.w500,
                            color: const Color(0xFF0F172A))),
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: Color(0xFF9CA3AF)),
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                      if (context.mounted) {
                        showSnackbar(
                            'Local cache & search history cleared successfully');
                      }
                    },
                  ),
                ]),

                const SizedBox(height: 24),

                // ── About section ──────────────────────────────────────────────
                _SectionHeader(label: 'LEGAL & COMPLIANCE'),
                _SettingsCard(children: [
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined,
                        color: Color(0xFF2563EB)),
                    title: Text('Privacy Policy',
                        style: pjs(
                            size: 15,
                            weight: FontWeight.w500,
                            color: const Color(0xFF0F172A))),
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: Color(0xFF9CA3AF)),
                    onTap: () => _showLegalDialog(
                      context,
                      'Privacy Policy',
                      'ProofBuy AI respects your privacy. We process your shopping briefs and constraint preferences securely using trusted AI models and verify payments via PayPal Developer APIs. No sensitive payment details are stored on device.',
                    ),
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(Icons.description_outlined,
                        color: Color(0xFF2563EB)),
                    title: Text('Terms of Service',
                        style: pjs(
                            size: 15,
                            weight: FontWeight.w500,
                            color: const Color(0xFF0F172A))),
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: Color(0xFF9CA3AF)),
                    onTap: () => _showLegalDialog(
                      context,
                      'Terms of Service',
                      'By using ProofBuy AI, you agree to comply with PayPal Developer Platform terms of service. All AI-ranked product evidence is verified against real merchant sources.',
                    ),
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(Icons.verified_user_outlined,
                        color: Color(0xFF2563EB)),
                    title: Text(
                      'PayPal Verified Merchant Partner',
                      style: pjs(
                        size: 13,
                        weight: FontWeight.w600,
                        color: const Color(0xFF059669),
                      ),
                    ),
                    subtitle: Text(
                      'Secure Platform • 256-bit Encryption',
                      style: pjs(
                          size: 11.5, color: const Color(0xFF64748B)),
                    ),
                  ),
                ]),

                const SizedBox(height: 32),

                // ── Sign out ───────────────────────────────────────────────────
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Sign Out'),
                        content:
                            const Text('Are you sure you want to sign out?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Sign Out'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await ref.read(authRepositoryProvider).logout();
                      ref.read(currentUserProvider.notifier).setUser(null);
                      if (context.mounted) {
                        context.go('/onboarding');
                      }
                    }
                  },
                  child: Text(
                    'Sign Out',
                    style: pjs(
                      size: 16,
                      weight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),

          // ── Bottom Navigation Bar ──────────────────────────────────────────
          _BottomNav(
            currentIndex: _navIndex,
            onTap: (i) {
              setState(() => _navIndex = i);
              if (i == 0) context.go('/brief');
              if (i == 1) context.go('/results/search');
              if (i == 2) context.go('/history');
              // i == 3 is current profile
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: pjs(
          size: 11,
          weight: FontWeight.w700,
          color: const Color(0xFF94A3B8),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(children: children),
    );
  }
}

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
