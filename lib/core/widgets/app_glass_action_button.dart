import 'package:call_schedular/core/widgets/app_glass_container.dart';
import 'package:call_schedular/theme/app_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class AppGlassActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool expand;

  const AppGlassActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(15.r),
        child: AppGlassContainer(
          padding: EdgeInsets.symmetric(
            horizontal: 14.w,
            vertical: 0,
          ),
          borderRadius: BorderRadius.circular(15.r),
          blurSigma: 16,
          opacity: 0.82,
          tintColor: colorScheme.primary,
          border: Border.all(
            color: colorScheme.onPrimary.withValues(alpha: 0.32),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.20),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
          child: isLoading
              ? SizedBox(
            height: 18.sp,
            width: 18.sp,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colorScheme.onPrimary,
            ),
          )
              : Row(
            mainAxisSize:
            expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 19.sp,
                color: colorScheme.onPrimary,
              ),
              SizedBox(width: 7.w),
              Text(
                label,
                style: AppFont.style.copyWith(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (expand) {
      return SizedBox(
        width: double.infinity,
        height: 44.h,
        child: button,
      );
    }

    return SizedBox(
      height: 44.h,
      child: button,
    );
  }
}