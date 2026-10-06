import 'package:call_schedular/constants/app_const.dart';
import 'package:call_schedular/theme/app_colors.dart';
import 'package:call_schedular/theme/app_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../services/notification_service.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView>
    with WidgetsBindingObserver {
  bool _notificationsEnabled = false;
  bool _isLoadingNotifications = true;
  String _appVersion = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _loadNotificationStatus();
    _loadAppInfo();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadNotificationStatus();
    }
  }

  Future<void> _loadAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();

    if (!mounted) return;

    setState(() {
      _appVersion = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
    });
  }

  Future<void> _loadNotificationStatus() async {
    final enabled = await NotificationService.instance
        .areNotificationsEnabled();

    if (!mounted) return;

    setState(() {
      _notificationsEnabled = enabled;
      _isLoadingNotifications = false;
    });
  }

  Future<void> _openNotificationSettings() async {
    await NotificationService.instance.openNotificationSettings();
  }

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
          icon: Icon(Icons.arrow_back, color: AppColors.black, size: 24.sp),
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
            subtitle: _isLoadingNotifications
                ? 'Checking notification status...'
                : _notificationsEnabled
                ? 'Enabled'
                : 'Disabled',
            onTap: _openNotificationSettings,
          ),

          SizedBox(height: 24.h),

          _buildSectionTitle('About'),

          _buildSettingTile(
            icon: Icons.info_outline,
            iconBackground: AppColors.iconPurpleBackground,
            iconColor: AppColors.iconPurple,
            title: 'About',
            subtitle: AppConst.appName,
            onTap: _showAboutDialog,
          ),

          SizedBox(height: 24.h),

          _buildSectionTitle('App Information'),

          _buildSettingTile(
            icon: Icons.phone_android_outlined,
            iconBackground: AppColors.iconGreenBackground,
            iconColor: AppColors.iconGreen,
            title: 'App Information',
            subtitle: 'Version $_appVersion • Build $_buildNumber',
            onTap: _showAppInformation,
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
                child: Icon(icon, color: iconColor, size: 22.sp),
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

  void _showAboutDialog() {
    Get.dialog(
      AlertDialog(
        title: Text(
          AppConst.appName,
          style: AppFont.style.copyWith(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A simple app to schedule and manage your calls.',
              style: AppFont.style.copyWith(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),

            SizedBox(height: 16.h),

            Text(
              'Version $_appVersion',
              style: AppFont.style.copyWith(
                fontSize: 13.sp,
                color: AppColors.textTertiary,
              ),
            ),

            SizedBox(height: 4.h),

            Text(
              'Build $_buildNumber',
              style: AppFont.style.copyWith(
                fontSize: 13.sp,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(
              'OK',
              style: AppFont.style.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAppInformation() {
    Get.dialog(
      AlertDialog(
        title: Text(
          'App Information',
          style: AppFont.style.copyWith(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              'App Name',
              AppConst.appName,
            ),
            SizedBox(height: 12.h),
            _buildInfoRow(
              'Version',
              _appVersion,
            ),
            SizedBox(height: 12.h),
            _buildInfoRow(
              'Build',
              _buildNumber,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(
              'OK',
              style: AppFont.style.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      String label,
      String value,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80.w,
          child: Text(
            label,
            style: AppFont.style.copyWith(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? 'Loading...' : value,
            style: AppFont.style.copyWith(
              fontSize: 13.sp,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
