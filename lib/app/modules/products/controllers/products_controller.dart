import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/product_model.dart';
import '../../../data/providers/api_provider.dart';

class ProductsController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final products = <Product>[].obs;
  final filteredProducts = <Product>[].obs;
  final categories = <String>[].obs;
  final companies = <String>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final selectedCategory = 'All'.obs;
  final selectedCompany = 'All'.obs;
  final selectedSort = 'popular'.obs;
  final minPrice = 0.0.obs;
  final maxPrice = 5000.0.obs;
  final priceRange = 2500.0.obs;
  final searchQuery = ''.obs;
  final showGridView = false.obs;
  final selectedPrescriptionType = 'All'.obs;
  final cartItemCount = 0.obs;
  final errorMessage = ''.obs;
  final hasMoreData = true.obs;
  final currentPage = 1.obs;
  final pageSize = 20.obs;
  final favoriteProducts = <int>[].obs;

  // Additional filter properties for tracking
  final appliedCompanyId = Rxn<int>();
  final appliedCategoryId = Rxn<int>();
  final appliedSubCategoryId = Rxn<int>();
  final filterType = ''.obs;

  // TextEditingController for search
  final searchController = TextEditingController();

  // Prescription types
  final prescriptionTypes = ['All', 'OTC', 'Rx'];

  // Sort options
  final sortOptions = {
    'popular': 'Popular',
    'newest': 'Newest',
    'price_low': 'Price: Low to High',
    'price_high': 'Price: High to Low',
    'rating': 'Highest Rated',
    'discount': 'Best Discount',
  };

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;

    if (args is Map<String, dynamic>) {
      initializeWithArgs(args);
    } else {
      loadProducts();
    }

    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });

    debounce(
      searchQuery,
          (_) {
        currentPage.value = 1;
        loadProducts();
      },
      time: const Duration(milliseconds: 500),
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // Initialize with arguments (for navigation)
// Initialize with arguments (for navigation)
  void initializeWithArgs(Map<String, dynamic>? args) {
    if (args != null) {
      print('Initializing with args: $args');

      // Store filter type
      if (args.containsKey('filterType')) {
        filterType.value = args['filterType'].toString();
      }

      // Handle company filter - check both 'company' and 'companyName'
      if (args.containsKey('company')) {
        selectedCompany.value = args['company'].toString();
        print('Setting company filter from company: ${selectedCompany.value}');
      } else if (args.containsKey('companyName')) {
        selectedCompany.value = args['companyName'].toString();
        print('Setting company filter from companyName: ${selectedCompany.value}');
      }

      if (args.containsKey('companyId')) {
        final companyId = args['companyId'];
        if (companyId is int) {
          appliedCompanyId.value = companyId;
        } else if (companyId is String) {
          appliedCompanyId.value = int.tryParse(companyId);
        }
      }

      // Handle category filter
      if (args.containsKey('category')) {
        selectedCategory.value = args['category'].toString();
        print('Setting category filter: ${selectedCategory.value}');
      }

      if (args.containsKey('categoryId')) {
        final categoryId = args['categoryId'];
        if (categoryId is int) {
          appliedCategoryId.value = categoryId;
        } else if (categoryId is String) {
          appliedCategoryId.value = int.tryParse(categoryId);
        }
      }

      // Handle subcategory filter
      if (args.containsKey('subCategoryId')) {
        final subCategoryId = args['subCategoryId'];
        if (subCategoryId is int) {
          appliedSubCategoryId.value = subCategoryId;
        } else if (subCategoryId is String) {
          appliedSubCategoryId.value = int.tryParse(subCategoryId);
        }
      }

      // Handle search
      if (args.containsKey('search')) {
        searchController.text = args['search'].toString();
        searchQuery.value = args['search'].toString();
      }

      // Load products after setting filters
      Future.delayed(const Duration(milliseconds: 50), () {
        loadProducts();

        // Show filter applied message
        String filterMessage = '';
        if (selectedCompany.value != 'All' && selectedCategory.value != 'All') {
          filterMessage = 'Showing products from ${selectedCompany.value} in ${selectedCategory.value}';
        } else if (selectedCompany.value != 'All') {
          filterMessage = 'Showing products from ${selectedCompany.value}';
        } else if (selectedCategory.value != 'All') {
          filterMessage = 'Showing products in ${selectedCategory.value}';
        }

        if (filterMessage.isNotEmpty) {
          Get.snackbar(
            'Filters Applied',
            filterMessage,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
            backgroundColor: const Color(0xFF0B630B),
            colorText: Colors.white,
          );
        }
      });
    } else {
      loadProducts();
    }
  }

  Future<void> loadProducts({bool loadMore = false}) async {
    try {
      if (loadMore) {
        if (!hasMoreData.value || isLoadingMore.value) return;
        isLoadingMore.value = true;
        currentPage.value++;
      } else {
        isLoading.value = true;
        currentPage.value = 1;
        products.clear();
        filteredProducts.clear();
      }

      errorMessage.value = '';

      print('Loading products with filters:');
      print('Category: ${selectedCategory.value != 'All' ? selectedCategory.value : 'All'}');
      print('Company: ${selectedCompany.value != 'All' ? selectedCompany.value : 'All'}');
      print('Search: ${searchQuery.value.isNotEmpty ? searchQuery.value : 'None'}');

      final apiProducts = await _apiService.getProducts(
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        category: selectedCategory.value != 'All' ? selectedCategory.value : null,
        company: selectedCompany.value != 'All' ? selectedCompany.value : null,
        page: currentPage.value,
        limit: pageSize.value,
      );

      print('API returned ${apiProducts.length} products');

      if (apiProducts.isEmpty) {
        hasMoreData.value = false;
        if (!loadMore) {
          if (products.isEmpty) {
            await _loadFallbackProducts();
          }
        }
      } else {
        if (loadMore) {
          products.addAll(apiProducts);
        } else {
          products.assignAll(apiProducts);
        }
        hasMoreData.value = apiProducts.length == pageSize.value;

        _extractFilters();
        filterProducts();
      }
    } catch (e) {
      errorMessage.value = 'Failed to load products: $e';
      print('Error loading products: $e');

      if (!loadMore && products.isEmpty) {
        await _loadFallbackProducts();
      }

      Get.snackbar(
        'Error',
        'Failed to load products. ${loadMore ? '' : 'Showing fallback data.'}',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

// Fallback products if API fails
Future<void> _loadFallbackProducts() async {
  final sampleProducts = [
    Product(
      id: 1,
      name: 'Azithromycin 500mg Tablet',
      genericName: 'Azithromycin',
      company: Company(id: 1, name: 'Cipla'),
      category: Category(id: 1, name: 'Antibiotics'),
      subCategory: SubCategory(id: 1, name: 'Tablets'),
      saltComposition: SaltComposition(id: 1, name: 'Azithromycin Dihydrate'),
      power: '500mg',
      unit: Unit(id: 1, name: 'Tablet'),
      hsnCode: '3004',
      gstPercentage: 12.0,
      description: 'Used to treat bacterial infections',
      sideEffects: 'Nausea, diarrhea',
      storageInstructions: 'Store in cool dry place',
      isPrescriptionRequired: true,
      isActive: true,
      attributes: 'NA',
      images: ['https://cdn-icons-png.flaticon.com/512/2731/2731826.png'],
      price: 120.00,
      discountPrice: 99.00,
      stock: 50,
      rating: 4.3,
      ratingCount: 245,
      brand: 'Cipla',
      manufacturer: 'Cipla Ltd',
      // New fields
      mrpPrice: '150.00',
      discountMin: 30,
      discountMax: 40,
      discountPercent: 20,
      vendorProducts: [], // Empty list for fallback
    ),
    Product(
      id: 2,
      name: 'Paracetamol 650mg Tablet',
      genericName: 'Paracetamol',
      company: Company(id: 2, name: 'DOLO'),
      category: Category(id: 2, name: 'Pain Relief'),
      subCategory: SubCategory(id: 2, name: 'Tablets'),
      saltComposition: SaltComposition(id: 2, name: 'Paracetamol'),
      power: '650mg',
      unit: Unit(id: 2, name: 'Tablet'),
      hsnCode: '3004',
      gstPercentage: 12.0,
      description: 'Used for fever and pain relief',
      sideEffects: 'Nausea, skin rash',
      storageInstructions: 'Store at room temperature',
      isPrescriptionRequired: false,
      isActive: true,
      attributes: 'NA',
      images: ['https://cdn-icons-png.flaticon.com/512/3103/3103355.png'],
      price: 45.00,
      discountPrice: 38.00,
      stock: 200,
      rating: 4.6,
      ratingCount: 512,
      brand: 'DOLO',
      manufacturer: 'Micro Labs',
      // New fields
      mrpPrice: '55.00',
      discountMin: 25,
      discountMax: 35,
      discountPercent: 15,
      vendorProducts: [],
    ),
    Product(
      id: 3,
      name: 'Vitamin D3 60K IU Capsule',
      genericName: 'Vitamin D3',
      company: Company(id: 3, name: 'HealthVit'),
      category: Category(id: 3, name: 'Supplements'),
      subCategory: SubCategory(id: 3, name: 'Capsules'),
      saltComposition: SaltComposition(id: 3, name: 'Cholecalciferol'),
      power: '60K IU',
      unit: Unit(id: 3, name: 'Capsule'),
      hsnCode: '3004',
      gstPercentage: 12.0,
      description: 'Vitamin D3 supplement for bone health',
      sideEffects: 'No major side effects',
      storageInstructions: 'Store below 30°C',
      isPrescriptionRequired: false,
      isActive: true,
      attributes: 'NA',
      images: ['https://cdn-icons-png.flaticon.com/512/3135/3135744.png'],
      price: 180.00,
      discountPrice: 150.00,
      stock: 75,
      rating: 4.5,
      ratingCount: 328,
      brand: 'HealthVit',
      manufacturer: 'HealthVit Ltd',
      // New fields
      mrpPrice: '220.00',
      discountMin: 25,
      discountMax: 35,
      discountPercent: 18,
      vendorProducts: [],
    ),
    Product(
      id: 4,
      name: 'Amoxicillin 250mg Capsule',
      genericName: 'Amoxicillin',
      company: Company(id: 4, name: 'Alkem'),
      category: Category(id: 4, name: 'Antibiotics'),
      subCategory: SubCategory(id: 4, name: 'Capsules'),
      saltComposition: SaltComposition(id: 4, name: 'Amoxicillin Trihydrate'),
      power: '250mg',
      unit: Unit(id: 4, name: 'Capsule'),
      hsnCode: '3004',
      gstPercentage: 12.0,
      description: 'Broad-spectrum antibiotic',
      sideEffects: 'Diarrhea, nausea',
      storageInstructions: 'Store in cool dry place',
      isPrescriptionRequired: true,
      isActive: true,
      attributes: 'NA',
      images: ['https://cdn-icons-png.flaticon.com/512/2731/2731826.png'],
      price: 85.00,
      discountPrice: 72.00,
      stock: 120,
      rating: 4.2,
      ratingCount: 189,
      brand: 'Alkem',
      manufacturer: 'Alkem Labs',
      // New fields
      mrpPrice: '100.00',
      discountMin: 28,
      discountMax: 35,
      discountPercent: 15,
      vendorProducts: [],
    ),
    Product(
      id: 5,
      name: 'Cetirizine 10mg Tablet',
      genericName: 'Cetirizine',
      company: Company(id: 5, name: 'Cipla'),
      category: Category(id: 5, name: 'Antihistamine'),
      subCategory: SubCategory(id: 5, name: 'Tablets'),
      saltComposition: SaltComposition(id: 5, name: 'Cetirizine Hydrochloride'),
      power: '10mg',
      unit: Unit(id: 5, name: 'Tablet'),
      hsnCode: '3004',
      gstPercentage: 12.0,
      description: 'Used for allergy symptoms',
      sideEffects: 'Drowsiness, dry mouth',
      storageInstructions: 'Store at room temperature',
      isPrescriptionRequired: false,
      isActive: true,
      attributes: 'NA',
      images: ['https://cdn-icons-png.flaticon.com/512/3103/3103355.png'],
      price: 35.00,
      discountPrice: 28.00,
      stock: 300,
      rating: 4.4,
      ratingCount: 423,
      brand: 'Cipla',
      manufacturer: 'Cipla Ltd',
      // New fields
      mrpPrice: '45.00',
      discountMin: 30,
      discountMax: 40,
      discountPercent: 22,
      vendorProducts: [],
    ),
    Product(
      id: 6,
      name: 'Omeprazole 20mg Capsule',
      genericName: 'Omeprazole',
      company: Company(id: 6, name: 'Sun Pharma'),
      category: Category(id: 6, name: 'Gastrointestinal'),
      subCategory: SubCategory(id: 6, name: 'Capsules'),
      saltComposition: SaltComposition(id: 6, name: 'Omeprazole'),
      power: '20mg',
      unit: Unit(id: 6, name: 'Capsule'),
      hsnCode: '3004',
      gstPercentage: 12.0,
      description: 'Treats acidity and heartburn',
      sideEffects: 'Headache, constipation',
      storageInstructions: 'Store in a cool place',
      isPrescriptionRequired: false,
      isActive: true,
      attributes: 'NA',
      images: ['https://cdn-icons-png.flaticon.com/512/2731/2731826.png'],
      price: 65.00,
      discountPrice: 52.00,
      stock: 150,
      rating: 4.3,
      ratingCount: 267,
      brand: 'Sun Pharma',
      manufacturer: 'Sun Pharmaceuticals',
      // New fields
      mrpPrice: '80.00',
      discountMin: 30,
      discountMax: 40,
      discountPercent: 19,
      vendorProducts: [],
    ),
    Product(
      id: 7,
      name: 'Metformin 500mg Tablet',
      genericName: 'Metformin',
      company: Company(id: 7, name: 'USV'),
      category: Category(id: 7, name: 'Diabetes'),
      subCategory: SubCategory(id: 7, name: 'Tablets'),
      saltComposition: SaltComposition(id: 7, name: 'Metformin Hydrochloride'),
      power: '500mg',
      unit: Unit(id: 7, name: 'Tablet'),
      hsnCode: '3004',
      gstPercentage: 12.0,
      description: 'Controls blood sugar levels',
      sideEffects: 'Nausea, diarrhea',
      storageInstructions: 'Store at room temperature',
      isPrescriptionRequired: true,
      isActive: true,
      attributes: 'NA',
      images: ['https://cdn-icons-png.flaticon.com/512/3103/3103355.png'],
      price: 55.00,
      discountPrice: 45.00,
      stock: 180,
      rating: 4.4,
      ratingCount: 356,
      brand: 'USV',
      manufacturer: 'USV Ltd',
      // New fields
      mrpPrice: '70.00',
      discountMin: 28,
      discountMax: 38,
      discountPercent: 21,
      vendorProducts: [],
    ),
    Product(
      id: 8,
      name: 'Aspirin 100mg Tablet',
      genericName: 'Aspirin',
      company: Company(id: 8, name: 'Bayer'),
      category: Category(id: 8, name: 'Pain Relief'),
      subCategory: SubCategory(id: 8, name: 'Tablets'),
      saltComposition: SaltComposition(id: 8, name: 'Acetylsalicylic Acid'),
      power: '100mg',
      unit: Unit(id: 8, name: 'Tablet'),
      hsnCode: '3004',
      gstPercentage: 12.0,
      description: 'Used for pain relief and blood thinning',
      sideEffects: 'Stomach irritation',
      storageInstructions: 'Store in a dry place',
      isPrescriptionRequired: false,
      isActive: true,
      attributes: 'NA',
      images: ['https://cdn-icons-png.flaticon.com/512/2731/2731826.png'],
      price: 25.00,
      discountPrice: 20.00,
      stock: 400,
      rating: 4.5,
      ratingCount: 578,
      brand: 'Bayer',
      manufacturer: 'Bayer Pharmaceuticals',
      // New fields
      mrpPrice: '30.00',
      discountMin: 25,
      discountMax: 35,
      discountPercent: 17,
      vendorProducts: [],
    ),
  ];

  products.assignAll(sampleProducts);
  _extractFilters();
  filterProducts();
}  void _extractFilters() {
    final uniqueCategories = products.map((p) => p.category.name).toSet().toList();
    categories.assignAll(['All', ...uniqueCategories]);

    final uniqueCompanies = products.map((p) => p.company.name).toSet().toList();
    companies.assignAll(['All', ...uniqueCompanies]);

    if (products.isNotEmpty) {
      final prices = products.map((p) => p.price).toList();
      minPrice.value = prices.reduce((a, b) => a < b ? a : b);
      maxPrice.value = prices.reduce((a, b) => a > b ? a : b);
      priceRange.value = maxPrice.value;
    }
  }

  void filterProducts() {
    print('Filtering products...');
    print('Selected category: ${selectedCategory.value}');
    print('Selected company: ${selectedCompany.value}');
    print('Total products before filter: ${products.length}');

    var filtered = [...products];

    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((product) {
        return product.name.toLowerCase().contains(query) ||
            product.genericName.toLowerCase().contains(query) ||
            product.company.name.toLowerCase().contains(query) ||
            product.category.name.toLowerCase().contains(query) ||
            product.saltComposition.name.toLowerCase().contains(query) ||
            product.description.toLowerCase().contains(query);
      }).toList();
    }

    if (selectedCategory.value != 'All') {
      filtered = filtered.where((p) => p.category.name == selectedCategory.value).toList();
    }

    if (selectedCompany.value != 'All') {
      filtered = filtered.where((p) => p.company.name == selectedCompany.value).toList();
    }

    if (selectedPrescriptionType.value != 'All') {
      final prescriptionFilter = selectedPrescriptionType.value == 'Rx';
      filtered = filtered.where((p) => p.isPrescriptionRequired == prescriptionFilter).toList();
    }

    filtered = filtered.where((p) => p.price <= priceRange.value).toList();

    switch (selectedSort.value) {
      case 'newest':
        filtered.sort((a, b) => b.id.compareTo(a.id));
        break;
      case 'price_low':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'discount':
        filtered.sort((a, b) => b.discountPercent.compareTo(a.discountPercent));
        break;
      case 'popular':
      default:
        filtered.sort((a, b) => b.ratingCount.compareTo(a.ratingCount));
        break;
    }

    print('Products after filter: ${filtered.length}');
    filteredProducts.assignAll(filtered);
  }

  void updateCategory(String category) {
    selectedCategory.value = category;
    currentPage.value = 1;
    loadProducts();
  }

  void updateCompany(String company) {
    selectedCompany.value = company;
    currentPage.value = 1;
    loadProducts();
  }

  void updateSort(String sort) {
    selectedSort.value = sort;
    filterProducts();
  }

  void updatePrescriptionType(String type) {
    selectedPrescriptionType.value = type;
    filterProducts();
  }

  void updatePriceRange(double value) {
    priceRange.value = value;
    filterProducts();
  }

  void toggleFavorite(int productId) {
    final index = products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      products[index] = products[index].copyWith(isFavorite: !products[index].isFavorite);
      filterProducts();
    }
  }

  void addToCart(Product product, {int quantity = 1}) {
    cartItemCount.value += quantity;
    Get.snackbar(
      'Added to Cart',
      '${product.name} added to cart',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: const Color(0xFF0B630B),
      colorText: Colors.white,
    );
  }

  void refreshProducts() {
    currentPage.value = 1;
    loadProducts();
  }

  void loadMoreProducts() {
    if (hasMoreData.value && !isLoadingMore.value) {
      loadProducts(loadMore: true);
    }
  }

  void clearFilter(String filterType) {
    switch (filterType) {
      case 'category':
        selectedCategory.value = 'All';
        appliedCategoryId.value = null;
        break;
      case 'company':
        selectedCompany.value = 'All';
        appliedCompanyId.value = null;
        break;
      case 'prescription':
        selectedPrescriptionType.value = 'All';
        break;
      case 'price':
        priceRange.value = maxPrice.value;
        break;
      case 'search':
        searchController.clear();
        break;
    }
    currentPage.value = 1;
    loadProducts();
  }

  void clearAllFilters() {
    selectedCategory.value = 'All';
    selectedCompany.value = 'All';
    selectedPrescriptionType.value = 'All';
    priceRange.value = maxPrice.value;
    searchController.clear();
    appliedCompanyId.value = null;
    appliedCategoryId.value = null;
    appliedSubCategoryId.value = null;
    filterType.value = '';
    currentPage.value = 1;
    loadProducts();
  }

  String get activeFilterDisplay {
    if (selectedCompany.value != 'All' && selectedCategory.value != 'All') {
      return '${selectedCompany.value} > ${selectedCategory.value}';
    } else if (selectedCompany.value != 'All') {
      return 'Company: ${selectedCompany.value}';
    } else if (selectedCategory.value != 'All') {
      return 'Category: ${selectedCategory.value}';
    } else if (searchQuery.value.isNotEmpty) {
      return 'Search: $searchQuery';
    } else {
      return 'All Products';
    }
  }

  int get activeFilterCount {
    int count = 0;
    if (selectedCategory.value != 'All') count++;
    if (selectedCompany.value != 'All') count++;
    if (selectedPrescriptionType.value != 'All') count++;
    if (priceRange.value < maxPrice.value) count++;
    if (searchQuery.value.isNotEmpty) count++;
    return count;
  }

  // Navigate to specific company and category
  void navigateToCompanyCategory(String companyName, String categoryName) {
    selectedCompany.value = companyName;
    selectedCategory.value = categoryName;
    currentPage.value = 1;
    loadProducts();
  }

  // Check if both company and category filters are active
  bool get hasCompanyAndCategoryFilters {
    return selectedCompany.value != 'All' && selectedCategory.value != 'All';
  }

  // Get filter description
  String get filterDescription {
    if (hasCompanyAndCategoryFilters) {
      return 'Showing products from ${selectedCompany.value} in ${selectedCategory.value}';
    } else if (selectedCompany.value != 'All') {
      return 'Showing products from ${selectedCompany.value}';
    } else if (selectedCategory.value != 'All') {
      return 'Showing products in ${selectedCategory.value}';
    } else {
      return 'Showing all products';
    }
  }

  // Price Range Filter Widget
  Widget _buildPriceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Price Range',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Obx(() => Slider(
          value: priceRange.value,
          min: minPrice.value,
          max: maxPrice.value,
          divisions: 10,
          label: '₹${priceRange.value.toStringAsFixed(0)}',
          onChanged: updatePriceRange,
        )),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(() => Text('₹${minPrice.value.toInt()}')),
            Obx(() => Text('₹${maxPrice.value.toInt()}')),
          ],
        ),
        Obx(() => Text(
          'Selected: ₹${priceRange.value.toInt()}',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Color(0xFF0B630B),
          ),
        )),
      ],
    );
  }

  // Category Filter Widget
  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Obx(() => Wrap(
          spacing: 8,
          runSpacing: 4,
          children: categories.map((category) {
            return FilterChip(
              label: Text(category),
              selected: selectedCategory.value == category,
              onSelected: (_) => updateCategory(category),
              backgroundColor: selectedCategory.value == category
                  ? const Color(0xFF0B630B).withOpacity(0.1)
                  : Colors.grey[200],
              selectedColor: const Color(0xFF0B630B).withOpacity(0.2),
              checkmarkColor: const Color(0xFF0B630B),
              labelStyle: TextStyle(
                color: selectedCategory.value == category
                    ? const Color(0xFF0B630B)
                    : Colors.grey[700],
                fontWeight: selectedCategory.value == category
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            );
          }).toList(),
        )),
      ],
    );
  }

  // Company Filter Widget
  Widget _buildCompanyFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Company',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Obx(() => Wrap(
          spacing: 8,
          runSpacing: 4,
          children: companies.map((company) {
            return FilterChip(
              label: Text(company),
              selected: selectedCompany.value == company,
              onSelected: (_) => updateCompany(company),
              backgroundColor: selectedCompany.value == company
                  ? const Color(0xFF111261).withOpacity(0.1)
                  : Colors.grey[200],
              selectedColor: const Color(0xFF111261).withOpacity(0.2),
              checkmarkColor: const Color(0xFF111261),
              labelStyle: TextStyle(
                color: selectedCompany.value == company
                    ? const Color(0xFF111261)
                    : Colors.grey[700],
                fontWeight: selectedCompany.value == company
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            );
          }).toList(),
        )),
      ],
    );
  }

  // Prescription Type Filter Widget
  Widget _buildPrescriptionFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Prescription Type',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Obx(() => Wrap(
          spacing: 8,
          runSpacing: 4,
          children: prescriptionTypes.map((type) {
            return FilterChip(
              label: Text(type),
              selected: selectedPrescriptionType.value == type,
              onSelected: (_) => updatePrescriptionType(type),
              backgroundColor: selectedPrescriptionType.value == type
                  ? const Color(0xFF6B7280).withOpacity(0.1)
                  : Colors.grey[200],
              selectedColor: const Color(0xFF6B7280).withOpacity(0.2),
              checkmarkColor: const Color(0xFF6B7280),
              labelStyle: TextStyle(
                color: selectedPrescriptionType.value == type
                    ? const Color(0xFF6B7280)
                    : Colors.grey[700],
                fontWeight: selectedPrescriptionType.value == type
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            );
          }).toList(),
        )),
      ],
    );
  }

  // Show Filters Dialog
  void showFiltersDialog() {
    Get.dialog(
      AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Filters',
              style: TextStyle(
                color: Color(0xFF111261),
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Color(0xFF111261)),
              onPressed: () => Get.back(),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPriceFilter(),
                const SizedBox(height: 24),
                _buildCategoryFilter(),
                const SizedBox(height: 24),
                _buildCompanyFilter(),
                const SizedBox(height: 24),
                _buildPrescriptionFilter(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    selectedCategory.value = 'All';
                    selectedCompany.value = 'All';
                    selectedPrescriptionType.value = 'All';
                    priceRange.value = maxPrice.value;
                    currentPage.value = 1;
                    loadProducts();
                    Get.back();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF111261),
                    side: const BorderSide(color: Color(0xFF111261)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Reset All'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    currentPage.value = 1;
                    loadProducts();
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B630B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
    );
  }

  // Show Sort Dialog
  void showSortDialog() {
    Get.dialog(
      AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Sort By',
              style: TextStyle(
                color: Color(0xFF111261),
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Color(0xFF111261)),
              onPressed: () => Get.back(),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: sortOptions.entries.map((entry) {
              return Obx(() => RadioListTile(
                title: Text(
                  entry.value,
                  style: TextStyle(
                    color: selectedSort.value == entry.key
                        ? const Color(0xFF0B630B)
                        : const Color(0xFF111261),
                    fontWeight: selectedSort.value == entry.key
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                value: entry.key,
                groupValue: selectedSort.value,
                onChanged: (value) {
                  updateSort(value!);
                  Get.back();
                },
                activeColor: const Color(0xFF0B630B),
                contentPadding: EdgeInsets.zero,
              ));
            }).toList(),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
    );
  }
}