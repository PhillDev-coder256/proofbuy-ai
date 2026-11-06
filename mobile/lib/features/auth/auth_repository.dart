import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/errors/app_exception.dart';
import '../../core/networking/api_client.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helper — unwrap DioException.error into AppException
// ─────────────────────────────────────────────────────────────────────────────

/// Runs [fn] and converts any [DioException] into the [AppException] stored
/// in its `.error` field — so callers can `catch (e) on AppException`.
Future<T> _call<T>(Future<T> Function() fn) async {
  try {
    return await fn();
  } on DioException catch (e) {
    if (e.error is AppException) throw e.error as AppException;
    throw NetworkException(e.message ?? 'Network error');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────────────────────

class AuthUser {
  const AuthUser({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.accessToken,
    this.country,
  });

  final String userId;
  final String fullName;
  final String email;
  final String accessToken;
  final String? country;

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        userId: json['user_id'] as String,
        fullName: json['full_name'] as String,
        email: json['email'] as String,
        accessToken: json['access_token'] as String,
        country: json['country'] as String?,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Prefs keys
// ─────────────────────────────────────────────────────────────────────────────

const _kToken    = 'auth_token';
const _kUserId   = 'auth_user_id';
const _kFullName = 'auth_full_name';
const _kEmail    = 'auth_email';
const _kCountry  = 'auth_country';

// ─────────────────────────────────────────────────────────────────────────────
// Repository
// ─────────────────────────────────────────────────────────────────────────────

class AuthRepository {
  AuthRepository(this._dio);
  final Dio _dio;

  // ── Register ───────────────────────────────────────────────────────────────
  Future<AuthUser> register({
    required String fullName,
    required String email,
    required String password,
    String? country,
  }) async {
    return _call(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/auth/register',
        data: {
          'full_name': fullName,
          'email': email,
          'password': password,
          if (country != null && country.isNotEmpty) 'country': country,
        },
      );
      final user = AuthUser.fromJson(response.data!);
      await _persist(user);
      return user;
    });
  }

  // ── Login ──────────────────────────────────────────────────────────────────
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    return _call(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/auth/login',
        data: {'email': email, 'password': password},
      );
      final user = AuthUser.fromJson(response.data!);
      await _persist(user);
      return user;
    });
  }

  // ── Logout ─────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kToken);
    await prefs.remove(_kUserId);
    await prefs.remove(_kFullName);
    await prefs.remove(_kEmail);
    await prefs.remove(_kCountry);
  }

  // ── Restore session from local storage ────────────────────────────────────
  Future<AuthUser?> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_kToken);
    if (token == null) return null;
    return AuthUser(
      accessToken: token,
      userId:   prefs.getString(_kUserId)   ?? '',
      fullName: prefs.getString(_kFullName) ?? '',
      email:    prefs.getString(_kEmail)    ?? '',
      country:  prefs.getString(_kCountry),
    );
  }

  // ── Persist to SharedPreferences ──────────────────────────────────────────
  Future<void> _persist(AuthUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken,    user.accessToken);
    await prefs.setString(_kUserId,   user.userId);
    await prefs.setString(_kFullName, user.fullName);
    await prefs.setString(_kEmail,    user.email);
    if (user.country != null) {
      await prefs.setString(_kCountry, user.country!);
    }
  }

  /// Persist credentials for "save password" feature (email only — never plain password).
  Future<void> saveEmailHint(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_email_hint', email);
  }

  Future<String?> getSavedEmailHint() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('saved_email_hint');
  }

  // ── Password reset ─────────────────────────────────────────────────────────

  /// Request an OTP for [email]. Returns the OTP string in dev mode
  /// (the backend includes it in the response since no email provider is configured).
  Future<String> forgotPassword({required String email}) async {
    return _call(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/auth/forgot-password',
        data: {'email': email},
      );
      // In dev mode the OTP is returned directly.
      final otp = response.data?['otp'] as String?;
      if (otp == null) {
        throw const ValidationException(
          'Reset code sent — check your email.',
        );
      }
      return otp;
    });
  }

  /// Verify [otp] for [email]. Returns a short-lived reset token on success.
  Future<String> verifyOtp({required String email, required String otp}) async {
    return _call(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/auth/verify-otp',
        data: {'email': email, 'otp': otp},
      );
      final token = response.data?['reset_token'] as String?;
      if (token == null) throw const ValidationException('No reset token received.');
      return token;
    });
  }

  /// Set [newPassword] using the [resetToken] from [verifyOtp].
  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    return _call(() async {
      await _dio.post<Map<String, dynamic>>(
        '/api/v1/auth/reset-password',
        data: {'reset_token': resetToken, 'new_password': newPassword},
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Riverpod providers
// ─────────────────────────────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(apiClientProvider)),
);

/// The currently signed-in user, or null if not authenticated.
/// Use ref.read(currentUserProvider.notifier).state = user to update.
class CurrentUserNotifier extends Notifier<AuthUser?> {
  @override
  AuthUser? build() => null;

  void setUser(AuthUser? user) => state = user;
}

final currentUserProvider =
    NotifierProvider<CurrentUserNotifier, AuthUser?>(CurrentUserNotifier.new);
