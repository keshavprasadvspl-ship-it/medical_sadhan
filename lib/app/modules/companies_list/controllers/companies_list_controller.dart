// lib/app/modules/companies/controllers/companies_list_view_controller.dart

import 'package:get/get.dart';
import '../../../data/models/company_model.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/providers/api_endpoints.dart';
import '../../../routes/app_pages.dart';

class CompaniesListViewController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // Observable variables
  final companies = <CompanyModel>[].obs;
  final filteredCompanies = <CompanyModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Search
  final searchQuery = ''.obs;

  // ADD THESE: Vendor filter properties
  final selectedVendorId = Rxn<int>();
  final selectedVendorName = ''.obs;
  final isVendorFiltered = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Check if we have vendor arguments
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      final vendorId = arguments['vendorId'];
      final vendorName = arguments['vendorName'];
      final filterType = arguments['filterType'];

      if (vendorId != null && filterType == 'vendor') {
        // Parse vendorId to int if it's a string
        int? parsedVendorId;
        if (vendorId is String) {
          parsedVendorId = int.tryParse(vendorId);
        } else if (vendorId is int) {
          parsedVendorId = vendorId;
        }

        setVendorFilter(parsedVendorId, vendorName);
      } else {
        loadCompanies();
      }
    } else {
      loadCompanies();
    }
  }

  // ADD THIS: Set vendor filter
  void setVendorFilter(int? vendorId, String? vendorName) {
    selectedVendorId.value = vendorId;
    selectedVendorName.value = vendorName ?? '';
    isVendorFiltered.value = vendorId != null;

    // Load all companies (filtering happens when navigating to categories)
    loadCompanies();
  }

  // MODIFY: Update the navigation method to pass vendor filter to categories
  void navigateToCompanyProducts(CompanyModel company) {
    print(
        "➡️ Navigating to categories for company: ${company.name} (ID: ${company.id})");

    Map<String, dynamic> arguments = {};

    if (isVendorFiltered.value) {
      // If we came from a vendor, pass both vendor and company filters
      arguments = {
        'vendorId': selectedVendorId.value,
        'vendorName': selectedVendorName.value,
        'companyId': company.id,
        'companyName': company.name,
        'companyData':  company.toJson(),
        'filterType': 'vendor_company',
      };
      print("   With vendor filter: ${selectedVendorName.value}");
    } else {
      arguments = {
        'companyId': company.id,
        'companyName': company.name,
        'companyData':  company.toJson(),
        'filterType': 'company',
      };
    }

    Get.toNamed(
      Routes.COMPANY_DIVISION,
      arguments: arguments,
    );
  }

  // ... rest of your existing methods (loadCompanies, applyFilters, etc.) remain exactly the same ...

  // Load companies from API
  Future<void> loadCompanies({bool refresh = false}) async {
    try {
      if (refresh) {
        companies.clear();
      }

      isLoading.value = true;
      errorMessage.value = '';

      print("=" * 50);
      print("LOADING COMPANIES - ${refresh ? 'REFRESH' : 'INITIAL'}");
      if (isVendorFiltered.value) {
        print(
            "VENDOR FILTER: ${selectedVendorName.value} (ID: ${selectedVendorId.value})");
      }
      print("=" * 50);

      final response = await _apiService.getCompanies();

      print("Companies API Response received");
      print("Response type: ${response.runtimeType}");
      print("Response length: ${response.length}");

      if (response.isNotEmpty) {
        print("First item sample: ${response.first}");
      }

      if (response.isNotEmpty) {
        final companyList = <CompanyModel>[];
        int successCount = 0;
        int errorCount = 0;

        for (var json in response) {
          print("Processing company JSON: $json");
          try {
            final company = CompanyModel.fromJson(json);
            companyList.add(company);
            successCount++;
            print(
                "✅ Successfully parsed company: ${company.name} (ID: ${company.id})");
          } catch (e) {
            errorCount++;
            print("❌ Error parsing company: $e");
            print("   Problem JSON: $json");
          }
        }

        print("📊 Parsing Summary:");
        print("   Total companies: ${response.length}");
        print("   Successfully parsed: $successCount");
        print("   Failed to parse: $errorCount");

        if (refresh) {
          companies.value = companyList;
        } else {
          companies.assignAll(companyList);
        }

        print(
            "📦 Companies observable length after assign: ${companies.length}");
        applyFilters();
      } else {
        print("⚠️ Response is empty");
        if (refresh) {
          companies.value = [];
        }
      }
    } catch (e) {
      errorMessage.value = 'Failed to load companies: $e';
      print('🔥 Error loading companies: $e');
    } finally {
      isLoading.value = false;
      print("✅ Loading completed. Companies count: ${companies.length}");
      print("   Filtered companies count: ${filteredCompanies.length}");
    }
  }

  // Apply search filter
  void applyFilters() {
    print("-" * 30);
    print("🔍 APPLYING FILTERS");
    print("   Companies list length: ${companies.length}");
    print("   Search query: '${searchQuery.value}'");

    if (companies.isEmpty) {
      print("   Companies list is empty, no filters applied");
      filteredCompanies.value = [];
      return;
    }

    var results = companies.where((company) {
      final name = company.name.toLowerCase();
      final matchesSearch = searchQuery.value.isEmpty ||
          name.contains(searchQuery.value.toLowerCase());
      final isActive = company.isActive;

      if (matchesSearch && isActive) {
        print(company);
        print("   ✅ Including company: ${company}");
      }

      return matchesSearch && isActive;
    }).toList();

    print("   Filtered companies count: ${results.length}");
    filteredCompanies.value = results;
    print("-" * 30);
  }

  // Update search query
  void updateSearchQuery(String query) {
    print("🔎 Search query updated to: '$query'");
    searchQuery.value = query;
    applyFilters();
  }

  // Clear search
  void clearSearch() {
    print("🧹 Clearing search");
    searchQuery.value = '';
    applyFilters();
  }

  // Refresh companies
  Future<void> refreshCompanies() async {
    print("🔄 Refreshing companies");
    await loadCompanies(refresh: true);
  }

  // Get company type display name
  String getCompanyTypeDisplay(String? type) {
    if (type == null || type.isEmpty) return 'Pharmaceutical Company';

    switch (type.toLowerCase()) {
      case 'pharma':
        return 'Pharmaceutical';
      case 'distributor':
        return 'Distributor';
      case 'manufacturer':
        return 'Manufacturer';
      default:
        return type.capitalizeFirst ?? type;
    }
  }
}
