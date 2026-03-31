import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../controllers/vendors_list_view_controller.dart';

class VendorsListView extends GetView<VendorsListViewController> {
  const VendorsListView({Key? key}) : super(key: key);

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
                onRefresh: controller.refreshVendors,
                color: const Color(0xFF0B630B),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildSearchBar(),
                          const SizedBox(height: 16),
                          // _buildFilterChips(),
                          // const SizedBox(height: 20),
                          _buildHeader(),
                          const SizedBox(height: 16),
                        ]),
                      ),
                    ),
                    _buildVendorsGrid(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back, color: Color(0xFF111261)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'All Vendors',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111261),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Browse and discover vendors',
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
                  color: const Color.fromARGB(255, 99, 39, 11).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Obx(() => Text(
                  '${controller.filteredVendors.length} vendors',
                  style: const TextStyle(
                    color: Color(0xFF0B630B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                )),
              ),
            ],
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
              onChanged: controller.updateSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search by name, category, GST...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey[500]),
              ),
            )
          ),
          Obx(() => controller.searchQuery.value.isNotEmpty
              ? IconButton(
            onPressed: controller.clearSearch,
            icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
          )
              : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // Widget _buildFilterChips() {
  //   return Obx(() => SingleChildScrollView(
  //     scrollDirection: Axis.horizontal,
  //     child: Row(
  //       children: controller.filterOptions.map((filter) {
  //         return Padding(
  //           padding: const EdgeInsets.only(right: 8),
  //           child: FilterChip(
  //             label: Text(filter),
  //             selected: controller.selectedFilter.value == filter,
  //             onSelected: (selected) => controller.updateFilter(filter),
  //             backgroundColor: Colors.white,
  //             selectedColor: const Color(0xFF0B630B).withOpacity(0.1),
  //             checkmarkColor: const Color(0xFF0B630B),
  //             labelStyle: TextStyle(
  //               color: controller.selectedFilter.value == filter
  //                   ? const Color(0xFF0B630B)
  //                   : Colors.grey[700],
  //               fontSize: 12,
  //               fontWeight: controller.selectedFilter.value == filter
  //                   ? FontWeight.w600
  //                   : FontWeight.normal,
  //             ),
  //             side: BorderSide(
  //               color: controller.selectedFilter.value == filter
  //                   ? const Color(0xFF0B630B)
  //                   : Colors.grey[300]!,
  //             ),
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(20),
  //             ),
  //           ),
  //         );
  //       }).toList(),
  //     ),
  //   ));
  // }

  Widget _buildHeader() {
    return Obx(() {
      if (controller.isLoading.value && controller.vendors.isEmpty) {
        return const SizedBox.shrink();
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Available Vendors',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111261),
            ),
          ),
          Text(
            '${controller.filteredVendors.length} results',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildVendorsGrid() {
    return Obx(() {
      if (controller.isLoading.value && controller.vendors.isEmpty) {
        return const SliverFillRemaining(
          child: Center(
            child: CircularProgressIndicator(
              color: Color(0xFF0B630B),
            ),
          ),
        );
      }

      if (controller.filteredVendors.isEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.storefront_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No vendors found',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() => Text(
                  controller.searchQuery.value.isNotEmpty ||
                      controller.selectedFilter.value != 'All'
                      ? 'Try adjusting your search or filters'
                      : 'Pull down to refresh',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                )),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.refreshVendors,
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
              final vendor = controller.filteredVendors[index];
              return _buildVendorCard(vendor);
            },
            childCount: controller.filteredVendors.length,
          ),
        ),
      );
    });
  }

  Widget _buildVendorCard(Map<String, dynamic> vendor) {
    // return Obx(() {
    print("vendor");
    print(vendor);
      final vendorName = controller.getVendorName(vendor);
      final isActive = controller.isVendorActive(vendor);
      final logoUrl = controller.getVendorLogoUrl(vendor);
      final vendorCategory = controller.getVendorCategory(vendor);
      final rating = controller.getVendorRating(vendor);
      final isVerified = controller.isVendorVerified(vendor);
      final businessType = controller.getVendorBusinessType(vendor);
      final gstNumber = controller.getVendorGST(vendor);

      return GestureDetector(
        onTap: isActive ? () {
          Get.toNamed(
            Routes.VENDOR_PRODUCT_STORE,
            arguments: {
              'vendor_id': vendor['user_details']['id'],
              'vendor_name': vendorName,
            },
          );
        } : null,
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
                // Logo and Rating Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[100]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: logoUrl.isNotEmpty
                            ? Image.network(
                          logoUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.store,
                                size: 25,
                                color: Colors.grey[400],
                              ),
                            );
                          },
                        )
                            : Center(
                          child: Icon(
                            Icons.store,
                            size: 25,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),


                  ],
                ),

                const SizedBox(height: 10),

                // Vendor Name with Verified Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      vendorName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isActive ? const Color(0xFF111261) : Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified,
                        size: 14,
                        color: Color(0xFF0B630B),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 4),

                // Category
                Text(
                  vendorCategory,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                // Business Type Badge
                if (businessType.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B630B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      businessType,
                      style: const TextStyle(
                        fontSize: 8,
                        color: Color(0xFF0B630B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                const SizedBox(height: 8),

                // GST (if available)
                if (gstNumber.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'GST: $gstNumber',
                      style: TextStyle(
                        fontSize: 7,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                const Spacer(),

                // View Button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF0B630B) : Colors.grey[300],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'View Store',
                        style: TextStyle(
                          fontSize: 10,
                          color: isActive ? Colors.white : Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        size: 10,
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
    // });
  }
}