import 'package:get/get.dart';

import '../controllers/orders_controller.dart';

class VendorsOrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorsOrdersController>(
      () => VendorsOrdersController(),
    );
  }
}
