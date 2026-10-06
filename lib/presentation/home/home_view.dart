import 'package:call_schedular/presentation/home/home_controller.dart';
import 'package:call_schedular/presentation/home/widget/filter_chip.dart';
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
    return SizedBox(
      height: 42.h,
      child: TabBar(
        onTap: (_) => controller.update(),
        labelPadding: EdgeInsets.zero,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        padding: EdgeInsets.zero,
        dividerColor: Colors.transparent,
        indicator: const BoxDecoration(),
        controller: controller.tabController,
        tabs: [
          AppFilterChip(
            isSelected: controller.tabController.index == 0,
            title: 'Today ${controller.todayCalls.length}',
          ),

          Padding(
            padding: EdgeInsets.only(left: 8.w),
            child: AppFilterChip(
              isSelected: controller.tabController.index == 1,
              title: 'Upcoming ${controller.upcomingCalls.length}',
            ),
          ),

          Padding(
            padding: EdgeInsets.only(left: 8.w),
            child: AppFilterChip(
              isSelected: controller.tabController.index == 2,
              title: 'Completed ${controller.completedCalls.length}',
            ),
          ),

          Padding(
            padding: EdgeInsets.only(left: 8.w),
            child: AppFilterChip(
              isSelected: controller.tabController.index == 3,
              title: 'Missed ${controller.missedCalls.length}',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallList(
    List<CallListEntity> calls, {
    required String emptyMessage,
  }) {
    if (calls.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: AppFont.style.copyWith(
            fontSize: 14.sp,
            color: AppColors.textTertiary,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.only(bottom: 80.h),
      itemCount: calls.length,
      separatorBuilder: (_, __) => SizedBox(height: 8.h),
      itemBuilder: (context, index) {
        final call = calls[index];

        return CallRecordTile(call: call);
      },
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
    final initial = call.contactName.isNotEmpty
        ? call.contactName[0].toUpperCase()
        : '?';

    return GestureDetector(
      onTap: () {
        Get.to(() => CallDetailsView(call: call));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color: AppColors.white,
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Text(
                initial,
                style: AppFont.style.copyWith(
                  fontSize: 20.sp,
                  color: AppColors.white,
                ),
              ),
            ),

            SizedBox(width: 16.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    call.contactName,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: AppFont.style.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                    ),
                  ),

                  SizedBox(height: 4.h),

                  Text(
                    call.phoneNumber,
                    style: AppFont.style.copyWith(
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w500,
                      fontSize: 12.sp,
                    ),
                  ),

                  SizedBox(height: 8.h),

                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16.sp,
                        color: AppColors.iconBlue,
                      ),

                      SizedBox(width: 8.w),

                      Text(
                        _formattedDateTime(call.scheduledAt),
                        style: AppFont.style.copyWith(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(width: 12.w),

            InkWell(
              borderRadius: BorderRadius.circular(50.r),
              onTap: () => _makeCall(call.phoneNumber),
              child: CircleAvatar(
                backgroundColor: AppColors.iconBlueBackground,
                child: Icon(Icons.call, size: 20.sp, color: AppColors.iconBlue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formattedDateTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;

    final formattedHour = hour % 12 == 0 ? 12 : hour % 12;
    final period = hour >= 12 ? 'PM' : 'AM';

    final time = '$formattedHour:${minute.toString().padLeft(2, '0')} $period';

    final now = DateTime.now();

    if (_isSameDay(dateTime, now)) {
      return time;
    }

    if (_isSameDay(dateTime, now.add(const Duration(days: 1)))) {
      return 'Tomorrow, $time';
    }

    return '${dateTime.day}/${dateTime.month}, $time';
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
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

      // The phone app was successfully opened.
      // Complete the current occurrence.
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
