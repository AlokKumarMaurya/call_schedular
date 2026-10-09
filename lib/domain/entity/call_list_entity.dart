class CallListEntity {
  final String id;
  final String contactName;
  final String phoneNumber;
  final DateTime scheduledAt;
  final CallStatusEntity status;
  final String? notes;
  final String repeat;
  final List<int> reminderMinutesBefore;

  const CallListEntity({
    required this.id,
    required this.contactName,
    required this.phoneNumber,
    required this.scheduledAt,
    this.status = CallStatusEntity.upcoming,
    this.notes,
    this.repeat = 'Does not repeat',
    this.reminderMinutesBefore = const [0],
  });

  String get initial =>
      contactName.isNotEmpty ? contactName[0].toUpperCase() : '?';

  List<int> get sortedReminderMinutesBefore {
    final reminders = List<int>.from(reminderMinutesBefore);
    reminders.sort();
    return reminders;
  }

  bool get isToday {
    final now = DateTime.now();

    return scheduledAt.year == now.year &&
        scheduledAt.month == now.month &&
        scheduledAt.day == now.day;
  }

  bool get isUpcoming {
    return scheduledAt.isAfter(DateTime.now()) && !isToday;
  }

  bool get isRecurring {
    return repeat != 'Does not repeat';
  }

  String get formattedTime {
    final hour = scheduledAt.hour;
    final minute = scheduledAt.minute;

    final period = hour >= 12 ? 'PM' : 'AM';
    final formattedHour = hour % 12 == 0 ? 12 : hour % 12;

    return '$formattedHour:${minute.toString().padLeft(2, '0')} $period';
  }

  String get formattedDate {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${scheduledAt.day} ${months[scheduledAt.month - 1]}';
  }

  /// Returns the date/time for the next occurrence.
  DateTime get nextOccurrenceDate {
    switch (repeat) {
      case 'Every day':
        return scheduledAt.add(const Duration(days: 1));
      case 'Every 2 days':
        return scheduledAt.add(const Duration(days: 2));
      case 'Every week':
        return scheduledAt.add(const Duration(days: 7));
      case 'Every 2 weeks':
        return scheduledAt.add(const Duration(days: 14));
      case 'Every month':
        return _addMonths(scheduledAt, 1);
      case 'Every 2 months':
        return _addMonths(scheduledAt, 2);
      case 'Every year':
        return _addYears(scheduledAt, 1);
      case 'Every weekday':
        return _nextWeekday(scheduledAt);
      case 'Every weekend':
        return _nextWeekendDay(scheduledAt);
      case 'Every Monday':
        return _nextNamedWeekday(scheduledAt, DateTime.monday);
      case 'Every Tuesday':
        return _nextNamedWeekday(scheduledAt, DateTime.tuesday);
      case 'Every Wednesday':
        return _nextNamedWeekday(scheduledAt, DateTime.wednesday);
      case 'Every Thursday':
        return _nextNamedWeekday(scheduledAt, DateTime.thursday);
      case 'Every Friday':
        return _nextNamedWeekday(scheduledAt, DateTime.friday);
      case 'Every Saturday':
        return _nextNamedWeekday(scheduledAt, DateTime.saturday);
      case 'Every Sunday':
        return _nextNamedWeekday(scheduledAt, DateTime.sunday);
      case 'Does not repeat':
      default:
        return scheduledAt;
    }
  }

  DateTime _nextNamedWeekday(DateTime date, int weekday) {
    var daysUntil = (weekday - date.weekday) % 7;
    if (daysUntil == 0) {
      daysUntil = 7;
    }
    return date.add(Duration(days: daysUntil));
  }

  DateTime _nextWeekday(DateTime date) {
    var next = date.add(const Duration(days: 1));
    while (next.weekday == DateTime.saturday ||
        next.weekday == DateTime.sunday) {
      next = next.add(const Duration(days: 1));
    }
    return next;
  }

  DateTime _nextWeekendDay(DateTime date) {
    var next = date.add(const Duration(days: 1));
    while (next.weekday != DateTime.saturday &&
        next.weekday != DateTime.sunday) {
      next = next.add(const Duration(days: 1));
    }
    return next;
  }

  DateTime _addMonths(
      DateTime date,
      int months,
      ) {
    final totalMonths =
        date.year * 12 + (date.month - 1) + months;

    final year = totalMonths ~/ 12;
    final month = totalMonths % 12 + 1;

    final lastDayOfMonth = DateTime(
      year,
      month + 1,
      0,
    ).day;

    final day = date.day > lastDayOfMonth
        ? lastDayOfMonth
        : date.day;

    return DateTime(
      year,
      month,
      day,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );
  }

  DateTime _addYears(
      DateTime date,
      int years,
      ) {
    final year = date.year + years;

    final lastDayOfMonth = DateTime(
      year,
      date.month + 1,
      0,
    ).day;

    final day = date.day > lastDayOfMonth
        ? lastDayOfMonth
        : date.day;

    return DateTime(
      year,
      date.month,
      day,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );
  }

  /// Creates the next occurrence as a new call.
  CallListEntity createNextOccurrence() {
    return CallListEntity(
      id: '${id}_${nextOccurrenceDate.microsecondsSinceEpoch}',
      contactName: contactName,
      phoneNumber: phoneNumber,
      scheduledAt: nextOccurrenceDate,
      status: CallStatusEntity.upcoming,
      notes: notes,
      repeat: repeat,
      reminderMinutesBefore: reminderMinutesBefore,
    );
  }

  CallListEntity copyWith({
    String? id,
    String? contactName,
    String? phoneNumber,
    DateTime? scheduledAt,
    CallStatusEntity? status,
    String? notes,
    String? repeat,
    List<int>? reminderMinutesBefore,
  }) {
    return CallListEntity(
      id: id ?? this.id,
      contactName: contactName ?? this.contactName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      repeat: repeat ?? this.repeat,
      reminderMinutesBefore:
          reminderMinutesBefore ?? this.reminderMinutesBefore,
    );
  }
}

enum CallStatusEntity {
  upcoming,
  completed,
  missed;

  static CallStatusEntity fromString(String s) {
    return CallStatusEntity.values.firstWhere(
          (element) => element.name == s,
    );
  }
}