import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../controllers/company_division_controller.dart';

class CompanyDivisionView extends GetView<CompanyDivisionController> {
  const CompanyDivisionView({Key? key}) : super(key: key);

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
                onRefresh: controller.refreshDivisions,
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
                          // _buildHeader(),
                          // const SizedBox(height: 16),
                          // _buildFilterChips(),
                          // const SizedBox(height: 16),
                        ]),
                      ),
                    ),
                    _buildDivisionsList(),
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
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back, color: Color(0xFF111261)),
          ),
          const SizedBox(width: 8),

          /// Main title area
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// LEFT SIDE (TEXT CONTENT)
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
                                'Select a division',
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
                                'Divisions from',
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
                            'Company Divisions',
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
                              ? 'Choose a division to view products from ${controller.selectedVendorName.value}'
                              : controller.isCompanyFiltered.value
                              ? 'Select a division to view products from ${controller.selectedCompanyName.value}'
                              : 'Browse products by company division',
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

                /// RIGHT SIDE (DIVISION COUNT)
                Obx(() => Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B630B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${controller.filteredDivisions.length} divisions',
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
              onChanged: controller.filterDivisions,
              decoration: InputDecoration(
                hintText: 'Search divisions...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey[500]),
              ),
            ),
          ),
          Obx(() => controller.searchQuery.value.isNotEmpty
              ? IconButton(
            onPressed: () {
              controller.filterDivisions('');
            },
            icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
          )
              : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // Widget _buildHeader() {
  //   return Obx(() {
  //     if (controller.isLoading.value && controller.divisions.isEmpty) {
  //       return const SizedBox.shrink();
  //     }

  //     return Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text(
  //           'Available Divisions',
  //           style: TextStyle(
  //             fontSize: 16,
  //             fontWeight: FontWeight.bold,
  //             color: const Color(0xFF111261),
  //           ),
  //         ),
  //         Text(
  //           '${controller.filteredDivisions.length} results',
  //           style: TextStyle(
  //             fontSize: 12,
  //             color: Colors.grey[600],
  //           ),
  //         ),
  //       ],
  //     );
  //   });
  // }

  // Widget _buildFilterChips() {
  //   return Obx(() {
  //     final filters = ['All', 'Active', 'Inactive'];

  //     return SingleChildScrollView(
  //       scrollDirection: Axis.horizontal,
  //       child: Row(
  //         children: filters.map((filter) {
  //           final isSelected = controller.selectedFilter.value == filter;
  //           return Padding(
  //             padding: const EdgeInsets.only(right: 8),
  //             child: FilterChip(
  //               selected: isSelected,
  //               label: Text(filter),
  //               onSelected: (selected) {
  //                 if (selected) {
  //                   controller.updateFilter(filter);
  //                 }
  //               },
  //               backgroundColor: Colors.grey[100],
  //               selectedColor: const Color(0xFF0B630B).withOpacity(0.2),
  //               checkmarkColor: const Color(0xFF0B630B),
  //               labelStyle: TextStyle(
  //                 color: isSelected ? const Color(0xFF0B630B) : Colors.black87,
  //                 fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
  //               ),
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(20),
  //                 side: BorderSide(
  //                   color: isSelected
  //                       ? const Color(0xFF0B630B)
  //                       : Colors.grey[300]!,
  //                 ),
  //               ),
  //             ),
  //           );
  //         }).toList(),
  //       ),
  //     );
  //   });
  // }

  Widget _buildDivisionsList() {
    return Obx(() {
      if (controller.isLoading.value && controller.divisions.isEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: const Color(0xFF0B630B),
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading divisions...',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      }

      if (controller.filteredDivisions.isEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.business_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Divisions Found',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    if (controller.isCompanyFiltered.value) {
                      return Text(
                        '${controller.selectedCompanyName.value} has no divisions available',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      );
                    } else {
                      return Text(
                        controller.searchQuery.value.isNotEmpty
                            ? 'No divisions match "${controller.searchQuery.value}"'
                            : 'This company doesn\'t have any divisions yet',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      );
                    }
                  }),
                  const SizedBox(height: 24),

                  // 🔥 NEW: Button to go directly to products page
                  Obx(() {
                    if (controller.isCompanyFiltered.value) {
                      return Column(
                        children: [
                          const Text(
                            'You can still view all products from this company',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Navigate to products page with company filter
                              Get.toNamed(
                                Routes.PRODUCTS,
                                arguments: {
                                  'company': controller.selectedCompanyName.value,
                                  'companyId': controller.selectedCompanyId.value,
                                  'companyData': controller.selectedCompanyData.value,
                                  'filterType': 'company',
                                },
                              );
                            },
                            icon: const Icon(Icons.shopping_bag_outlined),
                            label: const Text('View All Company Products'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0B630B),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  }),

                  const SizedBox(height: 16),

                  // Retry button (existing)
                  ElevatedButton(
                    onPressed: controller.refreshDivisions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: const Color(0xFF111261),
                      elevation: 0,
                    ),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final division = controller.filteredDivisions[index];

              // Check if we need to load more
              if (index == controller.filteredDivisions.length - 5 &&
                  controller.hasMoreData.value) {
                controller.loadMoreDivisions();
              }

              return _buildDivisionCard(division);
            },
            childCount: controller.filteredDivisions.length,
          ),
        ),
      );
    });
  }

  Widget _buildDivisionCard(Map<String, dynamic> division) {
    final icon = controller.getDivisionIcon(division);
    final isActive = division['is_active'] == true;
    final divisionName = division['name'] ?? 'Unknown';
    final description = division['description'] ?? 'No description available';
    final companyName = division['company_name'] ?? '';
    final imageUrl = division['image_url'];

    return GestureDetector(
      onTap: isActive
          ? () {
        controller.navigateToDivisionProducts(division);
      }
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
          child: Row(
            children: [
              // Division Icon/Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                  image: imageUrl != null
                      ? DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: imageUrl == null
                    ? Center(
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                )
                    : null,
              ),

              const SizedBox(width: 12),

              // Division Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            divisionName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isActive
                                  ? const Color(0xFF111261)
                                  : Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!isActive)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2
                            ),
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
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Company Name (if available)
                    if (companyName.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.business,
                              size: 12,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                companyName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Description
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // View Products Button
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF0B630B)
                            : Colors.grey[300],
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
            ],
          ),
        ),
      ),
    );
  }
}