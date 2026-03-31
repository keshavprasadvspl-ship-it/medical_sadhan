import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class CompanyDivisionSelectionView extends StatefulWidget {
  @override
  _CompanyDivisionSelectionViewState createState() => _CompanyDivisionSelectionViewState();
}

class _CompanyDivisionSelectionViewState extends State<CompanyDivisionSelectionView> {
  final AuthController controller = Get.find<AuthController>();
  final _searchController = TextEditingController();
  final _expandedCompanies = <String>[].obs;
  List<Map<String, dynamic>> _filteredDivisions = [];

  @override
  void initState() {
    super.initState();
    _loadDivisions();
  }

  Future<void> _loadDivisions() async {
    // Load divisions if they are empty
    if (controller.companyDivisions.isEmpty) {
      await controller.loadCompanyDivisions();
    }
    setState(() {
      _filteredDivisions = List.from(controller.companyDivisions);
    });
  }

  void _filterDivisions(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredDivisions = List.from(controller.companyDivisions);
      } else {
        _filteredDivisions = controller.companyDivisions.where((division) {
          final name = division['name']?.toString().toLowerCase() ?? '';
          final companyName = division['company_name']?.toString().toLowerCase() ?? '';
          final description = division['description']?.toString().toLowerCase() ?? '';

          return name.contains(query.toLowerCase()) ||
              companyName.contains(query.toLowerCase()) ||
              description.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _toggleCompanyExpansion(String companyId) {
    if (_expandedCompanies.contains(companyId)) {
      _expandedCompanies.remove(companyId);
    } else {
      _expandedCompanies.add(companyId);
    }
  }

  int _getSelectedCount() {
    return controller.selectedDivisions.length;
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
                if (controller.isLoadingDivisions.value && controller.companyDivisions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          color: Color(0xFF0B630B),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading company divisions...',
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
                      _buildDivisionsList(),
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
                      'Select Company Divisions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111261),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.isLoggedIn.value ? 'Step 2 of 2' : 'Select Divisions',
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
            '${controller.companyDivisions.length} divisions available',
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
                hintText: 'Search divisions or companies...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
              onChanged: _filterDivisions,
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              onPressed: () {
                _searchController.clear();
                _filterDivisions('');
              },
              icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  Widget _buildDivisionsList() {
    if (_filteredDivisions.isEmpty && !controller.isLoadingDivisions.value) {
      return SizedBox(
        height: 300,
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
                'No divisions found',
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
                onPressed: _loadDivisions,
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

    // Group divisions by company
    Map<String, List<Map<String, dynamic>>> groupedDivisions = {};
    for (var division in _filteredDivisions) {
      final companyId = division['company_id']?.toString() ?? 'unknown';
      final companyName = division['company_name']?.toString() ?? 'Unknown Company';

      if (!groupedDivisions.containsKey(companyId)) {
        groupedDivisions[companyId] = [];
      }
      groupedDivisions[companyId]!.add(division);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Company Divisions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111261),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Select the divisions you want to access',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 20),

        // List of companies with their divisions
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: groupedDivisions.keys.length,
          itemBuilder: (context, index) {
            final companyId = groupedDivisions.keys.elementAt(index);
            final divisions = groupedDivisions[companyId]!;
            final companyName = divisions.first['company_name']?.toString() ?? 'Unknown Company';

            return Obx(() => _buildCompanyCard(
              companyId: companyId,
              companyName: companyName,
              divisions: divisions,
            ));
          },
        ),
      ],
    );
  }

  Widget _buildCompanyCard({
    required String companyId,
    required String companyName,
    required List<Map<String, dynamic>> divisions,
  }) {
    final isExpanded = _expandedCompanies.contains(companyId);

    // Check if any divisions from this company are selected
    final hasSelectedDivisions = controller.selectedDivisions
        .any((div) => div['companyId'] == companyId);

    // Determine border color based on selection state
    Color borderColor = hasSelectedDivisions
        ? const Color(0xFF0B630B).withOpacity(0.5)
        : Colors.grey[200]!;
    double borderWidth = hasSelectedDivisions ? 1.5 : 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: hasSelectedDivisions
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
          // Company Header
          GestureDetector(
            onTap: () => _toggleCompanyExpansion(companyId),
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
                    child: const Icon(
                      Icons.business,
                      size: 20,
                      color: Color(0xFF111261),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          companyName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: hasSelectedDivisions
                                ? const Color(0xFF0B630B)
                                : const Color(0xFF111261),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${divisions.length} divisions',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
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

          // Divisions (if expanded)
          if (isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  // Quick select/deselect all divisions option
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Text(
                          'Divisions:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            // Select all divisions for this company
                            for (var division in divisions) {
                              controller.selectDivision({
                                'id': division['id'].toString(),
                                'name': division['name']?.toString() ?? 'Unknown',
                                'companyId': companyId,
                                'companyName': companyName,
                                'description': division['description']?.toString() ?? '',
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
                            // Deselect all divisions for this company
                            for (var division in divisions) {
                              controller.deselectDivision(division['id'].toString());
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

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: divisions.length,
                    itemBuilder: (context, index) {
                      final division = divisions[index];
                      return Obx(() => _buildDivisionCard(
                        companyId: companyId,
                        companyName: companyName,
                        division: division,
                      ));
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDivisionCard({
    required String companyId,
    required String companyName,
    required Map<String, dynamic> division,
  }) {
    final isSelected = controller.selectedDivisions
        .any((d) => d['id'] == division['id'].toString());

    final divisionName = division['name']?.toString() ?? 'Unknown';
    final description = division['description']?.toString() ?? '';
    final imageUrl = division['image_url'];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF0B630B).withOpacity(0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF0B630B)
              : Colors.grey[200]!,
        ),
      ),
      child: InkWell(
        onTap: () {
          controller.toggleDivisionSelection({
            'id': division['id'].toString(),
            'name': divisionName,
            'companyId': companyId,
            'companyName': companyName,
            'description': description,
            'image_url': imageUrl,
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Division Icon/Image
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(8),
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
                    _getDivisionIcon(divisionName),
                    style: const TextStyle(fontSize: 20),
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
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? const Color(0xFF0B630B)
                                  : const Color(0xFF111261),
                            ),
                          ),
                        ),
                        // Selection Checkbox
                        Container(
                          width: 20,
                          height: 20,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF0B630B)
                                : Colors.transparent,
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
                      ],
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.business,
                          size: 10,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            companyName,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[500],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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

  String _getDivisionIcon(String divisionName) {
    final name = divisionName.toLowerCase();

    if (name.contains('marketing') || name.contains('sales')) return '📊';
    if (name.contains('research') || name.contains('development') || name.contains('r&d')) return '🔬';
    if (name.contains('quality') || name.contains('assurance') || name.contains('control')) return '✅';
    if (name.contains('production') || name.contains('manufacturing')) return '🏭';
    if (name.contains('finance') || name.contains('accounting')) return '💰';
    if (name.contains('human') || name.contains('resource') || name.contains('hr')) return '👥';
    if (name.contains('information') || name.contains('technology') || name.contains('it')) return '💻';
    if (name.contains('customer') || name.contains('support')) return '🤝';
    if (name.contains('logistics') || name.contains('supply')) return '🚚';
    if (name.contains('legal') || name.contains('compliance')) return '⚖️';
    if (name.contains('pharma') || name.contains('medical')) return '💊';
    if (name.contains('device') || name.contains('equipment')) return '🩺';

    return '🏢';
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
              child: const Text('Back'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: controller.selectedDivisions.isNotEmpty
                  ? () {
                // ✅ Complete onboarding with all selections
                controller.completeOnboarding();
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: controller.selectedDivisions.isNotEmpty
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
                  const Text('Complete Setup'),
                  const SizedBox(width: 8),
                  const Icon(Icons.done, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }
}