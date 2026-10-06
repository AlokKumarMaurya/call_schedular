import 'package:call_schedular/domain/entity/call_list_entity.dart';
import 'package:call_schedular/presentation/home/home_controller.dart';
import 'package:call_schedular/presentation/schedule_call/schedule_call_view.dart';
import 'package:call_schedular/theme/app_colors.dart';
import 'package:call_schedular/theme/app_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/usecase/call_use_case.dart';

class CallDetailsView extends StatefulWidget {
  final CallListEntity call;

  const CallDetailsView({
    super.key,
    required this.call,
  });

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
    final initial = _call.contactName.isNotEmpty
        ? _call.contactName[0].toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 20.sp,
            color: AppColors.textPrimary,
          ),
        ),
        title: Text(
          'Call Details',
          style: AppFont.style.copyWith(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _editCall,
            icon: Icon(
              Icons.edit_outlined,
              color: AppColors.textPrimary,
              size: 22.sp,
            ),
          ),
          IconButton(
            onPressed: _deleteCall,
            icon: Icon(
              Icons.delete_outline,
              color: Colors.red,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 16.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22.r,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            initial,
                            style: AppFont.style.copyWith(
                              fontSize: 20.sp,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                _call.contactName.isEmpty
                                    ? 'Unknown Contact'
                                    : _call.contactName,
                                style: AppFont.style.copyWith(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                _call.phoneNumber,
                                style: AppFont.style.copyWith(
                                  fontSize: 13.sp,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 28.h),

                    _detailRow(
                      icon: Icons.calendar_today_outlined,
                      title: 'Date',
                      value: _formatDate(_call.scheduledAt),
                    ),

                    _detailRow(
                      icon: Icons.access_time,
                      title: 'Time',
                      value: _formatTime(_call.scheduledAt),
                    ),

                    _detailRow(
                      icon: Icons.autorenew,
                      title: 'Repeat',
                      value: _call.repeat,
                    ),

                    _detailRow(
                      icon: Icons.notes_outlined,
                      title: 'Notes',
                      value: _call.notes?.isNotEmpty == true
                          ? _call.notes!
                          : 'No notes',
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(
                16.w,
                8.h,
                16.w,
                16.h,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () => _makeCall(_call.phoneNumber),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Call Now',
                    style: AppFont.style.copyWith(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editCall() async {
    final updatedCall = await Get.to<CallListEntity>(
          () => ScheduleCallView(
        call: _call,
      ),
    );

    if (updatedCall == null) {
      return;
    }

    setState(() {
      _call = updatedCall;
    });

    // Refresh HomeController so the Home list also contains
    // the updated call.
    await Get.find<HomeController>().getCallList();
  }

  Widget _detailRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 18.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28.w,
            child: Icon(
              icon,
              size: 20.sp,
              color: AppColors.textPrimary,
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
                    fontSize: 12.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: AppFont.style.copyWith(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
    final hour = date.hour % 12 == 0
        ? 12
        : date.hour % 12;

    final minute = date.minute
        .toString()
        .padLeft(2, '0');

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

    final uri = Uri(
      scheme: 'tel',
      path: cleanedPhoneNumber,
    );

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
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete call?'),
        content: const Text(
          'Are you sure you want to delete this scheduled call?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    await Get.find<CallUseCase>().deleteCall(_call.id);

    await Get.find<HomeController>().getCallList();

    Get.back();
  }
}