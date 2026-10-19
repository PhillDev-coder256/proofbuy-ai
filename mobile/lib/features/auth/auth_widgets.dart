/// Shared widgets used by both SignUpScreen and SignInScreen.
library;

import 'package:flutter/material.dart';
import '../../app/theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Auth tab bar  (Create Account | Sign In)
// ─────────────────────────────────────────────────────────────────────────────

class AuthTabBar extends StatelessWidget {
  const AuthTabBar({
    super.key,
    required this.selectedIndex,
    required this.onCreateAccount,
    required this.onSignIn,
  });
  final int selectedIndex;
  final VoidCallback onCreateAccount;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFEEEBFF),
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _Tab(label: 'Create Account', active: selectedIndex == 0, onTap: onCreateAccount),
          _Tab(label: 'Sign In', active: selectedIndex == 1, onTap: onSignIn),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF6C47FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: pjs(
              size: 14,
              weight: FontWeight.w600,
              color: active ? Colors.white : const Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Text input field
// ─────────────────────────────────────────────────────────────────────────────

class AuthInputField extends StatelessWidget {
  const AuthInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.hint,
    required this.icon,
    this.nextFocus,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.obscureText = false,
    this.suffix,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocus;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      style: pjs(size: 15, weight: FontWeight.w500, color: const Color(0xFF0A0E2E)),
      validator: validator,
      onFieldSubmitted: (_) {
        if (nextFocus != null) FocusScope.of(context).requestFocus(nextFocus);
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: pjs(size: 12, color: const Color(0xFF9CA3AF)),
        hintStyle: pjs(size: 15, color: const Color(0xFFD1D5DB)),
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Icon(icon, size: 20, color: const Color(0xFF9CA3AF)),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 48),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          borderSide: const BorderSide(color: Color(0xFF6C47FF), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEA4335)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEA4335), width: 2),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Password field with visibility toggle
// ─────────────────────────────────────────────────────────────────────────────

class AuthPasswordField extends StatelessWidget {
  const AuthPasswordField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.obscure,
    required this.onToggle,
    this.validator,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool obscure;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return AuthInputField(
      controller: controller,
      focusNode: focusNode,
      label: 'Password',
      hint: '••••••••••••',
      icon: Icons.lock_outline_rounded,
      obscureText: obscure,
      textInputAction: TextInputAction.done,
      validator: validator,
      suffix: IconButton(
        icon: Icon(
          obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 20,
          color: const Color(0xFF9CA3AF),
        ),
        onPressed: onToggle,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Primary gradient button
// ─────────────────────────────────────────────────────────────────────────────

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: isLoading ? null : onPressed,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF6C47FF), Color(0xFF9F6EFF)],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x406C47FF),
                blurRadius: 20,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: isLoading
              ? const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(label,
                        style: pjs(
                            size: 17,
                            weight: FontWeight.w700,
                            color: Colors.white)),
                    const SizedBox(width: 10),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      child: const Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 16),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Social auth button
// ─────────────────────────────────────────────────────────────────────────────

class AuthSocialButton extends StatelessWidget {
  const AuthSocialButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });
  final String label;
  final Widget icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: pjs(
                    size: 13,
                    weight: FontWeight.w600,
                    color: const Color(0xFF0A0E2E),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Google coloured icon
// ─────────────────────────────────────────────────────────────────────────────

class GoogleIcon extends StatelessWidget {
  const GoogleIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    canvas.drawCircle(
        Offset(cx, cy), r, Paint()..color = const Color(0xFFF5F5F5));

    const colors = [
      Color(0xFF4285F4),
      Color(0xFFEA4335),
      Color(0xFFFBBC05),
      Color(0xFF34A853),
    ];

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.28
      ..strokeCap = StrokeCap.butt;

    for (int i = 0; i < 4; i++) {
      arcPaint.color = colors[i];
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.62),
        (i * 90 - 45) * 3.14159 / 180,
        88 * 3.14159 / 180,
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Security note banner
// ─────────────────────────────────────────────────────────────────────────────

class AuthSecurityNote extends StatelessWidget {
  const AuthSecurityNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFDDD6FE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.shield_outlined,
                size: 18, color: Color(0xFF6C47FF)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your information is secure. We use industry-standard '
              'encryption and never share your data.',
              style: pjs(size: 12, color: const Color(0xFF4B5563), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// or-continue-with divider
// ─────────────────────────────────────────────────────────────────────────────

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('or continue with',
              style: pjs(size: 12, color: const Color(0xFF9CA3AF))),
        ),
        const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Password strength rule chip row
// ─────────────────────────────────────────────────────────────────────────────

class PasswordRules extends StatelessWidget {
  const PasswordRules({
    super.key,
    required this.hasLength,
    required this.hasNumber,
    required this.hasLetter,
    required this.show,
  });
  final bool hasLength;
  final bool hasNumber;
  final bool hasLetter;
  final bool show;

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();
    return Wrap(
      spacing: 10,
      runSpacing: 6,
      children: [
        _RuleChip(label: 'At least 8 characters', met: hasLength),
        _RuleChip(label: '1 number', met: hasNumber),
        _RuleChip(label: '1 letter', met: hasLetter),
      ],
    );
  }
}

class _RuleChip extends StatelessWidget {
  const _RuleChip({required this.label, required this.met});
  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          met ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
          size: 14,
          color: met ? const Color(0xFF16A34A) : const Color(0xFFD1D5DB),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: pjs(
            size: 11,
            weight: FontWeight.w500,
            color: met ? const Color(0xFF16A34A) : const Color(0xFF9CA3AF),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Country list
// ─────────────────────────────────────────────────────────────────────────────

const authCountries = [
  'Kenya', 'Uganda', 'Tanzania', 'Nigeria', 'Ghana', 'South Africa',
  'Ethiopia', 'Rwanda', 'United States', 'United Kingdom', 'Canada',
  'Australia', 'India', 'Germany', 'France', 'Other',
];

// ─────────────────────────────────────────────────────────────────────────────
// Country dropdown
// ─────────────────────────────────────────────────────────────────────────────

class AuthCountryDropdown extends StatelessWidget {
  const AuthCountryDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final String value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: onChanged,
      style: pjs(size: 15, weight: FontWeight.w500, color: const Color(0xFF0A0E2E)),
      icon: const Icon(Icons.keyboard_arrow_down_rounded,
          color: Color(0xFF9CA3AF)),
      decoration: InputDecoration(
        labelText: 'Country / Region',
        labelStyle: pjs(size: 12, color: const Color(0xFF9CA3AF)),
        prefixIcon: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Icon(Icons.location_on_outlined,
              size: 20, color: Color(0xFF9CA3AF)),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 48),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          borderSide: const BorderSide(color: Color(0xFF6C47FF), width: 2),
        ),
      ),
      items: authCountries
          .map((c) => DropdownMenuItem(
                value: c,
                child: Text(c,
                    style: pjs(
                        size: 15,
                        weight: FontWeight.w500,
                        color: const Color(0xFF0A0E2E))),
              ))
          .toList(),
    );
  }
}
