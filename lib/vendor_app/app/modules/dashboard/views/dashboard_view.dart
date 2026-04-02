import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:medical_b2b_app/vendor_app/app/modules/orders/controllers/orders_controller.dart';
import 'package:medical_b2b_app/vendor_app/app/modules/orders/views/cash_order_view.dart';
import 'package:medical_b2b_app/vendor_app/app/modules/orders/views/chalan_orders_view.dart';
import '../../../../../app/data/models/vendors_orders_model.dart';
import '../../../../../app/routes/app_pages.dart';
import '../controllers/dashboard_controller.dart';
import 'package:lottie/lottie.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Medical Dashboard',
              style: TextStyle(
                color: const Color(0xFF1E2A3E),
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            Obx(() => Text(
                  'Welcome back, Vendor #${controller.vendorId.value}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                )),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: const Color(0xFF1E2A3E)),
                onPressed: () => Get.toNamed(Routes.NOTIFICATIONS),
              ),
              Obx(() {
                if (controller.pendingOrders.value > 0) {
                  return Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE74C3C),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${controller.pendingOrders.value}',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  );
                }
                return const SizedBox();
              }),
            ],
          ),
          IconButton(
            onPressed: () async {
              await controller.logout();
            },
            icon: const Icon(Icons.logout, color: Color(0xFF1E2A3E)),
          )
        ],
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async => controller.refreshDashboard(),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (!controller.isLoadingMore.value &&
                        scrollInfo.metrics.pixels >=
                            scrollInfo.metrics.maxScrollExtent - 200) {
                      controller.loadMorePendingOrders();
                    }
                    return true;
                  },
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stats Cards - Medical Theme (3 cards only)
                        GridView.count(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 0.8,
                          children: [
                            _buildMedicalStatCard(
                              'Pending Orders',
                              controller.pendingOrders.value.toString(),
                              Icons.medical_services,
                              const Color(0xFFFF6B6B),
                              const Color(0xFFEE5A5A),
                            ),
                            _buildMedicalStatCard(
                              "Today's Revenue",
                              controller.getFormattedRevenue(
                                  controller.todayRevenue.value),
                              Icons.trending_up,
                              const Color(0xFF5D9BEC),
                              const Color(0xFF4A8FE7),
                            ),
                            _buildMedicalStatCard(
                              'Cancelled',
                              controller.cancelledOrders.value.toString(),
                              Icons.cancel,
                              const Color(0xFFE74C3C),
                              const Color(0xFFD94333),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Stats Summary Row - Enhanced Medical Navigation
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildMedicalSummaryItem(
                                'Total Orders',
                                controller.totalOrders.value.toString(),
                                Icons.shopping_bag_outlined,
                                const Color(0xFF5D9BEC),
                                onTap: () => Get.toNamed(Routes.VENDERS_ORDERS),
                              ),
                              _buildMedicalSummaryItem(
                                'Products',
                                controller.totalProducts.value.toString(),
                                Icons.inventory_2_outlined,
                                const Color(0xFF4ECDC4),
                                onTap: () => Get.toNamed(Routes.VENDORS_PORDUCTS),
                              ),
                              GestureDetector(
                                onTap: () => Get.to(
                                  () => const ChallanOrdersView(),
                                  binding: BindingsBuilder(
                                    () => Get.put(VendorsOrdersController()),
                                  ),
                                ),
                                child: _buildMedicalSummaryItem(
                                  'Challan',
                                  controller.totalOrders.value.toString(),
                                  Icons.receipt_long,
                                  const Color(0xFF9B59B6),
                                  onTap: null,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Get.to(
                                  () => const CashOrdersView(),
                                  binding: BindingsBuilder(
                                    () => Get.put(VendorsOrdersController()),
                                  ),
                                ),
                                child: _buildMedicalSummaryItem(
                                  'Challan',
                                  controller.totalOrders.value.toString(),
                                  Icons.receipt_long,
                                  const Color(0xFFE67E22),
                                  onTap: null,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Pending Orders Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Pending Medical Orders',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E2A3E),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.toNamed(Routes.VENDERS_ORDERS);
                              },
                              child: const Text(
                                'View All',
                                style: TextStyle(color: Color(0xFF5D9BEC)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Pending Orders List
                        if (controller.pendingOrdersList.isEmpty)
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Lottie.asset(
                                  'assets/animations/no_order.json',
                                  height: 120,
                                  repeat: true,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No pending medical orders',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Column(
                            children: [
                              ...controller.pendingOrdersList
                                  .take(5)
                                  .map((order) => _buildMedicalOrderCard(order)),
                              if (controller.isLoadingMore.value)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              if (controller.pendingOrdersList.length > 5)
                                TextButton(
                                  onPressed: () {
                                    Get.toNamed(Routes.VENDERS_ORDERS);
                                  },
                                  child: const Text('Load More...'),
                                ),
                            ],
                          ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: 0,
          selectedItemColor: const Color(0xFF5D9BEC),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          onTap: (index) {
            switch (index) {
              case 0:
                break;
              case 1:
                Get.toNamed(Routes.VENDERS_ORDERS);
                break;
              case 2:
                Get.toNamed(Routes.VENDORS_PORDUCTS);
                break;
              case 3:
                Get.toNamed(Routes.VENDORS_PROFILE);
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.medical_services),
              label: 'Dashboard',
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
      ),
    );
  }

  Widget _buildMedicalStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    Color gradientColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, gradientColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalSummaryItem(
    String label,
    String value,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalOrderCard(OrderModel order) {
    final customerName =
        order.shippingAddress?.contactPerson ?? 'Customer';
    final location = order.shippingAddress != null
        ? '${order.shippingAddress!.city}, ${order.shippingAddress!.state}'
        : 'Location not specified';

    final totalItems =
        order.items.fold<int>(0, (sum, item) => sum + item.quantity);
    final firstItem = order.items.isNotEmpty ? order.items.first : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () => Get.toNamed(
          Routes.VENDERS_ORDER_DETAIL,
          arguments: order.id,
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF5D9BEC).withOpacity(0.1),
                          const Color(0xFF5D9BEC).withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.medical_services,
                      color: const Color(0xFF5D9BEC),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                order.orderNumber,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: const Color(0xFF1E2A3E),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getMedicalPaymentStatusColor(
                                    order.paymentStatus),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                order.paymentMethod.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.person_outline,
                                size: 14, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                customerName,
                                style: TextStyle(
                                    color: Colors.grey.shade700, fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 14, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                location,
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (firstItem != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                if (firstItem.vendorProduct?.product?.images
                                        .isNotEmpty ??
                                    false)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      firstItem.vendorProduct!.product!.images
                                          .first.imageUrl,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Icon(
                                        Icons.medical_information,
                                        size: 30,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.medical_information,
                                        size: 20, color: Colors.grey.shade500),
                                  ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        firstItem.productName,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1E2A3E),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'Qty: ${firstItem.quantity} × ₹${firstItem.unitPrice.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (totalItems > 1)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '+${totalItems - 1}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd MMM yyyy, hh:mm a')
                            .format(order.createdAt),
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF5D9BEC).withOpacity(0.1),
                          const Color(0xFF5D9BEC).withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '₹${order.finalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF5D9BEC),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          controller.showRejectDialog(order.id),
                      icon: const Icon(Icons.cancel_outlined, size: 16),
                      label: const Text('Reject', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE74C3C),
                        side: const BorderSide(color: Color(0xFFE74C3C)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => controller.overdueOrder(order.id),
                      icon: const Icon(Icons.timer_off_outlined, size: 16),
                      label: const Text('Overdue', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE67E22),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => controller.acceptOrder(order.id),
                      icon: const Icon(Icons.check_circle_outline, size: 16),
                      label: const Text('Accept', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4ECDC4),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
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

  Color _getMedicalPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return const Color(0xFF4ECDC4);
      case 'pending':
        return const Color(0xFFE67E22);
      case 'failed':
        return const Color(0xFFE74C3C);
      default:
        return Colors.grey;
    }
  }
}