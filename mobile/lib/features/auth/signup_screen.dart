import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/errors/app_exception.dart';
import 'auth_repository.dart';
import 'auth_widgets.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _nameFocus  = FocusNode();
  final _emailFocus = FocusNode();
  final _pwFocus    = FocusNode();

  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwCtrl    = TextEditingController();

  bool _obscure   = true;
  bool _loading   = false;
  bool _googleLoading = false;
  String _country = 'Kenya';

  bool get _hasLength => _pwCtrl.text.length >= 8;
  bool get _hasNumber => RegExp(r'\d').hasMatch(_pwCtrl.text);
  bool get _hasLetter => RegExp(r'[a-zA-Z]').hasMatch(_pwCtrl.text);

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    _pwCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameFocus.dispose();
    _emailFocus.dispose();
    _pwFocus.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      final user = await ref.read(authRepositoryProvider).register(
            fullName: _nameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            password: _pwCtrl.text,
            country: _country,
          );
      ref.read(currentUserProvider.notifier).setUser(user);
      if (!mounted) return;
      // Show success confirmation before navigating
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Welcome, ${user.fullName.split(' ').first}! Account created.',
            style: pjs(size: 13, color: Colors.white),
          ),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) context.go('/brief');
    } on AppException catch (e) {
      if (mounted) _showError(_messageFrom(e));
    } catch (e) {
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: pjs(size: 13, color: Colors.white)),
        backgroundColor: const Color(0xFFEA4335),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _googleLoading = true);
    try {
      final user = await ref.read(authRepositoryProvider).signInWithGoogle();
      ref.read(currentUserProvider.notifier).setUser(user);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Welcome, ${user.fullName.split(' ').first}!',
            style: pjs(size: 13, color: Colors.white)),
        backgroundColor: const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) context.go('/brief');
    } on AppException catch (e) {
      if (mounted) _showError(_messageFrom(e));
    } catch (e) {
      if (mounted) _showError('Google sign-in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
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
                    onTap: () => context.canPop()
                        ? context.pop()
                        : context.go('/onboarding'),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          size: 20, color: Color(0xFF0A0E2E)),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Header row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                  text: 'Welcome to\nProofBuy ',
                                  style: pjs(
                                    size: 28,
                                    weight: FontWeight.w800,
                                    color: const Color(0xFF0A0E2E),
                                    height: 1.2,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                TextSpan(
                                  text: 'AI',
                                  style: pjs(
                                    size: 28,
                                    weight: FontWeight.w800,
                                    color: const Color(0xFF6C47FF),
                                    height: 1.2,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                              ]),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Create an account to start shopping\nsmarter with AI, real product evidence\nand secure PayPal checkout.',
                              style: pjs(
                                  size: 13,
                                  color: const Color(0xFF6B7280),
                                  height: 1.6),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 130,
                        height: 130,
                        child: Image.asset(
                          'assets/images/signup.png',
                          fit: BoxFit.contain,
                          alignment: Alignment.centerRight,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.shopping_bag_outlined,
                            size: 64,
                            color: Color(0xFF6C47FF),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Tab switcher
                  AuthTabBar(
                    selectedIndex: 0,
                    onCreateAccount: () {},
                    onSignIn: () => context.go('/signin'),
                  ),

                  const SizedBox(height: 24),

                  // Full Name
                  AuthInputField(
                    controller: _nameCtrl,
                    focusNode: _nameFocus,
                    nextFocus: _emailFocus,
                    label: 'Full Name',
                    hint: 'John Doe',
                    icon: Icons.person_outline_rounded,
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Enter your name'
                        : null,
                  ),

                  const SizedBox(height: 14),

                  // Email
                  AuthInputField(
                    controller: _emailCtrl,
                    focusNode: _emailFocus,
                    nextFocus: _pwFocus,
                    label: 'Email Address',
                    hint: 'john@example.com',
                    icon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter your email';
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 14),

                  // Password
                  AuthPasswordField(
                    controller: _pwCtrl,
                    focusNode: _pwFocus,
                    obscure: _obscure,
                    onToggle: () => setState(() => _obscure = !_obscure),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter a password';
                      if (!_hasLength || !_hasNumber || !_hasLetter) {
                        return 'Password does not meet requirements';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 10),

                  PasswordRules(
                    hasLength: _hasLength,
                    hasNumber: _hasNumber,
                    hasLetter: _hasLetter,
                    show: _pwCtrl.text.isNotEmpty,
                  ),

                  const SizedBox(height: 14),

                  // Country
                  AuthCountryDropdown(
                    value: _country,
                    onChanged: (v) => setState(() => _country = v ?? _country),
                  ),

                  const SizedBox(height: 28),

                  // Create Account button
                  AuthPrimaryButton(
                    label: 'Create Account',
                    isLoading: _loading,
                    onPressed: _submit,
                  ),

                  const SizedBox(height: 20),
                  const AuthDivider(),
                  const SizedBox(height: 16),

                  // Google Sign-In (full width)
                  _GoogleSignInButton(
                    onPressed: _signInWithGoogle,
                    loading: _googleLoading,
                  ),

                  const SizedBox(height: 16),
                  const AuthSecurityNote(),
                  const SizedBox(height: 20),

                  // Sign in link
                  Center(
                    child: GestureDetector(
                      onTap: () => context.go('/signin'),
                      child: RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: 'Already have an account? ',
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
                        ]),
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

// ─────────────────────────────────────────────────────────────────────────────
// Full-width Google Sign-In button (also used on signup screen)
// ─────────────────────────────────────────────────────────────────────────────

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({required this.onPressed, this.loading = false});
  final VoidCallback onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Continue with Google',
      child: GestureDetector(
        onTap: loading ? null : onPressed,
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: const [
              BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
            ],
          ),
          child: loading
              ? const Center(
                  child: SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF6C47FF)),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/google-icon.jpeg',
                          width: 20,
                          height: 20,
                          errorBuilder: (_, __, ___) => const GoogleIcon(),
                        ),
                        const SizedBox(width: 12),
                    Text('Continue with Google',
                        style: pjs(size: 15, weight: FontWeight.w600,
                            color: const Color(0xFF0A0E2E))),
                  ],
                ),
        ),
      ),
    );
  }
}
