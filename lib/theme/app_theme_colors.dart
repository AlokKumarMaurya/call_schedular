import 'package:flutter/material.dart';

class AppThemeColors extends ThemeExtension<AppThemeColors> {
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color surfaceBlue;

  final Color glass;
  final Color glassTint;

  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;

  final Color border;
  final Color divider;

  final Color primaryLight;

  final Color successLight;
  final Color successDark;

  final Color dangerLight;
  final Color dangerDark;

  final Color purpleLight;
  final Color purpleDark;

  final Color orangeLight;
  final Color orangeDark;

  final Color shadow;

  const AppThemeColors({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceBlue,
    required this.glass,
    required this.glassTint,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.border,
    required this.divider,
    required this.primaryLight,
    required this.successLight,
    required this.successDark,
    required this.dangerLight,
    required this.dangerDark,
    required this.purpleLight,
    required this.purpleDark,
    required this.orangeLight,
    required this.orangeDark,
    required this.shadow,
  });

  static const light = AppThemeColors(
    background: Color(0xFFEEF3FA),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFF9FBFF),
    surfaceBlue: Color(0xFFF1F5FF),

    glass: Color(0xFFFFFFFF),
    glassTint: Color(0xFFEAF1FF),

    textPrimary: Color(0xFF0C141D),
    textSecondary: Color(0xFF5F6B7A),
    textTertiary: Color(0xFF8B95A5),
    textDisabled: Color(0xFFB5BCC7),

    border: Color(0xFFDCE4EF),
    divider: Color(0xFFE7ECF3),

    primaryLight: Color(0xFFEAF1FF),

    successLight: Color(0xFFE8F9EE),
    successDark: Color(0xFF18A844),

    dangerLight: Color(0xFFFFEEF1),
    dangerDark: Color(0xFFD93650),

    purpleLight: Color(0xFFF0EDFF),
    purpleDark: Color(0xFF765BEF),

    orangeLight: Color(0xFFFFF1E3),
    orangeDark: Color(0xFFE98625),

    shadow: Color(0x1A000000),
  );

  static const dark = AppThemeColors(
    background: Color(0xFF0A111B),
    surface: Color(0xFF141E2B),
    surfaceElevated: Color(0xFF1A2635),
    surfaceBlue: Color(0xFF16233A),

    glass: Color(0xFFFFFFFF),
    glassTint: Color(0xFF315FAF),

    textPrimary: Color(0xFFF7F9FC),
    textSecondary: Color(0xFFB8C1CE),
    textTertiary: Color(0xFF8793A4),
    textDisabled: Color(0xFF5E6877),

    border: Color(0xFF2A3748),
    divider: Color(0xFF222E3D),

    primaryLight: Color(0xFF1D3768),

    successLight: Color(0xFF153A27),
    successDark: Color(0xFF4DDB7B),

    dangerLight: Color(0xFF3D1D26),
    dangerDark: Color(0xFFFF7185),

    purpleLight: Color(0xFF2A2450),
    purpleDark: Color(0xFFA69AFF),

    orangeLight: Color(0xFF3D2A18),
    orangeDark: Color(0xFFFFB968),

    shadow: Color(0x66000000),
  );

  @override
  AppThemeColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? surfaceBlue,
    Color? glass,
    Color? glassTint,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    Color? border,
    Color? divider,
    Color? primaryLight,
    Color? successLight,
    Color? successDark,
    Color? dangerLight,
    Color? dangerDark,
    Color? purpleLight,
    Color? purpleDark,
    Color? orangeLight,
    Color? orangeDark,
    Color? shadow,
  }) {
    return AppThemeColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      surfaceBlue: surfaceBlue ?? this.surfaceBlue,
      glass: glass ?? this.glass,
      glassTint: glassTint ?? this.glassTint,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textDisabled: textDisabled ?? this.textDisabled,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      primaryLight: primaryLight ?? this.primaryLight,
      successLight: successLight ?? this.successLight,
      successDark: successDark ?? this.successDark,
      dangerLight: dangerLight ?? this.dangerLight,
      dangerDark: dangerDark ?? this.dangerDark,
      purpleLight: purpleLight ?? this.purpleLight,
      purpleDark: purpleDark ?? this.purpleDark,
      orangeLight: orangeLight ?? this.orangeLight,
      orangeDark: orangeDark ?? this.orangeDark,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppThemeColors lerp(
      covariant AppThemeColors? other,
      double t,
      ) {
    if (other == null) {
      return this;
    }

    return AppThemeColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated:
      Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      surfaceBlue: Color.lerp(surfaceBlue, other.surfaceBlue, t)!,
      glass: Color.lerp(glass, other.glass, t)!,
      glassTint: Color.lerp(glassTint, other.glassTint, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      successLight: Color.lerp(successLight, other.successLight, t)!,
      successDark: Color.lerp(successDark, other.successDark, t)!,
      dangerLight: Color.lerp(dangerLight, other.dangerLight, t)!,
      dangerDark: Color.lerp(dangerDark, other.dangerDark, t)!,
      purpleLight: Color.lerp(purpleLight, other.purpleLight, t)!,
      purpleDark: Color.lerp(purpleDark, other.purpleDark, t)!,
      orangeLight: Color.lerp(orangeLight, other.orangeLight, t)!,
      orangeDark: Color.lerp(orangeDark, other.orangeDark, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

extension AppThemeColorsContext on BuildContext {
  AppThemeColors get themeColors {
    return Theme.of(this).extension<AppThemeColors>()!;
  }
}