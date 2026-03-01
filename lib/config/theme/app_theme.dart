import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

/// Application theme — matches the Astro website design system.
///
/// Re-exports for convenience:
///   import 'package:fashion_store_flutter/config/theme/app_theme.dart';
///   // gives you AppTheme, AppColors, AppTypography, AppSpacing
export 'app_colors.dart';
export 'app_typography.dart';
export 'app_spacing.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppTypography.fontFamily,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.white,
        secondary: AppColors.secondary,
        onSecondary: AppColors.white,
        surface: AppColors.surface,
        onSurface: AppColors.text,
        error: AppColors.error,
        onError: AppColors.white,
      ),

      // ─── AppBar ───
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.text,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        titleTextStyle: AppTypography.headlineSmall.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),

      // ─── Cards ───
      cardTheme: CardThemeData(
        color: AppColors.cardBg,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: const BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),

      // ─── Elevated buttons ───
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.grey300,
          disabledForegroundColor: AppColors.grey500,
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          elevation: 0,
          textStyle: AppTypography.buttonText,
        ),
      ),

      // ─── Text buttons ───
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          textStyle: AppTypography.titleMedium,
        ),
      ),

      // ─── Outlined buttons ───
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle:
              AppTypography.buttonText.copyWith(color: AppColors.primary),
        ),
      ),

      // ─── Input decoration ───
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
          gapPadding: 6,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
          gapPadding: 6,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
          gapPadding: 6,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
          gapPadding: 6,
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
          gapPadding: 6,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textHint),
        labelStyle:
            AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        floatingLabelStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
        errorStyle: AppTypography.bodySmall.copyWith(color: AppColors.error),
      ),

      // ─── Chips ───
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.greyLight,
        selectedColor: AppColors.primary,
        labelStyle: AppTypography.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
        ),
      ),

      // ─── Bottom nav ───
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),

      // ─── FAB ───
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),

      // ─── Divider ───
      dividerColor: AppColors.divider,

      // ─── Text theme ───
      textTheme: const TextTheme(
        displayLarge: AppTypography.displayLarge,
        displayMedium: AppTypography.displayMedium,
        displaySmall: AppTypography.displaySmall,
        headlineMedium: AppTypography.headlineMedium,
        headlineSmall: AppTypography.headlineSmall,
        titleLarge: AppTypography.titleLarge,
        titleMedium: AppTypography.titleMedium,
        titleSmall: AppTypography.titleSmall,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.labelLarge,
      ),
    );
  }
}
