import 'package:flutter/material.dart';

/// A wrapper around [Image.asset] that always provides an [errorBuilder],
/// so the app degrades gracefully in test environments where asset bundles
/// are not available.
class AppImage extends StatelessWidget {
  const AppImage(
    this.assetPath, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.fallbackIcon = Icons.image_not_supported_outlined,
    this.fallbackColor = const Color(0xFF9CA3AF),
    this.fallbackBg = Colors.transparent,
  });

  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final IconData fallbackIcon;
  final Color fallbackColor;
  final Color fallbackBg;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      errorBuilder: (_, __, ___) => Container(
        width: width,
        height: height,
        color: fallbackBg,
        child: Icon(fallbackIcon, color: fallbackColor,
            size: _iconSize()),
      ),
    );
  }

  double _iconSize() {
    final smallest = (width ?? 48).clamp(0, height ?? 48).toDouble();
    return (smallest * 0.5).clamp(16, 64).toDouble();
  }
}
