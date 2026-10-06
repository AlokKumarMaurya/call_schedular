import 'package:call_schedular/domain/entity/call_list_entity.dart';
import 'package:call_schedular/domain/usecase/call_use_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:get/get.dart';
import 'package:call_schedular/services/notification_service.dart';

class ScheduleCallController extends GetxController {
  final CallListEntity? call;

  ScheduleCallController({this.call});

  final formKey = GlobalKey<FormState>();

  final contactNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final notesController = TextEditingController();

  DateTime selectedDate = DateUtils.dateOnly(DateTime.now());
  TimeOfDay selectedTime = TimeOfDay.now();

  String selectedRepeat = 'Does not repeat';

  final FlutterNativeContactPicker _contactPicker =
      FlutterNativeContactPicker();

  bool isPickingContact = false;

  final List<String> repeatOptions = [
    'Does not repeat',
    'Every day',
    'Every week',
    'Every month',
    'Every year',
  ];

  bool isSaving = false;

  @override
  void onInit() {
    super.onInit();

    if (call != null) {
      contactNameController.text = call!.contactName;
      phoneNumberController.text = call!.phoneNumber;
      notesController.text = call!.notes ?? '';

      selectedDate = DateUtils.dateOnly(call!.scheduledAt);
      selectedTime = TimeOfDay.fromDateTime(call!.scheduledAt);
      selectedRepeat = call!.repeat;
    }
  }

  DateTime get scheduledAt => DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
    selectedTime.hour,
    selectedTime.minute,
  );

  String get formattedDate {
    return '${selectedDate.day} ${_monthName(selectedDate.month)} ${selectedDate.year}';
  }

  String get formattedTime {
    final hour = selectedTime.hourOfPeriod == 0
        ? 12
        : selectedTime.hourOfPeriod;

    final minute = selectedTime.minute.toString().padLeft(2, '0');

    return '$hour:$minute ${selectedTime.period.name.toUpperCase()}';
  }

  String _monthName(int month) {
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

    return months[month - 1];
  }

  Future<void> selectDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateUtils.dateOnly(DateTime.now()),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (date != null) {
      selectedDate = date;
      update();
    }
  }

  Future<void> selectTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (time != null) {
      selectedTime = time;
      update();
    }
  }

  Future<void> selectRepeat(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Repeat Call',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                ...repeatOptions.map(
                  (option) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(option),
                    trailing: selectedRepeat == option
                        ? const Icon(
                            Icons.check_circle,
                            color: Color(0xFF2260F5),
                          )
                        : null,
                    onTap: () => Navigator.pop(context, option),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result != null) {
      selectedRepeat = result;
      update();
    }
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter phone number';
    }

    final digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.length < 7 || digits.length > 15) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  bool validate() {
    if (!(formKey.currentState?.validate() ?? false)) {
      return false;
    }

    if (!scheduledAt.isAfter(DateTime.now())) {
      Get.snackbar(
        'Invalid time',
        'Please select a future date and time.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    return true;
  }

  CallListEntity createCallEntity() {
    return CallListEntity(
      id: call?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      contactName: contactNameController.text.trim(),
      phoneNumber: phoneNumberController.text.trim(),
      scheduledAt: scheduledAt,
      status: call?.status ?? CallStatusEntity.upcoming,
      notes: notesController.text.trim().isEmpty
          ? null
          : notesController.text.trim(),
      repeat: selectedRepeat,
    );
  }

  @override
  void onClose() {
    contactNameController.dispose();
    phoneNumberController.dispose();
    notesController.dispose();
    super.onClose();
  }

  Future<void> pickContact() async {
    if (isPickingContact) return;

    try {
      isPickingContact = true;
      update();

      final contact = await _contactPicker.selectPhoneNumber();

      if (contact == null) return;

      final name = contact.fullName?.trim();
      final phone = contact.selectedPhoneNumber?.trim();

      if (name != null && name.isNotEmpty) {
        contactNameController.text = name;
      }

      if (phone != null && phone.isNotEmpty) {
        phoneNumberController.text = phone;
      }

      update();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to pick contact. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isPickingContact = false;
      update();
    }
  }

  Future<void> saveContact(CallListEntity entity) async {
    isSaving = true;

    final useCase = Get.find<CallUseCase>();

    if (call == null) {
      await useCase.addCall(entity);

      try {
        await NotificationService.instance.scheduleCallReminder(entity);
      } catch (e) {
        debugPrint('Error scheduling call reminder: $e');
      }
    } else {
      await useCase.updateCall(entity);
    }

    update();
  }
}
