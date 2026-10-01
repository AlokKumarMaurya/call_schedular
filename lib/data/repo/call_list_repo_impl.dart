import '../../domain/entity/call_list_entity.dart';
import '../../domain/repo/call_repo.dart';
import '../data_source/local/call_local_datasource.dart';

class CallRepoImpl implements CallRepo {
  final CallLocalDataSource _localDataSource;

  CallRepoImpl(this._localDataSource);

  @override
  Future<List<CallListEntity>> getCallList() {
    return _localDataSource.getCallList();
  }

  @override
  Future<void> addCall(CallListEntity call) {
    return _localDataSource.insertCall(call);
  }

  @override
  Future<void> updateCall(CallListEntity call) {
    return _localDataSource.updateCall(call);
  }

  @override
  Future<void> deleteCall(String id) {
    return _localDataSource.deleteCall(id);
  }
}
