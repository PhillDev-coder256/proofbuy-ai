import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/theme.dart';
import '../../core/config/app_config.dart';
import '../auth/auth_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    final String displayName = user?.fullName.isNotEmpty == true
        ? user!.fullName
        : 'Guest User';
    final String displayEmail = user?.email ?? '';
    final String initials = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : '?';

    void showSnackbar(String msg) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Settings',
          style: pjs(
            size: 18,
            weight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── User header ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 12,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: const Color(0xFF6C47FF),
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
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Account section ────────────────────────────────────────────
          _SectionHeader(label: 'ACCOUNT'),
          _SettingsCard(children: [
            ListTile(
              leading: const Icon(Icons.person_outline_rounded,
                  color: Color(0xFF6C47FF)),
              title: Text('Edit Profile',
                  style: pjs(
                      size: 15,
                      weight: FontWeight.w500,
                      color: const Color(0xFF0F172A))),
              trailing: const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFF9CA3AF)),
              onTap: () => showSnackbar('Coming soon'),
            ),
            const Divider(height: 1, indent: 56),
            ListTile(
              leading: const Icon(Icons.lock_outline_rounded,
                  color: Color(0xFF6C47FF)),
              title: Text('Change Password',
                  style: pjs(
                      size: 15,
                      weight: FontWeight.w500,
                      color: const Color(0xFF0F172A))),
              trailing: const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFF9CA3AF)),
              onTap: () => showSnackbar('Coming soon'),
            ),
          ]),

          const SizedBox(height: 20),

          // ── App section ────────────────────────────────────────────────
          _SectionHeader(label: 'APP'),
          _SettingsCard(children: [
            ListTile(
              leading: const Icon(Icons.dns_outlined,
                  color: Color(0xFF6C47FF)),
              title: Text('Backend URL',
                  style: pjs(
                      size: 15,
                      weight: FontWeight.w500,
                      color: const Color(0xFF0F172A))),
              subtitle: Text(
                AppConfig.backendUrl,
                style: pjs(
                    size: 12, color: const Color(0xFF94A3B8)),
              ),
            ),
            const Divider(height: 1, indent: 56),
            ListTile(
              leading: const Icon(Icons.info_outline_rounded,
                  color: Color(0xFF6C47FF)),
              title: Text('App Version',
                  style: pjs(
                      size: 15,
                      weight: FontWeight.w500,
                      color: const Color(0xFF0F172A))),
              subtitle: Text('1.0.0+1',
                  style: pjs(
                      size: 12, color: const Color(0xFF94A3B8))),
            ),
            const Divider(height: 1, indent: 56),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded,
                  color: Color(0xFF6C47FF)),
              title: Text('Clear Search History',
                  style: pjs(
                      size: 15,
                      weight: FontWeight.w500,
                      color: const Color(0xFF0F172A))),
              trailing: const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFF9CA3AF)),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('search_history');
                if (context.mounted) {
                  showSnackbar('Search history cleared');
                }
              },
            ),
          ]),

          const SizedBox(height: 20),

          // ── About section ──────────────────────────────────────────────
          _SectionHeader(label: 'ABOUT'),
          _SettingsCard(children: [
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined,
                  color: Color(0xFF6C47FF)),
              title: Text('Privacy Policy',
                  style: pjs(
                      size: 15,
                      weight: FontWeight.w500,
                      color: const Color(0xFF0F172A))),
              trailing: const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFF9CA3AF)),
              onTap: () => showSnackbar('Coming soon'),
            ),
            const Divider(height: 1, indent: 56),
            ListTile(
              leading: const Icon(Icons.description_outlined,
                  color: Color(0xFF6C47FF)),
              title: Text('Terms of Service',
                  style: pjs(
                      size: 15,
                      weight: FontWeight.w500,
                      color: const Color(0xFF0F172A))),
              trailing: const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFF9CA3AF)),
              onTap: () => showSnackbar('Coming soon'),
            ),
            const Divider(height: 1, indent: 56),
            ListTile(
              leading: const Icon(Icons.emoji_events_outlined,
                  color: Color(0xFF6C47FF)),
              title: Text(
                'Built for PayPal AI Hackathon 2026',
                style: pjs(
                    size: 13,
                    color: const Color(0xFF94A3B8)),
              ),
            ),
          ]),

          const SizedBox(height: 28),

          // ── Sign out ───────────────────────────────────────────────────
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text(
                      'Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () =>
                          Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.of(ctx).pop(true),
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await ref.read(authRepositoryProvider).logout();
                ref
                    .read(currentUserProvider.notifier)
                    .setUser(null);
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper widgets
// ─────────────────────────────────────────────────────────────────────────────

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
          color: const Color(0xFF9CA3AF),
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
