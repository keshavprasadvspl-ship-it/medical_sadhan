// lib/app/modules/main/views/main_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medical_b2b_app/app/global_widgets/cart_floating_widgets.dart';
import 'package:medical_b2b_app/app/modules/cart/bindings/cart_binding.dart';
import 'package:medical_b2b_app/app/modules/cart/controllers/cart_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../global_widgets/app_bottom_nav_bar.dart';
import '../../cart/views/cart_view.dart';
import '../../home/views/home_view.dart';
import '../../orders/views/orders_view.dart';
import '../../products/views/products_view.dart';
import '../../profile/views/profile_view.dart';
import '../controllers/main_controller.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  // Method to check login status
  Future<bool> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('auth_token');
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        Obx(() {
          switch (controller.currentIndex.value) {
            case 0:
              return HomeView();
            case 1:
              return ProductsView();
            case 2:
              // ✅ CartController safely initialize karo
              if (!Get.isRegistered<CartController>()) {
                CartBinding().dependencies();
              }
              return CartView();
            case 3:
              return FutureBuilder<bool>(
                future: _checkLogin(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.data == true) {
                    return OrdersView();
                  } else {
                    return _buildLoginRequiredView(
                      title: 'Orders',
                      message: 'Please login to view your orders',
                    );
                  }
                },
              );
            case 4:
              return FutureBuilder<bool>(
                future: _checkLogin(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.data == true) {
                    return ProfileView();
                  } else {
                    return _buildLoginRequiredView(
                      title: 'Profile',
                      message: 'Please login to access your profile',
                    );
                  }
                },
              );
            default:
              return HomeView();
          }
        }),

        // // ✅ FloatingCartWidget — cart screen pe hide
        // Obx(() {
        //   if (controller.currentIndex.value == 2) {
        //     return const SizedBox.shrink();
        //   }
        //   return const FloatingCartWidget();
        // }),
      ],
    ),
    bottomNavigationBar: AppBottomNavBar(
      currentIndex: controller.currentIndex,
      onTap: (index) {
        controller.currentIndex.value = index;
        if (index == 3 || index == 4) {
          _checkLogin().then((isLoggedIn) {
            if (!isLoggedIn) {
              Get.snackbar(
                'Login Required',
                'Please login to access this section',
                backgroundColor: Colors.orange,
                colorText: Colors.white,
              );
              Get.toNamed('/login');
            } else {
              controller.currentIndex.value = index;
            }
          });
        } else {
          controller.currentIndex.value = index;
        }
      },
    ),
  );
}
 Widget _buildLoginRequiredView({
    required String title,
    required String message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 80, color: Colors.grey[400]),
          SizedBox(height: 20),
          Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text(message, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Get.toNamed('/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF111261),
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            child: Text('Login Now', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}