// lib/app/modules/cart/controllers/cart_controller.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medical_b2b_app/app/global_widgets/controller/payment_Controller.dart';
import 'package:medical_b2b_app/app/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/providers/cart_service.dart';
import '../../../global_widgets/payment_method_dialog.dart';
import '../../main/controllers/main_controller.dart';


class CartController extends GetxController {
  final CartService _cartService = Get.find<CartService>();
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();

  // Observable variables
  final cartItems = <CartItemModel>[].obs;
  final isLoading = true.obs;
  final isCheckingOut = false.obs;

  final deliveryFee = 5.99.obs;
  final discount = 0.0.obs;
  final promoCode = ''.obs;
  final appliedPromoCode = ''.obs;
  
  // ─── Referral Controller ────────────────────────────────────────────────────
  final referredByController = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    ever(Get.find<MainController>().cartRefreshToken, (_) {
      print('🔄 Cart refresh triggered from main navigation');
      loadCart();
    });
    loadCart();
  }

  @override
  void onReady() {
    super.onReady();
    loadCart();
  }

  @override
  void onClose() {
    // referredByController.dispose();
    super.onClose();
  }

  // Load cart based on login status
  Future<void> loadCart() async {
    isLoading.value = true;

    bool isLoggedIn = false;
    String? userType;

    final user = await _storageService.getUser();

    if (user != null) {
      isLoggedIn = user['id'] != null;
      userType = user['type'];
    }

    print("login details");
    print(isLoggedIn);
    print(userType);

    if (isLoggedIn && userType == 'buyer') {
      await _loadCartFromApi();
    } else {
      _loadCartFromLocal();
    }

    printAllSharedPrefs();

    isLoading.value = false;
  }

  Future<void> printAllSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (String key in keys) {
      final value = prefs.get(key);
      print('$key: $value');
    }
  }

  // Load cart from API
  Future<void> _loadCartFromApi() async {
    try {
      final user = await _storageService.getUser();
      final token = await _storageService.getToken();

      if (user == null || token == null) {
        return _loadCartFromLocal();
      }

      final userId = user['id'];

      if (userId == null) {
        return _loadCartFromLocal();
      }

      final result = await _apiService.getUserCart(
        userId: userId.toString(),
        token: token,
      );
      print("api cart result");
      print(result);
      final success = result['success'] == true;
      final data = result['data'];

      if (!success || data == null || data['items'] is! List) {
        return _loadCartFromLocal();
      }

      cartItems.value = (data['items'] as List)
          .map((item) => CartItemModel.fromApiJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading cart from API: $e');
      _loadCartFromLocal();
    }
  }

  int getTotalItemCount() {
    return cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  // Show payment method dialog
  Future<void> showPaymentMethodDialog() async {
    final result = await Get.dialog<String>(
      PaymentMethodDialog(),
    );

    if (result != null) {
      proceedToCheckout(PaymentController.to.asMap);
    }
  }

 Future<void> proceedToCheckout(Map<String, dynamic> paymentInfo) async {
  if (cartItems.isEmpty) return;

  isCheckingOut.value = true;

  // ✅ FIX: PEHLE value capture karo — dialog se PEHLE
  final String referralText = referredByController.text.trim();
  print("💡 Referral captured before dialog: '$referralText'");

  final user = await _storageService.getUser();
  final token = await _storageService.getToken();

  if (user == null && token == null) {
    Get.dialog(
      AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please login to proceed with checkout'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0B630B),
            ),
            child: const Text('Login', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    isCheckingOut.value = false;
    return;
  }

  if (user?['type'] != 'buyer') {
    Get.snackbar(
      'Account Type Error',
      'Only buyer accounts can checkout',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    isCheckingOut.value = false;
    return;
  }

  // ✅ referralText use karo — TextController nahi
  Get.toNamed('/checkout', arguments: {
    'cartItems': cartItems,
    'subtotal': subtotal,
    'deliveryFee': deliveryFee.value,
    'discount': discount.value,
    'total': total,
    'promoCode': appliedPromoCode.value,
    'paymentMethod': paymentInfo['method'],
    'paymentDetails': paymentInfo['details'],
    'referredBy': referralText, // ✅ captured String — controller nahi
  });

  isCheckingOut.value = false;
}  // Load cart from local storage
  void _loadCartFromLocal() async {
    print('🔄 Loading cart from local storage...');

    final localItems = await _cartService.getLocalCartItems();

    print('📦 Raw local items count: ${localItems.length}');
    print('📦 Raw local items data: $localItems');

    if (localItems.isEmpty) {
      print('⚠️ No items found in local cart storage');
      cartItems.value = [];
      return;
    }

    try {
      cartItems.value = localItems.map<CartItemModel>((item) {
        print('🔄 Converting item: $item');
        return CartItemModel.fromLocalJson(item);
      }).toList();

      print('✅ Successfully loaded ${cartItems.length} items from local storage');
    } catch (e, stackTrace) {
      print('❌ Error parsing local cart items: $e');
      print('📚 Stack trace: $stackTrace');

      cartItems.value = [];

      Get.snackbar(
        'Error Loading Cart',
        'There was an issue loading your saved items. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ─── Getters (used by CartView) ───────────────────────────────────────────────

  double get subtotal {
    return cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  double get gstTotal {
    return cartItems.fold(0.0, (sum, item) {
      final itemTotal = item.price * item.quantity;
      final itemGst = itemTotal * (item.gstPercentage / 100);
      return sum + itemGst;
    });
  }

  double get total {
    return subtotal + gstTotal - discount.value;
  }

  // ─── Quantity Methods ─────────────────────────────────────────────────────────

  Future<void> increaseQuantity(String itemId) async {
    final index = cartItems.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      cartItems[index].quantity++;
      cartItems.refresh();
      await _syncCartItem(cartItems[index]);
      _cartService.refreshCartCount();
    }
  }

  Future<void> decreaseQuantity(String itemId) async {
    final index = cartItems.indexWhere((item) => item.id == itemId);
    if (index != -1 && cartItems[index].quantity > 1) {
      cartItems[index].quantity--;
      cartItems.refresh();
      await _syncCartItem(cartItems[index]);
      _cartService.refreshCartCount();
    }
  }

  Future<void> setQuantity(String itemId, int newQty) async {
    if (newQty < 1) return;

    final index = cartItems.indexWhere((item) => item.id == itemId);
    if (index == -1) return;

    final maxAllowed = cartItems[index].maxStock;
    final clamped = newQty > maxAllowed ? maxAllowed : newQty;

    if (clamped != newQty) {
      Get.snackbar(
        'Stock Limit',
        'Max available stock is $maxAllowed',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }

    cartItems[index].quantity = clamped;
    cartItems.refresh();

    await _syncCartItem(cartItems[index]);
    _cartService.refreshCartCount();
  }

  // ─── Remove Item ──────────────────────────────────────────────────────────────

  Future<void> removeItem(String itemId) async {
    final mainController = Get.find<MainController>(); // ✅ correct

    final index = cartItems.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      final item = cartItems[index];

      final isLoggedIn = await _cartService.isUserLoggedIn();
      final user = await _storageService.getUser();
      final userType = user?['type'];

      if (isLoggedIn && userType == 'buyer' && item.cartItemId != null) {
        final userId = user!['id'];
        final token = await _cartService.getUserToken();

        await _apiService.removeFromCart(
          cartItemId: item.cartItemId!.toString(),
          userId: userId?.toString(),
          token: token,
        );
      } else {
        await _cartService.removeFromCart(
          item.productId,
          item.vendorId,
          item.packingId ?? 0,
        );
      }

      // ✅ FIRST remove locally
      cartItems.removeAt(index);

      // ✅ THEN update global count
      await mainController.updateCartCount();

      // ✅ Optional: refresh token if needed
      mainController.incrementCartRefreshToken();

      Get.snackbar(
        'Removed',
        'Item removed from cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  // ─── Addon Methods ────────────────────────────────────────────────────────────
Future<void> addAddonToItem(String itemId, String addonText) async {
  final index = cartItems.indexWhere((item) => item.id == itemId);
  if (index == -1) return;

  final item = cartItems[index];

  // ✅ Convert String → int safely
  final int addonValue = int.tryParse(addonText) ?? 0;

  // ✅ UI update (agar UI me string dikhana hai to ye rehne do)
  item.addon = addonText;
  cartItems.refresh();

  // ✅ Local save (yaha bhi ideally int bhejna chahiye)
  await _cartService.updateCartItemAddon(
    item.productId,
    item.vendorId,
    item.packingId ?? 0,
    addonValue.toString(), // 👈 agar local DB string expect karta hai
  );

  // ✅ API update (IMPORTANT FIX)
  if (item.cartItemId != null) {
    final user = await _storageService.getUser();
    final token = await _storageService.getToken();

    await _apiService.updateCartItemQuantity(
      cartItemId: item.cartItemId!,
      quantity: item.quantity,
      addon: addonValue, // ✅ int pass karo
      userId: user?['id'],
      token: token,
    );
  }

  print("✅ Addon updated in API + local => $addonValue");
}  Future<void> removeAddonFromItem(String itemId) async {
    final index = cartItems.indexWhere((item) => item.id == itemId);
    if (index == -1) return;

    final item = cartItems[index];

    item.addon = null;
    cartItems.refresh();

    await _cartService.updateCartItemAddon(
      item.productId,
      item.vendorId,
      item.packingId ?? 0,
      null,
    );

    if (item.cartItemId != null) {
      final user = await _storageService.getUser();
      final token = await _storageService.getToken();

      await _apiService.updateCartItemQuantity(
        cartItemId: item.cartItemId!,
        quantity: item.quantity,
        addon: null,
        userId: user?['id'],
        token: token,
      );
    }

    print("❌ Addon removed from API + local");
  }

  // Get referral info for checkout
  String getReferralInfo() {
    return referredByController.text.trim();
  }

  // ─── Promo Code ───────────────────────────────────────────────────────────────

  Future<void> applyPromoCode(String code) async {
    if (code.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a promo code',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final isLoggedIn = await _cartService.isUserLoggedIn();
    final userType = await _cartService.getUserType();

    if (isLoggedIn && userType == 'buyer') {
      final userId = await _cartService.getUserId();
      final token = await _cartService.getUserToken();

      final result = await _apiService.applyCoupon(
        userId: userId?.toString() ?? '',
        couponCode: code,
        token: token,
      );

      if (result['success'] == true) {
        discount.value = result['discount_amount'] ?? 0.0;
        appliedPromoCode.value = code;
        promoCode.value = code;

        Get.snackbar(
          'Success',
          'Promo code applied! You saved ₹${discount.value.toStringAsFixed(2)}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF0B630B),
          colorText: Colors.white,
        );
      } else {
        _handleLocalPromoCode(code);
      }
    } else {
      _handleLocalPromoCode(code);
    }
  }

  Future<void> removePromoCode() async {
    final isLoggedIn = await _cartService.isUserLoggedIn();
    final userType = await _cartService.getUserType();

    if (isLoggedIn && userType == 'buyer') {
      final userId = await _cartService.getUserId();
      final token = await _cartService.getUserToken();

      await _apiService.removeCoupon(
        userId: userId?.toString() ?? '',
        token: token,
      );
    }

    discount.value = 0.0;
    appliedPromoCode.value = '';
    promoCode.value = '';
  }

  // ─── Sync Cart Item to API / Local ───────────────────────────────────────────
Future<void> _syncCartItem(CartItemModel item) async {
  final isLoggedIn = await _cartService.isUserLoggedIn();
  final user = await _storageService.getUser();

  if (user == null) return;

  final userType = user['type'];

  if (isLoggedIn && userType == 'buyer' && item.cartItemId != null) {
    final userId = user['id'];
    final token = await _cartService.getUserToken();

    // 🔥 IMPORTANT: addon preserve karo
    final int addonValue = int.tryParse(item.addon ?? '') ?? 0;

    final result = await _apiService.updateCartItemQuantity(
      cartItemId: item.cartItemId!,
      quantity: item.quantity,
      addon: addonValue, // ✅ FIX: addon send karo
      userId: userId,
      token: token,
    );

    if (!result['success']) {
      print('❌ Failed to update cart item: ${result['message']}');
    } else {
      print('✅ Cart synced with addon: $addonValue');
    }
  } else {
    // 🔥 Local update (addon bhi preserve)
    await _cartService.updateCartItemQuantity(
      item.productId,
      item.vendorId,
      item.packingId ?? 0,
      item.quantity,
    );
  }
}  // Local promo code fallback
  void _handleLocalPromoCode(String code) {
    if (code.toUpperCase() == 'SAVE15') {
      discount.value = subtotal * 0.15;
      appliedPromoCode.value = code;
      promoCode.value = code;

      Get.snackbar(
        'Success',
        'Promo code applied! You saved ₹${discount.value.toStringAsFixed(2)}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF0B630B),
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Invalid Code',
        'Please enter a valid promo code',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Checkout entry point
  Future<void> checkout() async {
    if (cartItems.isEmpty) return;
    await showPaymentMethodDialog();
  }

  // Clear entire cart
  Future<void> clearCart() async {
    final isLoggedIn = await _cartService.isUserLoggedIn();
    final userType = await _cartService.getUserType();

    if (isLoggedIn && userType == 'buyer') {
      final userId = await _cartService.getUserId();
      final token = await _cartService.getUserToken();

      await _apiService.clearCart(
        userId: userId?.toString() ?? '',
        token: token,
      );
    }

    await _cartService.clearLocalCart();
    cartItems.clear();
    discount.value = 0.0;
    appliedPromoCode.value = '';
    promoCode.value = '';

    _cartService.refreshCartCount();
  }

  // Refresh cart
  Future<void> refreshCart() async {
    await loadCart();
  }
}

// ─── Cart Item Model ──────────────────────────────────────────────────────────

class CartItemModel {
  final String id;
  final int? cartItemId;
  final int productId;
  final String name;
  final String category;
  final double price;
  final double mrpPrice;       // ─── NEW: api mrp_price ───────────────────────
  final double discountMin;    // ─── NEW: api discount_min ────────────────────
  final double discountMax;    // ─── NEW: api discount_max ────────────────────
  int quantity;
  final String image;
  final int vendorId;
  final String vendorName;
  final int? packingId;
  final int? vendorProductId;
  final String? packingType;
  final int maxStock;
  final double gstPercentage;
  final bool isSelected;
  String? addon;

  CartItemModel({
    required this.id,
    this.cartItemId,
    required this.productId,
    required this.name,
    required this.category,
    required this.price,
    this.mrpPrice = 0.0,       // ─── NEW ──────────────────────────────────────
    this.discountMin = 0.0,    // ─── NEW ──────────────────────────────────────
    this.discountMax = 0.0,    // ─── NEW ──────────────────────────────────────
    required this.quantity,
    required this.image,
    required this.vendorId,
    required this.vendorName,
    this.packingId,
    this.vendorProductId,
    this.packingType,
    required this.maxStock,
    this.gstPercentage = 0.0,
    this.isSelected = true,
    this.addon,
  });

  factory CartItemModel.fromApiJson(Map<String, dynamic> json) {
    print('🔄 Parsing API cart item: $json');

    final product = json['product'] ?? {};
    final vendor = json['vendor'] ?? {};
    String image = '';

    if (product['images'] != null &&
        product['images'] is List &&
        product['images'].isNotEmpty) {
      image = product['images'][0]['images'] ?? '';
    }

    String productName = product['name'] ?? json['product_name'] ?? 'Unknown Product';
    int maxStock = product['stock'] ?? 999;
    double gstPercentage =
        double.tryParse(product['gst_percentage']?.toString() ?? '0') ?? 0;

    return CartItemModel(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      cartItemId: json['id'],
      productId: json['product_id'] ?? product['id'] ?? 0,
      name: productName,
      category: 'Medicine',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      // ─── NEW: parse from API response ──────────────────────────────────────
      mrpPrice: double.tryParse(json['mrp_price']?.toString() ?? '0') ?? 0,
      discountMin: double.tryParse(json['discount_min']?.toString() ?? '0') ?? 0,
      discountMax: double.tryParse(json['discount_max']?.toString() ?? '0') ?? 0,
      quantity: json['quantity'] ?? 1,
      image: image,
      vendorId: json['vendor_id'] ?? vendor['id'] ?? 0,
      vendorName: vendor['name']?.toString() ?? json['vendor_name']?.toString() ?? 'Unknown Vendor',
      packingId: json['vendor_product_id'],
      vendorProductId: json['vendor_product_id'],
      packingType: 'Standard',
      maxStock: maxStock,
      gstPercentage: gstPercentage,
      isSelected: json['is_selected'] ?? true,
      addon: json['addon']?.toString(),
    );
  }

  factory CartItemModel.fromLocalJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['product_id'].toString(),
      productId: json['product_id'],
      name: json['product_name'] ?? 'Unknown Product',
      category: json['category'] ?? 'Medicine',
      price: json['price']?.toDouble() ?? 0,
      mrpPrice: json['mrp_price']?.toDouble() ?? 0,       // ─── NEW ───────────
      discountMin: json['discount_min']?.toDouble() ?? 0, // ─── NEW ───────────
      discountMax: json['discount_max']?.toDouble() ?? 0, // ─── NEW ───────────
      quantity: json['quantity'] ?? 1,
      image: json['product_image'] ?? '',
      vendorId: json['vendor_id'] ?? 0,
      vendorName: json['vendor_name'] ?? 'Unknown Vendor',
      packingId: json['packing_id'],
      vendorProductId: json['vendor_product_id'],
      packingType: json['packing_type'] ?? 'Standard',
      maxStock: json['max_stock'] ?? 999,
      gstPercentage: json['gst_percentage']?.toDouble() ?? 0,
      isSelected: json['is_selected'] ?? true,
      addon: json['addon']?.toString(),
    );
  }

  CartItem toStorageCartItem() {
    return CartItem(
      productId: productId,
      productName: name,
      vendorId: vendorId,
      vendorName: vendorName,
      packingId: packingId ?? 0,
      vendorProductId: vendorProductId ?? 0,
      packingName: packingType ?? 'Standard',
      quantity: quantity,
      price: price,
      mrpPrice: mrpPrice,       // ─── NEW ──────────────────────────────────────
      discountMin: discountMin, // ─── NEW ──────────────────────────────────────
      discountMax: discountMax, // ─── NEW ──────────────────────────────────────
      gstPercentage: gstPercentage,
      image: image,
      addon: addon,
    );
  }
}