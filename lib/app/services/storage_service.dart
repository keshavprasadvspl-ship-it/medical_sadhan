// lib/services/storage_service.dart
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../data/models/vendor_model.dart';
import '../data/models/packing_model.dart';
import '../data/models/cart_item_model.dart';

class StorageService {
  static const String _cartKey = 'cart_items';
  static const String _vendorPrefix = 'vendor_';
  static const String _packingPrefix = 'packing_';
  static const String _lastVendorPrefix = 'last_vendor_';
  static const String _userLoggedInKey = 'is_logged_in';
  static const String _userIdKey = 'user_id';

  Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  // User session management
  Future<void> setLoggedIn(bool isLoggedIn) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_userLoggedInKey, isLoggedIn);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_userLoggedInKey) ?? false;
  }

  Future<void> setUserId(String userId) async {
    final prefs = await _getPrefs();
    await prefs.setString(_userIdKey, userId);
  }

  Future<String?> getUserId() async {
    final prefs = await _getPrefs();
    return prefs.getString(_userIdKey);
  }

  // Vendor management
  Future<List<Vendor>> getVendorsForProduct(int productId) async {
    final prefs = await _getPrefs();
    final String? vendorsJson = prefs.getString('$_vendorPrefix$productId');

    if (vendorsJson != null) {
      final List<dynamic> decoded = jsonDecode(vendorsJson);
      return decoded.map((item) => Vendor.fromJson(item)).toList();
    }

    return [];
  }

  Future<void> saveVendorsForProduct(int productId, List<Vendor> vendors) async {
    final prefs = await _getPrefs();

    final vendorsJson = jsonEncode(vendors.map((v) {
      return {
        'id': v.id,
        'name': v.name,
        'price': v.price,
        'discountPrice': v.discountPrice,
        'stock': v.stock,
        'deliveryTime': v.deliveryTime,
        'rating': v.rating,
        'vendorProductId': v.vendorProductId,
      };
    }).toList());

    await prefs.setString('$_vendorPrefix$productId', vendorsJson);
  }

  // Packing management
  Future<List<Packing>> getPackingsForProduct(int productId) async {
    final prefs = await _getPrefs();
    final String? packingsJson = prefs.getString('$_packingPrefix$productId');

    if (packingsJson != null) {
      final List<dynamic> decoded = jsonDecode(packingsJson);
      return decoded.map((item) => Packing.fromJson(item)).toList();
    }

    return [];
  }

  Future<void> savePackingsForProduct(int productId, List<Packing> packings) async {
    final prefs = await _getPrefs();
    final packingsJson = jsonEncode(packings.map((p) => p.toJson()).toList());
    await prefs.setString('$_packingPrefix$productId', packingsJson);
  }

  // Last selected vendor
  Future<void> saveLastSelectedVendor(int productId, int vendorId) async {
    final prefs = await _getPrefs();
    await prefs.setInt('$_lastVendorPrefix$productId', vendorId);
  }

  Future<int?> getLastSelectedVendor(int productId) async {
    final prefs = await _getPrefs();
    return prefs.getInt('$_lastVendorPrefix$productId');
  }

  // Cart management - FIXED: Consistent StringList storage
  Future<void> addToCart(CartItem cartItem) async {
    final prefs = await _getPrefs();

    // Get existing cart items as StringList
    List<String> cartItems = prefs.getStringList(_cartKey) ?? [];

    // Check if item already exists (same product, vendor, packing)
    bool itemExists = false;
    for (int i = 0; i < cartItems.length; i++) {
      try {
        final Map<String, dynamic> existingItem = jsonDecode(cartItems[i]);
        if (existingItem['productId'] == cartItem.productId &&
            existingItem['vendorId'] == cartItem.vendorId &&
            existingItem['packingId'] == cartItem.packingId) {

          // Update quantity of existing item
          existingItem['quantity'] = cartItem.quantity;
          cartItems[i] = jsonEncode(existingItem);
          itemExists = true;
          break;
        }
      } catch (e) {
        print('Error parsing cart item: $e');
      }
    }

    // If item doesn't exist, add new one
    if (!itemExists) {
      final cartItemJson = jsonEncode(cartItem.toJson()); // Use toJson() from model
      cartItems.add(cartItemJson);
    }

    await prefs.setStringList(_cartKey, cartItems);
    print('Cart saved. Total items: ${cartItems.length}');
  }

  Future<void> updateCartItem(CartItem item) async {
    final prefs = await _getPrefs();
    List<String> cartItems = prefs.getStringList(_cartKey) ?? [];

    for (int i = 0; i < cartItems.length; i++) {
      try {
        final Map<String, dynamic> existingItem = jsonDecode(cartItems[i]);
        if (existingItem['productId'] == item.productId &&
            existingItem['vendorId'] == item.vendorId &&
            existingItem['packingId'] == item.packingId) {

          cartItems[i] = jsonEncode(item.toJson());
          break;
        }
      } catch (e) {
        print('Error updating cart item: $e');
      }
    }

    await prefs.setStringList(_cartKey, cartItems);
  }

  Future<void> removeFromCart(int productId, int vendorId, int packingId) async {
    final prefs = await _getPrefs();
    List<String> cartItems = prefs.getStringList(_cartKey) ?? [];

    cartItems.removeWhere((itemJson) {
      try {
        final Map<String, dynamic> item = jsonDecode(itemJson);
        return item['productId'] == productId &&
            item['vendorId'] == vendorId &&
            item['packingId'] == packingId;
      } catch (e) {
        return false;
      }
    });

    await prefs.setStringList(_cartKey, cartItems);
  }

  Future<List<CartItem>> getCartItems() async {
    final prefs = await _getPrefs();
    final List<String>? cartItemsList = prefs.getStringList(_cartKey);

    if (cartItemsList != null && cartItemsList.isNotEmpty) {
      List<CartItem> items = [];
      for (String itemJson in cartItemsList) {
        try {
          final Map<String, dynamic> decoded = jsonDecode(itemJson);
          items.add(CartItem.fromJson(decoded));
        } catch (e) {
          print('Error parsing cart item: $e');
        }
      }
      return items;
    }

    return [];
  }

  Future<void> clearCart() async {
    final prefs = await _getPrefs();
    await prefs.remove(_cartKey);
  }

  Future<int> getCartItemCount() async {
    final List<CartItem> cart = await getCartItems();
    return cart.fold<int>(0, (int sum, CartItem item) => sum + item.quantity);
  }

  // Remove the _saveCartItems method as it's not needed with StringList approach

  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await _getPrefs();
    final userString = prefs.getString('user_data');
    if (userString == null) return null;
    return jsonDecode(userString) as Map<String, dynamic>;
  }

  Future<String?> getToken() async {
    final prefs = await _getPrefs();
    return prefs.getString('auth_token');
  }

  Future<void> setString(String key, String value) async {
    final prefs = await _getPrefs();
    await prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    final prefs = await _getPrefs();
    return prefs.getString(key);
  }
}