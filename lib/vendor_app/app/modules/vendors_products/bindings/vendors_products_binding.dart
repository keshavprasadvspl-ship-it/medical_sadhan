import 'package:get/get.dart';
import '../controllers/products_controller.dart';

class VendorsProductsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorsProductsController>(
      () => VendorsProductsController(),
    );
  }
}
