import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/errors/app_exception.dart';
import 'auth_repository.dart';
import 'auth_widgets.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.email,
    this.devOtp, // shown in app during development (no email server)
  });

  final String email;
  final String? devOtp;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey   = GlobalKey<FormState>();
  // OTP — 6 individual digit controllers
  final _otpCtrls  = List.generate(6, (_) => TextEditingController());
  final _otpFoci   = List.generate(6, (_) => FocusNode());
  final _pwCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _pwFocus   = FocusNode();
  final _confirmFocus = FocusNode();

  bool _obscurePw      = true;
  bool _obscureConfirm = true;
  bool _loading        = false;
  // After OTP verified we hold the reset token
  String? _resetToken;

  bool get _otpComplete =>
      _otpCtrls.every((c) => c.text.isNotEmpty);

  bool get _hasLength => _pwCtrl.text.length >= 8;
  bool get _hasNumber => RegExp(r'\d').hasMatch(_pwCtrl.text);
  bool get _hasLetter => RegExp(r'[a-zA-Z]').hasMatch(_pwCtrl.text);

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    _pwCtrl.addListener(() => setState(() {}));
    _confirmCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    for (final c in _otpCtrls) { c.dispose(); }
    for (final f in _otpFoci) { f.dispose(); }
    _pwCtrl.dispose();
    _confirmCtrl.dispose();
    _pwFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  String get _otpValue => _otpCtrls.map((c) => c.text).join();

  Future<void> _verifyOtp() async {
    if (!_otpComplete) return;
    setState(() => _loading = true);
    try {
      final token = await ref.read(authRepositoryProvider).verifyOtp(
            email: widget.email,
            otp: _otpValue,
          );
      if (mounted) setState(() => _resetToken = token);
    } on AppException catch (e) {
      if (mounted) _showError(_messageFrom(e));
    } catch (_) {
      if (mounted) _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_resetToken == null) return;
    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).resetPassword(
            resetToken: _resetToken!,
            newPassword: _pwCtrl.text,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Password reset! Sign in with your new password.',
            style: pjs(size: 13, color: Colors.white),
          ),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) context.go('/signin');
    } on AppException catch (e) {
      if (mounted) _showError(_messageFrom(e));
    } catch (_) {
      if (mounted) _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _messageFrom(AppException e) => switch (e) {
        NetworkException(:final message)    => message,
        ServerException(:final message)     => message,
        NotFoundException(:final message)   => message,
        ValidationException(:final message) => message,
        PaymentException(:final message)    => message,
      };

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: pjs(size: 13, color: Colors.white)),
        backgroundColor: const Color(0xFFEA4335),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final verified = _resetToken != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FF),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // Back
                  GestureDetector(
                    onTap: () => context.canPop()
                        ? context.pop()
                        : context.go('/forgot-password'),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          size: 20, color: Color(0xFF0A0E2E)),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Icon — changes after verification
                  Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: Container(
                        key: ValueKey(verified),
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: verified
                              ? const Color(0xFFD1FAE5)
                              : const Color(0xFFEEEBFF),
                          boxShadow: [
                            BoxShadow(
                              color: verified
                                  ? const Color(0x2016A34A)
                                  : const Color(0x206C47FF),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          verified
                              ? Icons.check_circle_rounded
                              : Icons.key_rounded,
                          size: 38,
                          color: verified
                              ? const Color(0xFF16A34A)
                              : const Color(0xFF6C47FF),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Title
                  Center(
                    child: Text(
                      verified ? 'Set New Password' : 'Enter Reset Code',
                      style: pjs(
                        size: 24,
                        weight: FontWeight.w800,
                        color: const Color(0xFF0A0E2E),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Center(
                    child: Text(
                      verified
                          ? 'Choose a strong password for your account.'
                          : 'We sent a 6-digit code to\n${widget.email}',
                      textAlign: TextAlign.center,
                      style: pjs(
                        size: 13,
                        color: const Color(0xFF6B7280),
                        height: 1.6,
                      ),
                    ),
                  ),

                  // Dev OTP hint
                  if (widget.devOtp != null && !verified) ...[
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.info_outline_rounded,
                                size: 16, color: Color(0xFFD97706)),
                            const SizedBox(width: 8),
                            Text(
                              'Dev mode code: ',
                              style: pjs(
                                  size: 12,
                                  color: const Color(0xFF92400E)),
                            ),
                            SelectableText(
                              widget.devOtp!,
                              style: pjs(
                                size: 14,
                                weight: FontWeight.w800,
                                color: const Color(0xFF92400E),
                                letterSpacing: 3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // ── Phase 1: OTP entry ──────────────────────────────
                  if (!verified) ...[
                    _OtpField(
                      controllers: _otpCtrls,
                      focusNodes: _otpFoci,
                      onComplete: _verifyOtp,
                    ),
                    const SizedBox(height: 28),
                    AuthPrimaryButton(
                      label: 'Verify Code',
                      isLoading: _loading,
                      onPressed: _otpComplete ? _verifyOtp : () {},
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        child: Text(
                          "Didn't receive a code? Request again",
                          style: pjs(
                            size: 13,
                            weight: FontWeight.w500,
                            color: const Color(0xFF6C47FF),
                          ),
                        ),
                      ),
                    ),
                  ],

                  // ── Phase 2: New password ───────────────────────────
                  if (verified) ...[
                    AuthInputField(
                      controller: _pwCtrl,
                      focusNode: _pwFocus,
                      nextFocus: _confirmFocus,
                      label: 'New Password',
                      hint: '••••••••',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscurePw,
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter a password';
                        if (!_hasLength || !_hasNumber || !_hasLetter) {
                          return 'Password does not meet requirements';
                        }
                        return null;
                      },
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePw
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                          color: const Color(0xFF9CA3AF),
                        ),
                        onPressed: () =>
                            setState(() => _obscurePw = !_obscurePw),
                      ),
                    ),
                    const SizedBox(height: 10),
                    PasswordRules(
                      hasLength: _hasLength,
                      hasNumber: _hasNumber,
                      hasLetter: _hasLetter,
                      show: _pwCtrl.text.isNotEmpty,
                    ),
                    const SizedBox(height: 14),
                    AuthInputField(
                      controller: _confirmCtrl,
                      focusNode: _confirmFocus,
                      label: 'Confirm Password',
                      hint: '••••••••',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscureConfirm,
                      textInputAction: TextInputAction.done,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Confirm your password';
                        }
                        if (v != _pwCtrl.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      suffix: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                          color: const Color(0xFF9CA3AF),
                        ),
                        onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    const SizedBox(height: 28),
                    AuthPrimaryButton(
                      label: 'Reset Password',
                      isLoading: _loading,
                      onPressed: _resetPassword,
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 6-box OTP input
// ─────────────────────────────────────────────────────────────────────────────

class _OtpField extends StatelessWidget {
  const _OtpField({
    required this.controllers,
    required this.focusNodes,
    required this.onComplete,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) {
        return SizedBox(
          width: 48,
          height: 56,
          child: TextFormField(
            controller: controllers[i],
            focusNode: focusNodes[i],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: pjs(
              size: 22,
              weight: FontWeight.w800,
              color: const Color(0xFF0A0E2E),
            ),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                    color: Color(0xFF6C47FF), width: 2),
              ),
            ),
            onChanged: (v) {
              if (v.isNotEmpty && i < 5) {
                FocusScope.of(context).requestFocus(focusNodes[i + 1]);
              } else if (v.isEmpty && i > 0) {
                FocusScope.of(context).requestFocus(focusNodes[i - 1]);
              }
              if (controllers.every((c) => c.text.isNotEmpty)) {
                FocusScope.of(context).unfocus();
                onComplete();
              }
            },
          ),
        );
      }),
    );
  }
}
