import 'dart:async';

import 'package:call_schedular/data/data_source/local/call_local_datasource.dart';
import 'package:call_schedular/domain/entity/call_list_entity.dart';
import 'package:call_schedular/domain/repo/call_repo.dart';

import 'package:call_schedular/services/cloud_sync_service.dart';
import 'package:call_schedular/services/home_widget_service.dart';

class CallRepoImpl implements CallRepo {
  final CallLocalDataSource _localDataSource;
  final CloudSyncService _cloudSyncService;
  final HomeWidgetService _homeWidgetService;

  CallRepoImpl(
    this._localDataSource,
    this._cloudSyncService,
    this._homeWidgetService,
  );

  @override
  Future<List<CallListEntity>> getCallList() {
    return _localDataSource.getCallList();
  }

  @override
  Future<void> addCall(CallListEntity call) async {
    await _localDataSource.insertCall(call);
    await _cloudSyncService.queueUpsert(call);
    unawaited(_homeWidgetService.refresh());
  }

  @override
  Future<void> updateCall(CallListEntity call) async {
    await _localDataSource.updateCall(call);
    await _cloudSyncService.queueUpsert(call);
    unawaited(_homeWidgetService.refresh());
  }

  @override
  Future<void> deleteCall(String id) async {
    await _localDataSource.deleteCall(id);
    await _cloudSyncService.queueDelete(id);
    unawaited(_homeWidgetService.refresh());
  }

  @override
  Future<void> replaceCalls(List<CallListEntity> calls) async {
    await _localDataSource.replaceCalls(calls);
    await _cloudSyncService.syncAllCalls();
    unawaited(_homeWidgetService.refresh());
  }
}
