import 'package:flutter/material.dart' show Colors;
import 'package:get/get.dart';
import 'package:medical_b2b_app/app/data/providers/api_endpoints.dart';
import '../../../data/providers/api_provider.dart';
import 'banner_controller.dart';

class HomeController extends GetxController {
  final currentIndex = 0.obs;
  final ApiService _apiService = Get.find<ApiService>();
  final selectedPaymentMethod = Rx<Map<String, dynamic>?>( null);
  late final BannerController bannerController;

  // Companies data
  final companies = <Map<String, dynamic>>[].obs;
  final isLoadingCompanies = false.obs;
  final companiesErrorMessage = ''.obs;

  // Vendors data (new)
  final vendors = <Map<String, dynamic>>[].obs;
  final isLoadingVendors = false.obs;
  final vendorsErrorMessage = ''.obs;

  // Categories data
  final categories = <Map<String, dynamic>>[].obs;
  RxString cartItemCount = '2'.obs;

  // Featured products data
  final featuredProducts = <Map<String, dynamic>>[].obs;

  // Loading states
  final isLoading = false.obs;
  final isLoadingProducts = false.obs;
  final errorMessage = ''.obs;
  final productsErrorMessage = ''.obs;

  // Explore products (pagination)
  final exploreProducts = <Map<String, dynamic>>[].obs;

  final isLoadingExplore = false.obs;
  final isLoadingMoreExplore = false.obs;
  final hasMoreExploreData = true.obs;

  final currentExplorePage = 1.obs;
  final explorePageSize = 10.obs;


  void changeTab(int index) {
    currentIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    bannerController = Get.put(BannerController());
    loadCategories();
    loadFeaturedProducts();
    loadCompanies();
    loadVendors(); // Added vendors loading
    loadExploreProducts(); // ✅ ADD THIS
  }

