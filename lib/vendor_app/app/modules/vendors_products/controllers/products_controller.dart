import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../../app/data/models/venders_products_model.dart';
import '../../../../../app/data/providers/api_endpoints.dart';
import '../../../../../app/routes/app_pages.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VendorsProductsController extends GetxController {
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

  List<ProductModel> get filteredProducts => products;
  int get expiringCount => 0;

  final brands = <String>[].obs;
  final selectedBrand = ''.obs;

  void filterByBrand(String brand) {}

  final showPrescriptionOnly = false.obs;

  void togglePrescriptionFilter(bool value) {
    showPrescriptionOnly.value = value;
  }

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

  @override
  void onInit() {
    super.onInit();
    initializePrefs();

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

  Future<void> initializePrefs() async {
    _prefs = await SharedPreferences.getInstance();
    await loadVendorId();
    await fetchCategories();
    await fetchCompanies();
    await fetchProducts(reset: true);
  }

  Future<void> loadVendorId() async {
    final userDataString = _prefs.getString('user_data');
    if (userDataString != null && userDataString.isNotEmpty) {
      final userData = json.decode(userDataString);
      final id = userData['id'] ?? userData['vendor_id'];
      vendorId.value = int.tryParse(id.toString()) ?? 0;
      print("vendorId.value: ${vendorId.value}");
    }
  }

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

  Future<void> updatePrice(int vendorProductId, double newPrice) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/vendor-products/update-details/$vendorProductId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'selling_price': newPrice,
        }),
      );

      if (response.statusCode == 200) {
        final index = products.indexWhere(
                (p) => p.vendorProductId == vendorProductId);

        if (index != -1) {
          final updatedProduct = ProductModel(
            vendorProductId: products[index].vendorProductId,
            productId: products[index].productId,
            name: products[index].name,
            genericName: products[index].genericName,
            image: products[index].image,
            mrp: products[index].mrp,
            sellingPrice: newPrice,
            stockQuantity: products[index].stockQuantity,
            isAvailable: products[index].isAvailable,
          );

          products[index] = updatedProduct;
          products.refresh();
        }
        Get.back();
        Get.snackbar(
          'Success',
          'Price updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        throw Exception('Failed to update price');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update price',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> fetchProducts({bool reset = false}) async {
    if (reset) {
      currentPage.value = 1;
      products.clear();
      hasMoreData.value = true;
    }

    // Check if we should fetch more
    if (!hasMoreData.value || isLoading.value || isLoadingMore.value) {
      return;
    }

    try {
      if (reset) {
        isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }

      // Build query parameters
      final queryParams = {
        'vendor_id': vendorId.value.toString(),
        'page': currentPage.value.toString(),
        'per_page': perPage.value.toString(),
      };

      // Add search query
      if (searchQuery.value.isNotEmpty) {
        queryParams['search'] = searchQuery.value;
      }

      // Add category filter
      if (selectedCategoryId.value != null) {
        queryParams['category_id'] = selectedCategoryId.value!.toString();
      }

      // Add company filter
      if (selectedCompanyId.value != null) {
        queryParams['company_id'] = selectedCompanyId.value!.toString();
      }

      // Add price range filters
      if (minPrice != null) {
        queryParams['min_price'] = minPrice!.toString();
      }
      if (maxPrice != null) {
        queryParams['max_price'] = maxPrice!.toString();
      }

      // Add stock filter
      if (showInStockOnly.value) {
        queryParams['in_stock'] = '1';
      }

      // Add sorting
      if (sortByPrice != null) {
        queryParams['sort_by_price'] = sortByPrice!;
      }

      // Build URL with query parameters
      final uri = Uri.parse('${ApiEndpoints.baseUrl}/vendor-products/list')
          .replace(queryParameters: queryParams);

      print("Fetching products from: $uri");

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == true) {
          final data = jsonData['data'];

          // Handle different response structures
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

          // Parse products
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
      // If search is cleared, reset and fetch all
      applyFilters(reset: true);
    }
    // Debounce will handle the API call
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
        // You might want to add a different sort parameter for newest
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

  void applyFilters({bool reset = true}) {
    // Cancel any ongoing requests
    // You might want to add a cancel token here

    if (reset) {
      currentPage.value = 1;
      products.clear();
      hasMoreData.value = true;
    }

    // Add a small delay to prevent too many requests
    Future.delayed(Duration(milliseconds: 100), () {
      fetchProducts(reset: reset);
    });
  }

  // Product CRUD Operations
  void addProduct() {
    Get.toNamed(Routes.VENDERS_DASHBOARD)?.then((value) {
      if (value == true) {
        fetchProducts(reset: true);
      }
    });
  }

  void editProduct(ProductModel product) {
    Get.toNamed(Routes.VENDERS_DASHBOARD, arguments: product)?.then((value) {
      if (value == true) {
        fetchProducts(reset: true);
      }
    });
  }

  void viewProductDetails(ProductModel product) {
    Get.toNamed(Routes.PRODUCT_DETAILS, arguments: product);
  }

  void deleteProduct(ProductModel product) async {
    bool? confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Delete Product'),
        content: Text('Are you sure you want to delete ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        isLoading.value = true;

        final response = await http.delete(
          Uri.parse('${ApiEndpoints.baseUrl}/vendor-products/remove/${product.vendorProductId}'),
        );

        if (response.statusCode == 200) {
          products.removeWhere((p) => p.vendorProductId == product.vendorProductId);
          totalProducts.value = products.length;

          Get.snackbar(
            'Success',
            'Product deleted successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          throw Exception('Failed to delete product');
        }
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to delete product',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  void updateStock(ProductModel product, int newStock) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/vendor-products/update-details/${product.vendorProductId}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'stock_quantity': newStock,
        }),
      );

      if (response.statusCode == 200) {
        final index = products.indexWhere((p) => p.vendorProductId == product.vendorProductId);
        if (index != -1) {
          final updatedProduct = ProductModel(
            vendorProductId: products[index].vendorProductId,
            productId: products[index].productId,
            name: products[index].name,
            genericName: products[index].genericName,
            image: products[index].image,
            mrp: products[index].mrp,
            sellingPrice: products[index].sellingPrice,
            stockQuantity: newStock,
            isAvailable: products[index].isAvailable,
          );
          products[index] = updatedProduct;
          products.refresh();

          Get.snackbar(
            'Success',
            'Stock updated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade100,
            colorText: Colors.green.shade800,
          );
        }
      } else {
        throw Exception('Failed to update stock');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update stock',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  // Statistics getters
  int get totalProductsCount => totalProducts.value;
  int get lowStockCount => products.where((p) => (p.stockQuantity ?? 0) < 100).length;
  int get inStockCount => products.where((p) => p.isAvailable == true).length;

  double get totalInventoryValue {
    return products.fold(0.0, (sum, product) =>
    sum + ((product.sellingPrice ?? 0) * (product.stockQuantity ?? 0)));
  }
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