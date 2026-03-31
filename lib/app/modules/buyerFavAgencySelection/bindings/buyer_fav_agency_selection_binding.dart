import 'package:get/get.dart';

import '../controllers/buyer_fav_agency_selection_controller.dart';

class BuyerFavAgencySelectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BuyerFavAgencySelectionController>(
      () => BuyerFavAgencySelectionController(),
    );
  }
}
