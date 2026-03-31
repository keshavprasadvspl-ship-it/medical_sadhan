import 'package:get/get.dart';

import '../controllers/company_division_controller.dart';

class CompanyDivisionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CompanyDivisionController>(
      () => CompanyDivisionController(),
    );
  }
}
