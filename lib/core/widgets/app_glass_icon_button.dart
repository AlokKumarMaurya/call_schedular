import 'package:call_schedular/core/widgets/app_glass_container.dart';
import 'package:call_schedular/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class AppGlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color iconColor;
  final Color tintColor;
  final String? tooltip;
  final double size;
  final double iconSize;

  const AppGlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.iconColor = AppColors.textPrimary,
    this.tintColor = AppColors.white,
    this.tooltip,
    this.size = 46,
    this.iconSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(15.r),
        child: AppGlassContainer(
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(15.r),
          blurSigma: 16,
          opacity: 0.68,
          tintColor: tintColor,
          border: Border.all(
            color: AppColors.white.withValues(alpha: 0.75),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.7),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          child: SizedBox(
            width: size.w,
            height: size.w,
            child: Icon(
              icon,
              size: iconSize.sp,
              color: iconColor,
            ),
          ),
        ),
      ),
    );

    if (tooltip == null) {
      return button;
    }

    return Tooltip(
      message: tooltip!,
      child: button,
    );
  }
}