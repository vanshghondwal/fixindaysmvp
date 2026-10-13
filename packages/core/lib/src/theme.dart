import 'package:flutter/material.dart';

/// FixinDays brand design tokens.
/// Palette is fixed by the product spec — solid colours only, no gradients.
class FxColors {
  static const primary = Color(0xFF0AA66A);
  static const darkGreen = Color(0xFF078454);
  static const deepGreen = Color(0xFF056B45);
  static const navy = Color(0xFF082B52);
  static const white = Color(0xFFFFFFFF);
  static const background = Color(0xFFF6F8F7);
  static const secondaryText = Color(0xFF64748B);
  static const borders = Color(0xFFE5EAE7);
  static const error = Color(0xFFDC2626);
  static const warning = Color(0xFFD97706);
  static const success = Color(0xFF0AA66A);
  static const star = Color(0xFFF59E0B);
}

/// Spacing scale.
class FxSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

/// Corner radii.
class FxRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
}

/// App-wide ThemeData. Light theme is the primary design.
class FxTheme {
  FxTheme._();

  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: FxColors.primary,
      onPrimary: FxColors.white,
      primaryContainer: Color(0xFFE3F4EC),
      onPrimaryContainer: FxColors.deepGreen,
      secondary: FxColors.navy,
      onSecondary: FxColors.white,
      error: FxColors.error,
      onError: FxColors.white,
      surface: FxColors.white,
      onSurface: FxColors.navy,
      surfaceContainerHighest: FxColors.background,
      onSurfaceVariant: FxColors.secondaryText,
      outline: FxColors.borders,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: FxColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: FxColors.primary,
        foregroundColor: FxColors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: FxColors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: FxColors.white,
        elevation: 1,
        shadowColor: FxColors.navy.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FxRadius.lg),
          side: const BorderSide(color: FxColors.borders, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: FxColors.primary,
          foregroundColor: FxColors.white,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FxRadius.md),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: FxColors.primary,
          minimumSize: const Size(48, 48),
          side: const BorderSide(color: FxColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FxRadius.md),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: FxColors.primary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FxColors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FxRadius.md),
          borderSide: const BorderSide(color: FxColors.borders),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FxRadius.md),
          borderSide: const BorderSide(color: FxColors.borders),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FxRadius.md),
          borderSide: const BorderSide(color: FxColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FxRadius.md),
          borderSide: const BorderSide(color: FxColors.error),
        ),
        hintStyle: const TextStyle(color: FxColors.secondaryText),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FxRadius.sm),
        ),
      ),
      dividerTheme: const DividerThemeData(color: FxColors.borders, thickness: 1),
    );
  }
}

/// Shared text styles.
class FxText {
  static const headline =
      TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: FxColors.navy);
  static const title =
      TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: FxColors.navy);
  static const subtitle =
      TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: FxColors.navy);
  static const body = TextStyle(fontSize: 14, color: FxColors.navy);
  static const caption =
      TextStyle(fontSize: 12, color: FxColors.secondaryText);
  static const price =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: FxColors.navy);
}
