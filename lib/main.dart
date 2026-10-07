import 'dart:async';

import 'package:call_schedular/constants/app_const.dart';
import 'package:call_schedular/di.dart';
import 'package:call_schedular/local_storage/local_storage.dart';
import 'package:call_schedular/presentation/call_details/call_details_view.dart';
import 'package:call_schedular/presentation/home/home_view.dart';
import 'package:call_schedular/presentation/intro/intro_view.dart';
import 'package:call_schedular/theme/app_theme.dart';
import 'package:call_schedular/theme/app_theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:call_schedular/services/notification_service.dart';

import 'domain/entity/call_list_entity.dart';
import 'domain/usecase/call_use_case.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  } catch (e, stackTrace) {
    debugPrint('App startup initialization failed: $e');
    debugPrintStack(stackTrace: stackTrace);
  }

  /*
   * Do not defer the first Flutter frame.
   *
   * SplashActivity pre-warms the FlutterEngine while the native
   * splash is visible, so Flutter can start rendering immediately
   * when MainActivity attaches to the cached engine.
   */
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<String>? _notificationSubscription;

  @override
  void initState() {
    super.initState();

    /*
     * Listen for notification taps as soon as the Flutter app
     * is mounted.
     */
    _notificationSubscription = NotificationService
        .instance
        .callNotificationTapStream
        .listen(_openCallFromNotification);

    /*
     * Notification initialization is deliberately performed after
     * the first Flutter frame so it cannot delay the initial UI.
     */
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_initializeNotifications());
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
      debugPrint('Notification initialization failed: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _handleInitialNotification() async {
    final callId = NotificationService.instance.consumeInitialCallId();

    if (callId == null || callId.isEmpty) {
      return;
    }

    await _openCallFromNotification(callId);
  }

  Future<void> _openCallFromNotification(String callId) async {
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
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilPlusInit(
      designSize: const Size(360, 690),

      /*
       * IMPORTANT:
       *
       * Because SplashActivity pre-warms the FlutterEngine before
       * MainActivity attaches the FlutterView, ScreenUtil may
       * initially receive zero/uninitialized screen dimensions.
       *
       * ensureScreenSize waits for valid screen metrics before
       * building widgets that use .w / .h / .sp / .r.
       *
       * Without this, values such as:
       *
       *     13.sp
       *
       * can temporarily resolve to 0, which causes Flutter's
       * TextField/EditableText StrutStyle assertion to fail.
       */
      ensureScreenSize: true,

      minTextAdapt: true,
      splitScreenMode: true,

      builder: (context, child) {
        final themeController = Get.find<AppThemeController>();

        return Obx(
              () => GetMaterialApp(
            theme: appTheme,
            darkTheme: appDarkTheme,
            themeMode: themeController.themeMode.value,
            title: AppConst.appName,
            debugShowCheckedModeBanner: false,

            home: Scaffold(
              backgroundColor:
              themeController.themeMode.value == ThemeMode.dark
                  ? appDarkTheme.scaffoldBackgroundColor
                  : appTheme.scaffoldBackgroundColor,
              body: child,
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