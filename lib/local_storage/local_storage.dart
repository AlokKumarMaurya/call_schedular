import 'package:call_schedular/local_storage/local_storage_keys.dart';
import 'package:get_storage/get_storage.dart';

class AppLocalStorage {
  static final _box = GetStorage();

  static bool get isIntroViewed =>
      _box.read(AppLocalStorageKeys.isIntroViewed) ?? false;

  static void setIntroViewed(bool value) {
    _box.write(AppLocalStorageKeys.isIntroViewed, value);
  }

  static String get themeMode =>
      _box.read(AppLocalStorageKeys.themeMode) ?? 'system';

  static void setThemeMode(String value) {
    _box.write(AppLocalStorageKeys.themeMode, value);
  }
}