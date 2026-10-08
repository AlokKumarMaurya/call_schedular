import 'dart:async';

import '../../domain/entity/call_list_entity.dart';
import '../../domain/repo/call_repo.dart';
import '../../services/cloud_sync_service.dart';
import '../data_source/local/call_local_datasource.dart';

class CallRepoImpl implements CallRepo {
  final CallLocalDataSource _localDataSource;
  final CloudSyncService _cloudSyncService;

  CallRepoImpl(
    this._localDataSource,
    this._cloudSyncService,
  );

  @override
  Future<List<CallListEntity>> getCallList() {
    return _localDataSource.getCallList();
  }

  @override
  Future<void> addCall(CallListEntity call) async {
    await _localDataSource.insertCall(call);
    unawaited(_cloudSyncService.syncCall(call));
  }

  @override
  Future<void> updateCall(CallListEntity call) async {
    await _localDataSource.updateCall(call);
    unawaited(_cloudSyncService.syncCall(call));
  }

  @override
  Future<void> deleteCall(String id) async {
    await _localDataSource.deleteCall(id);
    unawaited(_cloudSyncService.deleteCall(id));
  }

  @override
  Future<void> replaceCalls(List<CallListEntity> calls) async {
    await _localDataSource.replaceCalls(calls);
    unawaited(_cloudSyncService.syncAllCalls());
  }
}
