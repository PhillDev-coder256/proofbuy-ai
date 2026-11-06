import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import 'session_provider.dart';

/// Shown at `/` for the single frame it takes to resolve the session.
/// Navigates immediately to the correct destination — users never linger here.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<String>>(sessionInitProvider, (_, next) {
      next.whenData((route) {
        // Navigate to the resolved destination (brief / signin / onboarding).
        if (context.mounted) context.go(route);
      });
    });

    // Minimal branded splash — visible for <200 ms on a modern device.
    return Scaffold(
      backgroundColor: ProofBuyColors.gradientTop,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: ProofBuyGradients.screen),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo
              Image.asset(
                'assets/images/logo.png',
                width: 80,
                height: 80,
                errorBuilder: (_, __, ___) => Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5B8EFF), Color(0xFF9333EA)],
                    ),
                  ),
                  child: const Icon(Icons.shopping_bag_outlined,
                      color: Colors.white, size: 40),
                ),
              ),
              const SizedBox(height: 20),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'ProofBuy ',
                      style: pjs(
                        size: 28,
                        weight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: 'AI',
                      style: pjs(
                        size: 28,
                        weight: FontWeight.w800,
                        color: const Color(0xFF5B8EFF),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Shop Smarter. Real Evidence.',
                style: pjs(
                  size: 13,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 40),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
