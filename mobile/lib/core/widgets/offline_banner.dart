import 'package:flutter/material.dart';

import '../networking/api_client.dart';
import '../../app/theme.dart';

/// Wraps [child] with an animated red offline banner that appears when
/// the device loses connectivity.
///
/// Used via MaterialApp.builder so it is visible on every screen.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isOfflineNotifier,
      builder: (context, isOffline, _) {
        return Stack(
          children: [
            // Main content fills all available space
            child,

            // Offline banner overlays at the very top (below status bar)
            if (isOffline)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AnimatedSlide(
                  offset: isOffline ? Offset.zero : const Offset(0, -1),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  child: SafeArea(
                    bottom: false,
                    child: Container(
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
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
