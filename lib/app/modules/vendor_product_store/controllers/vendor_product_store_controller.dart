import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../../app/data/models/venders_products_model.dart';
import '../../../../../app/data/providers/api_endpoints.dart';
import '../../../../../app/routes/app_pages.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../global_widgets/add_to_cart_popup.dart';
import '../../main/controllers/main_controller.dart';

class VendorProductStoreController extends GetxController {
  // Products
  final products = <ProductModel>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMoreData = true.obs;
  late Worker _searchDebounce;

  // Pagination
  final currentPage = 1.obs;
  final perPage = 20.obs;
  final totalProducts = 0.obs;

  // View mode
  final isGridView = false.obs;

  late SharedPreferences _prefs;
  final vendorId = 0.obs;
  final vendorName = ''.obs;

  // Filter variables
  final selectedCategory = 'All'.obs;
  final selectedCategoryId = Rx<int?>(null);
  final selectedFilter = 'All'.obs;
  final searchQuery = ''.obs;
  final selectedCompany = 'All'.obs;
  final selectedCompanyId = Rx<int?>(null);
  final priceRange = RangeValues(0, 10000).obs;
  final showInStockOnly = false.obs;

  // Filter options from API
  final categories = <CategoryModel>[].obs;
  final companies = <CompanyModel>[].obs;

  // Filter params for API
  double? minPrice;
  double? maxPrice;
  bool? inStock;
  String? sortByPrice;

  final filterOptions = [
    'All',
    'In Stock',
    'Price: Low to High',
    'Price: High to Low',
    'Newest First',
  ];

  // Cart related variables
  final cartItemCount = 0.obs;
  final cartItems = <CartItem>[].obs;

  // Track incoming filters from navigation
  final incomingCompanyId = Rx<int?>(null);
  final incomingCompanyName = ''.obs;
  final incomingCategoryId = Rx<int?>(null);
  final incomingCategoryName = ''.obs;
  final incomingSubCategoryId = Rx<int?>(null);
  final incomingSubCategoryName = ''.obs;
  final incomingFilterType = ''.obs;

  @override
  void onInit() {
    super.onInit();

    // Get vendor info and filters from arguments
    final args = Get.arguments;
    if (args != null) {
      vendorId.value = args['vendor_id'] ?? 0;
      vendorName.value = args['vendor_name'] ?? 'Vendor Store';

      // Handle incoming filters from categories page
      _handleIncomingFilters(args);
    }

    initializePrefs();
    loadCartFromPrefs();

    _searchDebounce = debounce(
      searchQuery,
          (_) {
        if (searchQuery.value.isNotEmpty) {
          applyFilters(reset: true);
        }
      },
      time: const Duration(milliseconds: 500),
    );
  }

  @override
  void onClose() {
    _searchDebounce.dispose();
    super.onClose();
  }

  // Handle incoming filters from categories page
  void _handleIncomingFilters(Map<String, dynamic> args) {
    print("📥 Received arguments in VendorProductStore: $args");

    // Store filter type
    if (args.containsKey('filterType')) {
      incomingFilterType.value = args['filterType'];
    }

    // Handle company filter
    if (args.containsKey('companyId')) {
      final companyId = args['companyId'];
      if (companyId is int) {
        incomingCompanyId.value = companyId;
        selectedCompanyId.value = companyId;
      } else if (companyId is String) {
        incomingCompanyId.value = int.tryParse(companyId);
        selectedCompanyId.value = int.tryParse(companyId);
      }
    }

    if (args.containsKey('company')) {
      incomingCompanyName.value = args['company'];
      selectedCompany.value = args['company'];
      print("🎯 Setting company filter: ${selectedCompany.value}");
    }

    // Handle category filter
    if (args.containsKey('categoryId')) {
      final categoryId = args['categoryId'];
      if (categoryId is int) {
        incomingCategoryId.value = categoryId;
        selectedCategoryId.value = categoryId;
      } else if (categoryId is String) {
        incomingCategoryId.value = int.tryParse(categoryId);
        selectedCategoryId.value = int.tryParse(categoryId);
      }
    }

    if (args.containsKey('category')) {
      incomingCategoryName.value = args['category'];
      selectedCategory.value = args['category'];
      print("🎯 Setting category filter: ${selectedCategory.value}");
    }

    // Handle subcategory filter
    if (args.containsKey('subCategoryId')) {
      final subCategoryId = args['subCategoryId'];
      if (subCategoryId is int) {
        incomingSubCategoryId.value = subCategoryId;
      } else if (subCategoryId is String) {
        incomingSubCategoryId.value = int.tryParse(subCategoryId);
      }
    }

    if (args.containsKey('subCategoryName')) {
      incomingSubCategoryName.value = args['subCategoryName'];
    }
  }

