// lib/app/modules/companies/views/companies_list_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/company_model.dart';
import '../controllers/companies_list_controller.dart';

class CompaniesListView extends GetView<CompaniesListViewController> {
  const CompaniesListView({Key? key}) : super(key: key);

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
                onRefresh: controller.refreshCompanies,
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
                    _buildCompaniesGrid(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


// Update the _buildAppBar method to show vendor context
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                  if (controller.isVendorFiltered.value) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Companies from',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          controller.selectedVendorName.value,
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
                      'Companies',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111261),
                      ),
                    );
                  }
                }),
                const SizedBox(height: 4),
                Obx(() => Text(
                  controller.isVendorFiltered.value
                      ? 'Select a company to view categories'
                      : 'Browse pharmaceutical companies',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                )),
              ],
            ),
          ),
          Obx(() => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0B630B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${controller.filteredCompanies.length} companies',
              style: const TextStyle(
                color: Color(0xFF0B630B),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          )),
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
                hintText: 'Search by company name...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey[500]),
              ),
            ),
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

  Widget _buildHeader() {
    return Obx(() {
      if (controller.isLoading.value && controller.companies.isEmpty) {
        return const SizedBox.shrink();
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'All Companies',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111261),
            ),
          ),
          Obx(() => Text(
            '${controller.filteredCompanies.length} results',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          )),
        ],
      );
    });
  }

  Widget _buildCompaniesGrid() {
    return Obx(() {
      print("Building grid - State:");
      print("  isLoading: ${controller.isLoading.value}");
      print("  companies length: ${controller.companies.length}");
      print("  filteredCompanies length: ${controller.filteredCompanies.length}");

      if (controller.filteredCompanies.isEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.business_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  controller.companies.isEmpty
                      ? 'No companies found'
                      : 'No matching companies',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() {
                  if (controller.companies.isEmpty) {
                    return Column(
                      children: [
                        if (controller.isVendorFiltered.value)
                          Text(
                            'No companies available for ${controller.selectedVendorName.value}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          )
                        else
                          Text(
                            'Pull down to refresh',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        if (controller.errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Error: ${controller.errorMessage.value}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    );
                  } else if (controller.searchQuery.value.isNotEmpty) {
                    return Text(
                      'No companies match "${controller.searchQuery.value}"',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.refreshCompanies,
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

      if (controller.filteredCompanies.isEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.business_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  controller.companies.isEmpty
                      ? 'No companies found'
                      : 'No matching companies',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() {
                  if (controller.companies.isEmpty) {
                    return Column(
                      children: [
                        Text(
                          'Pull down to refresh',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                        if (controller.errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Error: ${controller.errorMessage.value}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    );
                  } else if (controller.searchQuery.value.isNotEmpty) {
                    return Text(
                      'No companies match "${controller.searchQuery.value}"',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.refreshCompanies,
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
            childAspectRatio: 0.95,
          ),
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final company = controller.filteredCompanies[index];
              return _buildCompanyCard(company);
            },
            childCount: controller.filteredCompanies.length,
          ),
        ),
      );
    });
  }

  Widget _buildCompanyCard(CompanyModel company) {
    return GestureDetector(
      onTap: () => controller.navigateToCompanyProducts(company),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
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
              // Company Logo
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: company.logoUrl.isNotEmpty
                      ? Image.network(
                    company.logoUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print("Error loading image for ${company.name}: $error");
                      return _buildPlaceholderLogo();
                    },
                  )
                      : _buildPlaceholderLogo(),
                ),
              ),

              const SizedBox(height: 12),

              // Company Name
              Text(
                company.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111261),
                ),
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),

              // const SizedBox(height: 4),
              //
              // // Company Type
              // Container(
              //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              //   decoration: BoxDecoration(
              //     color: const Color(0xFF0B630B).withOpacity(0.1),
              //     borderRadius: BorderRadius.circular(12),
              //   ),
              //   child: Text(
              //     controller.getCompanyTypeDisplay(company.type),
              //     style: const TextStyle(
              //       fontSize: 10,
              //       color: Color(0xFF0B630B),
              //       fontWeight: FontWeight.w500,
              //     ),
              //   ),
              // ),

              const Spacer(),

              // View Products Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B630B),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'View Products',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      size: 11,
                      color: Colors.white,
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

  Widget _buildPlaceholderLogo() {
    return Center(
      child: Icon(
        Icons.apartment,
        size: 35,
        color: Colors.grey[400],
      ),
    );
  }
}