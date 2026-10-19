import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:proofbuy_ai/app/app.dart';

void main() {
  testWidgets('ProofBuyApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: ProofBuyApp()),
    );
    await tester.pumpAndSettle();
    // The app navigates to OnboardingScreen on first launch.
    // First page shows 'Next' button and the skip link.
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
  });
}
