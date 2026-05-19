import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ── Palette ──────────────────────────────────────────────
  static const Color primary = Color(0xFF1F2933); // ink charcoal
  static const Color secondary = Color(0xFF4B5563); // soft slate
  static const Color accent = Color(0xFF7C8A9F); // washed ink
  static const Color bgTop = Color(0xFFF6F7F9); // rice paper
  static const Color bgBottom = Color(0xFFE7ECF2); // misted grey
  static const Color surface = Color(0xFFFDFDFD);
  static const Color cardBase = Color(0xE6F7F8FA); // pale wash
  static const Color cardBorder = Color(0x22000000); // soft edge
  static const Color textDark = Color(0xFF111827);
  static const Color textMid = Color(0xFF4B5563);
  static const Color textLight = Color(0xFF6B7280);

  // ── Gradients ─────────────────────────────────────────────
  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [bgTop, bgBottom],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1F2933), Color(0xFF4B5563)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C8A9F), Color(0xFFD1D9E3)],
  );

  // ── Glass card decoration ─────────────────────────────────
  static BoxDecoration glassCard({
    double borderRadius = 20,
    Color? tint,
    double opacity = 0.75,
  }) =>
      BoxDecoration(
        color: (tint ?? surface).withAlphaPercent(opacity),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: cardBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withAlphaPercent(0.6),
            blurRadius: 12,
            offset: const Offset(-4, -4),
          ),
          BoxShadow(
            color: primary.withAlphaPercent(0.08),
            blurRadius: 20,
            offset: const Offset(8, 8),
          ),
        ],
      );

  // ── ThemeData ─────────────────────────────────────────────
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: 'Futura',
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ).copyWith(surface: bgTop),
    );

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0x00000000),
      textTheme: base.textTheme.copyWith(
        displayLarge: const TextStyle(
          fontFamily: 'Futura',
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: textDark,
        ),
        titleLarge: const TextStyle(
          fontFamily: 'Futura',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textDark,
        ),
        titleMedium: const TextStyle(
          fontFamily: 'Futura',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        bodyLarge: const TextStyle(
          fontFamily: 'Futura',
          fontSize: 15,
          color: textMid,
        ),
        bodyMedium: const TextStyle(
          fontFamily: 'Futura',
          fontSize: 14,
          color: textMid,
        ),
        labelSmall: const TextStyle(
          fontFamily: 'Futura',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: textLight,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: textDark),
        titleTextStyle: TextStyle(
          fontFamily: 'Futura',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textDark,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withAlphaPercent(0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: cardBorder, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: Colors.white.withAlphaPercent(0.7), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        labelStyle: const TextStyle(color: textMid, fontSize: 14),
        hintStyle: const TextStyle(color: textLight, fontSize: 14),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withAlphaPercent(0.6),
        selectedColor: primary.withAlphaPercent(0.2),
        labelStyle: const TextStyle(fontSize: 13),
        side: BorderSide(color: Colors.white.withAlphaPercent(0.7)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

extension ColorOpacityExtensions on Color {
  Color withAlphaPercent(double opacity) =>
      withAlpha((opacity.clamp(0.0, 1.0) * 0xFF).round());
}
