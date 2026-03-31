import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../controllers/categories_controller.dart';

class CategoriesView extends GetView<CategoriesController> {
  const CategoriesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshCategories,
                color: const Color(0xFF0B630B),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildSearchBar(),
                          const SizedBox(height: 20),
                          _buildHeader(),
                          const SizedBox(height: 16),
                        ]),
                      ),
                    ),
                    _buildCategoriesGrid(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// In CategoriesView, update the _buildAppBar method
  Widget _buildAppBar() {
    return Container(
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
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back, color: Color(0xFF111261)),
          ),

          const SizedBox(width: 8),

          /// ✅ IMPORTANT: Wrap this with Expanded
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// 🔹 LEFT SIDE (TEXT CONTENT)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() {
                        if (controller.isVendorFiltered.value &&
                            controller.isCompanyFiltered.value) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      controller.selectedVendorName.value,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF0B630B),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 10,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      controller.selectedCompanyName.value,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF111261),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Select a category',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          );
                        } else if (controller.isCompanyFiltered.value) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Categories from',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                controller.selectedCompanyName.value,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111261),
                                ),
                              ),
                            ],
                          );
                        } else {
                          return const Text(
                            'All Categories',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111261),
                            ),
                          );
                        }
                      }),

                      const SizedBox(height: 4),

                      Obx(() {
                        return Text(
                          controller.isVendorFiltered.value &&
                              controller.isCompanyFiltered.value
                              ? 'Choose a category to view products from ${controller.selectedVendorName.value}'
                              : controller.isCompanyFiltered.value
                              ? 'Select a category to view products from ${controller.selectedCompanyName.value}'
                              : 'Browse products by category',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                /// 🔹 RIGHT SIDE (CATEGORY COUNT)
                Obx(() => Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B630B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${controller.filteredCategories.length} categories',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF0B630B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
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
              onChanged: controller.filterCategories,
              decoration: InputDecoration(
                hintText: 'Search categories...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey[500]),
              ),
            ),
          ),
          Obx(() => controller.searchQuery.value.isNotEmpty
              ? IconButton(
            onPressed: () {
              controller.filterCategories('');
            },
            icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
          )
              : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Obx(() {
      if (controller.isLoading.value && controller.categories.isEmpty) {
        return const SizedBox.shrink();
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Available Categories',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111261),
            ),
          ),
          Text(
            '${controller.filteredCategories.length} results',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildCategoriesGrid() {
    return Obx(() {
      if (controller.filteredCategories.isEmpty) {
        return SliverFillRemaining(
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
                Obx(() {
                  if (controller.isVendorFiltered.value && controller.isCompanyFiltered.value) {
                    return Text(
                      'No categories available for ${controller.selectedVendorName.value} - ${controller.selectedCompanyName.value}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    );
                  } else if (controller.isCompanyFiltered.value) {
                    return Text(
                      'No categories available for ${controller.selectedCompanyName.value}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    );
                  } else {
                    return Text(
                      controller.searchQuery.value.isNotEmpty
                          ? 'Try adjusting your search'
                          : 'Pull down to refresh',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    );
                  }
                }),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.refreshCategories,
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


      if (controller.filteredCategories.isEmpty) {
        return SliverFillRemaining(
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
                Obx(() {
                  if (controller.isCompanyFiltered.value) {
                    return Text(
                      'No categories available for ${controller.selectedCompanyName.value}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    );
                  } else {
                    return Text(
                      controller.searchQuery.value.isNotEmpty
                          ? 'Try adjusting your search'
                          : 'Pull down to refresh',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    );
                  }
                }),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.refreshCategories,
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

      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final category = controller.filteredCategories[index];
              return _buildCategoryCard(category);
            },
            childCount: controller.filteredCategories.length,
          ),
        ),
      );
    });
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    final icon = controller.getCategoryIcon(category);
    final isActive = category['is_active'] == true;
    final categoryName = category['name'] ?? 'Unknown';
    final categoryCode = category['code'] ?? '';
    final subCategories = (category['sub_categories'] as List?) ?? [];
    final activeSubCount = subCategories.where((s) => s['is_active'] == true).length;

    return GestureDetector(
      onTap: isActive
          ? () {
        controller.navigateToCategoryProducts(category);
      }
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? Colors.grey[300]! : Colors.grey[400]!,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Category Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[100]!),
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Category Name with Code
              Column(
                children: [
                  Text(
                    categoryName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isActive ? const Color(0xFF111261) : Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Status Badge (if inactive)
              if (!isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Inactive',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ),

              const Spacer(),

              // View Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF0B630B) : Colors.grey[300],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'View Products',
                      style: TextStyle(
                        fontSize: 11,
                        color: isActive ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      size: 11,
                      color: isActive ? Colors.white : Colors.grey[600],
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
}