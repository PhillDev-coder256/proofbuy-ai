import 'package:flutter/material.dart';

/// Semantic colour constants for the ProofBuy AI design system.
class ProofBuyColors {
  ProofBuyColors._();

  static const Color pass = Color(0xFF34A853);
  static const Color fail = Color(0xFFEA4335);
  static const Color unknown = Color(0xFFFBBC04);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8F9FA);

  static const Color _primary = Color(0xFF1A73E8);
  static const Color _secondary = Color(0xFF34A853);
  static const Color _error = Color(0xFFEA4335);
}

/// Material theme factory for the ProofBuy AI app.
class ProofBuyTheme {
  ProofBuyTheme._();

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: ProofBuyColors._primary,
          primary: ProofBuyColors._primary,
          secondary: ProofBuyColors._secondary,
          error: ProofBuyColors._error,
          surface: ProofBuyColors.surface,
        ),
        scaffoldBackgroundColor: ProofBuyColors.background,
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: ProofBuyColors._primary,
          brightness: Brightness.dark,
          primary: ProofBuyColors._primary,
          secondary: ProofBuyColors._secondary,
          error: ProofBuyColors._error,
        ),
      );
}
