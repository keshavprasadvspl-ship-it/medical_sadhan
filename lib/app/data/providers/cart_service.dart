// lib/app/modules/cart/providers/cart_service.dart
import 'package:get/get.dart';
import 'package:medical_b2b_app/app/data/providers/api_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../modules/main/controllers/main_controller.dart';
import '../../services/storage_service.dart';
import '../models/cart_item_model.dart';

class CartService extends GetxService {
  final StorageService _storageService = Get.find<StorageService>();
  final ApiService _apiService = Get.find<ApiService>();

  static const String _userTokenKey = 'auth_token';
  static const String _userTypeKey = 'user_type';

  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_userTokenKey);
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    return userId != null ? int.tryParse(userId) : null;
  }

  Future<String?> getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userTokenKey);
  }

  Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userTypeKey);
  }

  Future<List<Map<String, dynamic>>> getLocalCartItems() async {
    final cartItems = await _storageService.getCartItems();
    return cartItems.map((item) {
      return {
        'product_id': item.productId,
        'product_name': item.productName,
        'vendor_id': item.vendorId,
        'vendor_name': item.vendorName,
        'packing_id': item.packingId,
        'vendor_product_id': item.vendorProductId,
        'packing_type': item.packingName,
        'quantity': item.quantity,
        'price': item.price,
        'product_image': item.image,
        'gst_percentage': item.gstPercentage,
        'max_stock': 999,
        'addon': item.addon, // 🔥 Include addon in local cart data
      };
    }).toList();
  }

  // ✅ UNTOUCHED — existing working method
  Future<void> updateCartItemAddon(
    int productId,
    int vendorId,
    int packingId,
    String? addon,
  ) async {
    final cartItems = await _storageService.getCartItems();

    for (int i = 0; i < cartItems.length; i++) {
      final item = cartItems[i];

      if (item.productId == productId &&
          item.vendorId == vendorId &&
          item.packingId == packingId) {
        final updatedItem = CartItem(
          productId: item.productId,
          productName: item.productName,
          vendorId: item.vendorId,
          vendorName: item.vendorName,
          packingId: item.packingId,
          vendorProductId: item.vendorProductId,
          packingName: item.packingName,
          quantity: item.quantity,
          price: item.price,
          gstPercentage: item.gstPercentage,
          image: item.image,
          specialInstructions: addon, // ✅ USE THIS FIELD
        );

        await _storageService.updateCartItem(updatedItem);
      }
    }

    refreshCartCount();
  }

  Future<void> addLocalCartItem(Map<String, dynamic> item) async {
    final cartItem = CartItem(
      productId: item['product_id'],
      productName: item['product_name'] ?? 'Unknown Product',
      vendorId: item['vendor_id'],
      vendorName: item['vendor_name'] ?? 'Unknown Vendor',
      packingId: item['packing_id'] ?? 0,
      vendorProductId: item['vendorProductId'] ?? 0,
      packingName: item['packing_type'] ?? 'Standard',
      quantity: item['quantity'],
      price: (item['price'] ?? 0).toDouble(),
      gstPercentage: (item['gst_percentage'] ?? 0).toDouble(),
      image: item['product_image'],
    );

    await _storageService.addToCart(cartItem);
    refreshCartCount();
  }

  Future<void> addToCart({
    required int productId,
    required String productName,
    required int vendorId,
    required String vendorName,
    required int packingId,
    required int vendorProductId,
    required String packingType,
    required int quantity,
    required double price,
    required double gstPercentage,
    String? image,
    int? addon, // ✅ optional int — from Add-on box
  }) async {
    try {
      final user = await _storageService.getUser();
      final token = await _storageService.getToken();

      // ✅ Logged in → Call API
      if (user != null && token != null && user['id'] != null) {
        final result = await _apiService.addToCartApi(
          productId: productId,
          userId: user['id'],
          vendorId: vendorId,
          vendorProductId: vendorProductId,
          quantity: quantity,
          token: token,
          addon: addon, // ✅ pass to API
        );

        print("add to cart result");
        print(result);

        if (result['success'] == true) {
          refreshCartCount();
          return;
        } else {
          throw Exception(result['message'] ?? "Failed to add to cart");
        }
      }

      // ✅ Not logged in → Save locally
      final cartItem = CartItem(
        productId: productId,
        productName: productName,
        vendorId: vendorId,
        vendorName: vendorName,
        packingId: packingId,
        vendorProductId: vendorProductId,
        packingName: packingType,
        quantity: quantity,
        price: price,
        gstPercentage: gstPercentage,
        image: image,
        addon: addon?.toString(), // ✅ int? → String? for CartItem model
      );

      await _storageService.addToCart(cartItem);
      refreshCartCount();
    } catch (e) {
      print("Add to cart error: $e");
      rethrow;
    }
  }

  Future<void> removeLocalCartItem(int index) async {
    final cartItems = await _storageService.getCartItems();
    if (index >= 0 && index < cartItems.length) {
      final item = cartItems[index];
      await _storageService.removeFromCart(
        item.productId,
        item.vendorId,
        item.packingId,
      );
    }
    refreshCartCount();
  }

  Future<void> removeFromCart(
      int productId, int vendorId, int packingId) async {
    await _storageService.removeFromCart(productId, vendorId, packingId);
    refreshCartCount();
  }

  Future<void> updateLocalCartItemQuantity(int index, int quantity) async {
    final cartItems = await _storageService.getCartItems();
    if (index >= 0 && index < cartItems.length) {
      final item = cartItems[index];
      final updatedItem = CartItem(
        productId: item.productId,
        productName: item.productName,
        vendorId: item.vendorId,
        vendorName: item.vendorName,
        packingId: item.packingId,
        vendorProductId: item.vendorProductId,
        packingName: item.packingName,
        quantity: quantity,
        price: item.price,
        gstPercentage: item.gstPercentage,
        specialInstructions: item.specialInstructions,
        image: item.image,
      );
      await _storageService.updateCartItem(updatedItem);
    }
    refreshCartCount();
  }

  Future<void> updateCartItemQuantity(
      int productId, int vendorId, int packingId, int quantity) async {
    final cartItems = await _storageService.getCartItems();
    final index = cartItems.indexWhere((item) =>
        item.productId == productId &&
        item.vendorId == vendorId &&
        item.packingId == packingId);

    if (index != -1) {
      await updateLocalCartItemQuantity(index, quantity);
    }
  }

  Future<void> clearAllCartData() async {
    await _storageService.clearCart();
    refreshCartCount();
  }

  Future<void> clearLocalCart() async {
    await _storageService.clearCart();
    refreshCartCount();
  }

  Future<int> getCartCount() async {
    return await _storageService.getCartItemCount();
  }

  void refreshCartCount() {
    try {
      final mainController = Get.find<MainController>();
      mainController.incrementCartRefreshToken();
    } catch (e) {
      print('MainController not found: $e');
    }
  }
}