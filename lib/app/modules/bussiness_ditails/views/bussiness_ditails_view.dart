import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/bussiness_ditails_controller.dart';

class BusinessDetailsView extends GetView<BusinessDetailsController> {
  const BusinessDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Business Details',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF0B630B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => controller.fetchBusinessDetails(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF0B630B),
            ),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return _buildErrorView();
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchBusinessDetails(),
          color: const Color(0xFF0B630B),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Business Header Card
                _buildBusinessHeader(),
                const SizedBox(height: 20),

                // Verification Status Card
                _buildVerificationCard(),
                const SizedBox(height: 16),

                // Business Information Card
                _buildInfoCard(
                  title: 'Business Information',
                  icon: Icons.business_outlined,
                  children: [
                    _buildDetailRow(
                      icon: Icons.business_outlined,
                      label: 'Business Name',
                      value: controller.businessName.value,
                      isImportant: true,
                    ),
                    _buildDetailRow(
                      icon: Icons.category_outlined,
                      label: 'Business Type',
                      value: controller.businessType.value,
                    ),
                    _buildDetailRow(
                      icon: Icons.person_outline,
                      label: 'Contact Person',
                      value: controller.contactPerson.value,
                    ),
                    _buildDetailRow(
                      icon: Icons.work_outlined,
                      label: 'Designation',
                      value: controller.designation.value,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Registration Details Card
                _buildInfoCard(
                  title: 'Registration Details',
                  icon: Icons.description_outlined,
                  children: [
                    _buildDetailRow(
                      icon: Icons.numbers_outlined,
                      label: 'GST Number',
                      value: controller.gstNumber.value,
                    ),
                    _buildDetailRow(
                      icon: Icons.description_outlined,
                      label: 'License Number',
                      value: controller.licenseNumber.value,
                    ),
                    _buildDetailRow(
                      icon: Icons.assignment_outlined,
                      label: 'Registration Number',
                      value: controller.businessRegistrationNumber.value,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Financial Details Card
                _buildInfoCard(
                  title: 'Financial Details',
                  icon: Icons.account_balance_wallet_outlined,
                  children: [
                    _buildDetailRow(
                      icon: Icons.trending_up_outlined,
                      label: 'Average Monthly Purchase',
                      value: controller.getFormattedAveragePurchase(),
                    ),
                    _buildDetailRow(
                      icon: Icons.credit_card_outlined,
                      label: 'Credit Limit',
                      value: controller.getFormattedCreditLimit(),
                    ),
                    _buildDetailRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Credit Days',
                      value: '${controller.creditDays.value} days',
                    ),
                    _buildDetailRow(
                      icon: Icons.payment_outlined,
                      label: 'Preferred Payment',
                      value: GetStringUtils(controller.preferredPaymentMethod.value).capitalizeFirst ?? '',
                    ),
                    _buildDetailRow(
                      icon: Icons.category_outlined,
                      label: 'Buyer Category',
                      value: GetStringUtils(controller.buyerCategory.value).capitalizeFirst ?? '',
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Credit Usage Card
                _buildCreditUsageCard(),
                const SizedBox(height: 16),

                // Additional Details Card
                _buildInfoCard(
                  title: 'Additional Details',
                  icon: Icons.info_outlined,
                  children: [
                    _buildDetailRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Establishment Year',
                      value: controller.establishmentYear.value.toString(),
                    ),
                    _buildDetailRow(
                      icon: Icons.business_outlined,
                      label: 'Total Branches',
                      value: controller.totalBranches.value.toString(),
                    ),
                    if (controller.notes.value.isNotEmpty)
                      _buildDetailRow(
                        icon: Icons.note_outlined,
                        label: 'Notes',
                        value: controller.notes.value,
                        isMultiline: true,
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // Edit Button
                _buildEditButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBusinessHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B630B), Color(0xFF1A8C1A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B630B).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Business Avatar
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Text(
                controller.getInitials(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Business Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.businessName.value.isNotEmpty
                      ? controller.businessName.value
                      : 'Business Name',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.userEmail.value,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  controller.userPhone.value,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: controller.getVerificationColor().withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: controller.getVerificationColor().withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: controller.getVerificationColor().withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              controller.isBuyerVerified.value
                  ? Icons.verified
                  : Icons.pending_outlined,
              color: controller.getVerificationColor(),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.getVerificationStatus(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: controller.getVerificationColor(),
                  ),
                ),
                if (controller.isBuyerVerified.value &&
                    controller.verifiedBy.value.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Verified by: ${controller.verifiedBy.value}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                if (!controller.isBuyerVerified.value) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Your business verification is in progress',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditUsageCard() {
    final double usedPercentage = controller.creditLimit.value > 0
        ? (controller.creditUsed.value / controller.creditLimit.value) * 100
        : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B630B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  color: Color(0xFF0B630B),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Credit Usage',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0B630B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCreditMetric(
                'Credit Limit',
                controller.getFormattedCreditLimit(),
                Icons.account_balance_wallet_outlined,
              ),
              _buildCreditMetric(
                'Credit Used',
                '₹ ${controller.creditUsed.value.toStringAsFixed(2)}',
                Icons.remove_circle_outline,
              ),
              _buildCreditMetric(
                'Available',
                '₹ ${controller.creditAvailable.value.toStringAsFixed(2)}',
                Icons.check_circle_outline,
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: usedPercentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              usedPercentage > 80 ? Colors.orange : const Color(0xFF0B630B),
            ),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
            '${usedPercentage.toStringAsFixed(1)}% of credit limit used',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditMetric(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFF0B630B).withOpacity(0.7),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0B630B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0B630B).withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B630B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: const Color(0xFF0B630B), size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0B630B),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    bool isImportant = false,
    bool isMultiline = false,
  }) {
    if (value.isEmpty && !isImportant) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF0B630B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF0B630B),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : 'Not provided',
                  style: TextStyle(
                    fontSize: isImportant ? 16 : 14,
                    fontWeight: isImportant ? FontWeight.w600 : FontWeight.normal,
                    color: value.isNotEmpty
                        ? (isImportant ? const Color(0xFF0B630B) : Colors.grey[800])
                        : Colors.grey[400],
                    fontStyle: value.isEmpty ? FontStyle.italic : FontStyle.normal,
                  ),
                  maxLines: isMultiline ? 5 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton() {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B630B).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0B630B),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        onPressed: controller.navigateToEditProfile,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.edit_outlined, size: 20),
            SizedBox(width: 8),
            Text(
              'Edit Business Profile',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: controller.fetchBusinessDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B630B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension for string capitalization
extension StringExtension on String {
  String capitalizeFirst() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}