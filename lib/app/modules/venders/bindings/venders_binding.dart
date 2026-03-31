import 'package:get/get.dart';

import '../controllers/venders_controller.dart';

class VendersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorsController>(
      () => VendorsController(),
    );
  }
}
