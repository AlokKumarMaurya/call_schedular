import 'dart:async';

import 'package:call_schedular/constants/app_const.dart';
import 'package:call_schedular/di.dart';
import 'package:call_schedular/local_storage/local_storage.dart';
import 'package:call_schedular/presentation/call_details/call_details_view.dart';
import 'package:call_schedular/presentation/home/home_view.dart';
import 'package:call_schedular/presentation/intro/intro_view.dart';
import 'package:call_schedular/services/app_crash_reporter.dart';
import 'package:call_schedular/services/app_lock_service.dart';
import 'package:call_schedular/services/app_update_service.dart';
import 'package:call_schedular/services/cloud_sync_service.dart';
import 'package:call_schedular/services/notification_service.dart';
import 'package:call_schedular/services/home_widget_service.dart';
import 'package:call_schedular/theme/app_theme.dart';
import 'package:call_schedular/theme/app_theme_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'domain/entity/call_list_entity.dart';
import 'domain/usecase/call_use_case.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /*
   * Firebase must be initialized before Crashlytics can
   * register its global error handlers.
   */
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await AppCrashReporter.instance.initialize();
  } catch (e, stackTrace) {
    debugPrint(
      'Firebase/Crashlytics initialization failed: $e',
    );

    debugPrintStack(
      stackTrace: stackTrace,
    );
  }

  /*
   * Only initialization required to determine the first Flutter
   * screen is performed before runApp().
   */
  try {
    await GetStorage.init();

    Get.put(
      AppThemeController(),
      permanent: true,
    );

    AppDI.init();
    await Get.find<AppLockService>().initialize();
  } catch (e, stackTrace) {
    debugPrint(
      'App startup initialization failed: $e',
    );

    debugPrintStack(
      stackTrace: stackTrace,
    );

    /*
     * If something fails during application startup, record it
     * as a non-fatal error when Crashlytics is available.
     */
    await AppCrashReporter.instance.recordError(
      e,
      stackTrace,
      reason: 'Application startup initialization failed',
    );
  }

  /*
   * Do not defer the first Flutter frame.
   *
   * The native splash remains visible while Flutter initializes.
   * The first Flutter frame is rendered as soon as the app is ready.
   */
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  StreamSubscription<String>? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    /*
     * Listen for notification taps as soon as the Flutter app
     * is mounted.
     */
    _notificationSubscription = NotificationService
        .instance
        .callNotificationTapStream
        .listen(_openCallFromNotification);

    /*
     * Notification initialization and app-update checking are
     * deliberately performed after the first Flutter frame.
     *
     * This prevents either service from delaying the initial UI
     * or affecting the native splash handoff.
     */
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_initializeNotifications());
      unawaited(Get.find<HomeWidgetService>().refresh());
      if (Get.find<AppLockService>().isLocked.value) {
        unawaited(Get.find<AppLockService>().authenticate());
      }

      /*
       * App update checking is intentionally started after the
       * first frame so the splash/startup experience remains
       * completely independent from Google Play.
       */
      unawaited(
        AppUpdateService.instance.checkAndPrompt(),
      );
    });
  }

  Future<void> _initializeNotifications() async {
    try {
      await NotificationService.instance.initialize();

      /*
       * Check whether the application was launched by tapping
       * a notification.
       */
      await _handleInitialNotification();
    } catch (e, stackTrace) {
      debugPrint(
        'Notification initialization failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      await AppCrashReporter.instance.recordError(
        e,
        stackTrace,
        reason: 'Notification initialization failed',
      );
    }
  }

  Future<void> _handleInitialNotification() async {
    final callId =
    NotificationService.instance.consumeInitialCallId();

    if (callId == null || callId.isEmpty) {
      return;
    }

    await _openCallFromNotification(callId);
  }

  Future<void> _openCallFromNotification(String callId) async {
    try {
      final useCase = Get.find<CallUseCase>();

      final calls = await useCase.getCallList();

      CallListEntity? call;

      for (final item in calls) {
        if (item.id == callId) {
          call = item;
          break;
        }
      }

      if (call == null) {
        debugPrint(
          'Call not found for notification: $callId',
        );

        await AppCrashReporter.instance.recordError(
          StateError(
            'Call not found for notification',
          ),
          StackTrace.current,
          reason: 'Notification referenced a missing call',
          information: [
            'callId: $callId',
          ],
        );

        return;
      }

      if (!mounted) {
        return;
      }

      Get.until(
            (route) => route.isFirst,
      );

      Get.to(
            () => CallDetailsView(
          call: call!,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint(
        'Failed to open call from notification: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      await AppCrashReporter.instance.recordError(
        e,
        stackTrace,
        reason: 'Failed to open call from notification',
        information: [
          'callId: $callId',
        ],
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final appLockService = Get.find<AppLockService>();
      if (appLockService.enabled) {
        appLockService.lock();
        unawaited(appLockService.authenticate());
      }

      unawaited(Get.find<CloudSyncService>().retryPendingSync());
      unawaited(Get.find<HomeWidgetService>().refresh());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _notificationSubscription?.cancel();

    AppUpdateService.instance.dispose();

    super.dispose();
  }

  Widget _buildAppLockOverlay(
      BuildContext context,
      AppLockService appLockService,
      ) {
    final isAuthenticating = appLockService.isAuthenticating.value;

    return Positioned.fill(
      child: ColoredBox(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_rounded,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Callmate is locked',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Authenticate with your device to continue.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: isAuthenticating
                          ? null
                          : () => unawaited(appLockService.authenticate()),
                      icon: isAuthenticating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.fingerprint_rounded),
                      label: Text(
                        isAuthenticating
                            ? 'Authenticating...'
                            : 'Unlock Callmate',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilPlusInit(
      designSize: const Size(360, 690),

      /*
       * ensureScreenSize waits for valid screen metrics before
       * building widgets that use .w / .h / .sp / .r.
       *
       * This is important for the current startup architecture,
       * where the native splash hands off directly to Flutter.
       */
      ensureScreenSize: true,

      minTextAdapt: true,
      splitScreenMode: true,

      builder: (context, child) {
        final themeController =
        Get.find<AppThemeController>();
        final appLockService = Get.find<AppLockService>();

        return Obx(
              () => GetMaterialApp(
            theme: appTheme,
            darkTheme: appDarkTheme,
            themeMode: themeController.themeMode.value,
            title: AppConst.appName,
            debugShowCheckedModeBanner: false,

            home: Scaffold(
              backgroundColor:
              themeController.themeMode.value ==
                  ThemeMode.dark
                  ? appDarkTheme.scaffoldBackgroundColor
                  : appTheme.scaffoldBackgroundColor,
              body: Stack(
                children: [
                  child,
                  if (appLockService.isLocked.value)
                    _buildAppLockOverlay(context, appLockService),
                ],
              ),
            ),
          ),
        );
      },

      child: AppLocalStorage.isIntroViewed
          ? const HomeView()
          : const IntroView(),
    );
  }
}