  // Load companies from API
  Future<void> loadCompanies() async {
    try {
      isLoadingCompanies.value = true;
      companiesErrorMessage.value = '';

      final apiCompanies = await _apiService.getCompanies();
      print("apiCompanies");
      print(apiCompanies);

      if (apiCompanies.isNotEmpty) {
        companies.value = apiCompanies.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      companiesErrorMessage.value = 'Failed to load companies: $e';
      Get.snackbar(
        'Error',
        'Failed to load companies',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoadingCompanies.value = false;
    }
  }


  Future<void> loadExploreProducts({bool loadMore = false}) async {
    try {

      if (loadMore) {

        if (!hasMoreExploreData.value || isLoadingMoreExplore.value) return;

        isLoadingMoreExplore.value = true;
        currentExplorePage.value++;

      } else {

        isLoadingExplore.value = true;
        currentExplorePage.value = 1;
        hasMoreExploreData.value = true;
        exploreProducts.clear();
      }

      final apiProducts = await _apiService.getProducts(
        page: currentExplorePage.value,
        limit: explorePageSize.value,
      );
print("apiProducts");
print(apiProducts);
      if (apiProducts.isEmpty) {

        hasMoreExploreData.value = false;

      } else {

        final mappedProducts =
        apiProducts.map((p) => p.toJson()).toList();

        if (loadMore) {
          exploreProducts.addAll(mappedProducts);
        } else {
          exploreProducts.assignAll(mappedProducts);
        }

        hasMoreExploreData.value =
            apiProducts.length == explorePageSize.value;
      }

    } catch (e) {

      print("Explore products error: $e");

    } finally {

      isLoadingExplore.value = false;
      isLoadingMoreExplore.value = false;
    }
  }

  // Load vendors from API (new method)
  Future<void> loadVendors() async {
    try {
      isLoadingVendors.value = true;
      vendorsErrorMessage.value = '';

      final apiVendors = await _apiService.getVendors(limit: 10);
      print("apiVendors");
      print(apiVendors);

      if (apiVendors.isNotEmpty) {
        vendors.value = apiVendors.cast<Map<String, dynamic>>();
      } else {
        vendors.value = [];
      }
    } catch (e) {
      vendorsErrorMessage.value = 'Failed to load vendors: $e';
      Get.snackbar(
        'Error',
        'Failed to load vendors',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoadingVendors.value = false;
    }
  }

  // Load categories from API
  Future<void> loadCategories() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final apiCategories = await _apiService.getCategories();
      print("apiCategories");
      print(apiCategories);

      if (apiCategories.isNotEmpty) {
        categories.value = apiCategories;
      } else {
        categories.value = _getDefaultCategories();
      }
    } catch (e) {
      errorMessage.value = 'Failed to load categories: $e';
      categories.value = _getDefaultCategories();
      Get.snackbar(
        'Error',
        'Failed to load categories. Showing default categories.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load featured products from API
  Future<void> loadFeaturedProducts() async {
    try {
      isLoadingProducts.value = true;
      productsErrorMessage.value = '';

      final apiProducts = await _apiService.getLatestProducts(limit: 10);
      print("apiProducts");
      print(apiProducts);

      if (apiProducts.isNotEmpty) {
        featuredProducts.value = apiProducts.cast<Map<String, dynamic>>();
      } else {
        featuredProducts.value = _getDefaultProducts();
      }
    } catch (e) {
      productsErrorMessage.value = 'Failed to load products: $e';
      featuredProducts.value = _getDefaultProducts();
      Get.snackbar(
        'Error',
        'Failed to load featured products. Showing default products.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoadingProducts.value = false;
    }
  }

  // Refresh all data
  Future<void> refreshData() async {
    await Future.wait([
      loadCategories(),
      loadFeaturedProducts(),
      loadCompanies(),
      loadVendors(),
      loadExploreProducts(), // 🔥 ADD THIS
      // bannerController.loadBanners(),
    ]);
  }

  // ========== VENDOR HELPER METHODS ==========

  // Get vendor logo URL
  String getVendorLogoUrl(Map<String, dynamic> vendor) {
    final logoUrl = vendor['logo_url'] as String?;

    if (logoUrl == null || logoUrl.isEmpty) {
      return '';
    }

    if (logoUrl.startsWith('http://') || logoUrl.startsWith('https://')) {
      return logoUrl;
    }

    String imagePath = logoUrl;
    if (imagePath.startsWith('/')) {
      imagePath = imagePath.substring(1);
    }

    return '${ApiEndpoints.imgUrl}/$imagePath';
  }

  // Get vendor display name
  String getVendorName(Map<String, dynamic> vendor) {
    // Try business_name first
    if (vendor['business_name'] != null && vendor['business_name'].toString().isNotEmpty) {
      return vendor['business_name'].toString();
    }

    // Fallback to user_details name
    if (vendor['user_details'] != null && vendor['user_details']['name'] != null) {
      return vendor['user_details']['name'].toString();
    }

    return 'Unknown Vendor';
  }

  // Check if vendor is active
  bool isVendorActive(Map<String, dynamic> vendor) {
    if (vendor['user_details'] != null && vendor['user_details']['is_active'] != null) {
      return vendor['user_details']['is_active'] as bool;
    }
    return true;
  }

  // Check if vendor is verified
  bool isVendorVerified(Map<String, dynamic> vendor) {
    if (vendor['user_details'] != null && vendor['user_details']['is_verified'] != null) {
      return vendor['user_details']['is_verified'] as bool;
    }
    return false;
  }

  // Get vendor rating
  String getVendorRating(Map<String, dynamic> vendor) {
    final rating = vendor['vendor_rating'] as String? ?? '0.00';
    try {
      return double.parse(rating).toStringAsFixed(1);
    } catch (e) {
      return '0.0';
    }
  }

  // Get vendor category
  String getVendorCategory(Map<String, dynamic> vendor) {
    return vendor['vendor_category'] as String? ?? 'General';
  }

  // Get vendor business type
  String getVendorBusinessType(Map<String, dynamic> vendor) {
    final type = vendor['business_type'] as String? ?? '';
    if (type.isNotEmpty) {
      return type[0].toUpperCase() + type.substring(1);
    }
    return '';
  }

  // Get vendor contact person
  String getVendorContactPerson(Map<String, dynamic> vendor) {
    return vendor['contact_person'] as String? ?? '';
  }

  // Get vendor GST number
  String getVendorGST(Map<String, dynamic> vendor) {
    return vendor['gst_number'] as String? ?? '';
  }

  // Get vendor establishment year
  String getVendorEstYear(Map<String, dynamic> vendor) {
    final year = vendor['year_of_establishment'];
    if (year != null) {
      return year.toString();
    }
    return '';
  }

  // Get vendor drug license number
  String getVendorDrugLicense(Map<String, dynamic> vendor) {
    return vendor['drug_license_number'] as String? ?? '';
  }

  // Get vendor successful orders count
  int getVendorSuccessfulOrders(Map<String, dynamic> vendor) {
    return vendor['successful_orders'] as int? ?? 0;
  }

  // Get vendor average monthly sales
  String getVendorMonthlySales(Map<String, dynamic> vendor) {
    final sales = vendor['average_monthly_sales'] as String? ?? '0';
    try {
      final amount = double.parse(sales);
      if (amount >= 100000) {
        return '₹${(amount/100000).toStringAsFixed(1)}L';
      } else if (amount >= 1000) {
        return '₹${(amount/1000).toStringAsFixed(1)}K';
      }
      return '₹$amount';
    } catch (e) {
      return '₹0';
    }
  }

  // ========== COMPANY HELPER METHODS (your existing ones) ==========

  // Get company logo URL
  String getCompanyLogoUrl(Map<String, dynamic> company) {
    final companyImage = company['logo'] as String?;

    if (companyImage == null || companyImage.isEmpty) {
      return '';
    }

    if (companyImage.startsWith('http://') || companyImage.startsWith('https://')) {
      return companyImage;
    }

    String imagePath = companyImage;
    if (imagePath.startsWith('/')) {
      imagePath = imagePath.substring(1);
    }

    return '${ApiEndpoints.imgUrl}/$imagePath';
  }

  // Check if company is active
  bool isCompanyActive(Map<String, dynamic> company) {
    return company['is_active'] as bool? ?? true;
  }

  // Get company description
  String getCompanyDescription(Map<String, dynamic> company) {
    return company['description'] as String? ?? '';
  }

  // ========== CATEGORY HELPER METHODS ==========

  // Get category icon based on name
  String getCategoryIcon(Map<String, dynamic> category) {
    final name = (category['name'] as String? ?? '').toLowerCase();
    final icon = category['icon'] as String?;

    if (icon != null && icon.isNotEmpty) {
      return icon;
    }

    if (name.contains('medic') || name.contains('pharma')) return '💊';
    if (name.contains('supplement') || name.contains('vitamin')) return '🧪';
    if (name.contains('device') || name.contains('equipment')) return '🩺';
    if (name.contains('personal') || name.contains('care')) return '💄';
    if (name.contains('beauty') || name.contains('cosmetic')) return '✨';
    if (name.contains('surgical') || name.contains('surgery')) return '🩹';
    if (name.contains('diagnostic') || name.contains('test')) return '🔬';
    if (name.contains('ayurved') || name.contains('herbal')) return '🌿';
    if (name.contains('cardiac') || name.contains('heart')) return '❤️';
    if (name.contains('diabetes') || name.contains('blood')) return '🩸';
    if (name.contains('neuro') || name.contains('brain')) return '🧠';
    if (name.contains('derma') || name.contains('skin')) return '🧴';
    if (name.contains('onco') || name.contains('cancer')) return '🦠';

    return '📦';
  }

  // Get category image URL
  String getCategoryImageUrl(Map<String, dynamic> category) {
    final categoryImage = category['image'] as String?;

    if (categoryImage == null || categoryImage.isEmpty) {
      return '';
    }

    if (categoryImage.startsWith('http://') || categoryImage.startsWith('https://')) {
      return categoryImage;
    }

    String imagePath = categoryImage;
    if (imagePath.startsWith('/')) {
      imagePath = imagePath.substring(1);
    }

    return '${ApiEndpoints.imgUrl}/$imagePath';
  }

  // Check if category is active
  bool isCategoryActive(Map<String, dynamic> category) {
    return category['is_active'] as bool? ?? true;
  }

  // Get subcategories count
  int getSubCategoriesCount(Map<String, dynamic> category) {
    final subCategories = category['subCategories'] as List?;
    return subCategories?.length ?? 0;
  }

  // ========== PRODUCT HELPER METHODS ==========

  // Get product image URL
  String getProductImageUrl(Map<String, dynamic> product) {
    if (product['images'] != null && product['images'] is List) {
      final imagesList = product['images'] as List;
      if (imagesList.isNotEmpty && imagesList[0]['images'] != null) {
        final imagePath = imagesList[0]['images'].toString();

        if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
          return imagePath;
        }

        String cleanPath = imagePath;
        if (cleanPath.startsWith('/')) {
          cleanPath = cleanPath.substring(1);
        }

        return '${ApiEndpoints.imgUrl}/$cleanPath';
      }
    }
    return '';
  }

  // Get product category name
  String getProductCategoryName(Map<String, dynamic> product) {
    if (product['category'] != null && product['category']['name'] != null) {
      return product['category']['name'].toString();
    }
    if (product['sub_category'] != null && product['sub_category']['name'] != null) {
      return product['sub_category']['name'].toString();
    }
    return 'General';
  }

  // Get product company name
  String getProductCompanyName(Map<String, dynamic> product) {
    if (product['company'] != null && product['company']['name'] != null) {
      return product['company']['name'].toString();
    }
    return '';
  }

  // Get product strength/power
  String getProductStrength(Map<String, dynamic> product) {
    if (product['power'] != null && product['power']['name'] != null) {
      return product['power']['name'].toString();
    }
    if (product['unit'] != null && product['unit']['name'] != null) {
      return product['unit']['name'].toString();
    }
    return '';
  }

  // Check if product requires prescription
  bool isProductPrescriptionRequired(Map<String, dynamic> product) {
    return product['is_prescription_required'] == 1;
  }

  // Get product GST percentage
  String getProductGST(Map<String, dynamic> product) {
    return product['gst_percentage']?.toString() ?? '0';
  }

  // Get product HSN code
  String getProductHSNCode(Map<String, dynamic> product) {
    return product['hsn_code']?.toString() ?? '';
  }

  // ========== DEFAULT FALLBACK DATA ==========

  // Default fallback categories
  List<Map<String, dynamic>> _getDefaultCategories() {
    return [
      {'id': '1', 'name': 'Medicines', 'icon': '💊', 'image': ''},
      {'id': '2', 'name': 'Supplements', 'icon': '🧪', 'image': ''},
      {'id': '3', 'name': 'Health Devices', 'icon': '🩺', 'image': ''},
      {'id': '4', 'name': 'Personal Care', 'icon': '💄', 'image': ''},
      {'id': '5', 'name': 'Beauty', 'icon': '✨', 'image': ''},
      {'id': '6', 'name': 'Surgical', 'icon': '🩹', 'image': ''},
      {'id': '7', 'name': 'Diagnostic', 'icon': '🔬', 'image': ''},
      {'id': '8', 'name': 'Ayurvedic', 'icon': '🌿', 'image': ''},
    ];
  }

  // Default fallback products
  List<Map<String, dynamic>> _getDefaultProducts() {
    return [
      {
        'id': 1,
        'name': 'Liver Cleanse Detox & Repair',
        'category': 'Supplements',
        'rating': 4.8,
        'reviews': '2.2k',
        'image': 'assets/images/liver_support.png',
        'mrp': 499.0,
        'selling_price': 399.0,
        'discount_percentage': 20.0,
        'stock_quantity': 100,
        'min_order_quantity': 10,
        'is_available': true,
      },
      {
        'id': 2,
        'name': 'Non-Drowsy Cold Flu Relief',
        'category': 'Medicine',
        'rating': 4.6,
        'reviews': '2.2k',
        'image': 'assets/images/daytime.png',
        'mrp': 299.0,
        'selling_price': 249.0,
        'discount_percentage': 16.0,
        'stock_quantity': 150,
        'min_order_quantity': 5,
        'is_available': true,
      },
      {
        'id': 3,
        'name': 'Vitamin C 1000mg Tablets',
        'category': 'Vitamins',
        'rating': 4.7,
        'reviews': '1.8k',
        'image': 'assets/images/vitamin_c.png',
        'mrp': 599.0,
        'selling_price': 449.0,
        'discount_percentage': 25.0,
        'stock_quantity': 200,
        'min_order_quantity': 10,
        'is_available': true,
      },
      {
        'id': 4,
        'name': 'Hand Sanitizer Gel',
        'category': 'Personal Care',
        'rating': 4.5,
        'reviews': '1.5k',
        'image': 'assets/images/sanitizer.png',
        'mrp': 199.0,
        'selling_price': 149.0,
        'discount_percentage': 25.0,
        'stock_quantity': 300,
        'min_order_quantity': 20,
        'is_available': true,
      },
    ];
  }

  // ========== UTILITY METHODS ==========

  // Format price
  String formatPrice(double price) {
    return '₹${price.toStringAsFixed(2)}';
  }

  // Calculate discount amount
  double calculateDiscount(double mrp, double sellingPrice) {
    return mrp - sellingPrice;
  }

  // Get formatted discount percentage
  String getDiscountText(double discountPercentage) {
    return '${discountPercentage.toStringAsFixed(0)}% OFF';
  }
}