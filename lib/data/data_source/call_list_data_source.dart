import 'package:call_schedular/data/models/call_list_model.dart';

abstract class CallListDataSource {
  Future<List<CallListModel>> getCallList();
}

class CallListDataSourceImpl implements CallListDataSource {
  @override
  Future<List<CallListModel>> getCallList() async {
    return dummyCalls;
  }
}

final List<CallListModel> dummyCalls = [
  CallListModel(
    id: '1',
    contactName: 'Rahul Sharma',
    phoneNumber: '+91 98765 43210',
    scheduledAt: DateTime.now().copyWith(hour: 10, minute: 30),
  ),

  CallListModel(
    id: '2',
    contactName: 'Mom',
    phoneNumber: '+91 98765 67890',
    scheduledAt: DateTime.now().copyWith(hour: 18, minute: 0),
  ),

  CallListModel(
    id: '3',
    contactName: 'Client Meeting Call',
    phoneNumber: '+91 91234 56789',
    scheduledAt: DateTime.now().add(const Duration(days: 1, hours: 11)),
  ),

  CallListModel(
    id: '4',
    contactName: 'Doctor Appointment',
    phoneNumber: '+91 99887 66554',
    scheduledAt: DateTime.now().add(const Duration(days: 2, hours: 16)),
  ),

  CallListModel(
    id: '5',
    contactName: 'Amit Verma',
    phoneNumber: '+91 90000 11111',
    scheduledAt: DateTime.now().subtract(const Duration(days: 1)),
    status: CallStatus.completed,
  ),
];
