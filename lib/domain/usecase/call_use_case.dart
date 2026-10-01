import 'package:call_schedular/domain/entity/call_list_entity.dart';
import 'package:call_schedular/domain/repo/call_repo.dart';

class CallUseCase {
  final CallRepo _repo;

  CallUseCase(this._repo);

  Future<List<CallListEntity>> getCallList() => _repo.getCallList();

  Future<void> addCall(CallListEntity call) {
    return _repo.addCall(call);
  }

  Future<void> updateCall(CallListEntity call) {
    return _repo.updateCall(call);
  }

  Future<void> deleteCall(String id) {
    return _repo.deleteCall(id);
  }
}
