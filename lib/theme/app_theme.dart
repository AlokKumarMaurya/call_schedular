import 'package:flutter/material.dart';

import 'app_theme_colors.dart';

final ThemeData appTheme = _buildTheme(
  brightness: Brightness.light,
  colors: AppThemeColors.light,
);

final ThemeData appDarkTheme = _buildTheme(
  brightness: Brightness.dark,
  colors: AppThemeColors.dark,
);

ThemeData _buildTheme({
  required Brightness brightness,
  required AppThemeColors colors,
}) {
  final isDark = brightness == Brightness.dark;

  final colorScheme = ColorScheme.fromSeed(
    seedColor: colors.primary,
    brightness: brightness,

    primary: colors.primary,
    onPrimary: colors.onPrimary,

    primaryContainer: colors.primaryLight,
    onPrimaryContainer: colors.primary,

    error: colors.dangerDark,
    errorContainer: colors.dangerLight,
    onError: colors.textPrimary,
    onErrorContainer: colors.dangerDark,

    outline: colors.border,
    outlineVariant: colors.divider,

    surface: colors.surface,
    onSurface: colors.textPrimary,
    onSurfaceVariant: colors.textSecondary,

    surfaceDim: colors.background,
    surfaceBright: colors.surfaceElevated,

    surfaceContainerLowest: colors.background,
    surfaceContainerLow: colors.background,
    surfaceContainer: colors.surface,
    surfaceContainerHigh: colors.surfaceElevated,
    surfaceContainerHighest: colors.surfaceElevated,

    shadow: colors.shadow,
  );

  return ThemeData(
    useMaterial3: true,

    brightness: brightness,

    colorScheme: colorScheme,

    scaffoldBackgroundColor: colors.background,

    extensions: <ThemeExtension<dynamic>>[
      colors,
    ],

    appBarTheme: AppBarTheme(
      backgroundColor: colors.background,
      foregroundColor: colors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),

    cardTheme: CardThemeData(
      color: colors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(16),
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.surface,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),

      hintStyle: TextStyle(
        color: colors.textTertiary,
      ),

      labelStyle: TextStyle(
        color: colors.textSecondary,
      ),

      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(14),
        ),
        borderSide: BorderSide(
          color: colors.border,
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(14),
        ),
        borderSide: BorderSide(
          color: colors.border,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(14),
        ),
        borderSide: BorderSide(
          color: colors.primary,
          width: 1.5,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(14),
        ),
        borderSide: BorderSide(
          color: colors.dangerDark,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(14),
        ),
        borderSide: BorderSide(
          color: colors.dangerDark,
          width: 1.5,
        ),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 0,
        minimumSize: const Size(
          double.infinity,
          48,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.primary,
        side: BorderSide(
          color: colors.primary,
        ),
        minimumSize: const Size(
          double.infinity,
          48,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.primary,
        minimumSize: const Size(
          44,
          44,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
      ),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colors.primary,
      foregroundColor: colors.onPrimary,
      elevation: 4,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(18),
        ),
      ),
    ),

    dividerTheme: DividerThemeData(
      color: colors.divider,
      thickness: 1,
      space: 1,
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,

      backgroundColor: isDark
          ? colors.surfaceElevated
          : colors.textPrimary,

      contentTextStyle: TextStyle(
        color: isDark
            ? colors.textPrimary
            : colors.onPrimary,
      ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 8,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),

      titleTextStyle: TextStyle(
        color: colors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),

      contentTextStyle: TextStyle(
        color: colors.textSecondary,
        fontSize: 14,
        height: 1.4,
      ),

      actionsPadding: const EdgeInsets.fromLTRB(
        20,
        0,
        20,
        12,
      ),
    ),
  );
}