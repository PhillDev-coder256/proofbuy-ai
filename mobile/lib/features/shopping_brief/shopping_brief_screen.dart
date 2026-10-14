import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'shopping_brief_provider.dart';

class ShoppingBriefScreen extends ConsumerStatefulWidget {
  const ShoppingBriefScreen({super.key});

  @override
  ConsumerState<ShoppingBriefScreen> createState() =>
      _ShoppingBriefScreenState();
}

class _ShoppingBriefScreenState extends ConsumerState<ShoppingBriefScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifierState = ref.watch(shoppingBriefProvider);
    final isLoading = notifierState is AsyncLoading;
    final textLength = _controller.text.length;
    final isButtonEnabled = textLength >= 10 && !isLoading;

    // React to state changes after the current build frame.
    ref.listen<AsyncValue<dynamic>>(shoppingBriefProvider,
        (previous, next) {
      next.whenOrNull(
        data: (session) {
          if (session != null) {
            _controller.clear();
            context.go('/loading/${session.id}');
          }
        },
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString())),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Shopping Brief')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              minLines: 3,
              maxLines: 8,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: 'Describe what you need...',
                border: OutlineInputBorder(),
                counterText: '',
              ),
              onChanged: (_) => setState(() {}),
              enabled: !isLoading,
            ),
            const SizedBox(height: 8),
            // Character counter
            Text(
              '$textLength / 500 chars',
              style: TextStyle(
                color: textLength < 10 ? Colors.red : Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 24),
            if (isLoading) const LinearProgressIndicator(),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isButtonEnabled
                  ? () => ref
                      .read(shoppingBriefProvider.notifier)
                      .submitBrief(_controller.text)
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Find Products'),
            ),
          ],
        ),
      ),
    );
  }
}
