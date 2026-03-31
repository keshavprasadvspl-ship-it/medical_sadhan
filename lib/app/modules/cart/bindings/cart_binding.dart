import 'package:get/get.dart';
import '../controllers/cart_controller.dart';

class CartBinding extends Bindings {
  @override
  void dependencies() {
    // ✅ feniks: true — dispose hone ke baad bhi recreate ho jayega
    Get.put<CartController>(
      CartController(),
      permanent: false,
    );
  }
}