import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medical_b2b_app/app/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainController extends GetxController {
  var currentIndex = 0.obs;
  final cartRefreshToken = 0.obs;

  var cartCount = 0.obs;

  // 🔥 Floating cart visibility
  var isCartVisible = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCartCountOnly();
  }

  void incrementCartRefreshToken() {
    cartRefreshToken.value++;
    // _loadCartCountOnly();
  }

  // ✅ App start pe call — cart hidden rakho
  Future<void> _loadCartCountOnly() async {
    try {
      final storageService = Get.find<StorageService>();
      final count = await storageService.getCartItemCount();
      cartCount.value = count;
      isCartVisible.value = false; // App start pe hamesha hidden
      print('🛒 Initial cart count loaded: $count (cart hidden)');
    } catch (e) {
      print('❌ Error loading cart count: $e');
    }
  }

  // ✅ Product add/remove hone par call karo
  Future<void> updateCartCount() async {
    try {
      final storageService = Get.find<StorageService>();
      final count = await storageService.getCartItemCount();
      cartCount.value = count;
      // 🔥 Count update karo but visibility change MAT karo
      // Visibility sirf showFloatingCart/hideFloatingCart se control hogi
      print('🛒 CartCount updated: $count');
    } catch (e) {
      print('❌ Error updating cart count: $e');
    }
  }

  // 🔥 Product add hone par — count instantly badao aur show karo
  void onProductAddedToCart() {
    cartCount.value += 1; // instant UI
    isCartVisible.value = true;

    // Future.delayed(const Duration(milliseconds: 300), () {
    //   updateCartCount(); // sync after storage update
    // });
  }

  // 🔥 Manual control
  void showFloatingCart() {
    isCartVisible.value = true;
    print('👁️ showFloatingCart: isCartVisible=true');
  }

  void hideFloatingCart() {
    isCartVisible.value = false;
    print('👁️ hideFloatingCart: isCartVisible=false');
  }

  Future<bool> checkIfLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null;
  }
void goToCart() {
  debugPrint('🚀 goToCart() called');
  debugPrint('📍 Current Route: ${Get.currentRoute}');

  // 🔥 Agar already Main screen par ho
  if (Get.currentRoute == '/main') {
    currentIndex.value = 2;
  } else {
    // 🔥 Pehle Main screen open karo
    Get.offAllNamed('/main');

    // 🔥 Phir cart tab activate karo (delay zaruri hai)
    Future.delayed(const Duration(milliseconds: 50), () {
      currentIndex.value = 2;
      incrementCartRefreshToken();
    });
  }
}
  void changeTab(int index) async {
    if (index == 3 || index == 4) {
      final isLoggedIn = await checkIfLoggedIn();

      if (!isLoggedIn) {
        Get.snackbar(
          'Login Required',
          'Please login to access this section',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        Get.toNamed('/login');
        return;
      }
    }

    currentIndex.value = index;
  }
}