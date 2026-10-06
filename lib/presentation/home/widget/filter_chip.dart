import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_font.dart';

class AppFilterChip extends StatelessWidget {
  final String title;
  final bool isSelected;

  const AppFilterChip({required this.isSelected, required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(
        vertical: 9.h,
        horizontal: 16.w,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        color: isSelected
            ? AppColors.primary
            : AppColors.surface,
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : AppColors.border,
        ),
        boxShadow: isSelected
            ? [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
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
              ? AppColors.white
              : AppColors.textSecondary,
        ),
      ),
    );
  }
}
