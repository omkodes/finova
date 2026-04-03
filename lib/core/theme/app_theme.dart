import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

extension ColorSchemeExtension on ColorScheme {
  Color get surfaceContainerLowest => brightness == Brightness.light ? AppColors.surfaceContainerLowest : AppColors.darkSurfaceContainerLowest;
  Color get surfaceContainerLow => brightness == Brightness.light ? AppColors.surfaceContainerLow : AppColors.darkSurfaceContainerLow;
  Color get surfaceContainer => brightness == Brightness.light ? AppColors.surfaceContainer : AppColors.darkSurfaceContainer;
  Color get surfaceContainerHighest => brightness == Brightness.light ? AppColors.surfaceContainerHighest : AppColors.darkSurfaceContainerHighest;

  Color get onSurfaceVariantSafe => brightness == Brightness.light ? AppColors.onSurfaceVariant : AppColors.darkOnSurfaceVariant;
  Color get outlineVariantSafe => brightness == Brightness.light ? AppColors.outlineVariant : AppColors.darkOutlineVariant;
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        background: AppColors.background,
        onBackground: AppColors.onBackground,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: _buildTextTheme(),
      appBarTheme: _buildAppBarTheme(false),
      elevatedButtonTheme: _buildElevatedButtonTheme(false),
      inputDecorationTheme: _buildInputDecorationTheme(false),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.darkPrimary,
        onPrimary: AppColors.darkOnPrimary,
        primaryContainer: AppColors.darkPrimaryContainer,
        onPrimaryContainer: AppColors.darkOnPrimaryContainer,
        secondary: AppColors.darkSecondary,
        onSecondary: AppColors.darkOnSecondary,
        secondaryContainer: AppColors.darkSecondaryContainer,
        error: AppColors.errorContainer,
        onError: AppColors.error,
        background: AppColors.darkBackground,
        onBackground: AppColors.darkOnBackground,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkOnSurface,
        onSurfaceVariant: AppColors.darkOnSurfaceVariant,
        outline: AppColors.darkOutline,
        outlineVariant: AppColors.darkOutlineVariant,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: _buildTextTheme().apply(
        bodyColor: AppColors.darkOnSurface,
        displayColor: AppColors.darkOnSurface,
        decorationColor: AppColors.darkOnSurface,
      ),
      appBarTheme: _buildAppBarTheme(true),
      elevatedButtonTheme: _buildElevatedButtonTheme(true),
      inputDecorationTheme: _buildInputDecorationTheme(true),
    );
  }

  static AppBarTheme _buildAppBarTheme(bool isDark) {
    final onSurface = isDark ? AppColors.darkOnSurface : AppColors.onSurface;
    return AppBarTheme(
      backgroundColor: (isDark ? AppColors.darkBackground : AppColors.background).withOpacity(0.8),
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: onSurface),
      titleTextStyle: GoogleFonts.manrope(
        color: onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme(bool isDark) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark ? AppColors.darkPrimary : AppColors.primary,
        foregroundColor: isDark ? AppColors.darkOnPrimary : AppColors.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme(bool isDark) {
    final surfaceLowest = isDark ? AppColors.darkSurfaceContainerLowest : AppColors.surfaceContainerLowest;
    final outlineColor = isDark ? AppColors.darkOutlineVariant : AppColors.outlineVariant;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;

    return InputDecorationTheme(
      filled: true,
      fillColor: surfaceLowest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: outlineColor.withOpacity(0.15)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: outlineColor.withOpacity(0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      labelStyle: GoogleFonts.inter(color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant),
    );
  }

  static TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.manrope(fontSize: 57, fontWeight: FontWeight.bold, letterSpacing: -1.14),
      displayMedium: GoogleFonts.manrope(fontSize: 45, fontWeight: FontWeight.bold, letterSpacing: -0.9),
      displaySmall: GoogleFonts.manrope(fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: -0.72),
      headlineLarge: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.w700),
      headlineMedium: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.w700),
      headlineSmall: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w700),
      titleLarge: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      titleSmall: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400),
      bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400),
      labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
      labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
      labelSmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500),
    );
  }
}
