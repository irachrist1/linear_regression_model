import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // core palette
  static const Color background = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF111118);
  static const Color surfaceElevated = Color(0xFF1A1A24);
  static const Color border = Color(0xFF2A2A38);

  static const Color textPrimary = Color(0xFFF2F2F7);
  static const Color textSecondary = Color(0xFF8E8EA0);
  static const Color textTertiary = Color(0xFF48485C);

  // risk colors mapped to health score thresholds
  static const Color riskLow = Color(0xFF34C759);
  static const Color riskMedium = Color(0xFFFF9F0A);
  static const Color riskHigh = Color(0xFFFF6B35);
  static const Color riskCritical = Color(0xFFFF3B30);

  static const Color accent = Color(0xFF6E6BFA);

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        surface: surface,
        primary: accent,
        onPrimary: textPrimary,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  static Color riskColor(String level) {
    switch (level) {
      case 'Low':
        return riskLow;
      case 'Medium':
        return riskMedium;
      case 'High':
        return riskHigh;
      case 'Critical':
        return riskCritical;
      default:
        return textSecondary;
    }
  }
}
