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

  // Keep the Android launch screen visible until all startup
  // initialization is completed and Flutter is ready to render.
  WidgetsBinding.instance.deferFirstFrame();

  try {
    await GetStorage.init();

    Get.put(
      AppThemeController(),
      permanent: true,
    );

    await NotificationService.instance.initialize();

    AppDI.init();
  } catch (e, stackTrace) {
    debugPrint('App initialization failed: $e');
    debugPrintStack(stackTrace: stackTrace);
  }

  runApp(const MyApp());

  // Give Flutter a chance to build the first frame before allowing
  // Android to remove the native launch screen.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    WidgetsBinding.instance.allowFirstFrame();
  });
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleInitialNotification();
    });

    _notificationSubscription = NotificationService
        .instance
        .callNotificationTapStream
        .listen(_openCallFromNotification);
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