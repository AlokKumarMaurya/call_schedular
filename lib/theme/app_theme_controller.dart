import 'package:call_schedular/local_storage/local_storage.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class AppThemeController extends GetxController {
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  @override
  void onInit() {
    super.onInit();

    _loadThemeMode();
  }

  void _loadThemeMode() {
    final savedMode = AppLocalStorage.themeMode;

    switch (savedMode) {
      case 'light':
        themeMode.value = ThemeMode.light;
        break;

      case 'dark':
        themeMode.value = ThemeMode.dark;
        break;

      default:
        themeMode.value = ThemeMode.system;
    }
  }

  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;

    AppLocalStorage.setThemeMode(
      _themeModeToString(mode),
    );
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';

      case ThemeMode.dark:
        return 'dark';

      case ThemeMode.system:
        return 'system';
    }
  }
}