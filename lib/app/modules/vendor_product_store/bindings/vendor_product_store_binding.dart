import 'package:get/get.dart';

import '../controllers/vendor_product_store_controller.dart';

class VendorProductStoreBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorProductStoreController>(
      () => VendorProductStoreController(),
    );
  }
}
