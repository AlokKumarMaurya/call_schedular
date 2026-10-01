 import 'package:call_schedular/presentation/schedule_call/schedule_call_controller.dart';
import 'package:call_schedular/presentation/schedule_call/widget/schedule_input_field.dart';
import 'package:call_schedular/presentation/schedule_call/widget/schedule_option_tile.dart';
import 'package:call_schedular/presentation/schedule_call/widget/schedule_primary_button.dart';
import 'package:call_schedular/theme/app_colors.dart';
import 'package:call_schedular/theme/app_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:get/get.dart';

class ScheduleCallView extends StatelessWidget {
  const ScheduleCallView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ScheduleCallController>(
      init: ScheduleCallController(),
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
              'Schedule Call',
              style: AppFont.style.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
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

                          _buildContactSection(controller),

                          SizedBox(height: 16.h),

                          _buildDateTimeSection(context, controller),

                          SizedBox(height: 12.h),

                          _buildRepeatSection(context, controller),

                          SizedBox(height: 12.h),

                          _buildNotesSection(controller),

                          SizedBox(height: 16.h),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
                    child: SchedulePrimaryButton(
                      title: 'Save Call',
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

  Widget _buildContactSection(ScheduleCallController controller) {
    return _sectionCard(
      child: Column(
        children: [
          ScheduleInputField(
            label: 'Contact Name (Optional)',
            hintText: 'Enter contact name',
            controller: controller.contactNameController,
            prefixIcon: Icons.person_outline,
          ),

          SizedBox(height: 14.h),

          ScheduleInputField(
            label: 'Phone Number',
            hintText: '+91 98765 43210',
            controller: controller.phoneNumberController,
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.call_outlined,
            validator: controller.validatePhoneNumber,
            suffixIcon: IconButton(
              onPressed: controller.isPickingContact
                  ? null
                  : controller.pickContact,
              icon: controller.isPickingContact
                  ? SizedBox(
                      height: 18.sp,
                      width: 18.sp,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.iconBlue,
                      ),
                    )
                  : Icon(
                      Icons.person_outline,
                      size: 21.sp,
                      color: AppColors.iconBlue,
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
    return _sectionCard(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        children: [
          ScheduleOptionTile(
            icon: Icons.calendar_today_outlined,
            title: 'Date',
            value: controller.formattedDate,
            showDivider: true,
            onTap: () => controller.selectDate(context),
          ),

          ScheduleOptionTile(
            icon: Icons.access_time,
            title: 'Time',
            value: controller.formattedTime,
            onTap: () => controller.selectTime(context),
          ),
        ],
      ),
    );
  }

  Widget _buildRepeatSection(
    BuildContext context,
    ScheduleCallController controller,
  ) {
    return _sectionCard(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: ScheduleOptionTile(
        icon: Icons.sync,
        title: 'Repeat (Optional)',
        value: controller.selectedRepeat,
        onTap: () => controller.selectRepeat(context),
      ),
    );
  }

  Widget _buildNotesSection(ScheduleCallController controller) {
    return _sectionCard(
      child: ScheduleInputField(
        label: 'Notes (Optional)',
        hintText: 'e.g. Discuss project update',
        controller: controller.notesController,
        prefixIcon: Icons.note_alt_outlined,
        maxLines: 2,
      ),
    );
  }

  Widget _sectionCard({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
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
      final call = controller.createCallEntity();

      await controller.saveContact(call);

      Get.back();

      Get.snackbar(
        'Success',
        'Call scheduled successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to schedule call. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      controller.isSaving = false;
      controller.update();
    }
  }
}
