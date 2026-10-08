import 'package:call_schedular/constants/app_const.dart';
import 'package:call_schedular/services/app_update_service.dart';
import 'package:call_schedular/services/notification_service.dart';
import 'package:call_schedular/theme/app_font.dart';
import 'package:call_schedular/theme/app_theme_colors.dart';
import 'package:call_schedular/theme/app_theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/widgets/app_glass_icon_button.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView>
    with WidgetsBindingObserver {
  late final AppThemeController _themeController;

  bool _notificationsEnabled = false;
  bool _isLoadingNotifications = true;

  bool _isCheckingForUpdate = false;

  String _appVersion = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();

    _themeController = Get.find<AppThemeController>();

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

    if (!mounted) {
      return;
    }

    setState(() {
      _appVersion = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
    });
  }

  Future<void> _loadNotificationStatus() async {
    final enabled = await NotificationService.instance
        .areNotificationsEnabled();

    if (!mounted) {
      return;
    }

    setState(() {
      _notificationsEnabled = enabled;
      _isLoadingNotifications = false;
    });
  }

  Future<void> _openNotificationSettings() async {
    await NotificationService.instance.openNotificationSettings();
  }

  Future<void> _checkForUpdates() async {
    if (_isCheckingForUpdate) {
      return;
    }

    setState(() {
      _isCheckingForUpdate = true;
    });

    try {
      await AppUpdateService.instance.checkAndPromptManually();
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        _isCheckingForUpdate = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 62.w,
        leading: Padding(
          padding: EdgeInsets.only(
            left: 12.w,
            top: 4.h,
            bottom: 2.h,
          ),
          child: AppGlassIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            tooltip: 'Back',
            onPressed: Get.back,
          ),
        ),
        title: Text(
          'Settings',
          style: AppFont.style.copyWith(
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16.w,
          8.h,
          16.w,
          24.h,
        ),
        children: [
          _buildSectionTitle(
            context,
            'Appearance',
          ),

          Obx(
                () => _buildSettingTile(
              context,
              icon: _themeModeIcon(
                _themeController.themeMode.value,
              ),
              iconBackground: colors.primaryLight,
              iconColor: Theme.of(context).colorScheme.primary,
              title: 'Appearance',
              subtitle: _themeModeLabel(
                _themeController.themeMode.value,
              ),
              onTap: _showAppearanceSheet,
            ),
          ),

          SizedBox(height: 24.h),

          _buildSectionTitle(
            context,
            'Notifications',
          ),

          _buildSettingTile(
            context,
            icon: Icons.notifications_outlined,
            iconBackground: colors.primaryLight,
            iconColor: Theme.of(context).colorScheme.primary,
            title: 'Notifications',
            subtitle: _isLoadingNotifications
                ? 'Checking notification status...'
                : _notificationsEnabled
                ? 'Enabled'
                : 'Disabled',
            onTap: _openNotificationSettings,
          ),

          SizedBox(height: 24.h),

          _buildSectionTitle(
            context,
            'App Updates',
          ),

          _buildSettingTile(
            context,
            icon: Icons.system_update_rounded,
            iconBackground: colors.orangeLight,
            iconColor: colors.orangeDark,
            title: 'Check for Updates',
            subtitle: _isCheckingForUpdate
                ? 'Checking Google Play...'
                : 'Check for the latest version',
            trailing: _isCheckingForUpdate
                ? SizedBox(
              width: 20.w,
              height: 20.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.orangeDark,
              ),
            )
                : null,
            onTap: _isCheckingForUpdate
                ? null
                : _checkForUpdates,
          ),

          SizedBox(height: 24.h),

          _buildSectionTitle(
            context,
            'About',
          ),

          _buildSettingTile(
            context,
            icon: Icons.info_outline_rounded,
            iconBackground: colors.purpleLight,
            iconColor: colors.purpleDark,
            title: 'About',
            subtitle: AppConst.appName,
            onTap: _showAboutDialog,
          ),

          SizedBox(height: 24.h),

          _buildSectionTitle(
            context,
            'App Information',
          ),

          _buildSettingTile(
            context,
            icon: Icons.phone_android_outlined,
            iconBackground: colors.successLight,
            iconColor: colors.successDark,
            title: 'App Information',
            subtitle: 'Version $_appVersion • Build $_buildNumber',
            onTap: _showAppInformation,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
      BuildContext context,
      String title,
      ) {
    final colors = context.themeColors;

    return Padding(
      padding: EdgeInsets.only(
        left: 4.w,
        bottom: 8.h,
      ),
      child: Text(
        title,
        style: AppFont.style.copyWith(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: colors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSettingTile(
      BuildContext context, {
        required IconData icon,
        required Color iconBackground,
        required Color iconColor,
        required String title,
        required String subtitle,
        required VoidCallback? onTap,
        Widget? trailing,
      }) {
    final colors = context.themeColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: colors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 12.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18.r),
          child: Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(13.r),
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
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppFont.style.copyWith(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),

                      SizedBox(height: 4.h),

                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFont.style.copyWith(
                          fontSize: 12.sp,
                          color: colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 8.w),

                trailing ??
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colors.textTertiary,
                      size: 22.sp,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showAppearanceSheet() async {
    final colors = context.themeColors;

    await Get.bottomSheet(
      SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28.r),
            ),
            border: Border.all(
              color: colors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 24.r,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(
            20.w,
            12.h,
            20.w,
            20.h,
          ),
          child: Obx(() {
            final selectedMode =
                _themeController.themeMode.value;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius:
                    BorderRadius.circular(10.r),
                  ),
                ),

                SizedBox(height: 18.h),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Appearance',
                    style: AppFont.style.copyWith(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                ),

                SizedBox(height: 6.h),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Choose how Call Scheduler looks.',
                    style: AppFont.style.copyWith(
                      fontSize: 13.sp,
                      color: colors.textSecondary,
                    ),
                  ),
                ),

                SizedBox(height: 18.h),

                _buildThemeOption(
                  context,
                  mode: ThemeMode.system,
                  icon: Icons.brightness_auto_rounded,
                  title: 'System',
                  subtitle:
                  'Follow your device appearance',
                  selectedMode: selectedMode,
                ),

                SizedBox(height: 10.h),

                _buildThemeOption(
                  context,
                  mode: ThemeMode.light,
                  icon: Icons.light_mode_rounded,
                  title: 'Light',
                  subtitle:
                  'Use the light appearance',
                  selectedMode: selectedMode,
                ),

                SizedBox(height: 10.h),

                _buildThemeOption(
                  context,
                  mode: ThemeMode.dark,
                  icon: Icons.dark_mode_rounded,
                  title: 'Dark',
                  subtitle:
                  'Use the dark appearance',
                  selectedMode: selectedMode,
                ),
              ],
            );
          }),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildThemeOption(
      BuildContext context, {
        required ThemeMode mode,
        required IconData icon,
        required String title,
        required String subtitle,
        required ThemeMode selectedMode,
      }) {
    final colors = context.themeColors;
    final colorScheme = Theme.of(context).colorScheme;

    final isSelected = mode == selectedMode;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _themeController.setThemeMode(mode);
          Get.back();
        },
        borderRadius: BorderRadius.circular(16.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(
            horizontal: 14.w,
            vertical: 12.h,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.primaryLight
                : colors.surfaceElevated,
            borderRadius:
            BorderRadius.circular(16.r),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary.withValues(
                alpha: 0.35,
              )
                  : colors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary.withValues(
                    alpha: 0.12,
                  )
                      : colors.surface,
                  borderRadius:
                  BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? colorScheme.primary
                      : colors.textSecondary,
                  size: 21.sp,
                ),
              ),

              SizedBox(width: 12.w),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppFont.style.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),

                    SizedBox(height: 3.h),

                    Text(
                      subtitle,
                      style: AppFont.style.copyWith(
                        fontSize: 12.sp,
                        color: colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 8.w),

              AnimatedContainer(
                duration:
                const Duration(milliseconds: 180),
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : colors.border,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                  child: Container(
                    width: 10.w,
                    height: 10.w,
                    decoration:
                    BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                      colorScheme.primary,
                    ),
                  ),
                )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _themeModeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode_rounded;

      case ThemeMode.dark:
        return Icons.dark_mode_rounded;

      case ThemeMode.system:
        return Icons.brightness_auto_rounded;
    }
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';

      case ThemeMode.dark:
        return 'Dark';

      case ThemeMode.system:
        return 'System default';
    }
  }

  void _showAboutDialog() {
    final colors = context.themeColors;
    final colorScheme = Theme.of(context).colorScheme;

    Get.dialog(
      AlertDialog(
        title: Text(
          AppConst.appName,
          style: AppFont.style.copyWith(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              'A simple app to schedule and manage your calls.',
              style: AppFont.style.copyWith(
                fontSize: 14.sp,
                color: colors.textSecondary,
              ),
            ),

            SizedBox(height: 16.h),

            Text(
              'Version $_appVersion',
              style: AppFont.style.copyWith(
                fontSize: 13.sp,
                color: colors.textTertiary,
              ),
            ),

            SizedBox(height: 4.h),

            Text(
              'Build $_buildNumber',
              style: AppFont.style.copyWith(
                fontSize: 13.sp,
                color: colors.textTertiary,
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
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAppInformation() {
    final colors = context.themeColors;
    final colorScheme = Theme.of(context).colorScheme;

    Get.dialog(
      AlertDialog(
        title: Text(
          'App Information',
          style: AppFont.style.copyWith(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              context,
              'App Name',
              AppConst.appName,
            ),

            SizedBox(height: 12.h),

            _buildInfoRow(
              context,
              'Version',
              _appVersion,
            ),

            SizedBox(height: 12.h),

            _buildInfoRow(
              context,
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
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context,
      String label,
      String value,
      ) {
    final colors = context.themeColors;

    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80.w,
          child: Text(
            label,
            style: AppFont.style.copyWith(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value.isEmpty
                ? 'Loading...'
                : value,
            style: AppFont.style.copyWith(
              fontSize: 13.sp,
              color: colors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}