import 'package:get/get.dart';

import '../controllers/companies_list_controller.dart';

class CompaniesListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CompaniesListViewController>(
      () => CompaniesListViewController(),
    );
  }
}
