import '../entity/call_list_entity.dart';

abstract class CallRepo {
  Future<List<CallListEntity>> getCallList();

  Future<void> addCall(CallListEntity call);

  Future<void> updateCall(CallListEntity call);

  Future<void> deleteCall(String id);
}
