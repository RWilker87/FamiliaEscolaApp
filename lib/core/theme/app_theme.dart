import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../constants/app_spacing.dart';
import '../constants/app_radius.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final colorScheme = const ColorScheme(
      brightness: Brightness.light,

      // Primary — Emerald 600
      primary: AppColors.primary600,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.primary100,
      onPrimaryContainer: AppColors.primary800,

      // Secondary — Blue
      secondary: AppColors.accentBlue,
      onSecondary: AppColors.white,
      secondaryContainer: AppColors.infoLight,
      onSecondaryContainer: AppColors.infoDark,

      // Tertiary — Purple
      tertiary: AppColors.accentPurple,
      onTertiary: AppColors.white,
      tertiaryContainer: Color(0xFFF5F3FF),
      onTertiaryContainer: Color(0xFF4C1D95),

      // Error
      error: AppColors.error,
      onError: AppColors.white,
      errorContainer: AppColors.errorLight,
      onErrorContainer: AppColors.errorDark,

      // Surface
      surface: AppColors.white,
      onSurface: AppColors.neutral900,
      surfaceContainerHighest: AppColors.neutral100,
      onSurfaceVariant: AppColors.neutral600,

      // Outline
      outline: AppColors.neutral300,
      outlineVariant: AppColors.neutral200,

      // Background (scaffold)
      // ignore: deprecated_member_use
      background: AppColors.neutral50,
      // ignore: deprecated_member_use
      onBackground: AppColors.neutral900,

      // Shadow & scrim
      shadow: Color(0x1A0F172A),
      scrim: Color(0x520F172A),

      // Inverse
      inverseSurface: AppColors.neutral800,
      onInverseSurface: AppColors.neutral100,
      inversePrimary: AppColors.primary300,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.neutral50,

      // ── AppBar ────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: AppColors.neutral200,
        centerTitle: false,
        titleTextStyle: AppTypography.titleLarge,
        iconTheme: const IconThemeData(color: AppColors.neutral700),
        actionsIconTheme: const IconThemeData(color: AppColors.neutral700),
      ),

      // ── Card ──────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.cardBorder,
          side: BorderSide(color: AppColors.neutral200, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),

      // ── FilledButton ──────────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary600,
          foregroundColor: AppColors.white,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.lg,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.buttonBorder),
          textStyle: AppTypography.labelLarge,
          elevation: 0,
        ),
      ),

      // ── OutlinedButton ────────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary600,
          side: const BorderSide(color: AppColors.primary600, width: 1.5),
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.lg,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.buttonBorder),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // ── TextButton ────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary600,
          textStyle: AppTypography.labelLarge,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm)),
          ),
        ),
      ),

      // ── ElevatedButton (manter compatível) ────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary600,
          foregroundColor: AppColors.white,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.lg,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.buttonBorder),
          textStyle: AppTypography.labelLarge,
          elevation: 0,
        ),
      ),

      // ── Input ─────────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.inputBorder,
          borderSide: const BorderSide(color: AppColors.neutral300, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputBorder,
          borderSide: const BorderSide(color: AppColors.neutral200, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputBorder,
          borderSide: const BorderSide(color: AppColors.primary600, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputBorder,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputBorder,
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: AppTypography.bodyMedium.copyWith(color: AppColors.neutral500),
        floatingLabelStyle: AppTypography.labelLarge.copyWith(color: AppColors.primary600),
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.neutral400),
        errorStyle: AppTypography.caption.copyWith(color: AppColors.error),
      ),

      // ── BottomNavigationBar ───────────────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary600,
        unselectedItemColor: AppColors.neutral400,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTypography.caption,
      ),

      // ── NavigationBar (M3) ────────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.white,
        indicatorColor: AppColors.primary100,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary600, size: 24);
          }
          return const IconThemeData(color: AppColors.neutral400, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.caption.copyWith(
              color: AppColors.primary600,
              fontWeight: FontWeight.w600,
            );
          }
          return AppTypography.caption;
        }),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),

      // ── Divider ───────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.neutral200,
        thickness: 1,
        space: 1,
      ),

      // ── ListTile ──────────────────────────────────────────────────────────
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
      ),

      // ── SnackBar ──────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
        ),
        backgroundColor: AppColors.neutral800,
        contentTextStyle: AppTypography.bodyMedium.copyWith(color: AppColors.white),
        actionTextColor: AppColors.primary300,
      ),

      // ── Dialog ────────────────────────────────────────────────────────────
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.xl)),
        ),
        elevation: 0,
      ),

      // ── Chip ──────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.neutral100,
        selectedColor: AppColors.primary100,
        labelStyle: AppTypography.labelMedium,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.xs)),
          side: BorderSide(color: AppColors.neutral200),
        ),
      ),

      // ── FloatingActionButton ──────────────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary600,
        foregroundColor: AppColors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.lg)),
        ),
      ),

      // ── CircularProgressIndicator ─────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary600,
      ),

      // ── Switch ────────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.white;
          return AppColors.neutral400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary600;
          return AppColors.neutral200;
        }),
      ),
    );
  }
}
