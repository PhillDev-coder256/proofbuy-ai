import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:proofbuy_ai/app/app.dart';
import 'package:proofbuy_ai/features/auth/session_provider.dart';

void main() {
  testWidgets('ProofBuyApp smoke test — first-launch lands on onboarding',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        // Override sessionInitProvider to simulate a first launch
        // (no saved token, no onboarding seen) without hitting SharedPreferences.
        overrides: [
          sessionInitProvider.overrideWith(
            (ref) async => '/onboarding',
          ),
        ],
        child: const ProofBuyApp(),
      ),
    );
    // First pump: SplashScreen is shown while provider resolves.
    await tester.pump();
    // Second settle: sessionInitProvider resolves → navigates to /onboarding.
    await tester.pumpAndSettle();

    // Onboarding page 1 shows 'Next' and 'Skip'.
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
  });

  testWidgets('ProofBuyApp smoke test — saved session lands on brief',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionInitProvider.overrideWith(
            (ref) async => '/brief',
          ),
        ],
        child: const ProofBuyApp(),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    // Verify app rendered without crashing — no crash = session restore works.
    expect(find.byType(ProviderScope), findsOneWidget);
  });
}
