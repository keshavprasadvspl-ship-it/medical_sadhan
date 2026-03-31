// lib/app/modules/order_report/views/order_report_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/order_report_controller.dart';
import '../../../data/models/order_model.dart';

class OrderReportView extends GetView<OrderReportController> {
  const OrderReportView({super.key});

  static const primary = Color(0xFF043734);
  static const secondary = Color(0xFF21827A);
  static const lightBg = Color(0xFFF0F7F6);
  static const cardBg = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Stats Cards
          _buildStatsCards(),

          // Filters Section
          _buildFiltersSection(),

          // Orders List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return _buildLoading();
              }

              if (controller.filteredOrders.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.filteredOrders.length,
                itemBuilder: (context, index) {
                  final order = controller.filteredOrders[index];
                  return _buildOrderCard(order);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: const Icon(Icons.arrow_back, color: Colors.white),
      ),
      title: const Text(
        'Order Reports',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: primary,
      elevation: 0,
      actions: [
        Obx(() => controller.isExporting.value
            ? const Padding(
          padding: EdgeInsets.all(16),
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
        )
            : PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) {
            if (value == 'reset') {
              controller.resetFilters();
            } else if (value == 'pdf') {
              controller.exportAsPDF();
            } else if (value == 'csv') {
              controller.exportAsCSV();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'reset',
              child: Row(
                children: [
                  Icon(Icons.refresh, size: 20),
                  SizedBox(width: 12),
                  Text('Reset Filters'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'pdf',
              child: Row(
                children: [
                  Icon(Icons.picture_as_pdf, size: 20),
                  SizedBox(width: 12),
                  Text('Export as PDF'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'csv',
              child: Row(
                children: [
                  Icon(Icons.table_chart, size: 20),
                  SizedBox(width: 12),
                  Text('Export as CSV'),
                ],
              ),
            ),
          ],
        ),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Obx(() {
      final stats = controller.getStats();

      return Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Orders',
                value: '${stats['totalOrders']}',
                icon: Icons.receipt_long_rounded,
                color: primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Items',
                value: '${stats['totalItems']}',
                icon: Icons.shopping_bag_rounded,
                color: secondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Amount',
                value: '₹${stats['totalAmount'].toStringAsFixed(0)}',
                icon: Icons.currency_rupee_rounded,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

// lib/app/modules/order_report/views/order_report_view.dart

// Only change the agency filter section - remove the length condition
  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period Filter
          _buildFilterLabel(Icons.calendar_today, 'Period'),
          const SizedBox(height: 8),
          Obx(() => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: controller.periodOptions.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildSmallChip(
                    label: entry.value,
                    isSelected: controller.selectedPeriod.value == entry.key,
                    onTap: () => controller.updatePeriod(entry.key),
                  ),
                );
              }).toList(),
            ),
          )),

          // Custom Date Range
          Obx(() {
            if (controller.isCustomRange.value) {
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildDateButton(
                        label: 'Start',
                        date: controller.startDate.value,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: Get.context!,
                            initialDate: controller.startDate.value,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            controller.updateCustomRange(date, controller.endDate.value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDateButton(
                        label: 'End',
                        date: controller.endDate.value,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: Get.context!,
                            initialDate: controller.endDate.value,
                            firstDate: controller.startDate.value,
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            controller.updateCustomRange(controller.startDate.value, date);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          const SizedBox(height: 16),

          // Agency Filter - REMOVED THE LENGTH CHECK
          _buildFilterLabel(Icons.business, 'Agency'),
          const SizedBox(height: 8),
          Obx(() => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: controller.agencies.map((agency) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildSmallChip(
                    label: agency == 'all' ? 'All' : agency,
                    isSelected: controller.selectedAgency.value == agency,
                    onTap: () => controller.updateAgency(agency),
                  ),
                );
              }).toList(),
            ),
          )),

          const SizedBox(height: 16),

          // Payment Method Filter
          _buildFilterLabel(Icons.payment, 'Payment Method'),
          const SizedBox(height: 8),
          Obx(() => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: controller.paymentMethods.map((method) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildPaymentChip(
                    label: method == 'all' ? 'All' : method.toUpperCase(),
                    isSelected: controller.selectedPaymentMethod.value == method,
                    onTap: () => controller.updatePaymentMethod(method),
                    method: method,
                  ),
                );
              }).toList(),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildFilterLabel(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: secondary),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: primary,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? secondary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.transparent : secondary.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : primary,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required String method,
  }) {
    Color getColor() {
      if (method == 'cash') return const Color(0xFF2E7D32);
      if (method == 'challan') return const Color(0xFF1565C0);
      return secondary;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? getColor().withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? getColor() : secondary.withOpacity(0.3),
            width: isSelected ? 1 : 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? getColor() : primary,
          ),
        ),
      ),
    );
  }

  Widget _buildDateButton({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: lightBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: secondary.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$label: ${DateFormat('dd MMM yyyy').format(date)}',
              style: const TextStyle(fontSize: 12),
            ),
            Icon(Icons.calendar_today, size: 14, color: secondary),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (existing code)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primary,
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
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(order.status.icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.orderNumber,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.formattedOrderDate,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.status.displayName,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (order.agency != null) ...[
                  Row(
                    children: [
                      Icon(Icons.business, size: 14, color: secondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          order.agency!,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // Items List - SHOW ITEMS HERE
                _buildItemsList(order),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: order.paymentMethod == 'cash'
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            order.paymentMethod == 'cash'
                                ? Icons.currency_rupee_rounded
                                : Icons.receipt_rounded,
                            size: 12,
                            color: order.paymentMethod == 'cash'
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFF1565C0),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            order.paymentMethod.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: order.paymentMethod == 'cash'
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFF1565C0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '₹${order.finalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),

                // Row(
                //   children: [
                //     _buildInfoChip(
                //       icon: Icons.shopping_bag_rounded,
                //       label: '${order.itemCount} items',
                //     ),
                //     const SizedBox(width: 8),
                //     if (order.discount > 0)
                //       _buildInfoChip(
                //         icon: Icons.local_offer_rounded,
                //         label: '₹${order.discount.toStringAsFixed(2)} off',
                //       ),
                //   ],
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Add this new method to show items list
  Widget _buildItemsList(Order order) {
    return Container(
      decoration: BoxDecoration(
        color: lightBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.shopping_bag, size: 14, color: secondary),
                const SizedBox(width: 8),
                Text(
                  'Items',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: primary,
                  ),
                ),
              ],
            ),
          ),

          // Items List - Each item in a row
          ...order.items.map((item) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey.shade200,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                // Quantity
                Container(
                  width: 30,
                  child: Text(
                    '${item.quantity}${item.addon > 0 ? ' +${item.addon}' : ''}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: secondary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Product Name
                Expanded(
                  child: Text(
                    item.productName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Price
                Text(
                  '₹${item.unitPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),

                const SizedBox(width: 12),

                // Total
                Text(
                  '₹${(item.quantity * item.unitPrice).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
              ],
            ),
          )).toList(),

          // Divider
          Container(
            height: 1,
            color: Colors.grey.shade200,
          ),

          // Subtotal
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  '₹${order.subtotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: primary,
                  ),
                ),
              ],
            ),
          ),

          if (order.discount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Discount',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    '-₹${order.discount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),

          if (order.tax > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tax',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    '₹${order.tax.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: primary,
                    ),
                  ),
                ],
              ),
            ),

          if (order.shippingCharge > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Shipping',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    '₹${order.shippingCharge.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: primary,
                    ),
                  ),
                ],
              ),
            ),

          // Total
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
                Text(
                  '₹${order.finalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: lightBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: secondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: secondary,
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            'Loading orders...',
            style: TextStyle(
              fontSize: 14,
              color: secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              color: lightBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 50,
              color: secondary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No orders found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try changing your filters',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => controller.resetFilters(),
            style: ElevatedButton.styleFrom(
              backgroundColor: secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Reset Filters'),
          ),
        ],
      ),
    );
  }
}