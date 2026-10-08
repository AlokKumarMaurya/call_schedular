import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppCrashReporter {
  AppCrashReporter._();

  static final AppCrashReporter instance = AppCrashReporter._();

  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  bool _initialized = false;

  /// Initializes Crashlytics and registers global error handlers.
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _initialized = true;

    FlutterError.onError = (FlutterErrorDetails details) {
      _crashlytics.recordFlutterFatalError(details);
    };

    PlatformDispatcher.instance.onError =
        (Object error, StackTrace stackTrace) {
          _crashlytics.recordError(error, stackTrace, fatal: true);

          return true;
        };

    await _setAppInformation();

    await _crashlytics.setCrashlyticsCollectionEnabled(true);

    debugPrint('Crashlytics initialized.');
  }

  /// Adds useful application information to every Crashlytics report.
  Future<void> _setAppInformation() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();

      await _crashlytics.setCustomKey('app_version', packageInfo.version);

      await _crashlytics.setCustomKey('build_number', packageInfo.buildNumber);

      await _crashlytics.setCustomKey('platform', defaultTargetPlatform.name);
    } catch (e, stackTrace) {
      debugPrint('Failed to set Crashlytics app information: $e');

      debugPrintStack(stackTrace: stackTrace);
    }
  }

  /// Records a non-fatal exception.
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    String? reason,
    Iterable<Object>? information,
  }) async {
    try {
      await _crashlytics.recordError(
        error,
        stackTrace,
        reason: reason,
        information: information ?? [],
        fatal: false,
      );
    } catch (e, stackTrace) {
      debugPrint('Failed to record Crashlytics error: $e');

      debugPrintStack(stackTrace: stackTrace);
    }
  }

  /// Adds a custom value to future Crashlytics reports.
  Future<void> setKey(String key, Object value) async {
    try {
      await _crashlytics.setCustomKey(key, value);
    } catch (e, stackTrace) {
      debugPrint('Failed to set Crashlytics key: $e');

      debugPrintStack(stackTrace: stackTrace);
    }
  }

  /// Adds a diagnostic breadcrumb/log entry.
  void log(String message) {
    try {
      _crashlytics.log(message);
    } catch (e) {
      debugPrint('Failed to write Crashlytics log: $e');
    }
  }

  /// Sets the current user identifier.
  ///
  /// Do not pass sensitive information such as phone numbers,
  /// passwords, access tokens, or other private data.
  Future<void> setUserIdentifier(String identifier) async {
    try {
      await _crashlytics.setUserIdentifier(identifier);
    } catch (e, stackTrace) {
      debugPrint('Failed to set Crashlytics user identifier: $e');

      debugPrintStack(stackTrace: stackTrace);
    }
  }

  /// Clears the current Crashlytics user identifier.
  Future<void> clearUserIdentifier() async {
    try {
      await _crashlytics.setUserIdentifier('');
    } catch (e, stackTrace) {
      debugPrint('Failed to clear Crashlytics user identifier: $e');

      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
