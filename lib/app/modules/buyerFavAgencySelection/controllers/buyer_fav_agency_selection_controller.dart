import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:medical_b2b_app/app/data/providers/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/providers/api_provider.dart';

class BuyerFavAgencySelectionController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final GetStorage _storage = GetStorage();

  // Observable variables
  final agencies = <Map<String, dynamic>>[].obs;
  final filteredAgencies = <Map<String, dynamic>>[].obs;
  final selectedAgencies = <String>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final isSaving = false.obs;
  final userId = 0.obs;

  // Search and filter
  final searchQuery = ''.obs;
  final selectedFilter = 'All'.obs;
  final filterOptions = ['All', 'Wholesaler', 'Retailer', 'Manufacturer', 'Distributor'].obs;

  // Pagination
  final currentPage = 1.obs;
  final hasMoreData = true.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {

      // Load user data from prefs
      final userData = json.decode(userDataString);
      userId.value = userData['id'] ?? 0;

      await loadAgencies();
      await  loadSelectedAgencies();
    }


  }

  // Load agencies from API
  Future<void> loadAgencies({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        agencies.clear();
      }

      isLoading.value = true;
      errorMessage.value = '';

      final response = await _apiService.getVendors();

      print("Agencies API Response: $response");

      if (response.isNotEmpty) {
        if (refresh) {
          agencies.value = response.cast<Map<String, dynamic>>();
        } else {
          agencies.addAll(response.cast<Map<String, dynamic>>());
        }

        applyFilters();
      } else {
        if (refresh) {
          agencies.value = [];
        }
        hasMoreData.value = false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load agencies: $e';
      print('Error loading agencies: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Load previously selected agencies from API
  Future<void> loadSelectedAgencies() async {
    try {
      final response = await _apiService.getFavoriteAgencies("${userId.value}");

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> favoriteIds = response['data'];
        selectedAgencies.value = favoriteIds.map((id) => id.toString()).toList();
        print('Loaded ${selectedAgencies.length} favorite agencies');
        print('Selected IDs: ${selectedAgencies.join(", ")}');
      } else {
        // Try to load from local storage as fallback
        _loadSelectedAgenciesFromLocal();
      }
    } catch (e) {
      print('Error loading selected agencies: $e');
      _loadSelectedAgenciesFromLocal();
    }
  }

  // Load from local storage
  void _loadSelectedAgenciesFromLocal() {
    final saved = _storage.read<List>('favorite_agencies');
    if (saved != null && saved.isNotEmpty) {
      selectedAgencies.value = saved.map((e) => e.toString()).toList();
      print('Loaded ${selectedAgencies.length} favorites from local storage');
    }
  }

  // Save to local storage
  void _saveSelectedAgenciesToLocal() {
    _storage.write('favorite_agencies', selectedAgencies.toList());
  }

  // Save selected agencies to server
  Future<void> saveSelectedAgencies() async {
    if (isSaving.value) return;

    try {
      isSaving.value = true;

      final response = await _apiService.saveFavoriteAgencies("${userId.value}",selectedAgencies);

      if (response['success'] == true) {
        // Save to local storage
        _saveSelectedAgenciesToLocal();

        await Get.offAllNamed('/main');
        Get.snackbar(
          'Success',
          '${selectedAgencies.length} agencies selected successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      } else {
        throw Exception(response['message'] ?? 'Failed to save');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save selected agencies: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  // Toggle agency selection
  void toggleAgencySelection(String agencyId) {
    if (selectedAgencies.contains(agencyId)) {
      selectedAgencies.remove(agencyId);
      _showSnackbar('Removed', 'Agency removed from favorites', Colors.orange);
    } else {
      selectedAgencies.add(agencyId);
      _showSnackbar('Added', 'Agency added to favorites', Colors.green);
    }
  }

  // Check if agency is selected
  bool isAgencySelected(String agencyId) {
    return selectedAgencies.contains(agencyId);
  }

  // Apply search and filter
  void applyFilters() {
    if (agencies.isEmpty) {
      filteredAgencies.value = [];
      return;
    }

    var results = agencies.where((agency) {
      final name = getAgencyName(agency).toLowerCase();
      final category = getAgencyCategory(agency).toLowerCase();
      final businessType = (agency['business_type'] as String? ?? '').toLowerCase();
      final contactPerson = (agency['contact_person'] as String? ?? '').toLowerCase();
      final gstNumber = (agency['gst_number'] as String? ?? '').toLowerCase();

      final matchesSearch = searchQuery.value.isEmpty ||
          name.contains(searchQuery.value.toLowerCase()) ||
          category.contains(searchQuery.value.toLowerCase()) ||
          businessType.contains(searchQuery.value.toLowerCase()) ||
          contactPerson.contains(searchQuery.value.toLowerCase()) ||
          gstNumber.contains(searchQuery.value.toLowerCase());

      final matchesFilter = selectedFilter.value == 'All' ||
          businessType == selectedFilter.value.toLowerCase();

      return matchesSearch && matchesFilter;
    }).toList();

    filteredAgencies.value = results;
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

  // Refresh agencies
  Future<void> refreshAgencies() async {
    await Future.wait([
      loadAgencies(refresh: true),
      loadSelectedAgencies()
    ]);
  }

  // Select all agencies on current page
  void selectAllOnPage() {
    int addedCount = 0;
    for (var agency in filteredAgencies) {
      final agencyId = getAgencyId(agency);
      if (!selectedAgencies.contains(agencyId)) {
        selectedAgencies.add(agencyId);
        addedCount++;
      }
    }
    if (addedCount > 0) {
      _showSnackbar('Added', '$addedCount agencies added', Colors.green);
    }
  }

  // Clear all selections
  void clearAllSelections() {
    int removedCount = selectedAgencies.length;
    selectedAgencies.clear();
    if (removedCount > 0) {
      _showSnackbar('Cleared', 'All $removedCount agencies removed', Colors.orange);
    }
  }

  // Check if all agencies on current page are selected
  bool isAllSelectedOnPage() {
    if (filteredAgencies.isEmpty) return false;
    for (var agency in filteredAgencies) {
      if (!selectedAgencies.contains(getAgencyId(agency))) {
        return false;
      }
    }
    return true;
  }

  // Toggle select all on current page
  void toggleSelectAllOnPage() {
    if (isAllSelectedOnPage()) {
      for (var agency in filteredAgencies) {
        final agencyId = getAgencyId(agency);
        selectedAgencies.remove(agencyId);
      }
      _showSnackbar('Updated', 'Deselected all agencies on this page', Colors.orange);
    } else {
      selectAllOnPage();
    }
  }

  // Get total selected count
  int getSelectedCount() {
    return selectedAgencies.length;
  }

  // Show snackbar helper
  void _showSnackbar(String title, String message, Color color) {
    Get.snackbar(
      title,
      message,
      backgroundColor: color,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
      margin: const EdgeInsets.all(10),
    );
  }

  // ========== AGENCY HELPER METHODS ==========

  String getAgencyId(Map<String, dynamic> agency) {
    if (agency['user_details'] != null && agency['user_details']['id'] != null) {
      return agency['user_details']['id'].toString();
    }
    return agency['id']?.toString() ?? '';
  }

  String getAgencyLogoUrl(Map<String, dynamic> agency) {
    final logoUrl = agency['logo_url'] as String?;

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

  String getAgencyName(Map<String, dynamic> agency) {
    if (agency['business_name'] != null && agency['business_name'].toString().isNotEmpty) {
      return agency['business_name'].toString();
    }

    if (agency['user_details'] != null && agency['user_details']['name'] != null) {
      return agency['user_details']['name'].toString();
    }

    return 'Unknown Agency';
  }

  bool isAgencyActive(Map<String, dynamic> agency) {
    if (agency['user_details'] != null && agency['user_details']['is_active'] != null) {
      return agency['user_details']['is_active'] as bool;
    }
    return true;
  }

  bool isAgencyVerified(Map<String, dynamic> agency) {
    if (agency['user_details'] != null && agency['user_details']['is_verified'] != null) {
      return agency['user_details']['is_verified'] as bool;
    }
    return false;
  }

  String getAgencyRating(Map<String, dynamic> agency) {
    final rating = agency['vendor_rating'] as String? ?? '0.00';
    try {
      return double.parse(rating).toStringAsFixed(1);
    } catch (e) {
      return '0.0';
    }
  }

  String getAgencyCategory(Map<String, dynamic> agency) {
    return agency['vendor_category'] as String? ?? 'General';
  }

  String getAgencyBusinessType(Map<String, dynamic> agency) {
    final type = agency['business_type'] as String? ?? '';
    if (type.isNotEmpty) {
      return type[0].toUpperCase() + type.substring(1);
    }
    return '';
  }

  String getAgencyContactPerson(Map<String, dynamic> agency) {
    return agency['contact_person'] as String? ?? '';
  }

  String getAgencyGST(Map<String, dynamic> agency) {
    return agency['gst_number'] as String? ?? '';
  }

  String getAgencyEstYear(Map<String, dynamic> agency) {
    final year = agency['year_of_establishment'];
    if (year != null) {
      return year.toString();
    }
    return '';
  }
}