import 'package:call_schedular/theme/app_font.dart';
import 'package:call_schedular/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class ScheduleOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;
  final bool showDivider;

  const ScheduleOptionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 12.h,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20.sp,
                  color: colorScheme.primary,
                ),

                SizedBox(width: 16.w),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppFont.style.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),

                      SizedBox(height: 4.h),

                      Text(
                        value,
                        style: AppFont.style.copyWith(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.chevron_right_rounded,
                  size: 22.sp,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),

          if (showDivider)
            Divider(
              height: 1,
              indent: 48.w,
              color: colors.divider,
            ),
        ],
      ),
    );
  }
}