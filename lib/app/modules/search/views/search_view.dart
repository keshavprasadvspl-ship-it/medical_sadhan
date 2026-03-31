import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';
import '../controllers/search_controller.dart';
import '../../../data/models/medicine_model.dart';

class SearchView extends GetView<SearchController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _buildSearchBar(),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
        floatingActionButton: Obx(() => controller.showFilters.value
            ? FloatingActionButton(
          onPressed: controller.toggleFilters,
          backgroundColor: const Color(0xFF0B630B),
          child: const Icon(Icons.filter_alt_off, color: Colors.white),
        )
            : FloatingActionButton(
          onPressed: controller.toggleFilters,
          backgroundColor: const Color(0xFF0B630B),
          child: const Icon(Icons.filter_alt, color: Colors.white),
        )),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF111261)),
            onPressed: () => Get.back(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Color(0xFF111261), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      controller: controller.searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search medicines...',
                        hintStyle: TextStyle(fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(fontSize: 14),
                      onChanged: (value) => controller.searchQuery.value = value,
                    ),
                  ),
                  Obx(() => controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: controller.clearSearch,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  )
                      : const SizedBox(width: 8)),
                ],
              ),
            ),
          ),
          Obx(() => IconButton(
            icon: Icon(
              controller.isListening.value ? Icons.mic : Icons.mic_none,
              color: controller.isListening.value ? Colors.red : const Color(0xFF111261),
            ),
            onPressed: () {
              if (controller.isListening.value) {
                controller.stopVoiceSearch();
              } else {
                controller.startVoiceSearch();
              }
            },
          )),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF0B630B)),
        );
      }

      if (controller.searchResults.isNotEmpty) {
        return _buildSearchResults();
      }

      if (controller.searchController.text.isNotEmpty) {
        return _buildNoResults();
      }

      return _buildInitialState();
    });
  }

  Widget _buildSearchResults() {
    return Column(
      children: [
        Obx(() => controller.showFilters.value ? _buildFilters() : const SizedBox.shrink()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${controller.searchResults.length} results found',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Obx(() => controller.selectedSort.value.isNotEmpty
                  ? Chip(
                label: Text(
                  _getSortLabel(controller.selectedSort.value),
                  style: const TextStyle(fontSize: 11),
                ),
                backgroundColor: const Color(0xFFF5F5F5),
              )
                  : const SizedBox()),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: controller.searchResults.length,
            itemBuilder: (context, index) {
              final medicine = controller.searchResults[index];
              return _buildMedicineCard(medicine);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMedicineCard(MedicineModel medicine) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => controller.onMedicineTap(medicine),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.network(
                  medicine.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.medication, size: 40, color: Colors.grey);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            medicine.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111261),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: medicine.isPrescriptionRequired
                                ? Colors.red[50]
                                : const Color(0xFF0B630B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            medicine.prescriptionType,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: medicine.isPrescriptionRequired
                                  ? Colors.red
                                  : const Color(0xFF0B630B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      medicine.displayManufacturer,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    if (medicine.genericName.isNotEmpty)
                      Text(
                        'Generic: ${medicine.genericName}',
                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    if (medicine.vendorProductsCount != null)
                      Text(
                        'Available from ${medicine.vendorProductsCount} sellers',
                        style: TextStyle(
                          fontSize: 12,
                          color: medicine.vendorProductsCount! > 0
                              ? const Color(0xFF0B630B)
                              : Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return Obx(() {
      if (controller.isLoadingSuggestions.value) {
        return const Center(child: CircularProgressIndicator(color: Color(0xFF0B630B)));
      }

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Popular Searches',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111261),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.getPopularSearchNames().map((search) {
              return ActionChip(
                label: Text(search),
                onPressed: () => controller.setSuggestion(search),
                backgroundColor: const Color(0xFFF5F5F5),
                labelStyle: const TextStyle(color: Color(0xFF111261)),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          // const Text(
          //   'Browse Categories',
          //   style: TextStyle(
          //     fontSize: 18,
          //     fontWeight: FontWeight.w600,
          //     color: Color(0xFF111261),
          //   ),
          // ),
          // const SizedBox(height: 12),
          // GridView.builder(
          //   shrinkWrap: true,
          //   physics: const NeverScrollableScrollPhysics(),
          //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          //     crossAxisCount: 3,
          //     crossAxisSpacing: 12,
          //     mainAxisSpacing: 12,
          //     childAspectRatio: 1.2,
          //   ),
          //   itemCount: 6,
          //   itemBuilder: (context, index) {
          //     final categories = ['Antibiotics', 'Pain Relief', 'Vitamins', 'Diabetes', 'Cardiac', 'Skincare'];
          //     final icons = [
          //       Icons.medication,
          //       Icons.health_and_safety,
          //       Icons.medication,
          //       Icons.monitor_heart,
          //       Icons.favorite,
          //       Icons.spa,
          //     ];
          //
          //     return InkWell(
          //       onTap: () {
          //         controller.selectedCategory.value = categories[index];
          //         controller.searchController.text = categories[index];
          //         controller.searchQuery.value = categories[index];
          //       },
          //       child: Column(
          //         children: [
          //           Container(
          //             width: 60,
          //             height: 60,
          //             decoration: BoxDecoration(
          //               color: const Color(0xFF0B630B).withOpacity(0.1),
          //               borderRadius: BorderRadius.circular(12),
          //             ),
          //             child: Icon(
          //               icons[index],
          //               color: const Color(0xFF0B630B),
          //               size: 30,
          //             ),
          //           ),
          //           const SizedBox(height: 8),
          //           Text(
          //             categories[index],
          //             style: const TextStyle(
          //               fontSize: 12,
          //               fontWeight: FontWeight.w500,
          //               color: Color(0xFF111261),
          //             ),
          //             textAlign: TextAlign.center,
          //           ),
          //         ],
          //       ),
          //     );
          //   },
          // ),
        ],
      );
    });
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 150,
            width: 150,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.search_off, size: 60, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          const Text(
            'No medicines found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111261),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try different keywords or browse categories',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: controller.clearSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0B630B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Clear Search'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: controller.showCategoryDialog,
              icon: const Icon(Icons.category, size: 16),
              label: Obx(() => Text(
                controller.selectedCategory.value.isEmpty
                    ? 'Category'
                    : controller.selectedCategory.value,
                style: const TextStyle(fontSize: 12),
              )),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF111261),
                side: const BorderSide(color: Color(0xFF111261)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: controller.showSortDialog,
              icon: const Icon(Icons.sort, size: 16),
              label: Obx(() => Text(
                controller.selectedSort.value.isEmpty
                    ? 'Sort'
                    : _getSortLabel(controller.selectedSort.value),
                style: const TextStyle(fontSize: 12),
              )),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF111261),
                side: const BorderSide(color: Color(0xFF111261)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getSortLabel(String sortValue) {
    switch (sortValue) {
      case 'name_asc':
        return 'A-Z';
      case 'name_desc':
        return 'Z-A';
      case 'price_low':
        return 'Price: Low';
      case 'price_high':
        return 'Price: High';
      case 'rating':
        return 'Most Available';
      default:
        return 'Sort';
    }
  }
}