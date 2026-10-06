import 'package:call_schedular/presentation/schedule_call/schedule_call_controller.dart';
import 'package:call_schedular/presentation/schedule_call/widget/schedule_input_field.dart';
import 'package:call_schedular/presentation/schedule_call/widget/schedule_primary_button.dart';
import 'package:call_schedular/theme/app_colors.dart';
import 'package:call_schedular/theme/app_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:get/get.dart';

import '../../domain/entity/call_list_entity.dart';

class ScheduleCallView extends StatelessWidget {
  final CallListEntity? call;
  final bool isReschedule;

  const ScheduleCallView({super.key, this.call, this.isReschedule = false});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ScheduleCallController>(
      init: ScheduleCallController(call: call, isReschedule: isReschedule),
      builder: (controller) {
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
            titleSpacing: 4.w,
            title: Text(
              call == null
                  ? 'Schedule Call'
                  : isReschedule
                  ? 'Reschedule Call'
                  : 'Update Call',
              style: AppFont.style.copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          body: SafeArea(
            child: Form(
              key: controller.formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 12.h),

                          _buildSectionTitle('Who are you calling?'),

                          SizedBox(height: 10.h),

                          _buildContactSection(controller),

                          SizedBox(height: 22.h),

                          _buildSectionTitle('When?'),

                          SizedBox(height: 10.h),

                          _buildDateTimeSection(context, controller),

                          SizedBox(height: 22.h),

                          _buildSectionTitle('Repeat'),

                          SizedBox(height: 10.h),

                          _buildRepeatSection(context, controller),

                          SizedBox(height: 22.h),

                          _buildSectionTitle('Notes'),

                          SizedBox(height: 10.h),

                          _buildNotesSection(controller),

                          SizedBox(height: 16.h),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
                    child: SchedulePrimaryButton(
                      title: call == null
                          ? 'Schedule Call'
                          : isReschedule
                          ? 'Reschedule Call'
                          : 'Update Call',
                      isLoading: controller.isSaving,
                      onPressed: () => _saveCall(controller),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppFont.style.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildContactSection(ScheduleCallController controller) {
    return _sectionCard(
      padding: EdgeInsets.all(14.w),
      child: Column(
        children: [
          ScheduleInputField(
            label: 'Contact Name (Optional)',
            hintText: 'Enter contact name',
            controller: controller.contactNameController,
            prefixIcon: Icons.person_outline_rounded,
          ),

          SizedBox(height: 16.h),

          ScheduleInputField(
            label: 'Phone Number',
            hintText: '+91 98765 43210',
            controller: controller.phoneNumberController,
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.call_outlined,
            validator: controller.validatePhoneNumber,
            suffixIcon: controller.isPickingContact
                ? Padding(
                    padding: EdgeInsets.all(12.w),
                    child: SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : IconButton(
                    onPressed: controller.pickContact,
                    icon: Icon(
                      Icons.contacts_outlined,
                      size: 21.sp,
                      color: AppColors.primary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSection(
    BuildContext context,
    ScheduleCallController controller,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildDateTimeCard(
            icon: Icons.calendar_month_rounded,
            label: 'Date',
            value: controller.formattedDate,
            onTap: () => controller.selectDate(context),
          ),
        ),

        SizedBox(width: 12.w),

        Expanded(
          child: _buildDateTimeCard(
            icon: Icons.access_time_rounded,
            label: 'Time',
            value: controller.formattedTime,
            onTap: () => controller.selectTime(context),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeCard({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, size: 19.sp, color: AppColors.primary),
              ),

              SizedBox(height: 12.h),

              Text(
                label,
                style: AppFont.style.copyWith(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textTertiary,
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
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRepeatSection(
    BuildContext context,
    ScheduleCallController controller,
  ) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: () => controller.selectRepeat(context),
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: Icon(
                  Icons.repeat_rounded,
                  size: 20.sp,
                  color: AppColors.primary,
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
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textTertiary,
                      ),
                    ),

                    SizedBox(height: 3.h),

                    Text(
                      controller.selectedRepeat,
                      style: AppFont.style.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,
                size: 22.sp,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotesSection(ScheduleCallController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: ScheduleInputField(
        label: 'Note',
        hintText: 'Add a note about this call...',
        controller: controller.notesController,
        prefixIcon: Icons.notes_rounded,
        maxLines: 3,
      ),
    );
  }

  Widget _sectionCard({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  Future<void> _saveCall(ScheduleCallController controller) async {
    if (controller.isSaving || !controller.validate()) {
      return;
    }

    controller.isSaving = true;
    controller.update();

    try {
      final entity = controller.createCallEntity();

      await controller.saveContact(entity);

      // Reset loading state before leaving this screen.
      controller.isSaving = false;

      // Return the updated entity to CallDetailsView.
      Get.back(result: entity);

      Get.snackbar(
        'Success',
        call == null
            ? 'Call scheduled successfully'
            : isReschedule
            ? 'Call rescheduled successfully'
            : 'Call updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      controller.isSaving = false;
      controller.update();

      debugPrint('Error saving call: $e');

      Get.snackbar(
        'Error',
        call == null
            ? 'Unable to schedule call. Please try again.'
            : 'Unable to update call. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
