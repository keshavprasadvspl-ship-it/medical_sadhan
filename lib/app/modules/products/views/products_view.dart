import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medical_b2b_app/app/data/providers/api_endpoints.dart';
import '../../../data/models/product_model.dart';
import '../../../global_widgets/add_to_cart_popup.dart';
import '../../main/controllers/main_controller.dart';
import '../controllers/products_controller.dart';

class ProductsView extends StatefulWidget {
  const ProductsView({super.key});

  @override
  State<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  late final ProductsController controller;
  final ScrollController _scrollController = ScrollController();

  // ─── THEME COLORS ──────────────────────────────────────────────────────────
  static const primary   = Color(0xFF043734);
  static const secondary = Color(0xFF21827A);
  static const lightBg   = Color(0xFFF0F7F6);
  static const discountOrange = Color(0xFFFF6B35); // Dark orange for discount

  final String baseUrl = '${ApiEndpoints.imgUrl}/';

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<ProductsController>()) {
      controller = Get.find<ProductsController>();
    } else {
      controller = Get.put(ProductsController());
    }

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        controller.loadMoreProducts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    if (imagePath.startsWith('/')) imagePath = imagePath.substring(1);
    return baseUrl + imagePath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildFiltersBar(),
            _buildActiveFilterBar(),
            Expanded(child: _buildProductsContent()),
          ],
        ),
      ),
      floatingActionButton: Obx(
        () => controller.cartItemCount.value > 0
            ? Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [primary, secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: FloatingActionButton.extended(
                  onPressed: () => Get.toNamed('/cart'),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  label: Row(
                    children: [
                      const Icon(Icons.shopping_cart, color: Colors.white),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          controller.cartItemCount.value.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : const SizedBox(),
      ),
    );
  }

  // ─── APP BAR ───────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              onPressed: () => Get.back(),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
            ),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.search,
                      color: Colors.white.withOpacity(0.8), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller.searchController,
                      decoration: InputDecoration(
                        hintText: 'Search products by name, company...',
                        hintStyle: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.6)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(fontSize: 13, color: Colors.white),
                      onChanged: (value) => controller.searchQuery.value = value,
                    ),
                  ),
                  Obx(() => controller.searchQuery.value.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            controller.searchController.clear();
                            controller.searchQuery.value = '';
                          },
                          child: Icon(Icons.close,
                              size: 16, color: Colors.white.withOpacity(0.8)),
                        )
                      : const SizedBox(width: 8)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),

          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart_outlined,
                  color: Colors.white, size: 20),
              onPressed: () {
                Future.delayed(const Duration(milliseconds: 100), () {
                  Get.find<MainController>().goToCart();
                });
              },
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }

  // ─── FILTERS BAR ───────────────────────────────────────────────────────────
  Widget _buildFiltersBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildBarButton(
            icon: Icons.filter_alt_rounded,
            label: 'Filter',
            onPressed: controller.showFiltersDialog,
          ),
          const SizedBox(width: 10),
          Obx(() => _buildBarButton(
                icon: Icons.sort_rounded,
                label: controller.sortOptions[controller.selectedSort.value] ??
                    'Sort',
                onPressed: controller.showSortDialog,
              )),
          const Spacer(),

          Obx(() => GestureDetector(
                onTap: () => controller.showGridView.value =
                    !controller.showGridView.value,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: lightBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: secondary.withOpacity(0.2)),
                  ),
                  child: Icon(
                    controller.showGridView.value
                        ? Icons.view_list_rounded
                        : Icons.grid_view_rounded,
                    size: 18,
                    color: secondary,
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildBarButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: lightBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: secondary.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: secondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── ACTIVE FILTER BAR ─────────────────────────────────────────────────────
  Widget _buildActiveFilterBar() {
    return Obx(() {
      final hasActiveFilter =
          controller.selectedCategory.value != 'All' ||
              controller.selectedCompany.value != 'All' ||
              controller.searchQuery.value.isNotEmpty ||
              controller.selectedPrescriptionType.value != 'All' ||
              controller.priceRange.value < controller.maxPrice.value;

      if (!hasActiveFilter) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: secondary.withOpacity(0.08),
          border: Border(
              bottom: BorderSide(color: secondary.withOpacity(0.15))),
        ),
        child: Row(
          children: [
            Icon(Icons.filter_list, size: 15, color: secondary),
            const SizedBox(width: 8),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (controller.selectedCompany.value != 'All' &&
                        controller.selectedCategory.value != 'All')
                      _buildActiveChip(
                        '${controller.selectedCompany.value} > ${controller.selectedCategory.value}',
                        Icons.filter_alt,
                        () {
                          controller.clearFilter('company');
                          controller.clearFilter('category');
                        },
                      )
                    else ...[
                      if (controller.selectedCompany.value != 'All')
                        _buildActiveChip(
                          'Company: ${controller.selectedCompany.value}',
                          Icons.business_rounded,
                          () => controller.clearFilter('company'),
                        ),
                      if (controller.selectedCategory.value != 'All')
                        _buildActiveChip(
                          'Category: ${controller.selectedCategory.value}',
                          Icons.category_rounded,
                          () => controller.clearFilter('category'),
                        ),
                    ],
                    if (controller.selectedPrescriptionType.value != 'All')
                      _buildActiveChip(
                        'Rx: ${controller.selectedPrescriptionType.value}',
                        Icons.medical_services_rounded,
                        () => controller.clearFilter('prescription'),
                      ),
                    if (controller.priceRange.value < controller.maxPrice.value)
                      _buildActiveChip(
                        'Max: ₹${controller.priceRange.value.toInt()}',
                        Icons.currency_rupee_rounded,
                        () => controller.clearFilter('price'),
                      ),
                    if (controller.searchQuery.value.isNotEmpty)
                      _buildActiveChip(
                        'Search: ${controller.searchQuery.value}',
                        Icons.search_rounded,
                        () => controller.clearFilter('search'),
                      ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: controller.clearAllFilters,
              child: const Text(
                'Clear All',
                style: TextStyle(
                  fontSize: 12,
                  color: secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildActiveChip(
      String label, IconData icon, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: secondary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: secondary),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
                fontSize: 11, color: primary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 13, color: secondary),
          ),
        ],
      ),
    );
  }

  // ─── PRODUCTS CONTENT ──────────────────────────────────────────────────────
  Widget _buildProductsContent() {
    return Obx(() {
      if (controller.isLoading.value && controller.products.isEmpty) {
        return _buildLoading();
      }
      if (controller.errorMessage.isNotEmpty && controller.products.isEmpty) {
        return _buildErrorState();
      }
      if (controller.filteredProducts.isEmpty) {
        return _buildEmptyState();
      }
      return _buildProductsList();
    });
  }

  Widget _buildProductsList() {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification.metrics.pixels ==
            scrollNotification.metrics.maxScrollExtent) {
          controller.loadMoreProducts();
        }
        return false;
      },
      child: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => controller.refreshProducts(),
              color: secondary,
              child: Obx(() => controller.showGridView.value
                  ? _buildGridView()
                  : _buildListView()),
            ),
          ),
          Obx(() => controller.isLoadingMore.value
              ? Container(
                  padding: const EdgeInsets.all(14),
                  child: const CircularProgressIndicator(
                      strokeWidth: 2, color: secondary),
                )
              : const SizedBox()),
        ],
      ),
    );
  }

  // ─── GRID VIEW ─────────────────────────────────────────────────────────────
  Widget _buildGridView() {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.6,
      ),
      itemCount: controller.filteredProducts.length,
      itemBuilder: (context, index) {
        return _buildProductCard(controller.filteredProducts[index]);
      },
    );
  }

  // ─── LIST VIEW ─────────────────────────────────────────────────────────────
  Widget _buildListView() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: controller.filteredProducts.length,
      itemBuilder: (context, index) {
        return _buildProductListItem(controller.filteredProducts[index]);
      },
    );
  }

  // ─── PRODUCT CARD (GRID) ───────────────────────────────────────────────────
  Widget _buildProductCard(Product product) {
    final fullImageUrl = getFullImageUrl(
        product.images.isNotEmpty ? product.images[0] : '');
    
    // Parse prices from API fields
    final double sellingPrice = product.price ?? 0.0;
    final double mrpPrice = double.tryParse(product.mrpPrice) ?? 0.0;
    final bool hasDiscount = mrpPrice > sellingPrice;
    
    // Discount range text
    String discountRange = '';
    if (product.discountMin > 0 && product.discountMax > 0) {
      discountRange = '${product.discountMin}% - ${product.discountMax}%';
    } else if (product.discountPercent > 0) {
      discountRange = '${product.discountPercent}% OFF';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Get.toNamed('/product-details/${product.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image without discount badge
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Container(
                height: 120,
                width: double.infinity,
                color: lightBg,
                child: fullImageUrl.isNotEmpty
                    ? Image.network(
                        fullImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.medication_rounded,
                              size: 40, color: secondary),
                        ),
                        loadingBuilder: (_, child, progress) => progress == null
                            ? child
                            : const Center(
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: secondary),
                              ),
                      )
                    : const Center(
                        child: Icon(Icons.medication_rounded,
                            size: 40, color: secondary),
                      ),
              ),
            ),

            // Details
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: primary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    product.company.name,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'PTR ',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '₹${sellingPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: secondary,
                                ),
                              ),
                            ],
                          ),
                          if (hasDiscount)
                            Row(
                              children: [
                                const Text(
                                  'MRP ',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  '₹${mrpPrice.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                if (discountRange.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 6),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: discountOrange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        discountRange,
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: discountOrange,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                        ],
                      ),
                      // const Row(
                      //   children: [
                      //     Text('View',
                      //         style: TextStyle(
                      //             fontSize: 11,
                      //             color: secondary,
                      //             fontWeight: FontWeight.w600)),
                      //     SizedBox(width: 2),
                      //     Icon(Icons.arrow_forward_rounded,
                      //         size: 12, color: secondary),
                      //   ],
                      // ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Add to cart button
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [primary, secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ElevatedButton(
                      onPressed: () =>
                          Get.dialog(AddToCartPopup(product: product)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        minimumSize: const Size(double.infinity, 32),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text(
                        'Add to Cart',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
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

  // ─── PRODUCT LIST ITEM ─────────────────────────────────────────────────────
  Widget _buildProductListItem(Product product) {
    final fullImageUrl = getFullImageUrl(
        product.images.isNotEmpty ? product.images[0] : '');
    
    // Parse prices from API fields
    final double sellingPrice = product.price;
    final double mrpPrice = double.tryParse(product.mrpPrice) ?? 0.0;
    final bool hasDiscount = mrpPrice > sellingPrice;
    
    // Discount range text
    String discountRange = '';
    if (product.discountMin > 0 && product.discountMax > 0) {
      discountRange = '${product.discountMin}% - ${product.discountMax}%';
    } else if (product.discountPercent > 0) {
      discountRange = '${product.discountPercent}% OFF';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Get.toNamed('/product-details/${product.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image without discount badge
              Container(
                width: 95,
                height: 95,
                decoration: BoxDecoration(
                  color: lightBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: secondary.withOpacity(0.15)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: fullImageUrl.isNotEmpty
                      ? Image.network(
                          fullImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.medication_rounded,
                                size: 32, color: secondary),
                          ),
                          loadingBuilder: (_, child, progress) =>
                              progress == null
                                  ? child
                                  : const Center(
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: secondary),
                                    ),
                        )
                      : const Center(
                          child: Icon(Icons.medication_rounded,
                              size: 32, color: secondary),
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: primary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      product.company.name,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'PTR ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  '₹${sellingPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: secondary,
                                  ),
                                ),
                              ],
                            ),
                            if (hasDiscount)
                              Row(
                                children: [
                                  const Text(
                                    'MRP ',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    '₹${mrpPrice.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  if (discountRange.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 6),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: discountOrange.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          discountRange,
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                            color: discountOrange,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [primary, secondary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ElevatedButton(
                            onPressed: () =>
                                Get.dialog(AddToCartPopup(product: product)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 8),
                            ),
                            child: const Text(
                              'Add',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                            ),
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
      ),
    );
  }

  // ─── STATES ────────────────────────────────────────────────────────────────
  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const CircularProgressIndicator(
                color: secondary, strokeWidth: 3),
          ),
          const SizedBox(height: 16),
          const Text(
            'Loading products...',
            style: TextStyle(
                fontSize: 14, color: secondary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline_rounded,
                  size: 52, color: Colors.orange[400]),
            ),
            const SizedBox(height: 20),
            const Text(
              'Failed to load products',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700, color: primary),
            ),
            const SizedBox(height: 8),
            Obx(() => Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                )),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [primary, secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton.icon(
                onPressed: () => controller.loadProducts(),
                icon: const Icon(Icons.refresh_rounded,
                    color: Colors.white, size: 18),
                label: const Text('Try Again',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primary.withOpacity(0.1),
                    secondary.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.inventory_2_outlined,
                  size: 52, color: secondary),
            ),
            const SizedBox(height: 20),
            const Text(
              'No products found',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700, color: primary),
            ),
            const SizedBox(height: 8),
            Obx(() => Text(
                  controller.searchQuery.value.isNotEmpty
                      ? 'Try a different search term'
                      : 'No products available at the moment',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                )),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [primary, secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton.icon(
                onPressed: controller.clearAllFilters,
                icon: const Icon(Icons.filter_alt_off_rounded,
                    color: Colors.white, size: 18),
                label: const Text('Clear Filters',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}