import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Prefs keys (mirrors auth_repository.dart)
// ─────────────────────────────────────────────────────────────────────────────
const _kToken    = 'auth_token';
const _kUserId   = 'auth_user_id';
const _kFullName = 'auth_full_name';
const _kEmail    = 'auth_email';
const _kCountry  = 'auth_country';
const _kOnboarded = 'has_onboarded';

// ─────────────────────────────────────────────────────────────────────────────
// Session initialiser — runs once at startup
// ─────────────────────────────────────────────────────────────────────────────

/// Reads SharedPreferences, restores the saved session into
/// [currentUserProvider], and returns the resolved launch destination:
///   - '/brief'      — valid token found
///   - '/signin'     — onboarding already seen but no token
///   - '/onboarding' — first ever launch
Future<String> initSession(Ref ref) async {
  final prefs = await SharedPreferences.getInstance();

  final token = prefs.getString(_kToken);

  if (token != null && token.isNotEmpty) {
    // Restore user into global provider so every screen sees it immediately.
    final user = AuthUser(
      accessToken: token,
      userId:   prefs.getString(_kUserId)   ?? '',
      fullName: prefs.getString(_kFullName) ?? 'User',
      email:    prefs.getString(_kEmail)    ?? '',
      country:  prefs.getString(_kCountry),
    );
    ref.read(currentUserProvider.notifier).setUser(user);
    return '/brief';
  }

  // No token — has the user seen onboarding before?
  final hasOnboarded = prefs.getBool(_kOnboarded) ?? false;
  return hasOnboarded ? '/signin' : '/onboarding';
}

/// Marks onboarding as seen so subsequent cold-starts skip it.
Future<void> markOnboarded() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_kOnboarded, true);
}

/// Provider that resolves the launch route once.
/// Auto-disposes so it won't replay after the first read.
final sessionInitProvider = FutureProvider.autoDispose<String>((ref) async {
  return initSession(ref);
});
