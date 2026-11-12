import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/errors/app_exception.dart';
import 'auth_repository.dart';
import 'auth_widgets.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _emailFocus = FocusNode();
  final _pwFocus    = FocusNode();

  final _emailCtrl = TextEditingController();
  final _pwCtrl    = TextEditingController();

  bool _obscure  = true;
  bool _loading  = false;
  bool _googleLoading = false;
  bool _saveEmail = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    // Pre-fill saved email
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final saved = await ref.read(authRepositoryProvider).getSavedEmailHint();
      if (saved != null && mounted) {
        _emailCtrl.text = saved;
      }
    });
  }

  @override
  void dispose() {
    _emailFocus.dispose();
    _pwFocus.dispose();
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      final user = await ref.read(authRepositoryProvider).login(
            email: _emailCtrl.text.trim(),
            password: _pwCtrl.text,
          );
      ref.read(currentUserProvider.notifier).setUser(user);
      // Save email hint if user opted in
      if (_saveEmail) {
        await ref.read(authRepositoryProvider).saveEmailHint(
          _emailCtrl.text.trim(),
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Welcome back, ${user.fullName.split(' ').first}!',
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome, ${user.fullName.split(' ').first}!',
              style: pjs(size: 13, color: Colors.white)),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
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
                                  text: 'Welcome\nBack to ',
                                  style: pjs(
                                    size: 28,
                                    weight: FontWeight.w800,
                                    color: const Color(0xFF0A0E2E),
                                    height: 1.2,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                TextSpan(
                                  text: 'ProofBuy',
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
                              'Sign in to continue shopping smarter\nwith AI-powered evidence and secure\nPayPal checkout.',
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

                  // Tab switcher — Sign In tab active
                  AuthTabBar(
                    selectedIndex: 1,
                    onCreateAccount: () => context.go('/signup'),
                    onSignIn: () {},
                  ),

                  const SizedBox(height: 24),

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
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Enter your password'
                        : null,
                  ),

                  const SizedBox(height: 10),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => context.push('/forgot-password'),
                      child: Text(
                        'Forgot password?',
                        style: pjs(
                          size: 13,
                          weight: FontWeight.w600,
                          color: const Color(0xFF6C47FF),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Save email toggle
                  Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: _saveEmail,
                          onChanged: (v) =>
                              setState(() => _saveEmail = v ?? true),
                          activeColor: const Color(0xFF6C47FF),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                          side: const BorderSide(
                              color: Color(0xFFD1D5DB), width: 1.5),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _saveEmail = !_saveEmail),
                        child: Text(
                          'Remember my email',
                          style: pjs(
                              size: 13,
                              color: const Color(0xFF6B7280)),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Sign In button
                  AuthPrimaryButton(
                    label: 'Sign In',
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

                  // Create account link
                  Center(
                    child: GestureDetector(
                      onTap: () => context.go('/signup'),
                      child: RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: "Don't have an account? ",
                            style: pjs(
                                size: 13, color: const Color(0xFF6B7280)),
                          ),
                          TextSpan(
                            text: 'Create Account',
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
// Full-width Google Sign-In button
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
              BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 8,
                  offset: Offset(0, 2)),
            ],
          ),
          child: loading
              ? const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Color(0xFF6C47FF)),
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
                    Text(
                      'Continue with Google',
                      style: pjs(
                        size: 15,
                        weight: FontWeight.w600,
                        color: const Color(0xFF0A0E2E),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
