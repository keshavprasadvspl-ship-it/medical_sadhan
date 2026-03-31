// lib/app/controllers/payment_controller.dart
//
// REGISTER IN main.dart ya AppBinding (sirf ek baar):
//   Get.put(PaymentController(), permanent: true);

import 'package:get/get.dart';

class PaymentController extends GetxController {
  static PaymentController get to => Get.find();

  // Global selected payment method — default: 'challan'
  final RxString selectedMethod = 'challan'.obs;

  void setMethod(String method) {
    selectedMethod.value = method;
  }

  // Backward-compatible Map — CartController ke purane code ke liye
  Map<String, dynamic> get asMap => {
        'method': selectedMethod.value,
        'details': {},
      };
}