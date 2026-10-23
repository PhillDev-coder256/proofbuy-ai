import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';

/// Shown when the user cancels the PayPal checkout flow
/// (deep link: proofbuy://checkout/cancel).
class CheckoutCancelScreen extends StatelessWidget {
  const CheckoutCancelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFEF3C7),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x20F59E0B),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.cancel_outlined,
                    size: 40,
                    color: Color(0xFFF59E0B),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'Payment Cancelled',
                textAlign: TextAlign.center,
                style: pjs(
                  size: 24,
                  weight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'You cancelled the PayPal payment. Your order has not been placed and no charge was made.',
                textAlign: TextAlign.center,
                style: pjs(
                  size: 14,
                  color: const Color(0xFF475569),
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 40),

              // Try again
              GestureDetector(
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/brief');
                  }
                },
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(27),
                    gradient: ProofBuyGradients.button,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x406C47FF),
                        blurRadius: 20,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Try Again',
                      style: pjs(
                        size: 16,
                        weight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Back to home
              GestureDetector(
                onTap: () => context.go('/brief'),
                child: Center(
                  child: Text(
                    'Back to Home',
                    style: pjs(
                      size: 14,
                      weight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
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
