import 'package:call_schedular/domain/entity/call_list_entity.dart';

enum CallStatus { upcoming, completed, missed }

class CallListModel {
  final String id;
  final String contactName;
  final String phoneNumber;
  final DateTime scheduledAt;
  final CallStatus status;
  final String? notes;

  const CallListModel({
    required this.id,
    required this.contactName,
    required this.phoneNumber,
    required this.scheduledAt,
    this.status = CallStatus.upcoming,
    this.notes,
  });

  CallListEntity toEntity() => CallListEntity(
    id: id,
    contactName: contactName,
    phoneNumber: phoneNumber,
    scheduledAt: scheduledAt,
    status: CallStatusEntity.fromString(status.name),
    notes: notes,
  );
}
