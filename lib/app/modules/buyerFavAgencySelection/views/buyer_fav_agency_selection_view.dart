import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/buyer_fav_agency_selection_controller.dart';

class BuyerFavAgencySelectionView extends GetView<BuyerFavAgencySelectionController> {
  const BuyerFavAgencySelectionView({Key? key}) : super(key: key);

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
                onRefresh: controller.refreshAgencies,
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
                          _buildFilterChips(),
                          const SizedBox(height: 16),
                          _buildSelectionActions(),
                          const SizedBox(height: 16),
                          _buildHeader(),
                          const SizedBox(height: 16),
                        ]),
                      ),
                    ),
                    _buildAgenciesGrid(),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
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
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
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
                const Text(
                  'Select Favorite Agencies',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111261),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose agencies you want to follow',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
            child: Obx(() => Text(
              '${controller.filteredAgencies.length} agencies',
              style: const TextStyle(
                color: Color(0xFF0B630B),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            )),
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
            ),
          ),
          Obx(() => controller.searchQuery.value.isNotEmpty
              ? IconButton(
            onPressed: controller.clearSearch,
            icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
          )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Obx(() => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: controller.filterOptions.map((filter) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: controller.selectedFilter.value == filter,
              onSelected: (selected) => controller.updateFilter(filter),
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF0B630B).withOpacity(0.1),
              checkmarkColor: const Color(0xFF0B630B),
              labelStyle: TextStyle(
                color: controller.selectedFilter.value == filter
                    ? const Color(0xFF0B630B)
                    : Colors.grey[700],
                fontSize: 12,
                fontWeight: controller.selectedFilter.value == filter
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
              side: BorderSide(
                color: controller.selectedFilter.value == filter
                    ? const Color(0xFF0B630B)
                    : Colors.grey[300]!,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        }).toList(),
      ),
    ));
  }

  Widget _buildSelectionActions() {
    return Obx(() {
      if (controller.filteredAgencies.isEmpty) return const SizedBox.shrink();

      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.selectAllOnPage,
                  icon: const Icon(Icons.select_all, size: 16),
                  label: const Text('Select All'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0B630B),
                    side: const BorderSide(color: Color(0xFF0B630B)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.clearAllSelections,
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: const Text('Clear All'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),

        ],
      );
    });
  }

  Widget _buildHeader() {
    return Obx(() {
      if (controller.isLoading.value && controller.agencies.isEmpty) {
        return const SizedBox.shrink();
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Available Agencies',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111261),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF0B630B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Obx(() => Text(
              '${controller.getSelectedCount()} selected',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0B630B),
              ),
            )),
          ),
        ],
      );
    });
  }

  Widget _buildAgenciesGrid() {
    return Obx(() {
      if (controller.isLoading.value && controller.agencies.isEmpty) {
        return const SliverFillRemaining(
          child: Center(
            child: CircularProgressIndicator(color: Color(0xFF0B630B)),
          ),
        );
      }

      if (controller.filteredAgencies.isEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.storefront_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No agencies found',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.searchQuery.value.isNotEmpty || controller.selectedFilter.value != 'All'
                      ? 'Try adjusting your search or filters'
                      : 'Pull down to refresh',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.refreshAgencies,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B630B)),
                  child: const Text('Retry', style: TextStyle(color: Colors.white)),
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
            childAspectRatio: 0.85,
          ),
          delegate: SliverChildBuilderDelegate(
                (context, index) => _buildAgencyCard(controller.filteredAgencies[index]),
            childCount: controller.filteredAgencies.length,
          ),
        ),
      );
    });
  }

  Widget _buildAgencyCard(Map<String, dynamic> agency) {
    final agencyId = controller.getAgencyId(agency);
    final agencyName = controller.getAgencyName(agency);
    final isActive = controller.isAgencyActive(agency);
    final logoUrl = controller.getAgencyLogoUrl(agency);
    final agencyCategory = controller.getAgencyCategory(agency);
    final rating = controller.getAgencyRating(agency);
    final isVerified = controller.isAgencyVerified(agency);
    final businessType = controller.getAgencyBusinessType(agency);
    final gstNumber = controller.getAgencyGST(agency);

    return Obx(() {
      final isSelected = controller.isAgencySelected(agencyId);

      return GestureDetector(
        onTap: isActive ? () => controller.toggleAgencySelection(agencyId) : null,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0B630B).withOpacity(0.05) : (isActive ? Colors.white : Colors.grey[100]),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF0B630B) : (isActive ? Colors.grey[300]! : Colors.grey[400]!),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: Stack(
            children: [
              if (isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Color(0xFF0B630B), shape: BoxShape.circle),
                    child: const Icon(Icons.check, size: 12, color: Colors.white),
                  ),
                ),
              if (!isActive)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.black.withOpacity(0.3)),
                    child: const Center(child: Text('Inactive', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: logoUrl.isNotEmpty
                            ? Image.network(logoUrl, width: 60, height: 60, fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Center(child: Icon(Icons.store, size: 30, color: Colors.grey[400])))
                            : Center(child: Icon(Icons.store, size: 30, color: Colors.grey[400])),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(agencyName,
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isActive ? const Color(0xFF111261) : Colors.grey[600]),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        if (isVerified && isActive) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, size: 14, color: Color(0xFF0B630B)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, size: 12, color: rating != '0.0' ? Colors.amber : Colors.grey[400]),
                        const SizedBox(width: 2),
                        Text(rating, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                        const SizedBox(width: 4),
                        Container(width: 3, height: 3, decoration: BoxDecoration(color: Colors.grey[400], shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Flexible(child: Text(agencyCategory, style: TextStyle(fontSize: 10, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (businessType.isNotEmpty && isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: const Color(0xFF0B630B).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text(businessType, style: const TextStyle(fontSize: 9, color: Color(0xFF0B630B), fontWeight: FontWeight.w500)),
                      ),
                    const SizedBox(height: 6),
                    if (gstNumber.isNotEmpty && isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(4)),
                        child: Text('GST: $gstNumber', style: TextStyle(fontSize: 8, color: Colors.grey[600], fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    const Spacer(),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF0B630B) : (isActive ? Colors.white : Colors.grey[300]),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: isSelected ? const Color(0xFF0B630B) : (isActive ? const Color(0xFF0B630B) : Colors.grey[400]!)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(isSelected ? Icons.check_circle : Icons.add_circle_outline, size: 14,
                              color: isSelected ? Colors.white : (isActive ? const Color(0xFF0B630B) : Colors.grey[600])),
                          const SizedBox(width: 6),
                          Text(isSelected ? 'Selected' : 'Select',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : (isActive ? const Color(0xFF0B630B) : Colors.grey[600]))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildBottomBar() {
    return Obx(() {
      final selectedCount = controller.getSelectedCount();

      if (selectedCount == 0 && !controller.isLoading.value) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$selectedCount ${selectedCount == 1 ? "Agency" : "Agencies"} Selected',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111261))),
                    const SizedBox(height: 4),
                    Text('Tap confirm to save your favorites', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                  ],
                ),
              ),
              Obx(() => ElevatedButton(
                onPressed: controller.isSaving.value ? null : controller.saveSelectedAgencies,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B630B),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: controller.isSaving.value
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Confirm', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
              )),
            ],
          ),
        ),
      );
    });
  }
}