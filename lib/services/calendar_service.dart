import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:call_schedular/domain/entity/call_list_entity.dart';
import 'package:call_schedular/services/app_crash_reporter.dart';
import 'package:flutter/foundation.dart';

class CalendarService {
  CalendarService._();

  static final CalendarService instance = CalendarService._();

  Future<bool> addCallToCalendar(
      CallListEntity call,
      ) async {
    try {
      final contactName = call.contactName.trim().isEmpty
          ? 'Unknown Contact'
          : call.contactName.trim();

      final phoneNumber = call.phoneNumber.trim();

      final description = _buildDescription(
        phoneNumber: phoneNumber,
        notes: call.notes,
      );

      final event = Event(
        title: 'Call $contactName',
        description: description,
        startDate: call.scheduledAt,
        endDate: call.scheduledAt.add(
          const Duration(minutes: 30),
        ),
        allDay: false,
        recurrence: _buildRecurrence(call.repeat),
      );

      final added = await Add2Calendar.addEvent2Cal(event);

      if (added) {
        AppCrashReporter.instance.log(
          'Call added to device calendar',
        );

        await AppCrashReporter.instance.setKey(
          'calendar_event_repeat',
          call.repeat,
        );
      }

      return added;
    } catch (e, stackTrace) {
      debugPrint(
        'Failed to add call to calendar: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      await AppCrashReporter.instance.recordError(
        e,
        stackTrace,
        reason: 'Failed to add call to device calendar',
        information: [
          'callId: ${call.id}',
          'repeat: ${call.repeat}',
        ],
      );

      return false;
    }
  }

  String _buildDescription({
    required String phoneNumber,
    required String? notes,
  }) {
    final parts = <String>[];

    if (phoneNumber.isNotEmpty) {
      parts.add('Phone: $phoneNumber');
    }

    final cleanedNotes = notes?.trim();

    if (cleanedNotes != null && cleanedNotes.isNotEmpty) {
      parts.add('Notes: $cleanedNotes');
    }

    if (parts.isEmpty) {
      return 'Scheduled call from Callmate.';
    }

    return parts.join('\n');
  }

  Recurrence? _buildRecurrence(String repeat) {
    switch (repeat) {
      case 'Every day':
        return Recurrence(
          frequency: Frequency.daily,
        );

      case 'Every week':
        return Recurrence(
          frequency: Frequency.weekly,
        );

      case 'Every month':
        return Recurrence(
          frequency: Frequency.monthly,
        );

      case 'Every year':
        return Recurrence(
          frequency: Frequency.yearly,
        );

      case 'Does not repeat':
      default:
        return null;
    }
  }
}