  Future<void> initializePrefs() async {
    _prefs = await SharedPreferences.getInstance();
    await fetchCategories();
    await fetchCompanies();

    // Load products with the incoming filters applied
    await fetchProducts(reset: true);

    // Show filter applied message
    _showFilterAppliedMessage();
  }

  // Show message about applied filters
  void _showFilterAppliedMessage() {
    String message = '';
    if (selectedCompany.value != 'All' && selectedCategory.value != 'All') {
      message = 'Showing products from ${selectedCompany.value} in ${selectedCategory.value}';
    } else if (selectedCompany.value != 'All') {
      message = 'Showing products from ${selectedCompany.value}';
    } else if (selectedCategory.value != 'All') {
      message = 'Showing products in ${selectedCategory.value}';
    }

    if (message.isNotEmpty) {
      Get.snackbar(
        'Filters Applied',
        message,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF0B630B),
        colorText: Colors.white,
      );
    }
  }

  // Cart Methods
  Future<void> loadCartFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString('cart_items_${vendorId.value}');
      if (cartJson != null) {
        final List<dynamic> cartList = json.decode(cartJson);
        cartItems.value = cartList.map((item) => CartItem.fromJson(item)).toList();
        _updateCartCount();
      }
    } catch (e) {
      print('Error loading cart: $e');
    }
  }

  Future<void> saveCartToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = json.encode(cartItems.map((item) => item.toJson()).toList());
      await prefs.setString('cart_items_${vendorId.value}', cartJson);
      _updateCartCount();
    } catch (e) {
      print('Error saving cart: $e');
    }
  }

  void _updateCartCount() {
    int count = 0;
    for (var item in cartItems) {
      count += item.quantity;
    }
    cartItemCount.value = count;
  }

  void addToCart(ProductModel product) {
    print("Add to cart product popup");
    print(product);
    Get.dialog(
      AddToCartPopup(product: product),
    );
    Get.find<MainController>().incrementCartRefreshToken();
  }

  // Method to refresh cart count (call this after item is added to cart)
  void refreshCartCount() {
    loadCartFromPrefs();
  }

  void goToCart() {
    Get.toNamed(
      Routes.CART,
      arguments: {
        'vendor_id': vendorId.value,
        'vendor_name': vendorName.value,
        'cart_items': cartItems.toList(),
      },
    );
  }

  void removeFromCart(int productId) {
    cartItems.removeWhere((item) => item.productId == productId);
    saveCartToPrefs();

    Get.snackbar(
      'Removed from Cart',
      'Item removed from cart',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void updateCartItemQuantity(int productId, int newQuantity) {
    final index = cartItems.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      if (newQuantity <= 0) {
        cartItems.removeAt(index);
      } else {
        cartItems[index] = cartItems[index].copyWith(quantity: newQuantity);
      }
      saveCartToPrefs();
    }
  }

  void clearCart() {
    cartItems.clear();
    saveCartToPrefs();

    Get.snackbar(
      'Cart Cleared',
      'All items removed from cart',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  // Fetch categories from API
  Future<void> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/category'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          final List<dynamic> categoriesJson = jsonData['data'];
          categories.value = categoriesJson.map((json) =>
              CategoryModel.fromJson(json)).toList();
        }
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  // Fetch companies from API
  Future<void> fetchCompanies() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/company'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          final List<dynamic> companiesJson = jsonData['data'];
          companies.value = companiesJson.map((json) =>
              CompanyModel.fromJson(json)).toList();
        }
      }
    } catch (e) {
      print('Error fetching companies: $e');
    }
  }

  // Fetch products with filters
  Future<void> fetchProducts({bool reset = false}) async {
    if (reset) {
      currentPage.value = 1;
      products.clear();
      hasMoreData.value = true;
    }

    if (!hasMoreData.value || isLoading.value || isLoadingMore.value) {
      return;
    }

    try {
      if (reset) {
        isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }

      final queryParams = {
        'vendor_id': vendorId.value.toString(),
        'page': currentPage.value.toString(),
        'per_page': perPage.value.toString(),
      };

      if (searchQuery.value.isNotEmpty) {
        queryParams['search'] = searchQuery.value;
      }

      if (selectedCategoryId.value != null) {
        queryParams['category_id'] = selectedCategoryId.value!.toString();
      }

      if (selectedCompanyId.value != null) {
        queryParams['company_id'] = selectedCompanyId.value!.toString();
      }

      if (minPrice != null) {
        queryParams['min_price'] = minPrice!.toString();
      }
      if (maxPrice != null) {
        queryParams['max_price'] = maxPrice!.toString();
      }

      if (showInStockOnly.value) {
        queryParams['in_stock'] = '1';
      }

      if (sortByPrice != null) {
        queryParams['sort_by_price'] = sortByPrice!;
      }

      final uri = Uri.parse('${ApiEndpoints.baseUrl}/vendor-products/list')
          .replace(queryParameters: queryParams);

      print("Fetching products from: $uri");
      print("With filters - Company: $selectedCompany, Category: $selectedCategory");

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == true) {
          final data = jsonData['data'];

          List<dynamic> productsJson = [];
          if (data is Map && data.containsKey('data')) {
            productsJson = data['data'] as List<dynamic>;
            totalProducts.value = data['total'] ?? 0;
            hasMoreData.value = (data['current_page'] ?? 1) < (data['last_page'] ?? 1);
          } else if (data is List) {
            productsJson = data;
            totalProducts.value = productsJson.length;
            hasMoreData.value = false;
          }

          final newProducts = productsJson.map((json) =>
              ProductModel.fromJson(json)).toList();

          if (reset) {
            products.value = newProducts;
          } else {
            products.addAll(newProducts);
          }

          print("Loaded ${newProducts.length} products, total: ${products.length}");
        }
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
      if (products.isEmpty) {
        Get.snackbar(
          'Error',
          'Failed to load products: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
        );
      }
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  void loadMoreProducts() {
    if (hasMoreData.value && !isLoadingMore.value && !isLoading.value) {
      currentPage.value++;
      fetchProducts(reset: false);
    }
  }

  void toggleViewMode() {
    isGridView.value = !isGridView.value;
  }

  void searchProducts(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      applyFilters(reset: true);
    } else {
      applyFilters(reset: true);
    }
  }

  void filterByCategory(String categoryName, int? categoryId) {
    selectedCategory.value = categoryName;
    selectedCategoryId.value = categoryId;
    applyFilters(reset: true);
  }

  void filterByCompany(String companyName, int? companyId) {
    selectedCompany.value = companyName;
    selectedCompanyId.value = companyId;
    applyFilters(reset: true);
  }

  void filterByOption(String filter) {
    selectedFilter.value = filter;

    switch (filter) {
      case 'All':
        sortByPrice = null;
        showInStockOnly.value = false;
        break;
      case 'In Stock':
        showInStockOnly.value = true;
        sortByPrice = null;
        break;
      case 'Price: Low to High':
        sortByPrice = 'asc';
        showInStockOnly.value = false;
        break;
      case 'Price: High to Low':
        sortByPrice = 'desc';
        showInStockOnly.value = false;
        break;
      case 'Newest First':
        sortByPrice = null;
        showInStockOnly.value = false;
        break;
    }

    applyFilters(reset: true);
  }

  void toggleStockFilter(bool value) {
    showInStockOnly.value = value;
    applyFilters(reset: true);
  }

  void updatePriceRange(RangeValues range) {
    priceRange.value = range;
    minPrice = range.start;
    maxPrice = range.end;
    applyFilters(reset: true);
  }

  // Reset all filters
  void resetFilters() {
    selectedCategory.value = 'All';
    selectedFilter.value = 'All';
    selectedCompany.value = 'All';
    showInStockOnly.value = false;
    priceRange.value = RangeValues(0, 10000);
    searchQuery.value = '';

    selectedCategoryId.value = null;
    selectedCompanyId.value = null;
    minPrice = null;
    maxPrice = null;
    inStock = null;
    sortByPrice = null;

    applyFilters(reset: true);
  }

  // Clear only navigation filters
  void clearNavigationFilters() {
    selectedCompany.value = 'All';
    selectedCompanyId.value = null;
    selectedCategory.value = 'All';
    selectedCategoryId.value = null;
    applyFilters(reset: true);
  }

  void applyFilters({bool reset = true}) {
    if (reset) {
      currentPage.value = 1;
      products.clear();
      hasMoreData.value = true;
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      fetchProducts(reset: reset);
    });
  }

  void viewProductDetails(ProductModel product) {
    Get.toNamed('/product-details/${product.productId}');
  }

  int get totalProductsCount => totalProducts.value;
  int get inStockCount => products.where((p) => p.isAvailable == true).length;

  // Check if we have active filters from navigation
  bool get hasIncomingFilters {
    return (selectedCompany.value != 'All' && selectedCompany.value.isNotEmpty) ||
        (selectedCategory.value != 'All' && selectedCategory.value.isNotEmpty);
  }

  // Get filter description for UI
  String get filterDescription {
    if (selectedCompany.value != 'All' && selectedCategory.value != 'All') {
      return '${selectedCompany.value} > ${selectedCategory.value}';
    } else if (selectedCompany.value != 'All') {
      return 'Company: ${selectedCompany.value}';
    } else if (selectedCategory.value != 'All') {
      return 'Category: ${selectedCategory.value}';
    } else {
      return 'All Products';
    }
  }
}

