import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../app/data/models/vendors_orders_model.dart';
import '../../../../../app/routes/app_pages.dart';
import '../controllers/dashboard_controller.dart';
import 'package:lottie/lottie.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({Key? key}) : super(key: key);

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
              'Dashboard',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Obx(() => Text(
                  'Welcome back, Vendor #${controller.vendorId.value}',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                )),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: Colors.black),
                onPressed: () => Get.toNamed(Routes.NOTIFICATIONS),
              ),
              Obx(() {
                if (controller.pendingOrders.value > 0) {
                  return Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${controller.pendingOrders.value}',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  );
                }
                return SizedBox();
              }),
            ],
          ),
          IconButton(
            onPressed: () async {
              await controller.logout();
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Obx(
        () => controller.isLoading.value
            ? Center(child: CircularProgressIndicator())
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
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stats Cards
                        GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          childAspectRatio: 1.3,
                          children: [
                            _buildStatCard(
                              'Pending Orders',
                              controller.pendingOrders.value.toString(),
                              Icons.access_time,
                              [
                                Colors.orange.shade400,
                                Colors.deepOrange.shade600
                              ],
                            ),
                            _buildStatCard(
                              "Products",
                              controller.deliveredOrders.value.toString(),
                              Icons.check_circle,
                              [
                                Colors.green.shade400,
                                Colors.green.shade600
                              ],
                            ),
                            _buildStatCard(
                              "Today's Revenue",
                              controller.getFormattedRevenue(
                                  controller.todayRevenue.value),
                              Icons.trending_up,
                              [
                                Colors.blue.shade400,
                                Colors.indigo.shade600
                              ],
                            ),
                            _buildStatCard(
                              'Cancelled',
                              controller.cancelledOrders.value.toString(),
                              Icons.cancel,
                              [Colors.red.shade400, Colors.red.shade600],
                            ),
                          ],
                        ),
                        SizedBox(height: 24),

                        // Stats Summary Row
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildSummaryItem(
                                'Total Orders',
                                controller.totalOrders.value.toString(),
                                Icons.shopping_bag,
                                Colors.blue,
                              ),
                              _buildSummaryItem(
                                'Total Revenue',
                                controller.getFormattedRevenue(
                                    controller.totalRevenue.value),
                                Icons.currency_rupee,
                                Colors.green,
                              ),
                              _buildSummaryItem(
                                'Products',
                                controller.totalProducts.value.toString(),
                                Icons.inventory,
                                Colors.purple,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24),

                        // Pending Orders Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Pending Orders',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.toNamed(Routes.VENDERS_ORDERS);
                              },
                              child: Text('View All'),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),

                        // Pending Orders List
                        if (controller.pendingOrdersList.isEmpty)
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
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
                                  'No pending orders',
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
                                  .map((order) =>
                                      _buildPendingOrderCard(order)),
                              if (controller.isLoadingMore.value)
                                Center(
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
                                  child: Text('Load More...'),
                                ),
                            ],
                          ),

                        SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
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

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    List<Color> colors,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.white.withOpacity(0.8), size: 32),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            title,
            style:
                TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(height: 4),
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
          ),
        ),
      ],
    );
  }

  Widget _buildPendingOrderCard(OrderModel order) {
    final customerName =
        order.shippingAddress?.contactPerson ?? 'Customer';
    final location = order.shippingAddress != null
        ? '${order.shippingAddress!.city}, ${order.shippingAddress!.state}'
        : 'Location not specified';

    final totalItems =
        order.items.fold<int>(0, (sum, item) => sum + item.quantity);
    final firstItem = order.items.isNotEmpty ? order.items.first : null;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Get.toNamed(
          Routes.VENDERS_ORDER_DETAIL,
          arguments: order.id,
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // ── Top Row: Icon + Order Details ──────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      color: Colors.blue.shade700,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Order Number + Payment Badge
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                order.orderNumber,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getPaymentStatusColor(
                                    order.paymentStatus),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                order.paymentMethod.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),

                        // Customer Name
                        Row(
                          children: [
                            Icon(Icons.person_outline,
                                size: 14, color: Colors.grey),
                            SizedBox(width: 4),
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
                        SizedBox(height: 2),

                        // Location
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 14, color: Colors.grey),
                            SizedBox(width: 4),
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

                        // Product Preview
                        if (firstItem != null) ...[
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                if (firstItem.vendorProduct?.product?.images
                                        .isNotEmpty ??
                                    false)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.network(
                                      firstItem.vendorProduct!.product!.images
                                          .first.imageUrl,
                                      width: 30,
                                      height: 30,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Icon(
                                        Icons.image_not_supported,
                                        size: 30,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    width: 30,
                                    height: 30,
                                    color: Colors.grey.shade200,
                                    child: Icon(Icons.image,
                                        size: 16, color: Colors.grey),
                                  ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        firstItem.productName,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'Qty: ${firstItem.quantity} × ₹${firstItem.unitPrice.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (totalItems > 1)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '+${totalItems - 1} more',
                                      style: TextStyle(
                                        fontSize: 9,
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

              SizedBox(height: 12),

              // ── Date + Amount Row ───────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 16, color: Colors.grey.shade500),
                      SizedBox(width: 4),
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
                        EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '₹${order.finalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),
              Divider(height: 1),
              SizedBox(height: 10),

              // ── Action Buttons: Reject | Overdue | Accept ───────────────
              Row(
                children: [
                  // Reject Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          controller.showRejectDialog(order.id),
                      icon: Icon(Icons.cancel_outlined, size: 15),
                      label: Text('Reject', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red.shade300),
                        padding: EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 6),

                  // ── Overdue Button (BEECH MEIN) ──────────────────────────
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => controller.overdueOrder(order.id),
                      icon: Icon(Icons.timer_off_outlined, size: 15),
                      label:
                          Text('Overdue', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),

                  SizedBox(width: 6),

                  // Accept Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => controller.acceptOrder(order.id),
                      icon: Icon(Icons.check_circle_outline, size: 15),
                      label:
                          Text('Accept', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
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

  Color _getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}