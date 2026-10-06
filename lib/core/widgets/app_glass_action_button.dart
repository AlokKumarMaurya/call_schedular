import 'package:call_schedular/core/widgets/app_glass_container.dart';
import 'package:call_schedular/theme/app_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class AppGlassActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const AppGlassActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20.r),
        child: AppGlassContainer(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
          borderRadius: BorderRadius.circular(20.r),
          blurSigma: 18,
          opacity: 0.82,
          tintColor: colorScheme.primary,
          border: Border.all(
            color: colorScheme.onPrimary.withValues(alpha: 0.35),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.24),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 23.sp, color: colorScheme.onPrimary),

              SizedBox(width: 10.w),

              Text(
                label,
                style: AppFont.style.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
