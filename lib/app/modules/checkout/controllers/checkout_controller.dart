// lib/app/modules/checkout/controllers/checkout_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../../data/models/address_model.dart';
import '../../../data/providers/api_provider.dart';
import '../../../services/storage_service.dart';

class CheckoutController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();
  final CartController _cartController = Get.find<CartController>();
  final referredBy = RxString('');
  // Observable variables
  final addresses = <AddressModel>[].obs;
  final selectedAddressId = Rxn<int>();
  final isLoading = true.obs;
  final isPlacingOrder = false.obs;
  final selectedPaymentMethod = 'cod'.obs;

  // Order summary data from cart
  late List<CartItemModel> cartItems;
  late double subtotal;
  late double deliveryFee;
  late double discount;
  late double total;
  late String? appliedPromoCode;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
     referredBy.value = args?['referredBy'] ?? '';
    if (args != null) {
      cartItems = args['cartItems'];
      subtotal = args['subtotal'];
      deliveryFee = args['deliveryFee'];
      discount = args['discount'];
      total = args['total'];
      appliedPromoCode = args['promoCode'];
      selectedPaymentMethod.value = args['paymentMethod'] ?? 'cod';
    }
    loadAddresses();
  }

  // Load user addresses
  Future<void> loadAddresses() async {
    isLoading.value = true;

    try {
      final user = await _storageService.getUser();
      final token = await _storageService.getToken();

      if (user != null && token != null) {
        final buyerId = user['id'];
        final result = await _apiService.getBuyerAddresses(
          buyerId: buyerId.toString(),
          token: token,
        );

        print('Addresses API Response: $result');

        if (result['success'] == true && result['data'] != null) {
          final List addressesData = result['data'];
          addresses.value = addressesData
              .map((json) => AddressModel.fromJson(json))
              .toList();

          // Auto-select default shipping address if available
          final defaultAddress = addresses.firstWhereOrNull(
                  (addr) => addr.isDefaultShipping
          );

          if (defaultAddress != null) {
            selectedAddressId.value = defaultAddress.id;
          } else if (addresses.isNotEmpty) {
            selectedAddressId.value = addresses.first.id;
          }
        }
      }
    } catch (e) {
      print('Error loading addresses: $e');
      Get.snackbar(
        'Error',
        'Failed to load addresses',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Add new address
  Future<void> addAddress(Map<String, dynamic> addressData) async {
    try {
      final user = await _storageService.getUser();
      final token = await _storageService.getToken();

      if (user != null && token != null) {
        final buyerId = user['id'];
        final result = await _apiService.createBuyerAddress(
          buyerId: buyerId.toString(),
          addressData: addressData,
          token: token,
        );

        if (result['success'] == true) {
          await loadAddresses();
          Get.back();
          Get.snackbar(
            'Success',
            'Address added successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          throw Exception(result['message'] ?? 'Failed to add address');
        }
      }
    } catch (e) {
      print('Error adding address: $e');
      Get.snackbar(
        'Error',
        'Failed to add address',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Update address
  Future<void> updateAddress(int addressId, Map<String, dynamic> addressData) async {
    try {
      final user = await _storageService.getUser();
      final token = await _storageService.getToken();

      if (user != null && token != null) {
        final buyerId = user['id'];
        final result = await _apiService.updateBuyerAddress(
          buyerId: buyerId.toString(),
          addressId: addressId,
          addressData: addressData,
          token: token,
        );

        if (result['success'] == true) {
          await loadAddresses();
          Get.back();
          Get.snackbar(
            'Success',
            'Address updated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          throw Exception(result['message'] ?? 'Failed to update address');
        }
      }
    } catch (e) {
      print('Error updating address: $e');
      Get.snackbar(
        'Error',
        'Failed to update address',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Delete address (soft delete)
  Future<void> deleteAddress(int addressId) async {
    try {
      final user = await _storageService.getUser();
      final token = await _storageService.getToken();

      if (user != null && token != null) {
        final buyerId = user['id'];
        final result = await _apiService.deleteBuyerAddress(
          buyerId: buyerId.toString(),
          addressId: addressId,
          token: token,
        );

        if (result['success'] == true) {
          await loadAddresses();

          // Clear selected address if it was deleted
          if (selectedAddressId.value == addressId) {
            selectedAddressId.value = null;
          }

          Get.snackbar(
            'Success',
            'Address removed successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          throw Exception(result['message'] ?? 'Failed to delete address');
        }
      }
    } catch (e) {
      print('Error deleting address: $e');
      Get.snackbar(
        'Error',
        'Failed to delete address',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Set as default shipping address
  Future<void> setDefaultShippingAddress(int addressId) async {
    try {
      final user = await _storageService.getUser();
      final token = await _storageService.getToken();

      if (user != null && token != null) {
        final buyerId = user['id'];
        final result = await _apiService.setDefaultShippingAddress(
          buyerId: buyerId.toString(),
          addressId: addressId,
          token: token,
        );

        if (result['success'] == true) {
          await loadAddresses();
        }
      }
    } catch (e) {
      print('Error setting default shipping address: $e');
    }
  }

// Place order
 Future<void> placeOrder() async {
  if (selectedAddressId.value == null) {
    Get.snackbar('Error', 'Please select a delivery address');
    return;
  }

  isPlacingOrder.value = true;

  try {
    final user = await _storageService.getUser();
    final token = await _storageService.getToken();

    if (user == null || token == null) {
      throw Exception('User not logged in');
    }

    final int buyerId = user['id'];
    final int addressId = selectedAddressId.value!;

    // 🔥 Referral safe value
    final String referralValue =
        referredBy.value.trim().isEmpty ? '' : referredBy.value.trim();

    print("🔥 Referral Value: $referralValue");

    // 🔹 Group items by vendor
    final Map<int, List<Map<String, dynamic>>> vendorGroups = {};

    for (var item in cartItems) {
      vendorGroups.putIfAbsent(item.vendorId, () => []);

      vendorGroups[item.vendorId]!.add({
        'packing_id': item.packingId ?? 0,
        'product_name': item.name,
        'quantity': item.quantity,
        'addon': item.addon ?? 0,
        'price': item.price,
        'gst_percentage': item.gstPercentage,
      });
    }

    List<Map<String, dynamic>> allOrderResults = [];

    // 🔹 API call per vendor
    for (var entry in vendorGroups.entries) {
      print("🚀 Placing order for Vendor: ${entry.key}");

      final result = await _apiService.placeOrder(
        buyerId: buyerId,
        vendorId: entry.key,
        shippingAddressId: addressId,
        billingAddressId: addressId,
        paymentMethod: selectedPaymentMethod.value,
        items: entry.value,
        couponCode: (appliedPromoCode?.isEmpty ?? true)
            ? null
            : appliedPromoCode,
        referredBy: referralValue.isEmpty ? null : referralValue, // ✅ FIX
        token: token,
      );

      print("📦 API ORDER RESULT:");
      print(result);

      if (result['success'] != true) {
        throw Exception(
            'Failed to place order for vendor ${entry.key}');
      }

      allOrderResults.add(result);
    }
  
    // 🔥 Clear cart
    await _cartController.clearCart();

    print("✅ FINAL ORDER RESULTS:");
    print(allOrderResults);

    // 🔥 Navigate
    Get.offAllNamed('/order-success', arguments: {
      'orderData': allOrderResults,
    });

  } catch (e) {
    print('❌ Error placing order: $e');

    Get.snackbar(
      'Error',
      'Failed to place order. Please try again.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  } finally {
    isPlacingOrder.value = false;
  }
}
}
Map<String, dynamic> result = {
  "success": true,
  "message": "Order created successfully",
  "data": {
    "order_id": 101,
    "order_number": "ORD-1708675300",
    "buyer_id": 1,
    "vendor_id": 2,
    "payment_status": "pending",
    "order_status": "placed",
    "total_amount": 200.00,
    "gst_amount": 10.00,
    "final_amount": 210.00,
    "items": [
      {
        "id": 1,
        "product_name": "Paracetamol 500mg",
        "quantity": 10,
        "addon": 0,
        "unit_price": 20.00,
        "gst_percentage": 5,
        "gst_amount": 10.00,
        "total_price": 210.00
      }
    ]
  }
};
