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
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.sp, horizontal: 16.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.sp),
        color: isSelected ? AppColors.primary : AppColors.primaryLight,
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        style: AppFont.style.copyWith(
          color: isSelected ? AppColors.white : AppColors.textTertiary,
        ),
      ),
    );
  }
}
