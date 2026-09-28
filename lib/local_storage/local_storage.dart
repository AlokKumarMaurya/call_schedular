import 'package:call_schedular/local_storage/local_storage_keys.dart';
import 'package:get_storage/get_storage.dart';

class AppLocalStorage {
  final _box = GetStorage();

  bool get isIntroViewed =>
      _box.read(AppLocalStorageKeys.isIntroViewed) ?? false;

  void setIntroViewed(bool value) {
    _box.write(AppLocalStorageKeys.isIntroViewed, value);
  }
}
