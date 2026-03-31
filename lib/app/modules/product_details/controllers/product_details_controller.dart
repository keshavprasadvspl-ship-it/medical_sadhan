// product_details_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/product_details_model.dart';
import '../../../data/models/related_product_model.dart';
import '../../../data/providers/api_provider.dart';
import '../../../global_widgets/product_add_to_cart_sheet.dart';
import '../../../services/storage_service.dart';
import '../../../data/providers/api_endpoints.dart'; // Add this import

class ProductDetailController extends GetxController {
  final ApiService _apiService = ApiService();

  final Rx<ProductDetail?> product = Rx<ProductDetail?>(null);
  final Rx<int> quantity = 1.obs;
  final Rx<int> selectedImageIndex = 0.obs;
  final Rx<bool> isLoading = false.obs;
  final Rx<String> errorMessage = ''.obs;
  var isLoadingRelated = true.obs;
  var relatedErrorMessage = ''.obs;

  final RxList<Map<String, dynamic>> reviews = <Map<String, dynamic>>[].obs;
  // Fix: Change this to RelatedProduct type
  final RxList<RelatedProduct> relatedProducts = <RelatedProduct>[].obs;

  // Sample features
  final RxList<Map<String, dynamic>> features = <Map<String, dynamic>>[
    {
      'icon': Icons.verified_outlined,
      'title': 'Quality Assured',
      'subtitle': 'Certified quality'
    },
    {
      'icon': Icons.support_agent_outlined,
      'title': '24/7 Support',
      'subtitle': 'Always here to help'
    },
  ].obs;

  final StorageService _storageService = StorageService();
  final RxInt cartCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final productId = Get.parameters['id'];
    print("PARAMETERS -> ${Get.parameters}");
    print("productIdproductId");
    print(productId);
    if (productId != null) {
      loadProductDetails(int.parse(productId));
    }
    loadCartCount();
  }

  Future<void> loadCartCount() async {
    final count = await _storageService.getCartItemCount();
    cartCount.value = count;
  }

  void updateCartCount() async {
    final count = await _storageService.getCartItemCount();
    cartCount.value = count;
  }

  // Modified addToCart method to show bottom sheet
  void showAddToCartSheet() {
    if (product.value == null) return;

    Get.bottomSheet(
      ProductAddToCartSheet(
        product: product.value!,
        controller: this,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> loadProductDetails(int productId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Set related products loading to true when starting to load
      isLoadingRelated.value = true;
      relatedErrorMessage.value = '';

      final response = await _apiService.getProductById(productId);
      print("getProductById");
      print(response);

      if (response['success'] == true) {
        final productData = response['data'] ?? {};

        // Debug print
        print('Product Data: $productData');

        // Try to convert to ProductDetail
        try {
          product.value = ProductDetail.fromJson(productData);

          // Fix: Properly handle related products
          if (productData['related_products'] != null) {
            final relatedData = productData['related_products'];
            if (relatedData['items'] != null && relatedData['items'] is List) {
              relatedProducts.value = (relatedData['items'] as List)
                  .map((item) => RelatedProduct.fromJson(item))
                  .toList();
            } else {
              // If no related products, set empty list
              relatedProducts.value = [];
            }
          } else {
            // If no related products field, set empty list
            relatedProducts.value = [];
          }

          print('Product loaded successfully: ${product.value?.name}');
          print('Related products count: ${relatedProducts.length}');
        } catch (e) {
          print('Error parsing product: $e');
          relatedProducts.value = []; // Set empty list on error
          throw Exception('Failed to parse product data');
        }

      } else {
        relatedProducts.value = []; // Set empty list on error
        throw Exception(response['message'] ?? 'Failed to load product details');
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
      relatedProducts.value = []; // Set empty list on error
      print('Error in loadProductDetails: $e');
      Get.snackbar(
        'Error',
        'Failed to load product details',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      // Always set isLoadingRelated to false when done loading
      isLoadingRelated.value = false;
    }
  }

  void increaseQuantity() {
    quantity.value++;
  }

  void decreaseQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  void changeImage(int index) {
    if (product.value?.images != null && index < product.value!.images.length) {
      selectedImageIndex.value = index;
    }
  }

  void toggleFavorite() {
    if (product.value != null) {
      product.value = product.value!.copyWith(
        isFavorite: !product.value!.isFavorite,
      );

      Get.snackbar(
        product.value!.isFavorite ? 'Added to Wishlist' : 'Removed from Wishlist',
        product.value!.isFavorite ? 'Product added to your wishlist' : 'Product removed from wishlist',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF0B630B),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void addToCart() {
    if (product.value != null) {
      Get.snackbar(
        'Added to Cart',
        '${quantity.value} ${product.value!.name} added to cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF0B630B),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void buyNow() {
    addToCart();
    Future.delayed(const Duration(milliseconds: 500), () {
      Get.toNamed('/cart');
    });
  }

  // Get ingredients list
  List<String> getIngredients() {
    if (product.value == null) return [];

    final composition = product.value!.saltComposition;
    if (composition != null && composition.name.isNotEmpty) {
      return [composition.name];
    }

    return [
      'Not Available',
    ];
  }

  // Get benefits list
  List<String> getBenefits() {
    if (product.value == null) return [];

    final List<String> benefits = [];

    if (product.value!.subCategory != null) {
      benefits.add('Supports ${product.value!.subCategory!.name.toLowerCase()} health');
    }

    benefits.addAll([
      'High quality formulation',
      'Trusted brand: ${product.value!.company.name}',
    ]);

    return benefits;
  }

  // Refresh product details
  Future<void> refresh() async {
    if (product.value != null) {
      await loadProductDetails(product.value!.id);
    }
  }

  // Get category name for display
  String getCategoryDisplay() {
    if (product.value == null) return 'Medicine';
    return product.value!.subCategory?.name ??
        product.value!.category?.name ??
        'Medicine';
  }

  // Check if product is in stock
  bool get isProductInStock {
    if (product.value == null) return false;
    return !product.value!.isOutOfStock;
  }

  // Get product price for display
  double get displayPrice {
    if (product.value == null) return 0.0;
    return product.value!.displayPrice;
  }

  // Get original price
  double get originalPrice {
    if (product.value == null) return 0.0;
    return product.value!.originalPrice;
  }

  // Check if product has discount
  bool get hasDiscount {
    if (product.value == null) return false;
    return product.value!.hasDiscount;
  }

  // Get discount percentage
  double get discountPercent {
    if (product.value == null) return 0.0;
    return product.value!.discountPercent;
  }
}