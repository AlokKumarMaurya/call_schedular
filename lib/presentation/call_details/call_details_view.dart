import 'package:call_schedular/domain/entity/call_list_entity.dart';
import 'package:call_schedular/presentation/home/home_controller.dart';
import 'package:call_schedular/presentation/schedule_call/schedule_call_view.dart';
import 'package:call_schedular/services/notification_service.dart';
import 'package:call_schedular/theme/app_font.dart';
import 'package:call_schedular/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/widgets/app_glass_action_button.dart';
import '../../core/widgets/app_glass_icon_button.dart';
import '../../domain/usecase/call_use_case.dart';

class CallDetailsView extends StatefulWidget {
  final CallListEntity call;

  const CallDetailsView({super.key, required this.call});

  @override
  State<CallDetailsView> createState() => _CallDetailsViewState();
}

class _CallDetailsViewState extends State<CallDetailsView> {
  late CallListEntity _call;

  @override
  void initState() {
    super.initState();

    _call = widget.call;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    final contactName = _call.contactName.trim().isEmpty
        ? 'Unknown Contact'
        : _call.contactName.trim();

    final initial = contactName[0].toUpperCase();

    final isHistorical =
        _call.status == CallStatusEntity.completed ||
        _call.status == CallStatusEntity.missed;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 62.w,
        leading: Padding(
          padding: EdgeInsets.only(left: 12.w),
          child: AppGlassIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            tooltip: 'Back',
            onPressed: Get.back,
          ),
        ),
        title: Text(
          'Call Details',
          style: AppFont.style.copyWith(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        actions: [
          AppGlassIconButton(
            icon: isHistorical
                ? Icons.event_repeat_outlined
                : Icons.edit_outlined,
            tooltip: isHistorical ? 'Reschedule' : 'Edit',
            onPressed: isHistorical ? _rescheduleCall : _editCall,
          ),
          SizedBox(width: 8.w),
          AppGlassIconButton(
            icon: Icons.delete_outline_rounded,
            tooltip: 'Delete',
            iconColor: colors.dangerDark,
            tintColor: colors.dangerLight,
            onPressed: _deleteCall,
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildContactHero(
                      context,
                      contactName: contactName,
                      initial: initial,
                    ),

                    SizedBox(height: 24.h),

                    _buildSectionTitle(context, 'Call Schedule'),

                    SizedBox(height: 10.h),

                    _buildScheduleInfo(context),

                    SizedBox(height: 12.h),

                    _buildRepeatCard(context),

                    SizedBox(height: 24.h),

                    _buildSectionTitle(context, 'Notes'),

                    SizedBox(height: 10.h),

                    _buildNotesCard(context),
                  ],
                ),
              ),
            ),

            _buildBottomActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildContactHero(
    BuildContext context, {
    required String contactName,
    required String initial,
  }) {
    final colors = context.themeColors;

    final avatarColor = _avatarColor(contactName, context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 76.w,
            height: 76.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: avatarColor.withValues(alpha: 0.12),
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: AppFont.style.copyWith(
                fontSize: 32.sp,
                fontWeight: FontWeight.w700,
                color: avatarColor,
              ),
            ),
          ),

          SizedBox(height: 14.h),

          Text(
            contactName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppFont.style.copyWith(
              fontSize: 21.sp,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),

          SizedBox(height: 5.h),

          Text(
            _call.phoneNumber,
            style: AppFont.style.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: colors.textTertiary,
            ),
          ),

          SizedBox(height: 14.h),

          _buildStatusChip(context),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final colors = context.themeColors;

    late final String label;
    late final IconData icon;
    late final Color color;
    late final Color backgroundColor;

    switch (_call.status) {
      case CallStatusEntity.upcoming:
        label = 'Upcoming';
        icon = Icons.schedule_rounded;
        color = Theme.of(context).colorScheme.primary;
        backgroundColor = colors.primaryLight;
        break;

      case CallStatusEntity.completed:
        label = 'Completed';
        icon = Icons.check_circle_outline_rounded;
        color = colors.successDark;
        backgroundColor = colors.successLight;
        break;

      case CallStatusEntity.missed:
        label = 'Missed';
        icon = Icons.error_outline_rounded;
        color = colors.dangerDark;
        backgroundColor = colors.dangerLight;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15.sp, color: color),

          SizedBox(width: 6.w),

          Text(
            label,
            style: AppFont.style.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleInfo(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            context,
            icon: Icons.calendar_month_rounded,
            label: 'Date',
            value: _formatDate(_call.scheduledAt),
          ),
        ),

        SizedBox(width: 12.w),

        Expanded(
          child: _buildInfoCard(
            context,
            icon: Icons.access_time_rounded,
            label: 'Time',
            value: _formatTime(_call.scheduledAt),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colors = context.themeColors;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: colors.primaryLight,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 19.sp, color: colorScheme.primary),
          ),

          SizedBox(height: 12.h),

