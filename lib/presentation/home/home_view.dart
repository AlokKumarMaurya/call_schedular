import 'package:call_schedular/presentation/home/home_controller.dart';
import 'package:call_schedular/theme/app_colors.dart';
import 'package:call_schedular/theme/app_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entity/call_list_entity.dart';
import '../../domain/usecase/call_use_case.dart';
import '../../services/notification_service.dart';
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

                  _buildHomeHeader(controller),

                  SizedBox(height: 20.h),

                  _buildSearchField(controller),

                  SizedBox(height: 18.h),

                  _buildStatusTabs(controller),

                  SizedBox(height: 20.h),

                  Expanded(
                    child: controller.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : TabBarView(
                            controller: controller.tabController,
                            children: [
                              _buildCallList(
                                controller.todayCalls,
                                emptyMessage: 'No calls scheduled for today',
                              ),
                              _buildCallList(
                                controller.upcomingCalls,
                                emptyMessage: 'No upcoming calls',
                              ),
                              _buildCallList(
                                controller.completedCalls,
                                emptyMessage: 'No completed calls yet',
                              ),
                              _buildCallList(
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Get.to(() => ScheduleCallView());
          await Get.find<HomeController>().getCallList();
        },
        backgroundColor: AppColors.primary,
        child: Icon(Icons.add, color: AppColors.white, size: 28.sp),
      ),
    );
  }

  Widget _buildHomeHeader(HomeController controller) {
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
                  color: AppColors.textSecondary,
                ),
              ),

              SizedBox(height: 4.h),

              Text(
                'Your calls',
                style: AppFont.style.copyWith(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
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
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),

        SizedBox(width: 12.w),

        Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          child: InkWell(
            borderRadius: BorderRadius.circular(14.r),
            onTap: () {
              Get.to(() => const SettingsView());
            },
            child: Container(
              width: 46.w,
              height: 46.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(
                Icons.settings_outlined,
                color: AppColors.textPrimary,
                size: 22.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTabs(HomeController controller) {
    final selectedIndex = controller.tabController.index;

    return Container(
      height: 64.h,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTab(
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
            color: isSelected ? AppColors.primaryLight : Colors.transparent,
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
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),

              SizedBox(height: 2.h),

              Text(
                '$count',
                style: AppFont.style.copyWith(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textTertiary,
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
    required String emptyMessage,
  }) {
    if (calls.isEmpty) {
      return _buildEmptyState(emptyMessage);
    }

    return ListView.separated(
      padding: EdgeInsets.only(top: 4.h, bottom: 100.h),
      itemCount: calls.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (context, index) {
        final call = calls[index];

        return CallRecordTile(call: call);
      },
    );
  }

  Widget _buildEmptyState(String message) {
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
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 34.sp, color: AppColors.primary),
            ),

            SizedBox(height: 18.h),

            Text(
              title,
              textAlign: TextAlign.center,
              style: AppFont.style.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),

            SizedBox(height: 8.h),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppFont.style.copyWith(
                fontSize: 13.sp,
                height: 1.4,
                color: AppColors.textTertiary,
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

  Widget _buildSearchField(HomeController controller) {
    return TextField(
      controller: controller.searchController,
      onChanged: controller.setSearchQuery,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search contacts or calls...',
        prefixIcon: Icon(
          Icons.search,
          color: AppColors.textTertiary,
          size: 22.sp,
        ),
        suffixIcon: controller.searchQuery.isNotEmpty
            ? IconButton(
                onPressed: controller.clearSearch,
                icon: Icon(
                  Icons.clear,
                  color: AppColors.textTertiary,
                  size: 20.sp,
                ),
              )
            : null,
        filled: true,
        fillColor: AppColors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: AppColors.primary),
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
    final contactName = call.contactName.trim().isEmpty
        ? 'Unknown Contact'
        : call.contactName.trim();

    final initial = contactName[0].toUpperCase();
    final avatarColor = _avatarColor(contactName);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(18.r),
        onTap: () {
          Get.to(() => CallDetailsView(call: call));
        },
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
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
                    _buildNameRow(contactName),

                    SizedBox(height: 4.h),

                    Text(
                      call.phoneNumber,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFont.style.copyWith(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textTertiary,
                      ),
                    ),

                    SizedBox(height: 10.h),

                    Row(
                      children: [
                        _buildStatusChip(),

                        const Spacer(),

                        _buildAction(),
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

  Widget _buildNameRow(String contactName) {
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
              color: AppColors.textPrimary,
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
                color: AppColors.textTertiary,
              ),
            ),

            SizedBox(height: 2.h),

            Text(
              _formattedTime(call.scheduledAt),
              style: AppFont.style.copyWith(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip() {
    final config = _statusConfig();

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

  Widget _buildAction() {
    switch (call.status) {
      case CallStatusEntity.upcoming:
        return _roundActionButton(
          icon: Icons.call_rounded,
          color: AppColors.iconBlue,
          backgroundColor: AppColors.iconBlueBackground,
          onTap: () => _makeCall(call.phoneNumber),
        );

      case CallStatusEntity.missed:
        return _roundActionButton(
          icon: Icons.event_repeat_rounded,
          color: AppColors.dangerDark,
          backgroundColor: AppColors.dangerLight,
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

  _StatusConfig _statusConfig() {
    switch (call.status) {
      case CallStatusEntity.upcoming:
        return const _StatusConfig(
          label: 'Upcoming',
          icon: Icons.schedule_rounded,
          color: AppColors.primary,
          backgroundColor: AppColors.primaryLight,
        );

      case CallStatusEntity.completed:
        return const _StatusConfig(
          label: 'Completed',
          icon: Icons.check_circle_outline_rounded,
          color: AppColors.successDark,
          backgroundColor: AppColors.successLight,
        );

      case CallStatusEntity.missed:
        return const _StatusConfig(
          label: 'Missed',
          icon: Icons.error_outline_rounded,
          color: AppColors.dangerDark,
          backgroundColor: AppColors.dangerLight,
        );
    }
  }

  Color _avatarColor(String name) {
    final colors = [
      AppColors.primary,
      AppColors.purpleDark,
      AppColors.successDark,
      AppColors.orangeDark,
      AppColors.dangerDark,
      AppColors.pink,
    ];

    var hash = 0;

    for (final unit in name.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }

    return colors[hash % colors.length];
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
