import 'package:call_schedular/theme/app_font.dart';
import 'package:call_schedular/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class AppFilterChip extends StatelessWidget {
  final String title;
  final bool isSelected;

  const AppFilterChip({
    required this.isSelected,
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(
        vertical: 9.h,
        horizontal: 16.w,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        color: isSelected
            ? colorScheme.primary
            : colors.surface,
        border: Border.all(
          color: isSelected
              ? colorScheme.primary
              : colors.border,
        ),
        boxShadow: isSelected
            ? [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ]
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        style: AppFont.style.copyWith(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: isSelected
              ? colorScheme.onPrimary
              : colors.textSecondary,
        ),
      ),
    );
  }
}