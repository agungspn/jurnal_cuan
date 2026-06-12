import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryGreen = Color(0xFF00C896);
  static const Color primaryDark = Color(0xFF0A1628);
  static const Color surfaceDark = Color(0xFF111F38);
  static const Color cardDark = Color(0xFF1A2E4A);
  static const Color accentGold = Color(0xFFFFCC02);
  static const Color profitGreen = Color(0xFF00E676);
  static const Color lossRed = Color(0xFFFF4757);
  static const Color textPrimary = Color(0xFFE8F4FF);
  static const Color textSecondary = Color(0xFF8BA3C1);
  static const Color borderColor = Color(0xFF1E3A5F);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primaryDark,
      colorScheme: const ColorScheme.dark(
        primary: primaryGreen,
        secondary: accentGold,
        surface: surfaceDark,
        onPrimary: primaryDark,
        onSecondary: primaryDark,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w800),
          displayMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
          headlineLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
          headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
          titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: textPrimary),
          bodyMedium: TextStyle(color: textSecondary),
          labelLarge: TextStyle(color: primaryDark, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: lossRed),
        ),
        hintStyle: const TextStyle(color: textSecondary),
        labelStyle: const TextStyle(color: textSecondary),
        prefixIconColor: textSecondary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: primaryDark,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      // PERBAIKAN: Menggunakan CardTheme (tanpa kata 'Data' di belakangnya)
      cardTheme: CardTheme(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderColor),
        ),
      ),
    );
  }
}