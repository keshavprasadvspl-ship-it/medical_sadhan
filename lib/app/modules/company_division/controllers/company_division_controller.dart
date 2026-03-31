import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/providers/api_provider.dart';
import '../../../routes/app_pages.dart';

class CompanyDivisionController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // State variables
  final divisions = <Map<String, dynamic>>[].obs;
  final filteredDivisions = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final searchQuery = ''.obs;

  // Pagination
  final currentPage = 1.obs;
  final lastPage = 1.obs;
  final totalDivisions = 0.obs;
  final hasMoreData = false.obs;

  // Selected filter
  var selectedFilter = 'All'.obs;

  // Company filter properties
  var selectedCompanyId = Rxn<int>();
  var selectedCompanyName = ''.obs;
  var selectedCompanyData = Rxn<Map<String, dynamic>>();
  var isCompanyFiltered = false.obs;

  // Vendor filter properties (if needed)
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
      final companyData = arguments['companyData'];
      final filterType = arguments['filterType'];
print('companyId');
print(companyId);
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

        setVendorCompanyFilter(
          parsedVendorId,
          vendorName,
          parsedCompanyId,
          companyName,
          companyData: companyData,
        );
      } else if (companyId != null && filterType == 'company') {
        // Just Company filter
        int? parsedCompanyId;
        if (companyId is String) {
          parsedCompanyId = int.tryParse(companyId);
        } else if (companyId is int) {
          parsedCompanyId = companyId;
        }

        setCompanyFilter(
          parsedCompanyId,
          companyName,
          companyData: companyData,
        );
      } else {
        loadDivisions();
      }
    } else {
      loadDivisions();
    }
  }

  // Set company filter
  void setCompanyFilter(int? companyId, String? companyName, {Map<String, dynamic>? companyData}) {
    selectedCompanyId.value = companyId;
    selectedCompanyName.value = companyName ?? '';
    selectedCompanyData.value = companyData;
    isCompanyFiltered.value = companyId != null;

    // Reset vendor filter
    isVendorFiltered.value = false;
    selectedVendorId.value = null;
    selectedVendorName.value = '';

    // Reset pagination
    currentPage.value = 1;

    // Load divisions for this company
    loadDivisions(reset: true);
  }

  // Set vendor + company filter
  void setVendorCompanyFilter(
      int? vendorId,
      String? vendorName,
      int? companyId,
      String? companyName, {
        Map<String, dynamic>? companyData,
      }) {
    selectedVendorId.value = vendorId;
    selectedVendorName.value = vendorName ?? '';
    isVendorFiltered.value = vendorId != null;

    selectedCompanyId.value = companyId;
    selectedCompanyName.value = companyName ?? '';
    selectedCompanyData.value = companyData;
    isCompanyFiltered.value = companyId != null;

    // Reset pagination
    currentPage.value = 1;

    // Load divisions for this company
    loadDivisions(reset: true);
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
      filtered = List.from(divisions);
    } else {
      filtered = divisions.where((division) {
        final name = (division['name'] as String? ?? '').toLowerCase();
        final description = (division['description'] as String? ?? '').toLowerCase();
        final companyName = (division['company_name'] as String? ?? '').toLowerCase();

        return name.contains(query.toLowerCase()) ||
            description.contains(query.toLowerCase()) ||
            companyName.contains(query.toLowerCase());
      }).toList();
    }

    // Then filter by status
    if (selectedFilter.value == 'Active') {
      filtered = filtered.where((div) => div['is_active'] == true).toList();
    } else if (selectedFilter.value == 'Inactive') {
      filtered = filtered.where((div) => div['is_active'] == false).toList();
    }

    filteredDivisions.value = filtered;
  }

  // Filter divisions by search query
  void filterDivisions(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  // Load divisions based on selected company
  Future<void> loadDivisions({bool reset = false}) async {
    try {
      if (reset) {
        divisions.clear();
        currentPage.value = 1;
      }

      isLoading.value = true;
      errorMessage.value = '';

      // If company is selected, fetch divisions for that company
      if (selectedCompanyId.value != null) {
        final result = await _apiService.getCompanyDivisions(
          page: currentPage.value, companyId: selectedCompanyId.value!, token: '',
        );

        if (result['success'] == true) {
          final data = result['data'];
          final List<dynamic> divisionList = data['data'] ?? [];

          if (reset) {
            divisions.value = List<Map<String, dynamic>>.from(divisionList);
          } else {
            divisions.addAll(List<Map<String, dynamic>>.from(divisionList));
          }

          // Update pagination info
          lastPage.value = data['last_page'] ?? 1;
          totalDivisions.value = data['total'] ?? 0;
          hasMoreData.value = currentPage.value < lastPage.value;

          // Store company info if available
          if (result['company'] != null) {
            selectedCompanyData.value = result['company'];
          }
        } else {
          if (divisions.isEmpty) {
            divisions.value = _getDefaultDivisions();
          }
        }
      } else {
        // If no company selected, maybe show message or load all divisions
        // You can implement an endpoint to get all divisions if available
        if (divisions.isEmpty) {
          divisions.value = _getDefaultDivisions();
        }
      }

      // Apply current filters
      applyFilters();

    } catch (e) {
      errorMessage.value = 'Failed to load divisions: $e';
      if (divisions.isEmpty) {
        divisions.value = _getDefaultDivisions();
        applyFilters();
      }

      Get.snackbar(
        'Error',
        'Failed to load divisions. Please try again.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load more divisions (pagination)
  Future<void> loadMoreDivisions() async {
    if (!hasMoreData.value || isLoading.value) return;

    currentPage.value++;
    await loadDivisions();
  }

  // Get default divisions (fallback when API fails)
  List<Map<String, dynamic>> _getDefaultDivisions() {
    return [
      {
        'id': 1,
        'company_id': selectedCompanyId.value ?? 1,
        'company_name': selectedCompanyName.value ?? 'Company Name',
        'name': 'Marketing Division',
        'image': null,
        'image_url': null,
        'description': 'Marketing and sales department',
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 2,
        'company_id': selectedCompanyId.value ?? 1,
        'company_name': selectedCompanyName.value ?? 'Company Name',
        'name': 'Research & Development',
        'image': null,
        'image_url': null,
        'description': 'New product development',
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 3,
        'company_id': selectedCompanyId.value ?? 1,
        'company_name': selectedCompanyName.value ?? 'Company Name',
        'name': 'Quality Control',
        'image': null,
        'image_url': null,
        'description': 'Quality assurance',
        'is_active': false,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
    ];
  }

  // Refresh divisions
  Future<void> refreshDivisions() async {
    await loadDivisions(reset: true);
  }

  // Get division icon based on name
  String getDivisionIcon(Map<String, dynamic> division) {
    final name = (division['name'] as String? ?? '').toLowerCase();

    if (name.contains('marketing') || name.contains('sales')) return '📊';
    if (name.contains('research') || name.contains('development') || name.contains('r&d')) return '🔬';
    if (name.contains('quality') || name.contains('assurance') || name.contains('control')) return '✅';
    if (name.contains('production') || name.contains('manufacturing')) return '🏭';
    if (name.contains('finance') || name.contains('accounting')) return '💰';
    if (name.contains('human') || name.contains('resource') || name.contains('hr')) return '👥';
    if (name.contains('information') || name.contains('technology') || name.contains('it')) return '💻';
    if (name.contains('customer') || name.contains('support')) return '🤝';
    if (name.contains('logistics') || name.contains('supply')) return '🚚';
    if (name.contains('legal') || name.contains('compliance')) return '⚖️';
    if (name.contains('pharma') || name.contains('medical')) return '💊';
    if (name.contains('device') || name.contains('equipment')) return '🩺';

    return '🏢';
  }

  // Navigate to division products
  void navigateToDivisionProducts(Map<String, dynamic> division) {
    if (isVendorFiltered.value && isCompanyFiltered.value) {
      // Vendor + Company + Division
      Get.toNamed(
        Routes.VENDOR_PRODUCT_STORE,
        arguments: {
          'vendor_id': selectedVendorId.value,
          'vendor_name': selectedVendorName.value,
          'companyId': selectedCompanyId.value,
          'company': selectedCompanyName.value,
          'companyData': selectedCompanyData.value,
          'division': division['name'],
          'divisionId': division['id'],
          'filterType': 'vendor_company_division',
        },
      );
    } else if (isCompanyFiltered.value) {
      // Company + Division
      Get.toNamed(
        Routes.PRODUCTS,
        arguments: {
          'company': selectedCompanyName.value,
          'companyId': selectedCompanyId.value,
          'companyData': selectedCompanyData.value,
          'division': division['name'],
          'divisionId': division['id'],
          'filterType': 'company_division',
        },
      );
    } else {
      // Just Division
      Get.toNamed(
        Routes.PRODUCTS,
        arguments: {
          'division': division['name'],
          'divisionId': division['id'],
          'filterType': 'division',
        },
      );
    }
  }
}