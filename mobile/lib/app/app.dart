import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme.dart';

/// Root application widget.
class ProofBuyApp extends ConsumerWidget {
  const ProofBuyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'ProofBuy AI',
      theme: ProofBuyTheme.lightTheme,
      darkTheme: ProofBuyTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