// Cart Item Model
class CartItem {
  final int productId;
  final String productName;
  final String? productImage;
  final double sellingPrice;
  final double? mrp;
  final int quantity;
  final int vendorId;
  final String vendorName;

  CartItem({
    required this.productId,
    required this.productName,
    this.productImage,
    required this.sellingPrice,
    this.mrp,
    required this.quantity,
    required this.vendorId,
    required this.vendorName,
  });

  CartItem copyWith({
    int? productId,
    String? productName,
    String? productImage,
    double? sellingPrice,
    double? mrp,
    int? quantity,
    int? vendorId,
    String? vendorName,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      mrp: mrp ?? this.mrp,
      quantity: quantity ?? this.quantity,
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'product_image': productImage,
      'selling_price': sellingPrice,
      'mrp': mrp,
      'quantity': quantity,
      'vendor_id': vendorId,
      'vendor_name': vendorName,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['product_id'],
      productName: json['product_name'],
      productImage: json['product_image'],
      sellingPrice: json['selling_price'].toDouble(),
      mrp: json['mrp']?.toDouble(),
      quantity: json['quantity'],
      vendorId: json['vendor_id'],
      vendorName: json['vendor_name'],
    );
  }

  double get totalPrice => sellingPrice * quantity;
  double? get totalMrp => mrp != null ? mrp! * quantity : null;
  double? get discount => mrp != null ? mrp! - sellingPrice : null;
}

