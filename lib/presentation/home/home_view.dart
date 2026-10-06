import 'package:call_schedular/presentation/home/home_controller.dart';
import 'package:call_schedular/theme/app_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/widgets/app_glass_action_button.dart';
import '../../core/widgets/app_glass_container.dart';
import '../../core/widgets/app_glass_icon_button.dart';
import '../../domain/entity/call_list_entity.dart';
import '../../domain/usecase/call_use_case.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme_colors.dart';
import '../call_details/call_details_view.dart';
import '../schedule_call/schedule_call_view.dart';
import '../settings/settings_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GetBuilder<HomeController>(
          init: HomeController(),
          builder: (controller) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w)
                  .copyWith(top: 2.h),
              child: Column(
                children: [
                  SizedBox(height: 12.h),

                  _buildHomeHeader(context, controller),

                  SizedBox(height: 20.h),

                  _buildSearchField(context, controller),

                  SizedBox(height: 18.h),

                  _buildStatusTabs(context, controller),

                  SizedBox(height: 20.h),

                  Expanded(
                    child: controller.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : TabBarView(
                            controller: controller.tabController,
                            children: [
                              _buildCallList(
                                controller.todayCalls,
                                context: context,
                                emptyMessage: 'No calls scheduled for today',
                              ),
                              _buildCallList(
                                controller.upcomingCalls,
                                context: context,
                                emptyMessage: 'No upcoming calls',
                              ),
                              _buildCallList(
                                controller.completedCalls,
                                context: context,
                                emptyMessage: 'No completed calls yet',
                              ),
                              _buildCallList(
                                context: context,
                                controller.missedCalls,
                                emptyMessage: 'No missed calls',
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: AppGlassActionButton(
        icon: Icons.add_rounded,
        label: 'Schedule Call',
        onPressed: () async {
          await Get.to(() => ScheduleCallView());
          await Get.find<HomeController>().getCallList();
        },
      ),
    );
  }

  Widget _buildHomeHeader(BuildContext context, HomeController controller) {
    final colors = context.themeColors;
    final hour = DateTime.now().hour;

    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
        ? 'Good afternoon'
        : 'Good evening';

    final todayCount = controller.todayCalls.length;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting 👋',
                style: AppFont.style.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: colors.textSecondary,
                ),
              ),

              SizedBox(height: 4.h),

              Text(
                'Your calls',
                style: AppFont.style.copyWith(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),

              SizedBox(height: 6.h),

              Text(
                todayCount == 0
                    ? 'No calls scheduled for today'
                    : '$todayCount ${todayCount == 1 ? 'call' : 'calls'} scheduled for today',
                style: AppFont.style.copyWith(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: colors.textTertiary,
                ),
              ),
            ],
          ),
        ),

        SizedBox(width: 12.w),

        AppGlassIconButton(
          icon: Icons.settings_outlined,
          tooltip: 'Settings',
          onPressed: () {
            Get.to(() => const SettingsView());
          },
        ),
      ],
    );
  }

  Widget _buildStatusTabs(BuildContext context, HomeController controller) {
    final colors = context.themeColors;
    final selectedIndex = controller.tabController.index;

    return Container(
      height: 64.h,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTab(
              context: context,
              colors: colors,
              label: 'Today',
              count: controller.todayCalls.length,
              isSelected: selectedIndex == 0,
              onTap: () {
                controller.tabController.animateTo(0);
              },
            ),
          ),

          Expanded(
            child: _buildTab(
              context: context,
              colors: colors,
              label: 'Upcoming',
              count: controller.upcomingCalls.length,
              isSelected: selectedIndex == 1,
              onTap: () {
                controller.tabController.animateTo(1);
              },
            ),
          ),

          Expanded(
            child: _buildTab(
              context: context,
              colors: colors,
              label: 'Completed',
              count: controller.completedCalls.length,
              isSelected: selectedIndex == 2,
              onTap: () {
                controller.tabController.animateTo(2);
              },
            ),
          ),

          Expanded(
            child: _buildTab(
              context: context,
              colors: colors,
              label: 'Missed',
              count: controller.missedCalls.length,
              isSelected: selectedIndex == 3,
              onTap: () {
                controller.tabController.animateTo(3);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required BuildContext context,
    required AppThemeColors colors,
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: isSelected ? colors.primaryLight : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFont.style.copyWith(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : colors.textSecondary,
                ),
              ),

              SizedBox(height: 2.h),

              Text(
                '$count',
                style: AppFont.style.copyWith(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : colors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCallList(
    List<CallListEntity> calls, {
    required BuildContext context,
    required String emptyMessage,
  }) {
    if (calls.isEmpty) {
      return _buildEmptyState(context, emptyMessage);
    }

    return ListView.separated(
      padding: EdgeInsets.only(top: 4.h, bottom: 100.h),
      itemCount: calls.length,
      separatorBuilder: (_, _) => SizedBox(height: 10.h),
      itemBuilder: (context, index) {
        final call = calls[index];

        return CallRecordTile(call: call);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    final colors = context.themeColors;
    final colorScheme = Theme.of(context).colorScheme;
    final isToday = message == 'No calls scheduled for today';
    final isUpcoming = message == 'No upcoming calls';
    final isCompleted = message == 'No completed calls yet';

    final IconData icon;
    final String title;
    final String subtitle;

    if (isToday) {
      icon = Icons.event_available_rounded;
      title = 'Your day is clear';
      subtitle = 'No calls scheduled for today.';
    } else if (isUpcoming) {
      icon = Icons.calendar_month_outlined;
      title = 'Nothing coming up';
      subtitle =
          'Schedule a call so you never forget an important conversation.';
    } else if (isCompleted) {
      icon = Icons.check_circle_outline_rounded;
      title = 'No completed calls';
      subtitle = 'Calls you complete will appear here.';
    } else {
      icon = Icons.sentiment_satisfied_alt_rounded;
      title = 'No missed calls';
      subtitle = 'Great! You haven’t missed any calls.';
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76.w,
              height: 76.w,
              decoration: BoxDecoration(
                color: colors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 34.sp, color: colorScheme.primary),
            ),

            SizedBox(height: 18.h),

            Text(
              title,
              textAlign: TextAlign.center,
              style: AppFont.style.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),

            SizedBox(height: 8.h),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppFont.style.copyWith(
                fontSize: 13.sp,
                height: 1.4,
                color: colors.textTertiary,
              ),
            ),

            if (isToday || isUpcoming) ...[
              SizedBox(height: 20.h),

              OutlinedButton.icon(
                onPressed: () async {
                  await Get.to(() => ScheduleCallView());

                  await Get.find<HomeController>().getCallList();
                },
                icon: Icon(Icons.add, size: 18.sp),
                label: const Text('Schedule Call'),
                style: OutlinedButton.styleFrom(minimumSize: Size(150.w, 44.h)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context, HomeController controller) {
    final colors = context.themeColors;
    final colorScheme = Theme.of(context).colorScheme;
    return AppGlassContainer(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(18.r),
      blurSigma: 14,
      opacity: 0.48,
      tintColor: colors.primaryLight,
      border: Border.all(
        color: Colors.white.withValues(
          alpha: Theme.of(context).brightness == Brightness.dark ? 0.18 : 0.85,
        ),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: colorScheme.primary.withValues(alpha: 0.06),
          blurRadius: 18,
          offset: const Offset(0, 5),
        ),
      ],
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.setSearchQuery,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search contacts or calls...',
          prefixIcon: Icon(
            Icons.search_rounded,
            color: colors.textSecondary,
            size: 22.sp,
          ),
          suffixIcon: controller.searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: controller.clearSearch,
                  icon: Icon(
                    Icons.clear_rounded,
                    color: colors.textTertiary,
                    size: 20.sp,
                  ),
                )
              : null,
          filled: false,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 13.h,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18.r),
            borderSide: BorderSide(
              color: colorScheme.primary.withValues(alpha: 0.30),
              width: 1,
            ),
          ),
        ),
        style: AppFont.style.copyWith(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: colors.textPrimary,
        ),
      ),
    );
  }
}

class CallRecordTile extends StatelessWidget {
  final CallListEntity call;

  const CallRecordTile({super.key, required this.call});

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final contactName = call.contactName.trim().isEmpty
        ? 'Unknown Contact'
        : call.contactName.trim();

    final initial = contactName[0].toUpperCase();
    final avatarColor = _avatarColor(context, contactName);

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(18.r),
        onTap: () {
          Get.to(() => CallDetailsView(call: call));
        },
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: colors.border),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildAvatar(initial, avatarColor),

              SizedBox(width: 12.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNameRow(context, contactName),

                    SizedBox(height: 4.h),

                    Text(
                      call.phoneNumber,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFont.style.copyWith(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: colors.textTertiary,
                      ),
                    ),

                    SizedBox(height: 10.h),

                    Row(
                      children: [
                        _buildStatusChip(context),

                        const Spacer(),

                        _buildAction(context),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String initial, Color color) {
    return Container(
      width: 52.w,
      height: 52.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.12),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppFont.style.copyWith(
          fontSize: 21.sp,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildNameRow(BuildContext context, String contactName) {
    final colors = context.themeColors;
    return Row(
      children: [
        Expanded(
          child: Text(
            contactName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFont.style.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
        ),

        SizedBox(width: 8.w),

        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formattedDate(call.scheduledAt),
              style: AppFont.style.copyWith(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: colors.textTertiary,
              ),
            ),

            SizedBox(height: 2.h),

            Text(
              _formattedTime(call.scheduledAt),
              style: AppFont.style.copyWith(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final config = _statusConfig(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 13.sp, color: config.color),
          SizedBox(width: 5.w),
          Text(
            config.label,
            style: AppFont.style.copyWith(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: config.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAction(BuildContext context) {
    final colors = context.themeColors;
    final colorScheme = Theme.of(context).colorScheme;
    switch (call.status) {
      case CallStatusEntity.upcoming:
        return _roundActionButton(
          icon: Icons.call_rounded,
          color: colorScheme.primary,
          backgroundColor: colors.primaryLight,
          onTap: () => _makeCall(call.phoneNumber),
        );

      case CallStatusEntity.missed:
        return _roundActionButton(
          icon: Icons.event_repeat_rounded,
          color: colors.dangerDark,
          backgroundColor: colors.dangerLight,
          onTap: () => _openReschedule(),
        );

      case CallStatusEntity.completed:
        return const SizedBox.shrink();
    }
  }

  Widget _roundActionButton({
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: backgroundColor,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 38.w,
          height: 38.w,
          child: Icon(icon, size: 18.sp, color: color),
        ),
      ),
    );
  }

  _StatusConfig _statusConfig(BuildContext context) {
    final colors = context.themeColors;
    final colorScheme = Theme.of(context).colorScheme;
    switch (call.status) {
      case CallStatusEntity.upcoming:
        return _StatusConfig(
          label: 'Upcoming',
          icon: Icons.schedule_rounded,
          color: colorScheme.primary,
          backgroundColor: colors.primaryLight,
        );

      case CallStatusEntity.completed:
        return _StatusConfig(
          label: 'Completed',
          icon: Icons.check_circle_outline_rounded,
          color: colors.successDark,
          backgroundColor: colors.successLight,
        );

      case CallStatusEntity.missed:
        return _StatusConfig(
          label: 'Missed',
          icon: Icons.error_outline_rounded,
          color: colors.dangerDark,
          backgroundColor: colors.dangerLight,
        );
    }
  }

  Color _avatarColor(BuildContext context, String name) {
    final colors = context.themeColors;

    final avatarColors = [
      Theme.of(context).colorScheme.primary,
      colors.purpleDark,
      colors.successDark,
      colors.orangeDark,
      colors.dangerDark,
    ];

    var hash = 0;

    for (final unit in name.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }

    return avatarColors[hash % avatarColors.length];
  }

  String _formattedDate(DateTime dateTime) {
    final now = DateTime.now();

    if (_isSameDay(dateTime, now)) {
      return 'Today';
    }

    if (_isSameDay(dateTime, now.add(const Duration(days: 1)))) {
      return 'Tomorrow';
    }

    return '${dateTime.day} ${_monthName(dateTime.month)}';
  }

  String _formattedTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;

    final minute = dateTime.minute.toString().padLeft(2, '0');

    final period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month - 1];
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  Future<void> _openReschedule() async {
    final rescheduledCall = await Get.to<CallListEntity>(
      () => ScheduleCallView(call: call, isReschedule: true),
    );

    if (rescheduledCall == null) {
      return;
    }

    await Get.find<HomeController>().getCallList();
  }

  Future<void> _makeCall(String phoneNumber) async {
    final cleanedPhoneNumber = phoneNumber.trim();

    if (cleanedPhoneNumber.isEmpty) {
      Get.snackbar(
        'Unable to call',
        'Phone number is not available.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final uri = Uri(scheme: 'tel', path: cleanedPhoneNumber);

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        Get.snackbar(
          'Unable to call',
          'Could not open the phone app.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (call.status != CallStatusEntity.completed) {
        final useCase = Get.find<CallUseCase>();

        try {
          await NotificationService.instance.cancelCallReminder(call);
        } catch (e) {
          debugPrint('Error cancelling call reminder: $e');
        }

        await useCase.completeCall(call);

        await Get.find<HomeController>().getCallList();
      }
    } catch (e) {
      debugPrint('Error launching phone app: $e');

      Get.snackbar(
        'Unable to call',
        'Could not open the phone app.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

class _StatusConfig {
  final String label;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const _StatusConfig({
    required this.label,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });
}
