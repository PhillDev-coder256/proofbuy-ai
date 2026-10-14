import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shown when the `proofbuy://checkout/return` deep link brings the user
/// back from the PayPal browser.
///
/// The actual payment capture happens in [CheckoutScreen] — not here.
/// This screen simply bridges the return and sends the user back to finish
/// the checkout flow.
class CheckoutReturnScreen extends StatelessWidget {
  const CheckoutReturnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Returning from PayPal')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            const Text(
              'Returning from PayPal…',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your PayPal session is complete. Tap the button below to '
              'confirm your payment.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Return to CheckoutScreen if it is still on the stack;
                // otherwise fall back to the shopping brief.
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/brief');
                }
              },
              child: const Text('Continue to confirmation'),
            ),
          ],
        ),
      ),
    );
  }
}
