import 'package:get/get.dart';

class CartStateService extends GetxService {
  static CartStateService get to => Get.find();

  // Observable cart count
  final RxInt cartCount = 0.obs;

  // Update cart count
  void updateCount(int count) {
    cartCount.value = count;
  }

  // Increment refresh token (to trigger updates)
  final RxInt refreshToken = 0.obs;

  void triggerRefresh() {
    refreshToken.value++;
  }
}