// Category Model
class CategoryModel {
  final int id;
  final String name;
  final String? code;
  final String? image;
  final bool isActive;
  final String? description;
  final List<SubCategoryModel> subCategories;

  CategoryModel({
    required this.id,
    required this.name,
    this.code,
    this.image,
    required this.isActive,
    this.description,
    this.subCategories = const [],
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString(),
      image: json['image']?.toString(),
      isActive: json['is_active'] ?? true,
      description: json['description']?.toString(),
      subCategories: json['sub_categories'] != null
          ? (json['sub_categories'] as List)
          .map((sub) => SubCategoryModel.fromJson(sub))
          .toList()
          : [],
    );
  }
}

// SubCategory Model
class SubCategoryModel {
  final int id;
  final String name;
  final String? code;
  final String? image;
  final bool isActive;
  final String? description;

  SubCategoryModel({
    required this.id,
    required this.name,
    this.code,
    this.image,
    required this.isActive,
    this.description,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString(),
      image: json['image']?.toString(),
      isActive: json['is_active'] ?? true,
      description: json['description']?.toString(),
    );
  }
}

// Company Model
class CompanyModel {
  final int id;
  final String name;
  final String? image;
  final bool isActive;
  final String? description;

  CompanyModel({
    required this.id,
    required this.name,
    this.image,
    required this.isActive,
    this.description,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString(),
      isActive: json['is_active'] ?? true,
      description: json['description']?.toString(),
    );
  }
}