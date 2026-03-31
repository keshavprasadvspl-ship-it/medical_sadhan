import 'package:get/get.dart';
import 'package:medical_b2b_app/vendor_app/app/modules/vendors_profile/controllers/profile_controller.dart';
import 'package:medical_b2b_app/vendor_app/app/modules/vendors_profile/views/profile_view.dart';


class VendorsProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorsProfileController>(
      () => VendorsProfileController(),
    );
  }
}
