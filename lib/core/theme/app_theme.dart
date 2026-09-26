import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.background,
        onSurface: AppColors.primaryText,
      ).copyWith(
        surfaceContainer: AppColors.card,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(color: AppColors.primaryText, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.poppins(color: AppColors.primaryText, fontWeight: FontWeight.w600),
        displaySmall: GoogleFonts.poppins(color: AppColors.primaryText, fontWeight: FontWeight.w600),
        headlineLarge: GoogleFonts.poppins(color: AppColors.primaryText, fontWeight: FontWeight.w600),
        headlineMedium: GoogleFonts.poppins(color: AppColors.primaryText, fontWeight: FontWeight.w600),
        headlineSmall: GoogleFonts.poppins(color: AppColors.primaryText, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.poppins(color: AppColors.primaryText, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.poppins(color: AppColors.primaryText, fontWeight: FontWeight.w500),
        titleSmall: GoogleFonts.poppins(color: AppColors.primaryText, fontWeight: FontWeight.w500),
        bodyLarge: GoogleFonts.poppins(color: AppColors.primaryText),
        bodyMedium: GoogleFonts.poppins(color: AppColors.primaryText),
        bodySmall: GoogleFonts.poppins(color: AppColors.secondaryText),
        labelLarge: GoogleFonts.poppins(color: AppColors.primaryText, fontWeight: FontWeight.w600),
        labelMedium: GoogleFonts.poppins(color: AppColors.primaryText, fontWeight: FontWeight.w500),
        labelSmall: GoogleFonts.poppins(color: AppColors.primaryText, fontWeight: FontWeight.w500),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: GoogleFonts.poppins(color: AppColors.secondaryText),
        hintStyle: GoogleFonts.poppins(color: AppColors.secondaryText),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
