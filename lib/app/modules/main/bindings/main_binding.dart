import 'package:get/get.dart';
import 'package:medical_b2b_app/app/modules/orders/controllers/orders_controller.dart';
import 'package:medical_b2b_app/app/modules/products/controllers/products_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../controllers/main_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(() => MainController());

    // ADD THESE 👇
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<CartController>(() => CartController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<OrdersController>(() => OrdersController());
    Get.lazyPut<ProductsController>(() => ProductsController());
  }
}
