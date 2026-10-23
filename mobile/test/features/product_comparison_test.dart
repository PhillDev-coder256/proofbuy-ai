import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shimmer/shimmer.dart';

import 'package:proofbuy_ai/core/networking/products_repository.dart';
import 'package:proofbuy_ai/core/networking/repositories_providers.dart';
import 'package:proofbuy_ai/core/networking/shopping_repository.dart';
import 'package:proofbuy_ai/core/widgets/error_widget.dart';
import 'package:proofbuy_ai/features/product_comparison/product_comparison_screen.dart';
import 'package:proofbuy_ai/shared/models/ranked_product.dart';
import 'package:proofbuy_ai/shared/models/shopping_session.dart';

class MockProductsRepository extends Mock implements ProductsRepository {}
class MockShoppingRepository extends Mock implements ShoppingRepository {}

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

ShoppingSession makeSession(String id) => ShoppingSession(
      id: id,
      briefText: 'test',
      status: 'complete',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

void main() {
  late MockProductsRepository mockProductsRepo;
  late MockShoppingRepository mockShoppingRepo;

  setUp(() {
    mockProductsRepo = MockProductsRepository();
    mockShoppingRepo = MockShoppingRepository();
  });

  const sessionId = 'test-session-123';

  /// Helper — builds widget with both repositories mocked.
  Widget buildScreen() => ProviderScope(
        overrides: [
          productsRepositoryProvider.overrideWithValue(mockProductsRepo),
          shoppingRepositoryProvider.overrideWithValue(mockShoppingRepo),
        ],
        child: const MaterialApp(
          home: ProductComparisonScreen(sessionId: sessionId),
        ),
      );

  group('ProductComparisonScreen', () {
    testWidgets('shows Shimmer while products are loading', (tester) async {
      final completer = Completer<List<RankedProduct>>();
      when(() => mockProductsRepo.getProducts(sessionId))
          .thenAnswer((_) => completer.future);
      when(() => mockShoppingRepo.getSession(sessionId))
          .thenAnswer((_) async => makeSession(sessionId));

      await tester.pumpWidget(buildScreen());
      await tester.pump(); // one frame — loading state

      expect(find.byType(Shimmer), findsWidgets);

      completer.complete([]);
      await tester.pumpAndSettle();
    });

    testWidgets('shows ProofBuyErrorWidget on error', (tester) async {
      when(() => mockProductsRepo.getProducts(sessionId))
          .thenThrow(Exception('network error'));
      when(() => mockShoppingRepo.getSession(sessionId))
          .thenAnswer((_) async => makeSession(sessionId));

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(ProofBuyErrorWidget), findsOneWidget);
    });

    testWidgets('shows ListView when products are returned', (tester) async {
      final products = [
        makeProduct(name: 'Product A', score: 0.9, id: 'id-a'),
        makeProduct(name: 'Product B', score: 0.7, id: 'id-b'),
      ];

      when(() => mockProductsRepo.getProducts(sessionId))
          .thenAnswer((_) async => products);
      when(() => mockShoppingRepo.getSession(sessionId))
          .thenAnswer((_) async => makeSession(sessionId));

      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Product A', skipOffstage: false), findsOneWidget);
      expect(find.text('Product B', skipOffstage: false), findsOneWidget);
    });

    testWidgets('products are sorted by rankingScore descending',
        (tester) async {
      final products = [
        makeProduct(name: 'Low Score', score: 0.3, id: 'id-low'),
        makeProduct(name: 'High Score', score: 0.95, id: 'id-high'),
        makeProduct(name: 'Mid Score', score: 0.6, id: 'id-mid'),
      ];

      when(() => mockProductsRepo.getProducts(sessionId))
          .thenAnswer((_) async => products);
      when(() => mockShoppingRepo.getSession(sessionId))
          .thenAnswer((_) async => makeSession(sessionId));

      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

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
