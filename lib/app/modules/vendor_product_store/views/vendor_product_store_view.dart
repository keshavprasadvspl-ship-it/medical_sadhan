import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medical_b2b_app/app/data/providers/api_endpoints.dart';
import '../../main/controllers/main_controller.dart';
import '../controllers/vendor_product_store_controller.dart';
import '../../../../../app/routes/app_pages.dart';
import '../../../../../app/data/models/venders_products_model.dart';

class VendorProductStoreView extends GetView<VendorProductStoreController> {
  const VendorProductStoreView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show vendor name
            Text(
              controller.vendorName.value,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            // Show active filters if any
            if (controller.hasIncomingFilters)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B630B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  controller.filterDescription,
                  style: const TextStyle(
                    color: Color(0xFF0B630B),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            // Product count
            Text(
              '${controller.totalProductsCount} products available',
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        )),
        actions: [
          // Filter Button
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFF0B630B)),
            onPressed: _showFilterBottomSheet,
          ),

          // Cart Icon with Badge
          Obx(
                () => Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () {
                    Get.offAllNamed('/main');

                    Future.delayed(const Duration(milliseconds: 100), () {
                      Get.find<MainController>().goToCart();
                    });
                  },
                  color: const Color(0xFF0B630B),
                ),
                if (controller.cartItemCount.value > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${controller.cartItemCount.value}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(),
          Obx(() {
            if (controller.hasIncomingFilters) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: const Color(0xFF0B630B).withOpacity(0.1),
                child: Row(
                  children: [
                    const Icon(
                      Icons.filter_list,
                      size: 16,
                      color: Color(0xFF0B630B),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF0B630B).withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    controller.filterDescription,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF0B630B),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () {
                                      controller.clearNavigationFilters();
                                    },
                                    child: const Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Color(0xFF0B630B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: controller.clearNavigationFilters,
                      child: const Text(
                        'Clear',
                        style: TextStyle(
                          color: Color(0xFF0B630B),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          }),

          // Products Grid/List
          Expanded(
            child: Obx(
                  () {
                if (controller.isLoading.value && controller.products.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0B630B)),
                  );
                }

                if (controller.products.isEmpty) {
                  return _buildEmptyState();
                }

                return controller.isGridView.value
                    ? _buildProductsGrid()
                    : _buildProductsList();
              },
            ),
          ),

          // Loading more indicator
          Obx(
                () => controller.isLoadingMore.value
                ? Container(
              padding: const EdgeInsets.all(16),
              child: const Center(
                child:
                CircularProgressIndicator(color: Color(0xFF0B630B)),
              ),
            )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: TextField(
        onChanged: (value) => controller.searchProducts(value),
        decoration: InputDecoration(
          hintText: 'Search products by name...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: Obx(
                () => controller.searchQuery.value.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: () {
                controller.searchQuery.value = '';
                controller.searchProducts('');
              },
            )
                : const SizedBox(),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0B630B), width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildProductsGrid() {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!controller.isLoadingMore.value &&
            scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 200) {
          controller.loadMoreProducts();
        }
        return true;
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: controller.products.length,
        itemBuilder: (context, index) {
          final product = controller.products[index];
          return _buildProductGridCard(product);
        },
      ),
    );
  }

  Widget _buildProductGridCard(ProductModel product) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => controller.viewProductDetails(product),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image/Icon
            Stack(
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B630B).withOpacity(0.1),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: product.image != null && product.image!.isNotEmpty
                      ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Image.network(
                      product.image!.startsWith('http')
                          ? product.image!
                          : '${ApiEndpoints.imgUrl}/${product.image}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.medical_services,
                            size: 50,
                            color:
                            const Color(0xFF0B630B).withOpacity(0.5),
                          ),
                        );
                      },
                    ),
                  )
                      : Center(
                    child: Icon(
                      Icons.medical_services,
                      size: 50,
                      color: const Color(0xFF0B630B).withOpacity(0.5),
                    ),
                  ),
                ),
                // Out of Stock Badge
                if (product.isAvailable == false)
                  const Positioned(
                    top: 8,
                    left: 8,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.red,
                      child: Icon(
                        Icons.block,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
              ],
            ),

            // Product Details
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF111261),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.genericName ?? 'Generic',
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${product.sellingPrice?.toStringAsFixed(2) ?? '0'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B630B),
                          fontSize: 14,
                        ),
                      ),
                      if (product.mrp != null &&
                          product.mrp! > (product.sellingPrice ?? 0))
                        Text(
                          '₹${product.mrp?.toStringAsFixed(2)}',
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Add to Cart Button
                  if (product.isAvailable == true)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => controller.addToCart(product),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B630B),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size(double.infinity, 32),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Add to Cart',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'Out of Stock',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsList() {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!controller.isLoadingMore.value &&
            scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 200) {
          controller.loadMoreProducts();
        }
        return true;
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.products.length,
        itemBuilder: (context, index) {
          final product = controller.products[index];
          return _buildProductListCard(product);
        },
      ),
    );
  }

  Widget _buildProductListCard(ProductModel product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => controller.viewProductDetails(product),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Product Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF0B630B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: product.image != null && product.image!.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    product.image!.startsWith('http')
                        ? product.image!
                        : '${ApiEndpoints.imgUrl}/${product.image}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.medical_services,
                          size: 30,
                          color: const Color(0xFF0B630B).withOpacity(0.5),
                        ),
                      );
                    },
                  ),
                )
                    : Center(
                  child: Icon(
                    Icons.medical_services,
                    size: 30,
                    color: const Color(0xFF0B630B).withOpacity(0.5),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF111261),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.genericName ?? 'Generic',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '₹${product.sellingPrice?.toStringAsFixed(2) ?? '0'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF0B630B),
                          ),
                        ),
                        if (product.mrp != null &&
                            product.mrp! > (product.sellingPrice ?? 0))
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              '₹${product.mrp?.toStringAsFixed(2)}',
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Add to Cart Button
              Column(
                children: [
                  if (product.isAvailable == true)
                    ElevatedButton(
                      onPressed: () => controller.addToCart(product),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B630B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(90, 36),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_shopping_cart, size: 16),
                          SizedBox(width: 4),
                          Text('Add', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Out of Stock',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'No products found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Obx(
                () => Text(
              controller.searchQuery.value.isNotEmpty
                  ? 'Try adjusting your search or filters'
                  : 'This vendor has no products yet',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),
          Obx(
                () => controller.searchQuery.value.isNotEmpty ||
                controller.hasIncomingFilters
                ? ElevatedButton(
              onPressed: () => controller.resetFilters(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B630B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
              ),
              child: const Text('Clear Filters'),
            )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.8,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Products',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111261),
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => controller.resetFilters(),
                      child: const Text(
                        'Reset',
                        style: TextStyle(color: Color(0xFF0B630B)),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                          () => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilterChip(
                            label: const Text('All'),
                            selected:
                            controller.selectedCategory.value == 'All',
                            onSelected: (_) {
                              controller.filterByCategory('All', null);
                              Get.back();
                            },
                            backgroundColor: Colors.grey.shade100,
                            selectedColor: const Color(0xFF0B630B),
                            labelStyle: TextStyle(
                              color: controller.selectedCategory.value == 'All'
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                          ...controller.categories.map((category) {
                            final isSelected =
                                controller.selectedCategoryId.value ==
                                    category.id;
                            return FilterChip(
                              label: Text(category.name),
                              selected: isSelected,
                              onSelected: (_) {
                                controller.filterByCategory(
                                    category.name, category.id);
                                Get.back();
                              },
                              backgroundColor: Colors.grey.shade100,
                              selectedColor: const Color(0xFF0B630B),
                              labelStyle: TextStyle(
                                color:
                                isSelected ? Colors.white : Colors.black87,
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Company',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                          () => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilterChip(
                            label: const Text('All'),
                            selected: controller.selectedCompany.value == 'All',
                            onSelected: (_) {
                              controller.filterByCompany('All', null);
                              Get.back();
                            },
                            backgroundColor: Colors.grey.shade100,
                            selectedColor: const Color(0xFF0B630B),
                            labelStyle: TextStyle(
                              color: controller.selectedCompany.value == 'All'
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                          ...controller.companies.map((company) {
                            final isSelected =
                                controller.selectedCompanyId.value ==
                                    company.id;
                            return FilterChip(
                              label: Text(company.name),
                              selected: isSelected,
                              onSelected: (_) {
                                controller.filterByCompany(
                                    company.name, company.id);
                                Get.back();
                              },
                              backgroundColor: Colors.grey.shade100,
                              selectedColor: const Color(0xFF0B630B),
                              labelStyle: TextStyle(
                                color:
                                isSelected ? Colors.white : Colors.black87,
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(
                          () => CheckboxListTile(
                        title: const Text('In Stock Only'),
                        value: controller.showInStockOnly.value,
                        onChanged: (value) {
                          controller.toggleStockFilter(value ?? false);
                        },
                        activeColor: const Color(0xFF0B630B),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Sort By',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                          () => Column(
                        children: controller.filterOptions.map((option) {
                          return RadioListTile<String>(
                            title: Text(option),
                            value: option,
                            groupValue: controller.selectedFilter.value,
                            onChanged: (value) {
                              if (value != null) {
                                controller.filterByOption(value);
                                Get.back();
                              }
                            },
                            activeColor: const Color(0xFF0B630B),
                            contentPadding: EdgeInsets.zero,
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}