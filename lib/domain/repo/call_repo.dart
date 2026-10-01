import 'package:call_schedular/domain/entity/call_list_entity.dart';

abstract class CallRepo {
  Future<List<CallListEntity>> getCallList();
}
