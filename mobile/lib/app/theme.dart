import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Font
// ─────────────────────────────────────────────────────────────────────────────
//
// Plus Jakarta Sans — geometric sans-serif designed for digital interfaces.
// 8 weights (200–800) + italics, SIL OFL license, safe to embed in APK/IPA.
// Closest open-source match to SF Pro's neutrality and optical clarity.
//
// Used via google_fonts package (v6). Runtime fetch + disk cache on first run.
// For fully offline production builds, add font files to assets/ and reference
// them in pubspec.yaml instead.

/// Returns a Plus Jakarta Sans TextStyle at the given [size], [weight], and
/// [color]. All text in the app should be routed through this helper or
/// through [ProofBuyTextStyles] so the font family is consistent everywhere.
TextStyle pjs({
  required double size,
  FontWeight weight = FontWeight.w400,
  Color? color,
  double? height,
  double? letterSpacing,
  FontStyle style = FontStyle.normal,
}) =>
    GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      fontStyle: style,
    );

// ─────────────────────────────────────────────────────────────────────────────
// Colour palette
// ─────────────────────────────────────────────────────────────────────────────

class _Palette {
  _Palette._();

  // Brand — Professional Fintech Blue
  static const Color royalBlue    = Color(0xFF1D4ED8);
  static const Color electricBlue = Color(0xFF2563EB);

  // Dark screen palette (Obsidian / Slate)
  static const Color gradientTop    = Color(0xFF090D16);
  static const Color gradientMid    = Color(0xFF111827);
  static const Color gradientBottom = Color(0xFF1F2937);

  // Light mode surfaces (Apple / Stripe style clean white/slate)
  static const Color surfaceLight     = Color(0xFFFFFFFF);
  static const Color backgroundLight  = Color(0xFFF8FAFC);

  // Dark mode surfaces
  static const Color surfaceDark    = Color(0xFF111827);
  static const Color backgroundDark = Color(0xFF090D16);

  // Semantic
  static const Color pass    = Color(0xFF10B981);
  static const Color fail    = Color(0xFFEF4444);
  static const Color unknown = Color(0xFFF59E0B);
  static const Color paypal  = Color(0xFF0070BA);

  // Text on dark
  static const Color textDark     = Color(0xFFF9FAFB);
  static const Color subtitleDark = Color(0xFF9CA3AF);

  // Subtle glows / borders
  static const Color glowPurple = Color(0x252563EB);
  static const Color glowBlue   = Color(0x252563EB);
  static const Color cardBg1 = Color(0xFF111827);
  static const Color cardBg2 = Color(0xFF0F172A);
}

// ─────────────────────────────────────────────────────────────────────────────
// Public colour namespace
// ─────────────────────────────────────────────────────────────────────────────

class ProofBuyColors {
  ProofBuyColors._();

  // Status badges
  static const Color pass    = _Palette.pass;
  static const Color fail    = _Palette.fail;
  static const Color unknown = _Palette.unknown;

  // Brand
  static const Color primary = _Palette.royalBlue;
  static const Color accent  = _Palette.electricBlue;
  static const Color paypal  = _Palette.paypal;

  // Gradient screen
  static const Color gradientTop    = _Palette.gradientTop;
  static const Color gradientMid    = _Palette.gradientMid;
  static const Color gradientBottom = _Palette.gradientBottom;

  // Text
  static const Color textOnDark     = _Palette.textDark;
  static const Color subtitleOnDark = _Palette.subtitleDark;

  // Light mode
  static const Color surface    = _Palette.surfaceLight;
  static const Color background = _Palette.backgroundLight;

  // Glows
  static const Color glowPurple = _Palette.glowPurple;
  static const Color glowBlue   = _Palette.glowBlue;

  // Feature icon bg
  static const Color featureIconBg = _Palette.cardBg1;
}

// ─────────────────────────────────────────────────────────────────────────────
// Gradient helpers
// ─────────────────────────────────────────────────────────────────────────────

class ProofBuyGradients {
  ProofBuyGradients._();

  static const LinearGradient screen = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [_Palette.gradientTop, _Palette.gradientMid, _Palette.gradientBottom],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient button = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
  );

  static const LinearGradient card = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [_Palette.cardBg1, _Palette.cardBg2],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Typographic scale  (Plus Jakarta Sans)
// ─────────────────────────────────────────────────────────────────────────────
//
// Naming mirrors Material 3 roles so ThemeData.textTheme stays in sync.
// All on-dark variants use ProofBuyColors.textOnDark or subtitleOnDark.

class ProofBuyTextStyles {
  ProofBuyTextStyles._();

  // ── Display / Hero ──────────────────────────────────────────────────────

  /// 36 px · ExtraBold 800 · tight  — onboarding hero title
  static final TextStyle displayLarge = pjs(
    size: 36,
    weight: FontWeight.w800,
    color: _Palette.textDark,
    height: 1.1,
    letterSpacing: -0.8,
  );

