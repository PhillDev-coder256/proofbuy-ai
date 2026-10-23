import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/widgets/offline_banner.dart';
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
      builder: (context, child) {
        // Wrap every screen with the offline connectivity banner.
        // The banner is a zero-height AnimatedSwitcher when online,
        // and shows a red "No internet connection" strip when offline.
        return OfflineBanner(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
