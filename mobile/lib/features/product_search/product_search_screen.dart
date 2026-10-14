import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/networking/repositories_providers.dart';
import '../../core/widgets/error_widget.dart';
import '../../core/widgets/loading_widget.dart';
import '../../shared/models/shopping_session.dart';

part 'product_search_screen.g.dart';

@riverpod
class ProductSearchNotifier extends _$ProductSearchNotifier {
  @override
  Future<ShoppingSession> build(String sessionId) async {
    final session = await ref
        .read(shoppingRepositoryProvider)
        .getSession(sessionId);
    // Pre-fetch products so they are cached for the comparison screen.
    await ref.read(productsRepositoryProvider).getProducts(sessionId);
    return session;
  }
}

class ProductSearchScreen extends ConsumerWidget {
  const ProductSearchScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state =
        ref.watch(productSearchProvider(sessionId));

    return Scaffold(
      appBar: AppBar(title: const Text('Searching Products')),
      body: state.when(
        loading: () =>
            const LoadingWidget(message: 'Finding products...'),
        error: (error, _) => ProofBuyErrorWidget(
          message: error.toString(),
          onRetry: () => ref
              .invalidate(productSearchProvider(sessionId)),
        ),
        data: (session) => _SearchResults(
          session: session,
          sessionId: sessionId,
        ),
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.session,
    required this.sessionId,
  });

  final ShoppingSession session;
  final String sessionId;

  @override
  Widget build(BuildContext context) {
    final requirements = session.requirementsJson ?? {};

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Requirements',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ...requirements.entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Text(
                        '${e.key}: ${e.value}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () => context.go('/results/$sessionId'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('These look right → continue'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => context.pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('← Edit my brief'),
          ),
        ],
      ),
    );
  }
}
