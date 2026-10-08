import 'package:call_schedular/theme/app_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:get/get.dart';

import '../../theme/app_theme_colors.dart';
import 'call_statistics_controller.dart';

class CallStatisticsView extends StatelessWidget {
  const CallStatisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.themeColors.background,
      appBar: AppBar(
        backgroundColor: context.themeColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: Get.back,
        ),
        title: Text('Call Statistics', style: AppFont.style.copyWith(fontSize: 22.sp, fontWeight: FontWeight.w700, color: context.themeColors.textPrimary)),
      ),
      body: GetBuilder<CallStatisticsController>(
        init: CallStatisticsController(),
        builder: (controller) {
          if (controller.isLoading) return const Center(child: CircularProgressIndicator());
          if (controller.errorMessage != null) return _buildError(context, controller);

          return RefreshIndicator(
            onRefresh: controller.loadStatistics,
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
              children: [
                _buildOverview(context, controller),
                SizedBox(height: 20.h),
                _buildCompletionCard(context, controller),
                SizedBox(height: 20.h),
                _buildSevenDayCard(context, controller),
                SizedBox(height: 20.h),
                _buildInsights(context, controller),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverview(BuildContext context, CallStatisticsController controller) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10.w,
      mainAxisSpacing: 10.h,
      childAspectRatio: 1.65,
      children: [
        _metricCard(context, Icons.call_rounded, 'Total', controller.totalCalls, context.themeColors.primaryLight, Theme.of(context).colorScheme.primary),
        _metricCard(context, Icons.check_circle_outline_rounded, 'Completed', controller.completedCalls, context.themeColors.successLight, context.themeColors.successDark),
        _metricCard(context, Icons.error_outline_rounded, 'Missed', controller.missedCalls, context.themeColors.dangerLight, context.themeColors.dangerDark),
        _metricCard(context, Icons.schedule_rounded, 'Upcoming', controller.upcomingCalls, context.themeColors.orangeLight, context.themeColors.orangeDark),
      ],
    );
  }

  Widget _metricCard(BuildContext context, IconData icon, String title, int value, Color background, Color foreground) {
    final colors = context.themeColors;
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(16.r), border: Border.all(color: colors.border)),
      child: Row(
        children: [
          Container(width: 38.w, height: 38.w, decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(11.r)), child: Icon(icon, color: foreground, size: 20.sp)),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppFont.style.copyWith(fontSize: 11.sp, fontWeight: FontWeight.w600, color: colors.textTertiary)),
                SizedBox(height: 3.h),
                Text('$value', style: AppFont.style.copyWith(fontSize: 21.sp, fontWeight: FontWeight.w800, color: colors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionCard(BuildContext context, CallStatisticsController controller) {
    final colors = context.themeColors;
    final rate = controller.completionRate;
    final percentage = (rate * 100).round();

    return _sectionCard(
      context,
      title: 'Completion rate',
      icon: Icons.task_alt_rounded,
      child: Row(
        children: [
          SizedBox(
            width: 86.w,
            height: 86.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(width: 82.w, height: 82.w, child: CircularProgressIndicator(value: rate, strokeWidth: 8, backgroundColor: colors.primaryLight, color: Theme.of(context).colorScheme.primary)),
                Text('$percentage%', style: AppFont.style.copyWith(fontSize: 17.sp, fontWeight: FontWeight.w800, color: colors.textPrimary)),
              ],
            ),
          ),
          SizedBox(width: 18.w),
          Expanded(
            child: Text(
              controller.completedCalls + controller.missedCalls == 0
                  ? 'Complete or miss a call to start building your completion rate.'
                  : 'You completed ' + controller.completedCalls.toString() + ' of ' + (controller.completedCalls + controller.missedCalls).toString() + ' finished calls.',
              style: AppFont.style.copyWith(fontSize: 13.sp, height: 1.45, color: colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSevenDayCard(BuildContext context, CallStatisticsController controller) {
    final colors = context.themeColors;
    final maxValue = controller.busiestDayCount == 0 ? 1 : controller.busiestDayCount;

    return _sectionCard(
      context,
      title: 'Last 7 days',
      icon: Icons.bar_chart_rounded,
      child: SizedBox(
        height: 150.h,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(7, (index) {
            final completed = controller.lastSevenDaysCompleted[index];
            final missed = controller.lastSevenDaysMissed[index];
            final total = completed + missed;
            final height = total == 0 ? 4.h : 82.h * (total / maxValue);

            return Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('$total', style: AppFont.style.copyWith(fontSize: 10.sp, fontWeight: FontWeight.w700, color: colors.textSecondary)),
                    SizedBox(height: 4.h),
                    Container(
                      height: height,
                      width: double.infinity,
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.vertical(top: Radius.circular(7.r))),
                    ),
                    SizedBox(height: 6.h),
                    Text(controller.dayLabel(index), style: AppFont.style.copyWith(fontSize: 10.sp, fontWeight: FontWeight.w600, color: colors.textTertiary)),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildInsights(BuildContext context, CallStatisticsController controller) {
    final colors = context.themeColors;
    return _sectionCard(
      context,
      title: 'Insights',
      icon: Icons.auto_awesome_rounded,
      child: Column(
        children: [
          _insightRow(context, Icons.repeat_rounded, 'Recurring calls', controller.recurringCalls.toString()),
          Divider(color: colors.divider, height: 22.h),
          _insightRow(context, Icons.pending_actions_rounded, 'Finished calls', (controller.completedCalls + controller.missedCalls).toString()),
        ],
      ),
    );
  }

  Widget _insightRow(BuildContext context, IconData icon, String title, String value) {
    final colors = context.themeColors;
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: Theme.of(context).colorScheme.primary),
        SizedBox(width: 12.w),
        Expanded(child: Text(title, style: AppFont.style.copyWith(fontSize: 13.sp, fontWeight: FontWeight.w600, color: colors.textSecondary))),
        Text(value, style: AppFont.style.copyWith(fontSize: 14.sp, fontWeight: FontWeight.w800, color: colors.textPrimary)),
      ],
    );
  }

  Widget _sectionCard(BuildContext context, {required String title, required IconData icon, required Widget child}) {
    final colors = context.themeColors;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(18.r), border: Border.all(color: colors.border), boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 10, offset: const Offset(0, 3))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 20.sp, color: Theme.of(context).colorScheme.primary),
            SizedBox(width: 8.w),
            Text(title, style: AppFont.style.copyWith(fontSize: 16.sp, fontWeight: FontWeight.w700, color: colors.textPrimary)),
          ]),
          SizedBox(height: 14.h),
          child,
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, CallStatisticsController controller) {
    final colors = context.themeColors;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.analytics_outlined, size: 48.sp, color: colors.textTertiary),
            SizedBox(height: 12.h),
            Text(controller.errorMessage!, textAlign: TextAlign.center, style: AppFont.style.copyWith(fontSize: 14.sp, color: colors.textSecondary)),
            SizedBox(height: 14.h),
            FilledButton(onPressed: controller.loadStatistics, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
