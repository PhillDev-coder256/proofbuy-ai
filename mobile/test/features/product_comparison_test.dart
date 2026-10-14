import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:proofbuy_ai/core/networking/products_repository.dart';
import 'package:proofbuy_ai/core/networking/repositories_providers.dart';
import 'package:proofbuy_ai/core/widgets/error_widget.dart';
import 'package:proofbuy_ai/core/widgets/loading_widget.dart';
import 'package:proofbuy_ai/features/product_comparison/product_comparison_screen.dart';
import 'package:proofbuy_ai/shared/models/ranked_product.dart';

class MockProductsRepository extends Mock implements ProductsRepository {}

RankedProduct makeProduct({
  required String name,
  required double score,
  String? id,
}) =>
    RankedProduct(
      productResultId: id,
      productData: ProductData(
        name: name,
        price: 99.99,
        currency: 'USD',
      ),
      constraintResults: const {'waterproof': 'PASS'},
      rankingScore: score,
      rankingConfidence: 0.9,
      explanation: 'Great choice.',
    );

void main() {
  late MockProductsRepository mockRepo;

  setUp(() {
    mockRepo = MockProductsRepository();
  });

  const sessionId = 'test-session-123';

  group('ProductComparisonScreen', () {
    testWidgets('shows LoadingWidget while products are loading',
        (tester) async {
      // Use a Completer so no pending timer is left behind.
      final completer = Completer<List<RankedProduct>>();
      when(() => mockRepo.getProducts(sessionId))
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productsRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            home: ProductComparisonScreen(sessionId: sessionId),
          ),
        ),
      );

      // Pump once without settling — loading state should be visible.
      await tester.pump();

      expect(find.byType(LoadingWidget), findsOneWidget);

      // Complete the future so the widget tree can be disposed cleanly.
      completer.complete([]);
      await tester.pumpAndSettle();
    });

    testWidgets('shows ProofBuyErrorWidget on error', (tester) async {
      when(() => mockRepo.getProducts(sessionId))
          .thenThrow(Exception('network error'));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productsRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            home: ProductComparisonScreen(sessionId: sessionId),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ProofBuyErrorWidget), findsOneWidget);
    });

    testWidgets('shows ListView when products are returned', (tester) async {
      final products = [
        makeProduct(name: 'Product A', score: 0.9, id: 'id-a'),
        makeProduct(name: 'Product B', score: 0.7, id: 'id-b'),
      ];

      when(() => mockRepo.getProducts(sessionId))
          .thenAnswer((_) async => products);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productsRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            home: ProductComparisonScreen(sessionId: sessionId),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Product A'), findsOneWidget);
      expect(find.text('Product B'), findsOneWidget);
    });

    testWidgets('products are sorted by rankingScore descending',
        (tester) async {
      final products = [
        makeProduct(name: 'Low Score', score: 0.3, id: 'id-low'),
        makeProduct(name: 'High Score', score: 0.95, id: 'id-high'),
        makeProduct(name: 'Mid Score', score: 0.6, id: 'id-mid'),
      ];

      when(() => mockRepo.getProducts(sessionId))
          .thenAnswer((_) async => products);

      // Use a large screen so all cards fit without scrolling.
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productsRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            home: ProductComparisonScreen(sessionId: sessionId),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Gather the product name texts in render (top-to-bottom) order.
      final productNames = {'High Score', 'Mid Score', 'Low Score'};
      final names = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data ?? '')
          .where(productNames.contains)
          .toList();

      expect(names, ['High Score', 'Mid Score', 'Low Score']);
    });
  });
}
