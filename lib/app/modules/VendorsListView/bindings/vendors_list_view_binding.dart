import 'package:get/get.dart';

import '../controllers/vendors_list_view_controller.dart';

class VendorsListViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorsListViewController>(
      () => VendorsListViewController(),
    );
  }
}
