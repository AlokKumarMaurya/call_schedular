import 'package:call_schedular/constants/app_const.dart';
import 'package:call_schedular/presentation/home/home_controller.dart';
import 'package:call_schedular/presentation/home/widget/filter_chip.dart';
import 'package:call_schedular/theme/app_colors.dart';
import 'package:call_schedular/theme/app_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:get/get.dart';
// import 'package:url_launcher/url_launcher.dart';

import '../../domain/entity/call_list_entity.dart';
import '../call_details/call_details_view.dart';
import '../schedule_call/schedule_call_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConst.appName,
          style: AppFont.style.copyWith(
            fontSize: 24.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [Icon(Icons.settings_outlined, color: AppColors.black)],
        actionsPadding: EdgeInsets.only(right: 16.w),
      ),
      body: GetBuilder<HomeController>(
        init: HomeController(),
        builder: (controller) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                SizedBox(height: 12.h),

                TabBar(
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
                      title: 'Today (${controller.todayCalls.length})',
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: AppFilterChip(
                        isSelected: controller.tabController.index == 1,
                        title: 'Upcoming (${controller.upcomingCalls.length})',
                      ),
                    ),
                    AppFilterChip(
                      isSelected: controller.tabController.index == 2,
                      title: 'Completed (${controller.completedCalls.length})',
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

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
                          ],
                        ),
                ),
              ],
            ),
          );
        },
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
    final uri = Uri(scheme: 'tel', path: phoneNumber);

    // if (await canLaunchUrl(uri)) {
    //   await launchUrl(uri);
    // }
  }
}
