import 'package:call_schedular/domain/entity/call_list_entity.dart';
import 'package:share_plus/share_plus.dart';

class CallShareService {
  CallShareService._();

  static final CallShareService instance = CallShareService._();

  Future<void> shareCall(CallListEntity call) async {
    final contactName = call.contactName.trim().isEmpty
        ? 'Unknown Contact'
        : call.contactName.trim();

    final phoneNumber = call.phoneNumber.trim().isEmpty
        ? 'Not available'
        : call.phoneNumber.trim();

    final notes = call.notes?.trim().isNotEmpty == true
        ? call.notes!.trim()
        : 'No notes';

    final status = _formatStatus(call.status);
    final repeat = call.repeat.trim().isEmpty
        ? 'Does not repeat'
        : call.repeat.trim();

    final text = '''
Callmate - Call Details

Contact: $contactName
Phone: $phoneNumber
Date: ${_formatDate(call.scheduledAt)}
Time: ${_formatTime(call.scheduledAt)}
Status: $status
Repeat: $repeat
Reminders: ${_formatReminders(call.reminderMinutesBefore)}
Notes: $notes
''';

    await Share.share(
      text,
      subject: 'Call details - $contactName',
    );
  }

  String _formatReminders(List<int> reminders) {
    final sorted = List<int>.from(reminders)..sort();

    return sorted.map((minutes) {
      if (minutes == 0) {
        return 'At call time';
      }

      if (minutes < 60) {
        return '$minutes minutes before';
      }

      if (minutes == 60) {
        return '1 hour before';
      }

      if (minutes == 1440) {
        return '1 day before';
      }

      return '${minutes ~/ 60} hours before';
    }).join(', ');
  }

  String _formatStatus(CallStatusEntity status) {
    switch (status) {
      case CallStatusEntity.upcoming:
        return 'Upcoming';
      case CallStatusEntity.completed:
        return 'Completed';
      case CallStatusEntity.missed:
        return 'Missed';
    }
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
}
