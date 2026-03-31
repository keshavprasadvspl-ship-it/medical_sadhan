import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../data/providers/api_provider.dart';
import '../../../data/models/medicine_model.dart';

class SearchController extends GetxController {
  final searchController = TextEditingController();
  final searchResults = <MedicineModel>[].obs;
  final suggestions = <MedicineModel>[].obs;
  final isLoading = false.obs;
  final isLoadingSuggestions = false.obs;
  final showFilters = false.obs;
  final selectedCategory = ''.obs;
  final selectedSort = ''.obs;
  final isSearchFieldFocused = false.obs;
  final stt.SpeechToText speech = stt.SpeechToText();
  final isListening = false.obs;

  final ApiService _apiService = ApiService();

  // Rx variable for debounce
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();

    // Load suggestions on init
    loadSuggestions();

    // Listen to text changes
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });

    // Debounce search
    debounce<String>(
      searchQuery,
          (value) {
        if (value.isNotEmpty) {
          performSearch(value);
        } else {
          searchResults.clear();
        }
      },
      time: const Duration(milliseconds: 500),
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    stopVoiceSearch();
    super.onClose();
  }

  Future<void> loadSuggestions() async {
    try {
      isLoadingSuggestions.value = true;
      final results = await _apiService.getSuggestions();
      suggestions.value = results;
    } catch (e) {
      print("Error loading suggestions: $e");
    } finally {
      isLoadingSuggestions.value = false;
    }
  }

  Future<void> performSearch(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      isLoading.value = true;
      final results = await _apiService.searchProducts(query);

      // Apply filters if selected
      var filteredResults = results;

      if (selectedCategory.value.isNotEmpty && selectedCategory.value != 'All') {
        filteredResults = filteredResults.where((medicine) {
          return medicine.displayCategory.toLowerCase().contains(selectedCategory.value.toLowerCase());
        }).toList();
      }

      // Apply sorting
      if (selectedSort.value.isNotEmpty) {
        filteredResults.sort((a, b) {
          switch (selectedSort.value) {
            case 'name_asc':
              return a.name.compareTo(b.name);
            case 'name_desc':
              return b.name.compareTo(a.name);
            case 'price_low':
              return a.price.compareTo(b.price);
            case 'price_high':
              return b.price.compareTo(a.price);
            case 'rating':
              return (b.vendorProductsCount ?? 0).compareTo(a.vendorProductsCount ?? 0);
            default:
              return 0;
          }
        });
      }

      searchResults.value = filteredResults;
    } catch (e) {
      print("Error performing search: $e");
      searchResults.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> startVoiceSearch() async {
    bool available = await speech.initialize();

    if (available) {
      isListening.value = true;

      speech.listen(
        onResult: (result) {
          searchController.text = result.recognizedWords;
          searchQuery.value = result.recognizedWords;
        },
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
        onSoundLevelChange: (level) {},
      );
    } else {
      Get.snackbar(
        'Voice Search',
        'Speech recognition not available',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void stopVoiceSearch() {
    if (isListening.value) {
      isListening.value = false;
      speech.stop();
    }
  }

  void clearSearch() {
    searchController.clear();
    searchResults.clear();
    searchQuery.value = '';
    selectedCategory.value = '';
    selectedSort.value = '';
  }

  void setSuggestion(String query) {
    searchController.text = query;
    searchQuery.value = query;
  }

  void toggleFilters() {
    showFilters.value = !showFilters.value;
  }

  void showCategoryDialog() {
    final categories = ['All', 'Antibiotic', 'Analgesic', 'Vitamin', 'Antihistamine', 'Antacid', 'Anti-diabetic', 'Cholesterol'];

    Get.dialog(
      AlertDialog(
        title: const Text('Select Category'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Obx(() => ListTile(
                title: Text(category),
                leading: Radio<String>(
                  value: category,
                  groupValue: selectedCategory.value.isEmpty ? 'All' : selectedCategory.value,
                  onChanged: (value) {
                    selectedCategory.value = value!;
                    Get.back();
                    if (searchQuery.value.isNotEmpty) {
                      performSearch(searchQuery.value);
                    }
                  },
                  activeColor: const Color(0xFF0B630B),
                ),
              ));
            },
          ),
        ),
      ),
    );
  }

  void showSortDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Sort By'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSortOption('Default', ''),
            _buildSortOption('Name (A-Z)', 'name_asc'),
            _buildSortOption('Name (Z-A)', 'name_desc'),
            _buildSortOption('Price: Low to High', 'price_low'),
            _buildSortOption('Price: High to Low', 'price_high'),
            _buildSortOption('Most Available', 'rating'),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String title, String value) {
    return Obx(() => ListTile(
      title: Text(title),
      leading: Radio<String>(
        value: value,
        groupValue: selectedSort.value,
        onChanged: (value) {
          selectedSort.value = value!;
          Get.back();
          if (searchQuery.value.isNotEmpty) {
            performSearch(searchQuery.value);
          }
        },
        activeColor: const Color(0xFF0B630B),
      ),
    ));
  }

  void onMedicineTap(MedicineModel medicine) {
    // Navigate to medicine detail page
    Get.toNamed('/product-details/${medicine.id}');
  }

  List<String> getPopularSearchNames() {
    return suggestions.take(8).map((m) => m.name).toList();
  }
}