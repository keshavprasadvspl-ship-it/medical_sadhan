import 'package:get/get.dart';
import '../../../data/providers/api_provider.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiService>(() => ApiService());
    Get.lazyPut<HomeController>(
          () => HomeController(),
    );
  }
}