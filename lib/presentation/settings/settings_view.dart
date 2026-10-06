import 'package:call_schedular/constants/app_const.dart';
import 'package:call_schedular/theme/app_colors.dart';
import 'package:call_schedular/theme/app_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:get/get.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppFont.style.copyWith(
            fontSize: 22.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.black,
            size: 24.sp,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _buildSectionTitle('Notifications'),

          _buildSettingTile(
            icon: Icons.notifications_outlined,
            iconBackground: AppColors.iconBlueBackground,
            iconColor: AppColors.iconBlue,
            title: 'Notifications',
            subtitle: 'Manage call reminder notifications',
            onTap: () {},
          ),

          SizedBox(height: 24.h),

          _buildSectionTitle('About'),

          _buildSettingTile(
            icon: Icons.info_outline,
            iconBackground: AppColors.iconPurpleBackground,
            iconColor: AppColors.iconPurple,
            title: 'About',
            subtitle: AppConst.appName,
            onTap: () {},
          ),

          SizedBox(height: 24.h),

          _buildSectionTitle('App Information'),

          _buildSettingTile(
            icon: Icons.phone_android_outlined,
            iconBackground: AppColors.iconGreenBackground,
            iconColor: AppColors.iconGreen,
            title: 'App Information',
            subtitle: 'Version and application details',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
      child: Text(
        title,
        style: AppFont.style.copyWith(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required Color iconBackground,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22.sp,
                ),
              ),

              SizedBox(width: 14.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppFont.style.copyWith(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: AppFont.style.copyWith(
                        fontSize: 12.sp,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
                size: 22.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}