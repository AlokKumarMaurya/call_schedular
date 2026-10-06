import 'dart:ui';

import 'package:call_schedular/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class AppGlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry borderRadius;
  final double blurSigma;
  final double opacity;
  final Color tintColor;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  const AppGlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
    this.blurSigma = 18,
    this.opacity = 0.72,
    this.tintColor = AppColors.white,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: blurSigma,
          sigmaY: blurSigma,
        ),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                tintColor.withValues(alpha: opacity),
                tintColor.withValues(alpha: opacity * 0.62),
              ],
            ),
            border: border ??
                Border.all(
                  color: AppColors.white.withValues(alpha: 0.55),
                  width: 1,
                ),
            boxShadow: boxShadow ??
                [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 18.r,
                    offset: const Offset(0, 6),
                  ),
                ],
          ),
          child: child,
        ),
      ),
    );
  }
}