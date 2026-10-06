import 'package:call_schedular/theme/app_colors.dart';
import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  useMaterial3: true,

  scaffoldBackgroundColor: AppColors.background,

  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
    primary: AppColors.primary,
    surface: AppColors.surface,
    error: AppColors.danger,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.background,
    foregroundColor: AppColors.textPrimary,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
  ),

  cardTheme: CardThemeData(
    color: AppColors.surface,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(16),
      ),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 14,
    ),

    hintStyle: const TextStyle(
      color: AppColors.textTertiary,
    ),

    labelStyle: const TextStyle(
      color: AppColors.textSecondary,
    ),

    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(14),
      ),
      borderSide: BorderSide(
        color: AppColors.border,
      ),
    ),

    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(14),
      ),
      borderSide: BorderSide(
        color: AppColors.border,
      ),
    ),

    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(14),
      ),
      borderSide: BorderSide(
        color: AppColors.primary,
        width: 1.5,
      ),
    ),

    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(14),
      ),
      borderSide: BorderSide(
        color: AppColors.danger,
      ),
    ),

    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(14),
      ),
      borderSide: BorderSide(
        color: AppColors.danger,
        width: 1.5,
      ),
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: 0,
      minimumSize: const Size(double.infinity, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(
        color: AppColors.primary,
      ),
      minimumSize: const Size(double.infinity, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(14),
        ),
      ),
    ),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(18),
      ),
    ),
  ),

  dividerTheme: const DividerThemeData(
    color: AppColors.divider,
    thickness: 1,
    space: 1,
  ),

  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: AppColors.textPrimary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),

  dialogTheme: DialogThemeData(
    backgroundColor: AppColors.surface,
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),
);