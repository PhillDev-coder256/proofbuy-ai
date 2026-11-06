import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/errors/app_exception.dart';
import 'auth_repository.dart';
import 'auth_widgets.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _emailCtrl  = TextEditingController();
  final _emailFocus = FocusNode();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    // Pre-fill from saved hint
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final hint = await ref.read(authRepositoryProvider).getSavedEmailHint();
      if (hint != null && mounted) _emailCtrl.text = hint;
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      final otp = await ref
          .read(authRepositoryProvider)
          .forgotPassword(email: _emailCtrl.text.trim());

      if (!mounted) return;
      // Navigate to OTP screen, passing the email and the dev-mode OTP
      context.push(
        '/reset-password',
        extra: {
          'email': _emailCtrl.text.trim(),
          'dev_otp': otp,
        },
      );
    } on AppException catch (e) {
      if (mounted) _showInfo(_messageFrom(e));
    } catch (_) {
      // Still navigate — backend always 200s to prevent enumeration
      if (mounted) {
        context.push(
          '/reset-password',
          extra: {'email': _emailCtrl.text.trim(), 'dev_otp': null},
        );
      }
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

  void _showInfo(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: pjs(size: 13, color: Colors.white)),
        backgroundColor: const Color(0xFF6C47FF),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    onTap: () =>
                        context.canPop() ? context.pop() : context.go('/signin'),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          size: 20, color: Color(0xFF0A0E2E)),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Lock icon
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFEEEBFF),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0x206C47FF),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.lock_reset_rounded,
                        size: 38,
                        color: Color(0xFF6C47FF),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Title
                  Center(
                    child: Text(
                      'Forgot Password?',
                      style: pjs(
                        size: 26,
                        weight: FontWeight.w800,
                        color: const Color(0xFF0A0E2E),
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Center(
                    child: Text(
                      "Enter your registered email address and\nwe'll send you a reset code.",
                      textAlign: TextAlign.center,
                      style: pjs(
                        size: 14,
                        color: const Color(0xFF6B7280),
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Email field
                  AuthInputField(
                    controller: _emailCtrl,
                    focusNode: _emailFocus,
                    label: 'Email Address',
                    hint: 'john@example.com',
                    icon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter your email';
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 28),

                  // Send code button
                  AuthPrimaryButton(
                    label: 'Send Reset Code',
                    isLoading: _loading,
                    onPressed: _submit,
                  ),

                  const SizedBox(height: 24),

                  // Back to sign in
                  Center(
                    child: GestureDetector(
                      onTap: () => context.go('/signin'),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Remembered it? ',
                              style: pjs(
                                  size: 13, color: const Color(0xFF6B7280)),
                            ),
                            TextSpan(
                              text: 'Sign In',
                              style: pjs(
                                size: 13,
                                weight: FontWeight.w700,
                                color: const Color(0xFF6C47FF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

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
