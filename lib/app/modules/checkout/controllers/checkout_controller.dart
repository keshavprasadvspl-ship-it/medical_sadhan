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

  // Observable variables
  final addresses = <AddressModel>[].obs;
  final selectedAddressId = Rxn<int>();
  final isLoading = true.obs;
  final isPlacingOrder = false.obs;
  final selectedPaymentMethod = 'cod'.obs;
  final referredBy = RxString('');

  // Order summary data from cart
  late List<CartItemModel> cartItems;
  late double subtotal;
  late double deliveryFee;
  late double discount;
  late double total;
  late String? appliedPromoCode;

  // Vendor-specific checkout flag
  bool isVendorSpecific = false;
  String? vendorName;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;

    if (args != null) {
      cartItems = args['cartItems'];
      subtotal = args['subtotal'];
      deliveryFee = args['deliveryFee'] ?? 0.0;
      discount = args['discount'] ?? 0.0;
      total = args['total'];
      appliedPromoCode = args['promoCode'];
      selectedPaymentMethod.value = args['paymentMethod'] ?? 'cod';
      referredBy.value = args['referredBy'] ?? '';
      isVendorSpecific = args['isVendorSpecific'] ?? false;
      vendorName = args['vendorName'];
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

  // Place order (updated for vendor-specific checkout)
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

      // Referral safe value
      final String referralValue =
      referredBy.value.trim().isEmpty ? '' : referredBy.value.trim();

      print("🔥 Referral Value: $referralValue");
      print("🔥 Is Vendor Specific: $isVendorSpecific");
      print("🔥 Vendor Name: $vendorName");

      List<Map<String, dynamic>> allOrderResults = [];

      if (isVendorSpecific && vendorName != null) {
        // Vendor-specific checkout - place order for single vendor
        final int vendorId = cartItems.first.vendorId;

        final items = cartItems.map((item) => {
          'packing_id': item.packingId ?? 0,
          'product_name': item.name,
          'quantity': item.quantity,
          'addon': int.tryParse(item.addon ?? '0') ?? 0,
          'price': item.price,
          'gst_percentage': item.gstPercentage,
        }).toList();

        print("🚀 Placing order for Vendor: $vendorId ($vendorName)");

        final result = await _apiService.placeOrder(
          buyerId: buyerId,
          vendorId: vendorId,
          shippingAddressId: addressId,
          billingAddressId: addressId,
          paymentMethod: selectedPaymentMethod.value,
          items: items,
          couponCode: (appliedPromoCode?.isEmpty ?? true) ? null : appliedPromoCode,
          referredBy: referralValue.isEmpty ? null : referralValue,
          token: token,
        );

        print("📦 API ORDER RESULT:");
        print(result);

        if (result['success'] != true) {
          throw Exception('Failed to place order for vendor $vendorName');
        }

        allOrderResults.add(result);

        // Remove only the items for this vendor from cart
        await _removeVendorItemsFromCart(vendorId);

      } else {
        // Regular checkout - group items by vendor
        final Map<int, List<Map<String, dynamic>>> vendorGroups = {};

        for (var item in cartItems) {
          vendorGroups.putIfAbsent(item.vendorId, () => []);
          vendorGroups[item.vendorId]!.add({
            'packing_id': item.packingId ?? 0,
            'product_name': item.name,
            'quantity': item.quantity,
            'addon': int.tryParse(item.addon ?? '0') ?? 0,
            'price': item.price,
            'gst_percentage': item.gstPercentage,
          });
        }

        // API call per vendor
        for (var entry in vendorGroups.entries) {
          print("🚀 Placing order for Vendor: ${entry.key}");

          final result = await _apiService.placeOrder(
            buyerId: buyerId,
            vendorId: entry.key,
            shippingAddressId: addressId,
            billingAddressId: addressId,
            paymentMethod: selectedPaymentMethod.value,
            items: entry.value,
            couponCode: (appliedPromoCode?.isEmpty ?? true) ? null : appliedPromoCode,
            referredBy: referralValue.isEmpty ? null : referralValue,
            token: token,
          );

          print("📦 API ORDER RESULT:");
          print(result);

          if (result['success'] != true) {
            throw Exception('Failed to place order for vendor ${entry.key}');
          }

          allOrderResults.add(result);
        }

        // Clear entire cart for regular checkout
        await _cartController.clearCart();
      }

      print("✅ FINAL ORDER RESULTS:");
      print(allOrderResults);

      // Navigate to success page
      Get.offAllNamed('/order-success', arguments: {
        'orderData': allOrderResults,
        'isVendorSpecific': isVendorSpecific,
        'vendorName': vendorName,
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

  // Helper method to remove items for a specific vendor from cart
  Future<void> _removeVendorItemsFromCart(int vendorId) async {
    final itemsToRemove = cartItems.where((item) => item.vendorId == vendorId).toList();

    for (var item in itemsToRemove) {
      await _cartController.removeItem(item.id);
    }

    // Refresh cart count
    await _cartController.refreshCart();
  }
}

// Note: The CartItemModel is imported from cart_controller.dart