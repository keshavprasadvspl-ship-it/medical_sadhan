import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/providers/api_provider.dart';
import '../../../routes/app_pages.dart';

class CategoriesController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // State variables
  final categories = <Map<String, dynamic>>[].obs;
  final filteredCategories = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final searchQuery = ''.obs;
  final expandedCategories = <String>[].obs;

  // Category stats
  final totalCategories = 0.obs;
  final totalSubCategories = 0.obs;

  // Selected filter
  var selectedFilter = 'All'.obs;

  // Company filter properties
  var selectedCompanyId = Rxn<int>();
  var selectedCompanyName = ''.obs;
  var isCompanyFiltered = false.obs;

  // ADD THESE: Vendor filter properties
  var selectedVendorId = Rxn<int>();
  var selectedVendorName = ''.obs;
  var isVendorFiltered = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Check if we have arguments
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      final vendorId = arguments['vendorId'];
      final vendorName = arguments['vendorName'];
      final companyId = arguments['companyId'];
      final companyName = arguments['companyName'];
      final filterType = arguments['filterType'];

      if (vendorId != null && companyId != null && filterType == 'vendor_company') {
        // Vendor + Company filter
        int? parsedVendorId;
        if (vendorId is String) {
          parsedVendorId = int.tryParse(vendorId);
        } else if (vendorId is int) {
          parsedVendorId = vendorId;
        }

        int? parsedCompanyId;
        if (companyId is String) {
          parsedCompanyId = int.tryParse(companyId);
        } else if (companyId is int) {
          parsedCompanyId = companyId;
        }

        setVendorCompanyFilter(parsedVendorId, vendorName, parsedCompanyId, companyName);
      } else if (companyId != null && filterType == 'company') {
        // Just Company filter
        int? parsedCompanyId;
        if (companyId is String) {
          parsedCompanyId = int.tryParse(companyId);
        } else if (companyId is int) {
          parsedCompanyId = companyId;
        }

        setCompanyFilter(parsedCompanyId, companyName);
      } else {
        loadCategories();
      }
    } else {
      loadCategories();
    }
  }

  // Set company filter
  void setCompanyFilter(int? companyId, String? companyName) {
    selectedCompanyId.value = companyId;
    selectedCompanyName.value = companyName ?? '';
    isCompanyFiltered.value = companyId != null;

    // Reset vendor filter
    isVendorFiltered.value = false;
    selectedVendorId.value = null;
    selectedVendorName.value = '';

    // Load all categories
    loadCategories();
  }

  // ADD THIS: Set vendor + company filter
  void setVendorCompanyFilter(int? vendorId, String? vendorName, int? companyId, String? companyName) {
    selectedVendorId.value = vendorId;
    selectedVendorName.value = vendorName ?? '';
    isVendorFiltered.value = vendorId != null;

    selectedCompanyId.value = companyId;
    selectedCompanyName.value = companyName ?? '';
    isCompanyFiltered.value = companyId != null;

    // Load all categories
    loadCategories();
  }

  // Update filter
  void updateFilter(String filter) {
    selectedFilter.value = filter;
    applyFilters();
  }

  // Apply both search and filter
  void applyFilters() {
    String query = searchQuery.value;

    // First filter by search
    List<Map<String, dynamic>> filtered;

    if (query.isEmpty) {
      filtered = List.from(categories);
    } else {
      filtered = categories.where((category) {
        final name = (category['name'] as String? ?? '').toLowerCase();
        final code = (category['code'] as String? ?? '').toLowerCase();
        final description = (category['description'] as String? ?? '').toLowerCase();

        return name.contains(query.toLowerCase()) ||
            code.contains(query.toLowerCase()) ||
            description.contains(query.toLowerCase()) ||
            _checkSubCategories(category, query);
      }).toList();
    }

    // Then filter by status
    if (selectedFilter.value == 'Active') {
      filtered = filtered.where((cat) => cat['is_active'] == true).toList();
    } else if (selectedFilter.value == 'Inactive') {
      filtered = filtered.where((cat) => cat['is_active'] == false).toList();
    }

    filteredCategories.value = filtered;
  }

  // Filter categories by search query
  void filterCategories(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  // Load all categories
  Future<void> loadCategories() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final apiCategories = await _apiService.getCategories();

      if (apiCategories.isNotEmpty) {
        categories.value = apiCategories;
      } else {
        categories.value = _getDefaultCategories();
      }

      // Apply current filters
      applyFilters();
      _calculateCategoryStats();

    } catch (e) {
      errorMessage.value = 'Failed to load categories: $e';
      categories.value = _getDefaultCategories();
      applyFilters();
      _calculateCategoryStats();

      Get.snackbar(
        'Error',
        'Failed to load categories. Showing default data.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Calculate category statistics
  void _calculateCategoryStats() {
    int totalSubCats = 0;
    for (var category in categories) {
      final subCats = category['sub_categories'] as List?;
      if (subCats != null) {
        totalSubCats += subCats.length;
      }
    }
    totalCategories.value = categories.length;
    totalSubCategories.value = totalSubCats;
  }

  // Check if any subcategory matches the search query
  bool _checkSubCategories(Map<String, dynamic> category, String query) {
    final subCategories = category['sub_categories'] as List?;
    if (subCategories == null || subCategories.isEmpty) return false;

    return subCategories.any((subCat) {
      final subName = (subCat['name'] as String? ?? '').toLowerCase();
      final subCode = (subCat['code'] as String? ?? '').toLowerCase();
      return subName.contains(query.toLowerCase()) ||
          subCode.contains(query.toLowerCase());
    });
  }

  // Toggle category expansion
  void toggleCategoryExpansion(String categoryId) {
    if (expandedCategories.contains(categoryId)) {
      expandedCategories.remove(categoryId);
    } else {
      expandedCategories.add(categoryId);
    }
  }

  // Expand all categories
  void expandAllCategories() {
    expandedCategories.value = filteredCategories
        .map((category) => category['id'].toString())
        .toList();
  }

  // Collapse all categories
  void collapseAllCategories() {
    expandedCategories.clear();
  }

  // Check if category is expanded
  bool isCategoryExpanded(String categoryId) {
    return expandedCategories.contains(categoryId);
  }

  // Get category icon
  String getCategoryIcon(Map<String, dynamic> category) {
    final icon = category['icon'] as String?;
    final name = (category['name'] as String? ?? '').toLowerCase();

    if (icon != null && icon.isNotEmpty) return icon;

    // Map category names to icons
    if (name.contains('medic') || name.contains('pharma')) return '💊';
    if (name.contains('antibiotic')) return '🦠';
    if (name.contains('pain') || name.contains('analgesic')) return '😷';
    if (name.contains('vitamin') || name.contains('supplement')) return '🧪';
    if (name.contains('cardiac') || name.contains('heart')) return '❤️';
    if (name.contains('diabetes') || name.contains('blood')) return '🩸';
    if (name.contains('gastro') || name.contains('stomach')) return '🤢';
    if (name.contains('neuro') || name.contains('brain')) return '🧠';
    if (name.contains('derma') || name.contains('skin')) return '🧴';
    if (name.contains('onco') || name.contains('cancer')) return '🦠';
    if (name.contains('respiratory') || name.contains('lung')) return '🌬️';

    return '📦';
  }

  // Refresh categories
  Future<void> refreshCategories() async {
    await loadCategories();
  }

  // Get default categories (fallback)
  List<Map<String, dynamic>> _getDefaultCategories() {
    return [
      {
        'id': '1',
        'name': 'Medicines',
        'code': 'MED',
        'description': 'All types of medicines',
        'icon': '💊',
        'image': '',
        'is_active': true,
        'sub_categories': [
          {'id': '1', 'name': 'Tablets', 'code': 'TAB', 'is_active': true},
          {'id': '2', 'name': 'Capsules', 'code': 'CAP', 'is_active': true},
          {'id': '3', 'name': 'Syrups', 'code': 'SYR', 'is_active': true},
          {'id': '4', 'name': 'Injections', 'code': 'INJ', 'is_active': true},
        ],
      },
      {
        'id': '2',
        'name': 'Supplements',
        'code': 'SUP',
        'description': 'Health supplements and vitamins',
        'icon': '🧪',
        'image': '',
        'is_active': true,
        'sub_categories': [
          {'id': '5', 'name': 'Vitamins', 'code': 'VIT', 'is_active': true},
          {'id': '6', 'name': 'Minerals', 'code': 'MIN', 'is_active': true},
          {'id': '7', 'name': 'Proteins', 'code': 'PRO', 'is_active': true},
        ],
      },
      {
        'id': '3',
        'name': 'Medical Devices',
        'code': 'DEV',
        'description': 'Medical equipment and devices',
        'icon': '🩺',
        'image': '',
        'is_active': true,
        'sub_categories': [
          {'id': '8', 'name': 'Diagnostic', 'code': 'DIA', 'is_active': true},
          {'id': '9', 'name': 'Monitoring', 'code': 'MON', 'is_active': true},
          {'id': '10', 'name': 'Surgical', 'code': 'SUR', 'is_active': true},
        ],
      },
    ];
  }

  // UPDATED: Navigate to products with vendor, company and category filters
  void navigateToCategoryProducts(Map<String, dynamic> category) {
    if (isVendorFiltered.value && isCompanyFiltered.value) {
      // Vendor + Company + Category - Navigate to VendorProductStore
      Get.toNamed(
        Routes.VENDOR_PRODUCT_STORE,
        arguments: {
          'vendor_id': selectedVendorId.value,
          'vendor_name': selectedVendorName.value,
          'companyId': selectedCompanyId.value,
          'company': selectedCompanyName.value,
          'category': category['name'],
          'categoryId': category['id'],
          'filterType': 'vendor_company_category',
        },
      );
    } else if (isCompanyFiltered.value) {
      // Just Company + Category - Navigate to regular Products page
      Get.toNamed(
        Routes.PRODUCTS,
        arguments: {
          'company': selectedCompanyName.value,
          'companyId': selectedCompanyId.value,
          'category': category['name'],
          'categoryId': category['id'],
          'filterType': 'company_category',
        },
      );
    } else {
      // Just Category - Navigate to regular Products page
      Get.toNamed(
        Routes.PRODUCTS,
        arguments: {
          'category': category['name'],
          'categoryId': category['id'],
          'filterType': 'category',
        },
      );
    }
  }

  // UPDATED: Navigate to subcategory products with filters
  void navigateToSubCategoryProducts(
      Map<String, dynamic> category,
      Map<String, dynamic> subCategory
      ) {
    if (isVendorFiltered.value && isCompanyFiltered.value) {
      // Vendor + Company + Category + SubCategory - Navigate to VendorProductStore
      Get.toNamed(
        Routes.VENDOR_PRODUCT_STORE,
        arguments: {
          'vendor_id': selectedVendorId.value,
          'vendor_name': selectedVendorName.value,
          'companyId': selectedCompanyId.value,
          'company': selectedCompanyName.value,
          'category': category['name'],
          'categoryId': category['id'],
          'subCategoryId': subCategory['id'],
          'subCategoryName': subCategory['name'],
          'filterType': 'vendor_company_category_subcategory',
        },
      );
    } else if (isCompanyFiltered.value) {
      // Company + Category + SubCategory - Navigate to regular Products page
      Get.toNamed(
        Routes.PRODUCTS,
        arguments: {
          'company': selectedCompanyName.value,
          'companyId': selectedCompanyId.value,
          'category': category['name'],
          'categoryId': category['id'],
          'subCategoryId': subCategory['id'],
          'subCategoryName': subCategory['name'],
          'filterType': 'company_category_subcategory',
        },
      );
    } else {
      // Just Category + SubCategory - Navigate to regular Products page
      Get.toNamed(
        Routes.PRODUCTS,
        arguments: {
          'category': category['name'],
          'categoryId': category['id'],
          'subCategoryId': subCategory['id'],
          'subCategoryName': subCategory['name'],
          'filterType': 'category_subcategory',
        },
      );
    }
  }
}