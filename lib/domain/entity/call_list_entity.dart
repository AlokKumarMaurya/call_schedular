enum CallStatusEntity {
  upcoming,
  completed,
  missed;

  static CallStatusEntity fromString(String s) {
    return CallStatusEntity.values.firstWhere((element) => element.name == s);
  }
}

class CallListEntity {
  final String id;
  final String contactName;
  final String phoneNumber;
  final DateTime scheduledAt;
  final CallStatusEntity status;
  final String? notes;

  const CallListEntity({
    required this.id,
    required this.contactName,
    required this.phoneNumber,
    required this.scheduledAt,
    this.status = CallStatusEntity.upcoming,
    this.notes,
  });

  /// First character for avatar
  String get initial =>
      contactName.isNotEmpty ? contactName[0].toUpperCase() : '?';

  /// Check whether call is scheduled for today
  bool get isToday {
    final now = DateTime.now();

    return scheduledAt.year == now.year &&
        scheduledAt.month == now.month &&
        scheduledAt.day == now.day;
  }

  /// Check whether call is scheduled for future
  bool get isUpcoming {
    return scheduledAt.isAfter(DateTime.now()) && !isToday;
  }

  /// Formatted time
  String get formattedTime {
    final hour = scheduledAt.hour;
    final minute = scheduledAt.minute;

    final period = hour >= 12 ? 'PM' : 'AM';
    final formattedHour = hour % 12 == 0 ? 12 : hour % 12;

    return '$formattedHour:${minute.toString().padLeft(2, '0')} $period';
  }

  /// Formatted date
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

  CallListEntity copyWith({
    String? id,
    String? contactName,
    String? phoneNumber,
    DateTime? scheduledAt,
    CallStatusEntity? status,
    String? notes,
  }) {
    return CallListEntity(
      id: id ?? this.id,
      contactName: contactName ?? this.contactName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}
