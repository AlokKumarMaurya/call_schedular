import 'package:call_schedular/data/repo/call_list_repo_impl.dart';
import 'package:call_schedular/domain/repo/call_repo.dart';
import 'package:get/get.dart';

import 'data/data_source/call_list_data_source.dart';
import 'domain/usecase/call_use_case.dart';

class AppDI {
  static void init() {
    _initDataSource();
    _initRepo();
    _initUseCase();
  }

  static void _initDataSource() {
    Get.lazyPut<CallListDataSource>(() => CallListDataSourceImpl());
  }

  static void _initRepo() {
    Get.lazyPut<CallRepo>(
      () => CallListRepoImpl(Get.find<CallListDataSource>()),
    );
  }

  static void _initUseCase() {
    Get.lazyPut(() => CallUseCase(Get.find<CallRepo>()));
  }
}
