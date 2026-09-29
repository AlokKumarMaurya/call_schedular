import 'package:call_schedular/local_storage/local_storage.dart';
import 'package:call_schedular/presentation/home/home_view.dart';
import 'package:get/get.dart';

class IntroController extends GetxController {
  void handelGetStarted() {
    AppLocalStorage.setIntroViewed(true);
    Get.offAll(HomeView());
  }
}
