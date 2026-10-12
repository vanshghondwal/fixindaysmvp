import 'package:flutter/material.dart';

/// FixinDays brand theme — matched to the InnoHacks 4.0 pitch deck.
class FixTheme {
  static const Color primary = Color(0xFF2196F3); // deck blue
  static const Color primaryDark = Color(0xFF0D1B2A); // deck navy
  static const Color accent = Color(0xFF4CAF50); // "brighter days" green
  static const Color star = Color(0xFFFFB300); // rating stars
  static const Color rupee = Color(0xFFFF9800); // transparent pricing badge

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
