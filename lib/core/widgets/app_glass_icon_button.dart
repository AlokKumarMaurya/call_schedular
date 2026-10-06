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
    this.size = 40,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final effectiveIconColor = iconColor ?? colors.textPrimary;

    final effectiveTintColor = tintColor ?? colors.glassTint;

    final borderColor = tintColor != null
        ? effectiveTintColor.withValues(alpha: isDark ? 0.28 : 0.35)
        : isDark
        ? colors.primary.withValues(alpha: 0.20)
        : Colors.white.withValues(alpha: 0.72);

    final button = UnconstrainedBox(
      child: Semantics(
        button: true,
        enabled: true,
        label: tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(14.r),
            splashColor: effectiveIconColor.withValues(alpha: 0.12),
            highlightColor: effectiveIconColor.withValues(alpha: 0.08),
            child: AppGlassContainer(
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.circular(14.r),
              blurSigma: 16,
              opacity: isDark ? 0.50 : 0.60,
              tintColor: effectiveTintColor,
              border: Border.all(color: borderColor, width: 1),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
              child: SizedBox(
                width: size.w,
                height: size.w,
                child: Center(
                  child: Icon(
                    icon,
                    size: iconSize.sp,
                    color: effectiveIconColor,
                  ),
                ),
              ),
            ),
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