  /// 28 px · Bold 700 · tight  — screen titles on dark
  static final TextStyle displayMedium = pjs(
    size: 28,
    weight: FontWeight.w700,
    color: _Palette.textDark,
    height: 1.15,
    letterSpacing: -0.4,
  );

  // ── Headlines ───────────────────────────────────────────────────────────

  /// 22 px · SemiBold 600  — section headings
  static final TextStyle headlineMedium = pjs(
    size: 22,
    weight: FontWeight.w600,
    color: _Palette.textDark,
    height: 1.3,
    letterSpacing: -0.2,
  );

  /// 18 px · SemiBold 600  — card titles, app bar
  static final TextStyle headlineSmall = pjs(
    size: 18,
    weight: FontWeight.w600,
    color: _Palette.textDark,
    height: 1.3,
  );

  // ── Body ────────────────────────────────────────────────────────────────

  /// 16 px · Medium 500  — primary body copy
  static final TextStyle bodyLarge = pjs(
    size: 16,
    weight: FontWeight.w500,
    color: _Palette.subtitleDark,
    height: 1.55,
  );

  /// 14 px · Regular 400  — secondary body copy
  static final TextStyle bodyMedium = pjs(
    size: 14,
    weight: FontWeight.w400,
    color: _Palette.subtitleDark,
    height: 1.5,
  );

  /// 13 px · Regular 400  — captions, helper text
  static final TextStyle bodySmall = pjs(
    size: 13,
    weight: FontWeight.w400,
    color: _Palette.subtitleDark,
    height: 1.45,
  );

  // ── Labels ──────────────────────────────────────────────────────────────

  /// Feature row title  — 15 px Bold 700 white
  static final TextStyle featureTitle = pjs(
    size: 15,
    weight: FontWeight.w700,
    color: _Palette.textDark,
    height: 1.3,
  );

  /// Feature row subtitle — 13 px Regular 400 muted
  static final TextStyle featureSubtitle = pjs(
    size: 13,
    weight: FontWeight.w400,
    color: _Palette.subtitleDark,
    height: 1.4,
  );

  // ── Interactive ─────────────────────────────────────────────────────────

  /// Primary CTA button  — 17 px Bold 700 white
  static final TextStyle buttonLabel = pjs(
    size: 17,
    weight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: 0.1,
  );

  /// Secondary / text button — 14 px SemiBold 600 muted
  static final TextStyle buttonSecondary = pjs(
    size: 14,
    weight: FontWeight.w600,
    color: _Palette.subtitleDark,
  );

  /// Skip pill label — 14 px Medium 500 muted
  static final TextStyle skipLabel = pjs(
    size: 14,
    weight: FontWeight.w500,
    color: _Palette.subtitleDark,
  );

  /// Constraint badge — 11 px Bold 700 uppercase
  static final TextStyle badge = pjs(
    size: 11,
    weight: FontWeight.w700,
    letterSpacing: 0.5,
    color: Colors.white,
  );

  /// Price / numeric display — 20 px ExtraBold 800
  static final TextStyle price = pjs(
    size: 20,
    weight: FontWeight.w800,
    color: _Palette.textDark,
    letterSpacing: -0.3,
  );

  // ── Light-surface variants ───────────────────────────────────────────────
  // Use these on white/light backgrounds (product list, settings, etc.)

  static final TextStyle lightHeadline = pjs(
    size: 18,
    weight: FontWeight.w700,
    color: _Palette.gradientTop,
    height: 1.3,
    letterSpacing: -0.2,
  );

  static final TextStyle lightBody = pjs(
    size: 15,
    weight: FontWeight.w400,
    color: Color(0xFF4B5563),
    height: 1.55,
  );

  static final TextStyle lightCaption = pjs(
    size: 12,
    weight: FontWeight.w400,
    color: Color(0xFF9CA3AF),
    height: 1.4,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Theme factory
// ─────────────────────────────────────────────────────────────────────────────

class ProofBuyTheme {
  ProofBuyTheme._();

  static ThemeData get lightTheme {
    final base = ThemeData(
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
    );

    return base.copyWith(
      // Apply Plus Jakarta Sans to every Material text role
      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme),
      primaryTextTheme: GoogleFonts.plusJakartaSansTextTheme(base.primaryTextTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: const IconThemeData(color: _Palette.royalBlue),
        titleTextStyle: pjs(
          size: 18,
          weight: FontWeight.w700,
          color: _Palette.gradientTop,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ProofBuyColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          textStyle: ProofBuyTextStyles.buttonLabel,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: ProofBuyColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: pjs(size: 15, color: const Color(0xFF9CA3AF)),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white,
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData(
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
    );

    return base.copyWith(
      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme),
      primaryTextTheme: GoogleFonts.plusJakartaSansTextTheme(base.primaryTextTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: pjs(
          size: 18,
          weight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
