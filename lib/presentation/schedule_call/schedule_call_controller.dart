import 'package:call_schedular/domain/entity/call_list_entity.dart';
import 'package:call_schedular/domain/usecase/call_use_case.dart';
import 'package:call_schedular/services/notification_service.dart';
import 'package:call_schedular/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:get/get.dart';

class ScheduleCallController extends GetxController {
  final CallListEntity? call;
  final bool isReschedule;

  ScheduleCallController({this.call, this.isReschedule = false});

  final formKey = GlobalKey<FormState>();

  final contactNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final notesController = TextEditingController();

  DateTime selectedDate = DateUtils.dateOnly(DateTime.now());

  TimeOfDay selectedTime = TimeOfDay.now();

  String selectedRepeat = 'Does not repeat';

  List<int> selectedReminderMinutesBefore = const [0];

  static const Map<int, String> reminderOptions = {
    0: 'At call time',
    15: '15 minutes before',
    30: '30 minutes before',
    60: '1 hour before',
    1440: '1 day before',
  };

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
      selectedReminderMinutesBefore =
          List<int>.from(call!.reminderMinutesBefore);
      if (selectedReminderMinutesBefore.isEmpty) {
        selectedReminderMinutesBefore = const [0];
      }
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
    return '${selectedDate.day} '
        '${_monthName(selectedDate.month)} '
        '${selectedDate.year}';
  }

  String get formattedTime {
    final hour = selectedTime.hourOfPeriod == 0
        ? 12
        : selectedTime.hourOfPeriod;

    final minute = selectedTime.minute.toString().padLeft(2, '0');

    return '$hour:$minute '
        '${selectedTime.period.name.toUpperCase()}';
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
    final colors = context.themeColors;
    final colorScheme = Theme.of(context).colorScheme;

    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: colors.surface,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final sheetColors = context.themeColors;
        final sheetColorScheme = Theme.of(context).colorScheme;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Repeat Call',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: sheetColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        color: sheetColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  'Choose how often you want to repeat this call.',
                  style: TextStyle(
                    fontSize: 13,
                    color: sheetColors.textTertiary,
                  ),
                ),

                const SizedBox(height: 12),

                ...repeatOptions.map((option) {
                  final isSelected = selectedRepeat == option;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? sheetColors.primaryLight
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? sheetColorScheme.primary.withValues(alpha: 0.18)
                            : sheetColors.border,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                      ),
                      title: Text(
                        option,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: sheetColors.textPrimary,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: sheetColorScheme.primary,
                            )
                          : Icon(
                              Icons.circle_outlined,
                              color: sheetColors.textDisabled,
                            ),
                      onTap: () {
                        Navigator.pop(context, option);
                      },
                    ),
                  );
                }),
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

  String get remindersSummary {
    final selected = List<int>.from(
      selectedReminderMinutesBefore,
    )..sort();

    if (selected.length == 1) {
      return reminderOptions[selected.first] ?? 'Custom reminder';
    }

    return '${selected.length} reminders selected';
  }

  Future<void> selectReminders(BuildContext context) async {
    final colors = context.themeColors;
    final colorScheme = Theme.of(context).colorScheme;

    final selected = Set<int>.from(
      selectedReminderMinutesBefore,
    );

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        final sheetColors = context.themeColors;
        final sheetColorScheme = Theme.of(context).colorScheme;

        return SafeArea(
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Reminders',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: sheetColors.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close_rounded,
                            color: sheetColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose when Callmate should remind you about this call.',
                      style: TextStyle(
                        fontSize: 13,
                        color: sheetColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...reminderOptions.entries.map((entry) {
                      final isSelected = selected.contains(entry.key);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? sheetColors.primaryLight
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? sheetColorScheme.primary
                                    .withValues(alpha: 0.18)
                                : sheetColors.border,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                          ),
                          title: Text(
                            entry.value,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: sheetColors.textPrimary,
                            ),
                          ),
                          trailing: Icon(
                            isSelected
                                ? Icons.check_circle_rounded
                                : Icons.circle_outlined,
                            color: isSelected
                                ? sheetColorScheme.primary
                                : sheetColors.textDisabled,
                          ),
                          onTap: () {
                            setSheetState(() {
                              if (isSelected) {
                                if (selected.length > 1) {
                                  selected.remove(entry.key);
                                }
                              } else {
                                selected.add(entry.key);
                              }
                            });
                          },
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          selectedReminderMinutesBefore =
                              selected.toList()..sort();
                          update();
                          Navigator.pop(context);
                        },
                        child: const Text('Done'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
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
      id: isReschedule
          ? DateTime.now().microsecondsSinceEpoch.toString()
          : call?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      contactName: contactNameController.text.trim(),
      phoneNumber: phoneNumberController.text.trim(),
      scheduledAt: scheduledAt,
      status: isReschedule
          ? CallStatusEntity.upcoming
          : call?.status ?? CallStatusEntity.upcoming,
      notes: notesController.text.trim().isEmpty
          ? null
          : notesController.text.trim(),
      repeat: selectedRepeat,
      reminderMinutesBefore:
          List<int>.from(selectedReminderMinutesBefore)..sort(),
    );
  }

  Future<void> pickContact() async {
    if (isPickingContact) {
      return;
    }

    try {
      isPickingContact = true;
      update();

      final contact = await _contactPicker.selectPhoneNumber();

      if (contact == null) {
        return;
      }

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

    try {
      if (call == null || isReschedule) {
        if (isReschedule && call != null) {
          try {
            await NotificationService.instance.cancelCallReminder(call!);
          } catch (e) {
            debugPrint('Error cancelling old call reminder: $e');
          }
        }

        await useCase.addCall(entity);
      } else {
        await NotificationService.instance.cancelCallReminder(call!);

        await useCase.updateCall(entity);
      }

      if (entity.status == CallStatusEntity.upcoming &&
          entity.scheduledAt.isAfter(DateTime.now())) {
        try {
          if (entity.status == CallStatusEntity.upcoming &&
              entity.scheduledAt.isAfter(DateTime.now())) {
            try {
              final permissionGranted = await NotificationService.instance
                  .requestNotificationPermission();

              if (!permissionGranted) {
                debugPrint('Notification permission was not granted.');
              } else {
                await NotificationService.instance
                    .requestExactAlarmPermission();

                await NotificationService.instance.scheduleCallReminder(entity);
              }
            } catch (e, stackTrace) {
              debugPrint('Error scheduling call reminder: $e');

              debugPrintStack(stackTrace: stackTrace);
            }
          } else {
            debugPrint('Notification permission was not granted.');
          }
        } catch (e) {
          debugPrint('Error scheduling call reminder: $e');
        }
      }

      update();
    } finally {
      isSaving = false;
    }
  }

  @override
  void onClose() {
    contactNameController.dispose();
    phoneNumberController.dispose();
    notesController.dispose();

    super.onClose();
  }
}
