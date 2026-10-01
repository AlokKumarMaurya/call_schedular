import 'package:call_schedular/constants/app_const.dart';
import 'package:call_schedular/di.dart';
import 'package:call_schedular/local_storage/local_storage.dart';
import 'package:call_schedular/presentation/home/home_view.dart';
import 'package:call_schedular/presentation/intro/intro_view.dart';
import 'package:call_schedular/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  AppDI.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilPlusInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          theme: appTheme,
          title: AppConst.appName,
          home: child,
          debugShowCheckedModeBanner: false,
        );
      },
      child: AppLocalStorage.isIntroViewed
          ? const HomeView()
          : const IntroView(),
    );
  }
}
