import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';

class AppUpdateService {
  AppUpdateService._();

  static final AppUpdateService instance = AppUpdateService._();

  StreamSubscription<InstallStatus>? _installStatusSubscription;

  bool _isChecking = false;
  bool _isUpdateDialogVisible = false;
  bool _isInstallDialogVisible = false;

  AppUpdateInfo? _latestUpdateInfo;

  AppUpdateInfo? get latestUpdateInfo => _latestUpdateInfo;

  bool get isChecking => _isChecking;

  /// Checks Google Play for an available update.
  ///
  /// This method is safe to call on unsupported platforms because
  /// the underlying plugin only supports Android.
  Future<AppUpdateInfo?> checkForUpdate() async {
    if (!GetPlatform.isAndroid) {
      return null;
    }

    if (_isChecking) {
      return _latestUpdateInfo;
    }

    _isChecking = true;

    try {
      final info = await InAppUpdate.checkForUpdate();

      _latestUpdateInfo = info;

      return info;
    } catch (e, stackTrace) {
      debugPrint('App update check failed: $e');
      debugPrintStack(stackTrace: stackTrace);

      return null;
    } finally {
      _isChecking = false;
    }
  }

  /// Checks for an update and automatically decides whether to show
  /// a normal or critical update flow.
  ///
  /// This should only be called after the first Flutter frame.
  Future<void> checkAndPrompt() async {
    final info = await checkForUpdate();

    if (info == null) {
      return;
    }

    if (info.updateAvailability != UpdateAvailability.updateAvailable) {
      return;
    }

    if (_isUpdateDialogVisible) {
      return;
    }

    /*
     * Google Play allows the developer to assign an update priority.
     *
     * We treat priority 4 or 5 as critical.
     *
     * Critical updates use Google's immediate update flow.
     * Normal updates use the flexible flow.
     */
    final isCriticalUpdate =
        info.updatePriority >= 4 && info.immediateUpdateAllowed;

    if (isCriticalUpdate) {
      await _startImmediateUpdate();
      return;
    }

    if (info.flexibleUpdateAllowed) {
      await _showNormalUpdateDialog(info);
      return;
    }

    /*
     * If flexible update is not currently allowed but immediate
     * update is allowed, offer the immediate flow as a fallback.
     */
    if (info.immediateUpdateAllowed) {
      await _showNormalUpdateDialog(
        info,
        allowImmediateFallback: true,
      );
    }
  }

  /// Manual update check used from Settings.
  ///
  /// Returns true when an update is available.
  Future<bool> checkAndPromptManually() async {
    final info = await checkForUpdate();

    if (info == null) {
      return false;
    }

    if (info.updateAvailability != UpdateAvailability.updateAvailable) {
      _showMessage(
        'You are already using the latest version.',
      );

      return false;
    }

    if (_isUpdateDialogVisible) {
      return true;
    }

    final isCriticalUpdate =
        info.updatePriority >= 4 && info.immediateUpdateAllowed;

    if (isCriticalUpdate) {
      await _startImmediateUpdate();
      return true;
    }

    if (info.flexibleUpdateAllowed) {
      await _showNormalUpdateDialog(info);
      return true;
    }

    if (info.immediateUpdateAllowed) {
      await _showNormalUpdateDialog(
        info,
        allowImmediateFallback: true,
      );

      return true;
    }

    _showMessage(
      'An update is available, but Google Play is not ready to install it yet.',
    );

    return true;
  }

  Future<void> _showNormalUpdateDialog(
      AppUpdateInfo info, {
        bool allowImmediateFallback = false,
      }) async {
    if (_isUpdateDialogVisible) {
      return;
    }

    _isUpdateDialogVisible = true;

    try {
      await Get.dialog(
        AlertDialog(
          title: const Text('Update available'),
          content: const Text(
            'A newer version of Callmate is available. '
                'Update now to get the latest improvements and fixes.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('Later'),
            ),
            FilledButton(
              onPressed: () async {
                Get.back();

                if (info.flexibleUpdateAllowed) {
                  await _startFlexibleUpdate();
                } else if (allowImmediateFallback &&
                    info.immediateUpdateAllowed) {
                  await _startImmediateUpdate();
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
        barrierDismissible: true,
      );
    } finally {
      _isUpdateDialogVisible = false;
    }
  }

  Future<void> _startFlexibleUpdate() async {
    try {
      _listenForFlexibleUpdateCompletion();

      final result = await InAppUpdate.startFlexibleUpdate();

      if (result == AppUpdateResult.userDeniedUpdate) {
        _showMessage(
          'Update cancelled.',
        );
        return;
      }

      if (result == AppUpdateResult.inAppUpdateFailed) {
        _showMessage(
          'Could not start the update. Please try again later.',
        );
        return;
      }

      _showMessage(
        'Update is downloading in the background.',
      );
    } catch (e, stackTrace) {
      debugPrint('Flexible app update failed: $e');
      debugPrintStack(stackTrace: stackTrace);

      _showMessage(
        'Could not start the update. Please try again later.',
      );
    }
  }

  void _listenForFlexibleUpdateCompletion() {
    _installStatusSubscription?.cancel();

    _installStatusSubscription =
        InAppUpdate.installUpdateListener.listen(
              (status) {
            debugPrint(
              'App update install status: $status',
            );

            if (status == InstallStatus.downloaded) {
              unawaited(_handleDownloadedUpdate());
            }
          },
          onError: (Object error, StackTrace stackTrace) {
            debugPrint(
              'App update listener failed: $error',
            );
            debugPrintStack(stackTrace: stackTrace);
          },
        );
  }

  Future<void> _handleDownloadedUpdate() async {
    if (_isInstallDialogVisible) {
      return;
    }

    _isInstallDialogVisible = true;

    try {
      await Get.dialog(
        AlertDialog(
          title: const Text('Update ready'),
          content: const Text(
            'The new version has been downloaded. '
                'Restart the app to finish the update.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('Later'),
            ),
            FilledButton(
              onPressed: () async {
                Get.back();

                await _completeFlexibleUpdate();
              },
              child: const Text('Restart & Update'),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    } finally {
      _isInstallDialogVisible = false;
    }
  }

  Future<void> _completeFlexibleUpdate() async {
    try {
      await InAppUpdate.completeFlexibleUpdate();
    } catch (e, stackTrace) {
      debugPrint(
        'Completing flexible app update failed: $e',
      );
      debugPrintStack(stackTrace: stackTrace);

      _showMessage(
        'The update could not be completed. '
            'Please restart the app and try again.',
      );
    }
  }

  Future<void> _startImmediateUpdate() async {
    try {
      final result = await InAppUpdate.performImmediateUpdate();

      if (result == AppUpdateResult.userDeniedUpdate) {
        _showMessage(
          'This update is required to continue using the latest version.',
        );
        return;
      }

      if (result == AppUpdateResult.inAppUpdateFailed) {
        _showMessage(
          'The update could not be started. Please try again later.',
        );
      }
    } catch (e, stackTrace) {
      debugPrint(
        'Immediate app update failed: $e',
      );
      debugPrintStack(stackTrace: stackTrace);

      _showMessage(
        'The update could not be started. Please try again later.',
      );
    }
  }

  void _showMessage(String message) {
    if (Get.context == null) {
      return;
    }

    Get.snackbar(
      'App Update',
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 4),
    );
  }

  void dispose() {
    _installStatusSubscription?.cancel();
    _installStatusSubscription = null;
  }
}