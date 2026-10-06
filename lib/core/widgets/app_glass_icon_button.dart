import 'package:call_schedular/core/widgets/app_glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../theme/app_theme_colors.dart';

class AppGlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? iconColor;
  final Color? tintColor;
  final String? tooltip;
  final double size;
  final double iconSize;

  const AppGlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.iconColor,
    this.tintColor,
    this.tooltip,
    this.size = 46,
    this.iconSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    final effectiveIconColor = iconColor ?? colors.textPrimary;

    final effectiveTintColor = tintColor ?? colors.glass;

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
          tintColor: effectiveTintColor,
          border: Border.all(
            color: Colors.white.withValues(
              alpha: Theme.of(context).brightness == Brightness.dark
                  ? 0.18
                  : 0.75,
            ),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.shadow,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          child: SizedBox(
            width: size.w,
            height: size.w,
            child: Icon(icon, size: iconSize.sp, color: effectiveIconColor),
          ),
        ),
      ),
    );

    if (tooltip == null) {
      return button;
    }

    return Tooltip(message: tooltip!, child: button);
  }
}
