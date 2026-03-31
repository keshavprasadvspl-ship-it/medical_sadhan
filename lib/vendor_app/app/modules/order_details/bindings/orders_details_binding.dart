import 'package:get/get.dart';

import '../../orders/controllers/orders_controller.dart' show VendorsOrdersController;
import '../controllers/orders_controller.dart';

class VendorsOrdersDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorsOrdersController>(
      () => VendorsOrdersController(),
    );
  }
}
