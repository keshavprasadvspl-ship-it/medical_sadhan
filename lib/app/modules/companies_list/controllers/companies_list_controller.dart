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

  // Vendor filter properties
  final selectedVendorId = Rxn<int>();
  final selectedVendorName = ''.obs;
  final isVendorFiltered = false.obs;

  // Category filter properties
  final categories = <String>[].obs;
  final selectedCategory = Rxn<String>();
  final availableCategories = <String>[].obs;

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

  void setVendorFilter(int? vendorId, String? vendorName) {
    selectedVendorId.value = vendorId;
    selectedVendorName.value = vendorName ?? '';
    isVendorFiltered.value = vendorId != null;

    loadCompanies();
  }

  void navigateToCompanyProducts(CompanyModel company) {
    print(
        "➡️ Navigating to categories for company: ${company.name} (ID: ${company.id})");

    Map<String, dynamic> arguments = {};

    if (isVendorFiltered.value) {
      arguments = {
        'vendorId': selectedVendorId.value,
        'vendorName': selectedVendorName.value,
        'companyId': company.id,
        'companyName': company.name,
        'companyData': company.toJson(),
        'filterType': 'vendor_company',
      };
      print("   With vendor filter: ${selectedVendorName.value}");
    } else {
      arguments = {
        'companyId': company.id,
        'companyName': company.name,
        'companyData': company.toJson(),
        'filterType': 'company',
      };
    }

    Get.toNamed(
      Routes.COMPANY_DIVISION,
      arguments: arguments,
    );
  }

  // Load companies from API
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
        print("VENDOR FILTER: ${selectedVendorName.value} (ID: ${selectedVendorId.value})");
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

        // Set to collect unique categories
        final categorySet = <String>{};

        // Debug: Track companies with categories
        int companiesWithCategories = 0;
        int totalCategoriesFound = 0;

        for (var json in response) {
          print("Processing company JSON: $json");
          try {
            final company = CompanyModel.fromJson(json);
            companyList.add(company);
            successCount++;

            // Debug: Print categories for this company
            print("Company: ${company.name}");
            print("  Categories count: ${company.categories.length}");
            print("  Categories found: ${company.categories.map((c) => c.name).join(', ')}");

            // FIX: Properly collect categories
            if (company.categories.isNotEmpty) {
              companiesWithCategories++; // Increment counter
              for (var category in company.categories) {
                if (category.name.trim().isNotEmpty) {
                  categorySet.add(category.name.trim());
                  totalCategoriesFound++; // Increment total categories counter
                }
              }
            } else {
              print("  No categories found for this company");
            }

            print("✅ Successfully parsed company: ${company.name} (ID: ${company.id})");
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
        print("   Companies with categories: $companiesWithCategories");
        print("   Total categories found: $totalCategoriesFound");
        print("   Unique categories in set: ${categorySet.length}");

        // Update available categories
        final categoryList = categorySet.toList()..sort();
        availableCategories.value = categoryList;
        print("📋 Available categories (${availableCategories.length}):");
        for (var cat in availableCategories) {
          print("   - $cat");
        }

        if (availableCategories.isEmpty) {
          print("⚠️ WARNING: No categories found in any company!");
        }

        if (refresh) {
          companies.value = companyList;
        } else {
          companies.assignAll(companyList);
        }

        print("📦 Companies observable length after assign: ${companies.length}");
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
      print("   Available categories count: ${availableCategories.length}");
    }
  }

  // Apply search and category filters
  void applyFilters() {
    print("-" * 30);
    print("🔍 APPLYING FILTERS");
    print("   Companies list length: ${companies.length}");
    print("   Search query: '${searchQuery.value}'");
    print("   Selected category: '${selectedCategory.value}'");
    print("   Available categories: ${availableCategories.length}");

    if (companies.isEmpty) {
      print("   Companies list is empty, no filters applied");
      filteredCompanies.value = [];
      return;
    }

    var results = companies.where((company) {
      // Search filter
      final name = company.name.toLowerCase();
      final matchesSearch = searchQuery.value.isEmpty ||
          name.contains(searchQuery.value.toLowerCase());

      // Category filter
      bool matchesCategory = true;
      if (selectedCategory.value != null && selectedCategory.value!.isNotEmpty) {
        matchesCategory = company.categories.any(
                (category) =>
            category.name.trim().toUpperCase() ==
                selectedCategory.value?.trim().toUpperCase()
        );
        if (matchesCategory) {
          print("   Company '${company.name}' matches category '${selectedCategory.value}'");
        }
      }

      final isActive = company.isActive;

      return matchesSearch && matchesCategory && isActive;
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

  // Update selected category
  void updateSelectedCategory(String? category) {
    print("🏷️ Selected category updated to: '$category'");
    selectedCategory.value = category;
    applyFilters();
  }

  // Clear category filter
  void clearCategoryFilter() {
    print("🧹 Clearing category filter");
    selectedCategory.value = null;
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