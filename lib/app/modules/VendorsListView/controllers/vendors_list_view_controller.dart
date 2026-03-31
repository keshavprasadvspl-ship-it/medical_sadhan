import 'package:get/get.dart';
import 'package:medical_b2b_app/app/data/providers/api_endpoints.dart';
import '../../../data/providers/api_provider.dart';

class VendorsListViewController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // Observable variables
  final vendors = <Map<String, dynamic>>[].obs;
  final filteredVendors = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Search and filter
  final searchQuery = ''.obs;
  final selectedFilter = 'All'.obs;
  final filterOptions = ['All', 'Wholesaler', 'Retailer', 'Manufacturer', 'Distributor'].obs;

  // Pagination
  final currentPage = 1.obs;
  final lastPage = 1.obs;
  final totalVendors = 0.obs;
  final hasMoreData = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadVendors();
  }

  // Load vendors from API
  Future<void> loadVendors({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        vendors.clear();
      }

      isLoading.value = true;
      errorMessage.value = '';

      final response = await _apiService.getVendors(

      );

      print("Vendors API Response: $response");

      if (response.isNotEmpty) {
        if (refresh) {
          vendors.value = response.cast<Map<String, dynamic>>();
        } else {
          vendors.addAll(response.cast<Map<String, dynamic>>());
        }

        // Update pagination info if available in response
        // You'll need to adjust this based on your API response structure
        // hasMoreData.value = response.length >= 20;

        applyFilters();
      } else {
        if (refresh) {
          vendors.value = [];
        }
        hasMoreData.value = false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load vendors: $e';
      print('Error loading vendors: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Load more vendors for pagination
  Future<void> loadMoreVendors() async {
    if (!hasMoreData.value || isLoading.value) return;

    currentPage.value++;
    await loadVendors();
  }

  // Apply search and filter
  void applyFilters() {
    if (vendors.isEmpty) {
      filteredVendors.value = [];
      return;
    }

    var results = vendors.where((vendor) {
      final name = getVendorName(vendor).toLowerCase();
      final category = getVendorCategory(vendor).toLowerCase();
      final businessType = (vendor['business_type'] as String? ?? '').toLowerCase();
      final contactPerson = (vendor['contact_person'] as String? ?? '').toLowerCase();
      final gstNumber = (vendor['gst_number'] as String? ?? '').toLowerCase();

      // Apply search filter
      final matchesSearch = searchQuery.value.isEmpty ||
          name.contains(searchQuery.value.toLowerCase()) ||
          category.contains(searchQuery.value.toLowerCase()) ||
          businessType.contains(searchQuery.value.toLowerCase()) ||
          contactPerson.contains(searchQuery.value.toLowerCase()) ||
          gstNumber.contains(searchQuery.value.toLowerCase());

      // Apply business type filter
      final matchesFilter = selectedFilter.value == 'All' ||
          businessType == selectedFilter.value.toLowerCase();

      return matchesSearch && matchesFilter;
    }).toList();

    filteredVendors.value = results;
  }

  // Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  // Update selected filter
  void updateFilter(String filter) {
    selectedFilter.value = filter;
    applyFilters();
  }

  // Clear search
  void clearSearch() {
    searchQuery.value = '';
    applyFilters();
  }

  // Refresh vendors
  Future<void> refreshVendors() async {
    await loadVendors(refresh: true);
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

  // Get vendor average monthly sales (formatted)
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

  // Get vendor designation
  String getVendorDesignation(Map<String, dynamic> vendor) {
    return vendor['designation'] as String? ?? '';
  }

  // Get vendor notes
  String getVendorNotes(Map<String, dynamic> vendor) {
    return vendor['notes'] as String? ?? '';
  }

  // Format date
  String getVendorCreatedDate(Map<String, dynamic> vendor) {
    final dateStr = vendor['created_at'] as String?;
    if (dateStr == null) return '';

    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '';
    }
  }
}