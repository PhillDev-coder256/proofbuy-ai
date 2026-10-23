import 'package:flutter/material.dart';

import '../networking/api_client.dart';
import '../../app/theme.dart';

/// Wraps [child] with an animated red offline banner that appears when
/// [isOfflineNotifier] is true.
///
/// Place this near the root of any screen that wants to show offline status,
/// or wrap the app's root widget with it.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isOfflineNotifier,
      builder: (context, isOffline, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isOffline
                  ? Container(
                      key: const ValueKey('offline'),
                      width: double.infinity,
                      color: const Color(0xFFEF4444),
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.wifi_off_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'No internet connection',
                            style: pjs(
                              size: 13,
                              weight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('online')),
            ),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}
