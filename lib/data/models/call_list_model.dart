import 'package:call_schedular/domain/entity/call_list_entity.dart';

enum CallStatus { upcoming, completed, missed }

class CallListModel {
  final String id;
  final String contactName;
  final String phoneNumber;
  final DateTime scheduledAt;
  final CallStatus status;
  final String? notes;
  final String repeat;

  const CallListModel({
    required this.id,
    required this.contactName,
    required this.phoneNumber,
    required this.scheduledAt,
    this.status = CallStatus.upcoming,
    this.notes,
    this.repeat = 'Does not repeat',
  });

  /// Convert domain entity to data model
  factory CallListModel.fromEntity(CallListEntity entity) {
    return CallListModel(
      id: entity.id,
      contactName: entity.contactName,
      phoneNumber: entity.phoneNumber,
      scheduledAt: entity.scheduledAt,
      status: CallStatus.values.firstWhere(
            (value) => value.name == entity.status.name,
        orElse: () => CallStatus.upcoming,
      ),
      notes: entity.notes,
      repeat: entity.repeat,
    );
  }

  /// Convert SQLite row to model
  factory CallListModel.fromMap(Map<String, Object?> map) {
    return CallListModel(
      id: map['id'] as String,
      contactName: map['contact_name'] as String,
      phoneNumber: map['phone_number'] as String,
      scheduledAt: DateTime.fromMillisecondsSinceEpoch(
        map['scheduled_at'] as int,
      ),
      status: CallStatus.values.firstWhere(
            (value) => value.name == map['status'],
        orElse: () => CallStatus.upcoming,
      ),
      notes: map['notes'] as String?,
      repeat: map['repeat'] as String,
    );
  }

  /// Convert model to SQLite row
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'contact_name': contactName,
      'phone_number': phoneNumber,
      'scheduled_at': scheduledAt.millisecondsSinceEpoch,
      'status': status.name,
      'notes': notes,
      'repeat': repeat,
    };
  }

  /// Convert data model to domain entity
  CallListEntity toEntity() => CallListEntity(
    id: id,
    contactName: contactName,
    phoneNumber: phoneNumber,
    scheduledAt: scheduledAt,
    status: CallStatusEntity.fromString(status.name),
    notes: notes,
    repeat: repeat,
  );
}