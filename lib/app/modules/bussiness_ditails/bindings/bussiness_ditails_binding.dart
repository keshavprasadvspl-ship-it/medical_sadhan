import 'package:get/get.dart';

import '../controllers/bussiness_ditails_controller.dart';


class BussinessDitailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BusinessDetailsController>(
      () => BusinessDetailsController(),
    );
  }
}
