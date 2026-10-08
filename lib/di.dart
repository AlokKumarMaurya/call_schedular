import 'package:call_schedular/data/data_source/local/call_database.dart';
import 'package:call_schedular/data/repo/call_list_repo_impl.dart';
import 'package:call_schedular/domain/repo/call_repo.dart';
import 'package:call_schedular/services/app_lock_service.dart';
import 'package:call_schedular/services/backup_service.dart';
import 'package:call_schedular/services/cloud_sync_service.dart';
import 'package:call_schedular/services/home_widget_service.dart';
import 'package:get/get.dart';

import 'data/data_source/call_list_data_source.dart';
import 'data/data_source/local/call_local_datasource.dart';
import 'domain/usecase/call_use_case.dart';

class AppDI {
  static void init() {
    _initDataSource();
    _initServices();
    _initRepo();
    _initUseCase();
  }

  static void _initDataSource() {
    Get.lazyPut<CallListDataSource>(() => CallListDataSourceImpl());

    Get.lazyPut<CallLocalDataSource>(
      () => CallLocalDataSource(CallDatabase.instance),
    );
  }

  static void _initServices() {
    Get.put<AppLockService>(
      AppLockService(),
      permanent: true,
    );
    Get.put<CloudSyncService>(
      CloudSyncService(Get.find<CallLocalDataSource>()),
      permanent: true,
    );

    Get.put<HomeWidgetService>(
      HomeWidgetService(Get.find<CallLocalDataSource>()),
      permanent: true,
    );

    Get.lazyPut<BackupService>(
      () => BackupService(Get.find<CallRepo>()),
    );
  }

  static void _initRepo() {
    Get.lazyPut<CallRepo>(
      () => CallRepoImpl(
        Get.find<CallLocalDataSource>(),
        Get.find<CloudSyncService>(),
        Get.find<HomeWidgetService>(),
      ),
    );
  }

  static void _initUseCase() {
    Get.lazyPut(() => CallUseCase(Get.find<CallRepo>()));
  }
}
