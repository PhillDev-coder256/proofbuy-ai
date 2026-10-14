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
    expect(find.text('Welcome to ProofBuy'), findsOneWidget);
  });
}