          Text(
            label,
            style: AppFont.style.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: colors.textTertiary,
            ),
          ),

          SizedBox(height: 4.h),

          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppFont.style.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepeatCard(BuildContext context) {
    final colors = context.themeColors;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: colors.primaryLight,
              borderRadius: BorderRadius.circular(11.r),
            ),
            child: Icon(
              Icons.repeat_rounded,
              size: 20.sp,
              color: colorScheme.primary,
            ),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Repeat',
                  style: AppFont.style.copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: colors.textTertiary,
                  ),
                ),

                SizedBox(height: 3.h),

                Text(
                  _call.repeat,
                  style: AppFont.style.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard(BuildContext context) {
    final colors = context.themeColors;
    final colorScheme = Theme.of(context).colorScheme;

    final hasNotes = _call.notes?.trim().isNotEmpty == true;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: colors.primaryLight,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.notes_rounded,
              size: 19.sp,
              color: colorScheme.primary,
            ),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: Text(
              hasNotes ? _call.notes!.trim() : 'No notes added for this call.',
              style: AppFont.style.copyWith(
                fontSize: 14.sp,
                height: 1.4,
                fontWeight: FontWeight.w500,
                color: hasNotes ? colors.textPrimary : colors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final colors = context.themeColors;

    return Text(
      title,
      style: AppFont.style.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        color: colors.textPrimary,
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    final colors = context.themeColors;
    final colorScheme = Theme.of(context).colorScheme;

    final isCompleted = _call.status == CallStatusEntity.completed;
    final isMissed = _call.status == CallStatusEntity.missed;

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(top: BorderSide(color: colors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            AppGlassActionButton(
              icon: Icons.call_rounded,
              label: 'Call Now',
              onPressed: () => _makeCall(_call.phoneNumber),
              expand: true,
            ),

            if (!isCompleted) ...[
              SizedBox(height: 10.h),

              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: OutlinedButton.icon(
                  onPressed: isMissed ? _rescheduleCall : _markAsCompleted,
                  icon: Icon(
                    isMissed ? Icons.event_repeat_rounded : Icons.check_rounded,
                    size: 18.sp,
                  ),
                  label: Text(
                    isMissed ? 'Reschedule Call' : 'Mark as Completed',
                    style: AppFont.style.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    side: BorderSide(color: colorScheme.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _avatarColor(String name, BuildContext context) {
    final colors = context.themeColors;
    final colorScheme = Theme.of(context).colorScheme;

    final avatarColors = [
      colorScheme.primary,
      colors.purpleDark,
      colors.successDark,
      colors.orangeDark,
      colors.dangerDark,
      colorScheme.tertiary,
    ];

    var hash = 0;

    for (final unit in name.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }

    return avatarColors[hash % avatarColors.length];
  }

  Future<void> _editCall() async {
    final updatedCall = await Get.to<CallListEntity>(
      () => ScheduleCallView(call: _call),
    );

    if (updatedCall == null) {
      return;
    }

    setState(() {
      _call = updatedCall;
    });

    await Get.find<HomeController>().getCallList();
  }

  Future<void> _rescheduleCall() async {
    final rescheduledCall = await Get.to<CallListEntity>(
      () => ScheduleCallView(call: _call, isReschedule: true),
    );

    if (rescheduledCall == null) {
      return;
    }

    await Get.find<HomeController>().getCallList();

    if (!mounted) {
      return;
    }

    Get.back();
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;

    final minute = date.minute.toString().padLeft(2, '0');

    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
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

      if (_call.status != CallStatusEntity.completed) {
        final useCase = Get.find<CallUseCase>();

        try {
          await NotificationService.instance.cancelCallReminder(_call);
        } catch (e) {
          debugPrint('Error cancelling call reminder: $e');
        }

        final updatedCall = await useCase.completeCall(_call);

        if (!mounted) {
          return;
        }

        setState(() {
          _call = updatedCall;
        });

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

  Future<void> _deleteCall() async {
    final colors = context.themeColors;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(
          'Delete call?',
          style: AppFont.style.copyWith(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this scheduled call?',
          style: AppFont.style.copyWith(
            fontSize: 14.sp,
            height: 1.4,
            color: colors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Cancel',
              style: AppFont.style.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'Delete',
              style: AppFont.style.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: colors.dangerDark,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await Get.find<CallUseCase>().deleteCall(_call.id);

      try {
        await NotificationService.instance.cancelCallReminder(_call);
      } catch (e) {
        debugPrint('Error cancelling call reminder: $e');
      }

      await Get.find<HomeController>().getCallList();

      Get.back();
    } catch (e) {
      debugPrint('Error deleting call: $e');

      Get.snackbar(
        'Error',
        'Unable to delete call. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _markAsCompleted() async {
    if (_call.status == CallStatusEntity.completed) {
      return;
    }

    try {
      final useCase = Get.find<CallUseCase>();

      try {
        await NotificationService.instance.cancelCallReminder(_call);
      } catch (e) {
        debugPrint('Error cancelling call reminder: $e');
      }

      final updatedCall = await useCase.completeCall(_call);

      if (!mounted) {
        return;
      }

      setState(() {
        _call = updatedCall;
      });

      await Get.find<HomeController>().getCallList();

      Get.snackbar(
        'Completed',
        _call.repeat == 'Does not repeat'
            ? 'Call marked as completed.'
            : 'Call completed. Next occurrence scheduled.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('Error marking call as completed: $e');

      Get.snackbar(
        'Error',
        'Unable to update call status.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
