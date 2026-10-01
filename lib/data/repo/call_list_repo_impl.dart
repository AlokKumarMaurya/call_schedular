import 'package:call_schedular/data/data_source/call_list_data_source.dart';
import 'package:call_schedular/domain/entity/call_list_entity.dart';
import 'package:call_schedular/domain/repo/call_repo.dart';

class CallListRepoImpl implements CallRepo {
  final CallListDataSource _dataSource;

  CallListRepoImpl(this._dataSource);

  @override
  Future<List<CallListEntity>> getCallList() async =>
      (await _dataSource.getCallList()).map((call) => call.toEntity()).toList();
}
