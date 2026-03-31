import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class CategorySelectionView extends StatefulWidget {
  @override
  _CategorySelectionViewState createState() => _CategorySelectionViewState();
}

class _CategorySelectionViewState extends State<CategorySelectionView> {
  final AuthController controller = Get.find<AuthController>();
  final _searchController = TextEditingController();
  final _expandedCategories = <String>[].obs;
  List<Map<String, dynamic>> _filteredCategories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    // Load categories if they are empty
    if (controller.categories.isEmpty) {
      await controller.loadCategories();
    }
    setState(() {
      _filteredCategories = List.from(controller.categories);
    });
  }

  void _filterCategories(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCategories = List.from(controller.categories);
      } else {
        _filteredCategories = controller.categories.where((category) {
          final name = category['name']?.toString().toLowerCase() ?? '';
          final code = category['code']?.toString().toLowerCase() ?? '';
          final description = category['description']?.toString().toLowerCase() ?? '';

          return name.contains(query.toLowerCase()) ||
              code.contains(query.toLowerCase()) ||
              description.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _toggleCategoryExpansion(String categoryId) {
    if (_expandedCategories.contains(categoryId)) {
      _expandedCategories.remove(categoryId);
    } else {
      _expandedCategories.add(categoryId);
    }
  }

  int _getSelectedCount() {
    return controller.selectedCategories.length + controller.selectedSubCategories.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.categories.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          color: Color(0xFF0B630B),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading categories...',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchBar(),
                      const SizedBox(height: 24),
                      _buildCategoriesList(),
                      const SizedBox(height: 40),
                    ],
                  ),
                );
              }),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(Icons.arrow_back, color: Color(0xFF111261)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Categories',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111261),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.isLoggedIn.value ? 'Step 2 of 2' : 'Select Categories',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B630B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_getSelectedCount()} selected',
                  style: const TextStyle(
                    color: Color(0xFF0B630B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${controller.categories.length} categories',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey[500], size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search medicine categories...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
              onChanged: _filterCategories,
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              onPressed: () {
                _searchController.clear();
                _filterCategories('');
              },
              icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList() {
    if (_filteredCategories.isEmpty && !controller.isLoading.value) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.category_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No categories found',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _searchController.text.isNotEmpty
                    ? 'Try a different search term'
                    : 'Pull down to refresh',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadCategories,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B630B),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Medicine Categories',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111261),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Select categories and subcategories you specialize in',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 20),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredCategories.length,
          itemBuilder: (context, index) {
            final category = _filteredCategories[index];
            return Obx(() => _buildCategoryCard(category));
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    final subCategories = (category['subCategories'] as List?) ?? [];
    final isExpanded = _expandedCategories.contains(category['id'].toString());

    // Check if category itself is selected
    final isCategorySelected = controller.selectedCategories
        .contains(category['id'].toString());


    // Check if any subcategories are selected
    final hasSelectedSubCats = controller.selectedSubCategories
        .any((sc) => sc['categoryId'] == category['id'].toString());

    // Determine border color based on selection state
    Color borderColor;
    double borderWidth;

    if (isCategorySelected) {
      borderColor = const Color(0xFF0B630B);
      borderWidth = 2;
    } else if (hasSelectedSubCats) {
      borderColor = const Color(0xFF0B630B).withOpacity(0.5);
      borderWidth = 1.5;
    } else {
      borderColor = Colors.grey[200]!;
      borderWidth = 1;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: (isCategorySelected || hasSelectedSubCats)
            ? const Color(0xFF0B630B).withOpacity(0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Category Header
          GestureDetector(
            onTap: () => _toggleCategoryExpansion(category['id'].toString()),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      category['icon'] as String? ?? '💊',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category['name']?.toString() ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isCategorySelected
                                ? const Color(0xFF0B630B)
                                : const Color(0xFF111261),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${subCategories.length} subcategories',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Category selection checkbox (NEW)
                  GestureDetector(
                    onTap: () {
                      controller.toggleCategorySelection(
                        category['id'].toString(),
                      );
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: isCategorySelected
                            ? const Color(0xFF0B630B)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isCategorySelected
                              ? const Color(0xFF0B630B)
                              : Colors.grey[400]!,
                        ),
                      ),
                      child: isCategorySelected
                          ? const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                          : null,
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: const Color(0xFF111261),
                  ),
                ],
              ),
            ),
          ),

          // Subcategories (if expanded)
          if (isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  // Quick select/deselect all subcategories option
                  if (subCategories.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Text(
                            'Subcategories:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              // Select all subcategories for this category
                              for (var subCat in subCategories) {
                                controller.selectSubCategory({
                                  'id': subCat['id'].toString(),
                                  'name': subCat['name']?.toString() ?? 'Unknown',
                                  'categoryId': category['id'].toString(),
                                  'categoryName': category['name']?.toString() ?? 'Unknown',
                                });
                              }
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              minimumSize: Size.zero,
                            ),
                            child: Text(
                              'Select All',
                              style: TextStyle(
                                fontSize: 11,
                                color: const Color(0xFF0B630B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              // Deselect all subcategories for this category
                              for (var subCat in subCategories) {
                                controller.deselectSubCategory(subCat['id'].toString());
                              }
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              minimumSize: Size.zero,
                            ),
                            child: Text(
                              'Clear',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 3.5,
                    ),
                    itemCount: subCategories.length,
                    itemBuilder: (context, index) {
                      final subCat = subCategories[index];
                      return Obx(() => _buildSubCategoryCard(category, subCat));
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubCategoryCard(Map<String, dynamic> category, Map<String, dynamic> subCategory) {
    final isSelected = controller.selectedSubCategories
        .any((sc) => sc['id'] == subCategory['id'].toString());

    return GestureDetector(
      onTap: () {
        controller.toggleSubCategorySelection({
          'id': subCategory['id'].toString(),
          'name': subCategory['name']?.toString() ?? 'Unknown',
          'categoryId': category['id'].toString(),
          'categoryName': category['name']?.toString() ?? 'Unknown',
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0B630B).withOpacity(0.1)
              : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0B630B)
                : Colors.transparent,
            width: isSelected ? 1.5 : 0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF0B630B)
                    : Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF0B630B)
                      : Colors.grey[400]!,
                ),
              ),
              child: isSelected
                  ? const Icon(
                Icons.check,
                size: 14,
                color: Colors.white,
              )
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                subCategory['name']?.toString() ?? 'Unknown',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF0B630B)
                      : const Color(0xFF111261),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Get.back();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF111261),
                side: const BorderSide(color: Color(0xFF111261)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Go Back'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: (controller.selectedCategories.isNotEmpty ||
                  controller.selectedSubCategories.isNotEmpty)
                  ? () {
                if (controller.isLoggedIn.value) {
                  print("📝 Categories selected, navigating to Company Selection");

                  // ✅ FIXED: Navigate to Company Selection instead of completing onboarding
                  Get.toNamed('/vendors-company-selection');

                } else {
                  // If not logged in, just save selections and go back
                  Get.back(result: {
                    'categories': controller.selectedCategories.toList(),
                    'subCategories': controller.selectedSubCategories.toList(),
                  });
                }
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: (controller.selectedCategories.isNotEmpty ||
                    controller.selectedSubCategories.isNotEmpty)
                    ? const Color(0xFF0B630B)
                    : Colors.grey[400],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: controller.isLoading.value
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.isLoggedIn.value
                        ? 'Next: Select Companies'  // ✅ Updated text
                        : 'Done',
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    controller.isLoggedIn.value
                        ? Icons.arrow_forward  // ✅ Changed icon to arrow
                        : Icons.check,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }
}