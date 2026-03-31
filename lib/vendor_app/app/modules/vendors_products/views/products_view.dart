import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medical_b2b_app/app/data/providers/api_endpoints.dart';
import '../controllers/products_controller.dart';
import '../../../../../app/routes/app_pages.dart';
import '../../../../../app/data/models/venders_products_model.dart';

class VendorsProductsView extends GetView<VendorsProductsController> {
  const VendorsProductsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Products',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Obx(
                  () => Text(
                '${controller.totalProductsCount} products found',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          // View Toggle
          Obx(
                () => IconButton(
              icon: Icon(
                controller.isGridView.value
                    ? Icons.view_list
                    : Icons.grid_view,
                color: Colors.blue,
              ),
              onPressed: () => controller.toggleViewMode(),
            ),
          ),
          // Filter Button
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.blue),
            onPressed: _showFilterBottomSheet,
          ),
          // Add Product Button
          IconButton(
            icon: Icon(Icons.add, color: Colors.green),
            onPressed: () => Get.toNamed('/vendors-category-selection'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(),

          // Stats Summary
          // _buildStatsSummary(),

          // Filter Chips Row
          // _buildFilterChips(),

          // Products Grid/List
          Expanded(
            child: Obx(
                  () {
                // Show full screen loader only on initial load
                if (controller.isLoading.value && controller.products.isEmpty) {
                  return Center(child: CircularProgressIndicator());
                }

                // Show empty state
                if (controller.products.isEmpty) {
                  return _buildEmptyState();
                }

                // Show products grid/list
                return controller.isGridView.value
                    ? _buildProductsGrid()
                    : _buildProductsList();
              },
            ),
          ),

          // Show loading more indicator at bottom
          Obx(
                () => controller.isLoadingMore.value
                ? Container(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
                : SizedBox(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 2, // Products is index 2
        onTap: (index) {
          switch (index) {
            case 0:
              Get.offNamed(Routes.VENDERS_DASHBOARD);
              break;
            case 1:
              Get.offNamed(Routes.VENDERS_ORDERS);
              break;
            case 2:
            // Already on products
              break;
            case 3:
              Get.offNamed(Routes.VENDORS_PROFILE);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) => controller.searchProducts(value),
        decoration: InputDecoration(
          hintText: 'Search products by name...',
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          suffixIcon: Obx(
                () => controller.searchQuery.value.isNotEmpty
                ? IconButton(
              icon: Icon(Icons.clear, color: Colors.grey),
              onPressed: () {
                controller.searchQuery.value = '';
                controller.searchProducts('');
              },
            )
                : SizedBox(),
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
            borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSummary() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.purple.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Obx(() => _buildStatItem(
            'Total',
            controller.totalProductsCount.toString(),
            Icons.inventory,
          )),
          Obx(() => _buildStatItem(
            'Low Stock',
            controller.lowStockCount.toString(),
            Icons.warning,
          )),
          Obx(() => _buildStatItem(
            'In Stock',
            controller.inStockCount.toString(),
            Icons.check_circle,
          )),
          Obx(() => _buildStatItem(
            'Value',
            '₹${(controller.totalInventoryValue / 100000).toStringAsFixed(1)}L',
            Icons.currency_rupee,
          )),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 40,
      margin: EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.filterOptions.length,
        itemBuilder: (context, index) {
          final filter = controller.filterOptions[index];
          return Obx(
                () {
              final isSelected = controller.selectedFilter.value == filter;
              return Container(
                margin: EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(
                    filter,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (_) => controller.filterByOption(filter),
                  backgroundColor: Colors.white,
                  selectedColor: Colors.blue,
                  checkmarkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? Colors.blue : Colors.grey.shade300,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProductsGrid() {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!controller.isLoadingMore.value &&
            scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
          controller.loadMoreProducts();
        }
        return true;
      },
      child: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
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
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: product.image != null && product.image!.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.vertical(
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
                            color: Colors.blue.shade300,
                          ),
                        );
                      },
                    ),
                  )
                      : Center(
                    child: Icon(
                      Icons.medical_services,
                      size: 50,
                      color: Colors.blue.shade300,
                    ),
                  ),
                ),
                // Stock Warning Badge
                if ((product.stockQuantity ?? 0) < 100)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Low Stock',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // Out of Stock Badge
                if (product.isAvailable == false)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.block,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                // Edit Button
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.edit, size: 16, color: Colors.blue),
                      onPressed: () => _showEditPriceDialog(product),
                      padding: EdgeInsets.all(6),
                      constraints: BoxConstraints(),
                    ),
                  ),
                ),
              ],
            ),

            // Product Details
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Text(
                    product.genericName ?? 'Generic',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${product.sellingPrice?.toStringAsFixed(2) ?? '0'}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                          fontSize: 14,
                        ),
                      ),
                      if (product.mrp != null && product.mrp! > (product.sellingPrice ?? 0))
                        Text(
                          '₹${product.mrp?.toStringAsFixed(2)}',
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                    ],
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
            scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
          controller.loadMoreProducts();
        }
        return true;
      },
      child: ListView.builder(
        padding: EdgeInsets.all(16),
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
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Product Icon
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                            color: Colors.blue.shade300,
                          ),
                        );
                      },
                    ),
                  )
                      : Center(
                    child: Icon(
                      Icons.medical_services,
                      size: 30,
                      color: Colors.blue.shade300,
                    ),
                  ),
                ),
                SizedBox(width: 12),

                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        product.genericName ?? 'Generic',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          // Price
                          Text(
                            '₹${product.sellingPrice?.toStringAsFixed(2) ?? '0'}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          if (product.mrp != null && product.mrp! > (product.sellingPrice ?? 0))
                            Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Text(
                                '₹${product.mrp?.toStringAsFixed(2)}',
                                style: TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (product.isAvailable == false)
                        Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            'Out of Stock',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Action Buttons
                Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue, size: 20),
                      onPressed: () => _showEditPriceDialog(product),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                    SizedBox(height: 8),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed: () => controller.deleteProduct(product),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ],
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
          SizedBox(height: 16),
          Text(
            'No products found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8),
          Obx(
                () => Text(
              controller.searchQuery.value.isNotEmpty
                  ? 'Try adjusting your search or filters'
                  : 'Click the + button to add your first product',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ),
          SizedBox(height: 24),
          Obx(
                () => controller.searchQuery.value.isNotEmpty
                ? ElevatedButton(
              onPressed: () => controller.resetFilters(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text('Clear Filters'),
            )
                : SizedBox(),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.8,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Products',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => controller.resetFilters(),
                      child: Text(
                        'Reset',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ],
            ),
            Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Filter
                    Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Obx(
                          () => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          // All Categories option
                          FilterChip(
                            label: Text('All'),
                            selected: controller.selectedCategory.value == 'All',
                            onSelected: (_) {
                              controller.filterByCategory('All', null);
                              Get.back();
                            },
                            backgroundColor: Colors.grey.shade100,
                            selectedColor: Colors.blue,
                            labelStyle: TextStyle(
                              color: controller.selectedCategory.value == 'All'
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                          // Categories from API
                          ...controller.categories.map((category) {
                            final isSelected =
                                controller.selectedCategoryId.value == category.id;
                            return FilterChip(
                              label: Text(category.name),
                              selected: isSelected,
                              onSelected: (_) {
                                controller.filterByCategory(category.name, category.id);
                                Get.back();
                              },
                              backgroundColor: Colors.grey.shade100,
                              selectedColor: Colors.blue,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),

                    // Company/Brand Filter
                    Text(
                      'Company',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Obx(
                          () => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          // All Companies option
                          FilterChip(
                            label: Text('All'),
                            selected: controller.selectedCompany.value == 'All',
                            onSelected: (_) {
                              controller.filterByCompany('All', null);
                              Get.back();
                            },
                            backgroundColor: Colors.grey.shade100,
                            selectedColor: Colors.blue,
                            labelStyle: TextStyle(
                              color: controller.selectedCompany.value == 'All'
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                          // Companies from API
                          ...controller.companies.map((company) {
                            final isSelected =
                                controller.selectedCompanyId.value == company.id;
                            return FilterChip(
                              label: Text(company.name),
                              selected: isSelected,
                              onSelected: (_) {
                                controller.filterByCompany(company.name, company.id);
                                Get.back();
                              },
                              backgroundColor: Colors.grey.shade100,
                              selectedColor: Colors.blue,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),

                    // In Stock Filter
                    Obx(
                          () => CheckboxListTile(
                        title: Text('In Stock Only'),
                        value: controller.showInStockOnly.value,
                        onChanged: (value) {
                          controller.toggleStockFilter(value ?? false);
                        },
                        activeColor: Colors.blue,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),

                    SizedBox(height: 16),

                    // Price Range Filter
                    Text(
                      'Price Range',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Obx(
                          () => RangeSlider(
                        values: controller.priceRange.value,
                        min: 0,
                        max: 10000,
                        divisions: 20,
                        labels: RangeLabels(
                          '₹${controller.priceRange.value.start.round()}',
                          '₹${controller.priceRange.value.end.round()}',
                        ),
                        onChanged: controller.updatePriceRange,
                        activeColor: Colors.blue,
                      ),
                    ),
                    Obx(
                          () => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₹${controller.priceRange.value.start.round()}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '₹${controller.priceRange.value.end.round()}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),

                    // Sort Options
                    Text(
                      'Sort By',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 8),
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
                            activeColor: Colors.blue,
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

  void _showEditPriceDialog(ProductModel product) {
    final TextEditingController priceController =
    TextEditingController(text: product.sellingPrice?.toString() ?? '0');

    Get.dialog(
      AlertDialog(
        title: Text('Update Price'),
        content: TextField(
          controller: priceController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Selling Price',
            prefixText: '₹ ',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newPrice = double.tryParse(priceController.text.trim());

              if (newPrice == null) {
                Get.snackbar(
                  'Invalid Price',
                  'Please enter valid number',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              await controller.updatePrice(
                product.vendorProductId,
                newPrice,
              );
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }
}