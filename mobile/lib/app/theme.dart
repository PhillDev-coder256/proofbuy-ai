import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Design tokens
// ─────────────────────────────────────────────────────────────────────────────

/// All raw colour constants used in the ProofBuy AI design system.
/// Do NOT use these directly in widgets — use [ProofBuyColors] instead.
class _Palette {
  _Palette._();

  // Brand
  static const Color royalBlue = Color(0xFF1A73E8);
  static const Color electricBlue = Color(0xFF4285F4);

  // Onboarding gradient stops
  static const Color gradientTop = Color(0xFF0A0E2E); // deep navy
  static const Color gradientMid = Color(0xFF1A1464); // dark indigo
  static const Color gradientBottom = Color(0xFF2D1B69); // dark violet

  // Surface / background (light mode)
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF0F4FF); // very light blue-tinted

  // Surface / background (dark mode)
  static const Color surfaceDark = Color(0xFF12162E);
  static const Color backgroundDark = Color(0xFF0A0E2E);

  // Semantic
  static const Color pass = Color(0xFF34A853); // green
  static const Color fail = Color(0xFFEA4335); // red
  static const Color unknown = Color(0xFFFBBC04); // amber
  static const Color paypal = Color(0xFF009CDE); // PayPal brand blue

  // Text on dark
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB8C0E0);

  // Glows / accents
  static const Color glow = Color(0x33A855F7); // purple glow at 20%
  static const Color glowBlue = Color(0x334285F4); // blue glow at 20%

  // Feature icon backgrounds
  static const Color iconBgAI = Color(0xFF1E2B6E);
}

// ─────────────────────────────────────────────────────────────────────────────
// Public colour namespace
// ─────────────────────────────────────────────────────────────────────────────

class ProofBuyColors {
  ProofBuyColors._();

  // Semantic — status badges
  static const Color pass = _Palette.pass;
  static const Color fail = _Palette.fail;
  static const Color unknown = _Palette.unknown;

  // Brand
  static const Color primary = _Palette.royalBlue;
  static const Color accent = _Palette.electricBlue;
  static const Color paypal = _Palette.paypal;

  // Onboarding / dark screens
  static const Color gradientTop = _Palette.gradientTop;
  static const Color gradientMid = _Palette.gradientMid;
  static const Color gradientBottom = _Palette.gradientBottom;
  static const Color textOnDark = _Palette.textPrimaryDark;
  static const Color subtitleOnDark = _Palette.textSecondaryDark;
  static const Color featureIconBg = _Palette.iconBgAI;
  static const Color glow = _Palette.glow;
  static const Color glowBlue = _Palette.glowBlue;

  // Light mode
  static const Color surface = _Palette.surfaceLight;
  static const Color background = _Palette.backgroundLight;
}

// ─────────────────────────────────────────────────────────────────────────────
// Gradient helpers
// ─────────────────────────────────────────────────────────────────────────────

class ProofBuyGradients {
  ProofBuyGradients._();

  /// Full-screen deep navy → violet background used on onboarding & dark screens.
  static const LinearGradient screen = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      _Palette.gradientTop,
      _Palette.gradientMid,
      _Palette.gradientBottom,
    ],
    stops: [0.0, 0.5, 1.0],
  );

  /// Button gradient: electric blue → purple.
  static const LinearGradient button = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF5B7FFF),
      Color(0xFF9333EA),
    ],
  );

  /// Subtle card background on dark.
  static const LinearGradient card = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E2B6E),
      Color(0xFF0F1A4A),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Typography scale
// ─────────────────────────────────────────────────────────────────────────────

class ProofBuyTextStyles {
  ProofBuyTextStyles._();

  static const TextStyle heroTitle = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 36,
    fontWeight: FontWeight.w800,
    color: _Palette.textPrimaryDark,
    height: 1.1,
    letterSpacing: -0.5,
  );

  static const TextStyle heroSubtitle = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: _Palette.textSecondaryDark,
    height: 1.5,
  );

  static const TextStyle featureTitle = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: _Palette.textPrimaryDark,
    height: 1.3,
  );

  static const TextStyle featureSubtitle = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: _Palette.textSecondaryDark,
    height: 1.4,
  );

  static const TextStyle buttonLabel = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: 0.2,
  );

  static const TextStyle skipLabel = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: _Palette.textSecondaryDark,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Theme factory
// ─────────────────────────────────────────────────────────────────────────────

class ProofBuyTheme {
  ProofBuyTheme._();

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: ProofBuyColors.primary,
          primary: ProofBuyColors.primary,
          secondary: _Palette.pass,
          error: _Palette.fail,
          surface: ProofBuyColors.surface,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: ProofBuyColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          iconTheme: IconThemeData(color: _Palette.royalBlue),
          titleTextStyle: TextStyle(
            color: _Palette.gradientTop,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: ProofBuyColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            textStyle: ProofBuyTextStyles.buttonLabel,
          ),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: ProofBuyColors.primary,
          brightness: Brightness.dark,
          primary: ProofBuyColors.primary,
          secondary: _Palette.pass,
          error: _Palette.fail,
          surface: _Palette.surfaceDark,
        ),
        scaffoldBackgroundColor: _Palette.backgroundDark,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}
