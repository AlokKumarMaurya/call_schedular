import 'package:call_schedular/local_storage/local_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';

class AppLockService extends GetxService {
  final LocalAuthentication _localAuthentication = LocalAuthentication();

  final RxBool isEnabled = false.obs;
  final RxBool isLocked = false.obs;
  final RxBool isAuthenticating = false.obs;

  bool _initialized = false;

  bool get enabled => isEnabled.value;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _initialized = true;
    isEnabled.value = AppLocalStorage.isAppLockEnabled;

    if (isEnabled.value) {
      isLocked.value = true;
    }
  }

  Future<bool> canAuthenticate() async {
    try {
      return await _localAuthentication.isDeviceSupported();
    } catch (e) {
      debugPrint('Failed to check device authentication support: $e');
      return false;
    }
  }

  Future<bool> enable() async {
    final supported = await canAuthenticate();

    if (!supported) {
      return false;
    }

    final authenticated = await authenticate();

    if (!authenticated) {
      return false;
    }

    isEnabled.value = true;
    isLocked.value = false;
    AppLocalStorage.setAppLockEnabled(true);
    return true;
  }

  Future<void> disable() async {
    isLocked.value = false;
    isEnabled.value = false;
    AppLocalStorage.setAppLockEnabled(false);
  }

  Future<bool> authenticate() async {
    if (isAuthenticating.value) {
      return false;
    }

    isAuthenticating.value = true;

    try {
      final supported = await canAuthenticate();

      if (!supported) {
        return false;
      }

      final authenticated = await _localAuthentication.authenticate(
        localizedReason: 'Authenticate to open Callmate',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );

      if (authenticated) {
        isLocked.value = false;
      }

      return authenticated;
    } catch (e) {
      debugPrint('App authentication failed: $e');
      return false;
    } finally {
      isAuthenticating.value = false;
    }
  }

  void lock() {
    if (isEnabled.value) {
      isLocked.value = true;
    }
  }
}
