import 'package:call_schedular/theme/app_font.dart';
import 'package:call_schedular/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class ScheduleInputField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController controller;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const ScheduleInputField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppFont.style.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: colors.textSecondary,
          ),
        ),

        SizedBox(height: 6.h),

        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: AppFont.style.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: colors.textPrimary,
          ),
          cursorColor: colorScheme.primary,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppFont.style.copyWith(
              fontSize: 14.sp,
              color: colors.textTertiary,
            ),
            prefixIcon: prefixIcon == null
                ? null
                : Icon(
              prefixIcon,
              size: 20.sp,
              color: colors.textSecondary,
            ),
            suffixIcon: suffixIcon,

            filled: true,
            fillColor: colors.surface,

            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 12.h,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: colors.border,
              ),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: colors.border,
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: colorScheme.primary,
                width: 1.5,
              ),
            ),

            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: colors.dangerDark,
              ),
            ),

            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: colors.dangerDark,
                width: 1.5,
              ),
            ),

            errorStyle: AppFont.style.copyWith(
              fontSize: 11.sp,
              color: colors.dangerDark,
            ),
          ),
        ),
      ],
    );
  }
}