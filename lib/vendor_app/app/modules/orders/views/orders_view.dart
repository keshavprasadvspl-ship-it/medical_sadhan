import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/orders_controller.dart';
import '../../../../../app/routes/app_pages.dart';
import '../../../../../app/data/models/vendors_orders_model.dart';

class VendorsOrdersView extends GetView<VendorsOrdersController> {
  const VendorsOrdersView({Key? key}) : super(key: key);

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
              'Orders',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Obx(
                  () => Text(
                '${controller.filteredOrders.length} orders found',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          // Search Button
          IconButton(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: _showSearchDialog,
          ),
          // Refresh Button
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black),
            onPressed: () => controller.fetchOrders(reset: true),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Summary Card
          _buildStatsSummary(),

          // Filter Chips
          _buildFilterChips(),

          // Orders List
          Expanded(
            child: Obx(
                  () => controller.isLoading.value
                  ? Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                onRefresh: () async => controller.fetchOrders(reset: true),
                child: controller.filteredOrders.isEmpty
                    ? _buildEmptyState()
                    : NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (!controller.isLoadingMore.value &&
                        scrollInfo.metrics.pixels >=
                            scrollInfo.metrics.maxScrollExtent - 200) {
                      controller.loadMoreOrders();
                    }
                    return true;
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: controller.filteredOrders.length +
                        (controller.isLoadingMore.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= controller.filteredOrders.length) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final order = controller.filteredOrders[index];
                      return _buildOrderCard(order);
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1, // Orders is index 1
        onTap: (index) {
          switch (index) {
            case 0:
              Get.offNamed(Routes.VENDERS_DASHBOARD);
              break;
            case 1:
            // Already on orders
              break;
            case 2:
              Get.offNamed(Routes.VENDORS_PORDUCTS);
              break;
            case 3:
              Get.offNamed(Routes.VENDORS_PROFILE);
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

  Widget _buildStatsSummary() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.purple.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Obx(
            () {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Placed',
                controller.pendingCount.toString(),
                Icons.access_time,
                Colors.orange,
              ),
              _buildStatItem(
                'Confirmed',
                controller.confirmedCount.toString(),
                Icons.check_circle,
                Colors.green,
              ),
              _buildStatItem(
                'Cancelled',
                controller.cancelledCount.toString(),
                Icons.cancel,
                Colors.red,
              ),
              _buildStatItem(
                'Revenue',
                '₹${(controller.totalRevenue / 1000).toStringAsFixed(1)}K',
                Icons.currency_rupee,
                Colors.purple,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      margin: EdgeInsets.only(bottom: 8),
      child: ValueListenableBuilder<String>(
        valueListenable: controller.selectedFilterNotifier,
        builder: (context, currentFilter, child) {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: controller.filterOptions.length,
            itemBuilder: (context, index) {
              final filter = controller.filterOptions[index];
              final isSelected = currentFilter == filter;

              Color getColor() {
                switch (filter) {
                  case 'placed':
                    return Colors.orange;
                  case 'confirmed':
                    return Colors.green;
                  case 'cancelled':
                    return Colors.red;
                  default:
                    return Colors.grey;
                }
              }

              String getDisplayName() {
                if (filter == 'all') return 'All';
                return filter.substring(0, 1).toUpperCase() + filter.substring(1);
              }

              return Container(
                margin: EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(
                    getDisplayName(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : getColor(),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (_) => controller.setFilter(filter),
                  backgroundColor: Colors.white,
                  selectedColor: getColor(),
                  checkmarkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? getColor() : getColor().withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    // Get customer name from shipping address
    final customerName = order.shippingAddress?.contactPerson ?? 'Customer';
    final location = order.shippingAddress != null
        ? '${order.shippingAddress!.city}, ${order.shippingAddress!.state}'
        : 'Location not specified';

    // Calculate total items
    final totalItems = order.items.fold<int>(0, (sum, item) => sum + item.quantity);

    // Get first item for preview
    final firstItem = order.items.isNotEmpty ? order.items.first : null;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => Get.toNamed(
          Routes.VENDERS_ORDER_DETAIL,
          arguments: order.id,
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Order Icon
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.orderStatus).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getOrderIcon(order.orderStatus),
                      color: _getStatusColor(order.orderStatus),
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12),

                  // Order Number and Customer
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.orderNumber,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'monospace',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.person_outline, size: 14, color: Colors.grey),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                customerName,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
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

                  // Status Chip
                  _buildStatusChip(order.orderStatus),
                ],
              ),

              SizedBox(height: 16),

              // Details Grid
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    // Date
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                          SizedBox(width: 6),
                          Text(
                            _formatDate(order.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Payment Method
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                order.paymentMethod == 'cod'
                                    ? Icons.money
                                    : Icons.credit_card,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              SizedBox(width: 4),
                              Text(
                                order.paymentMethod.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _getPaymentStatusColor(order.paymentStatus),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 4),
                              Text(
                                order.paymentStatus.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Payment Status

                  ],
                ),
              ),

              // Address
              if (order.shippingAddress != null) ...[
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        order.shippingAddress!.fullAddress,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              // Product Preview
              if (firstItem != null) ...[
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      // Product Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          width: 40,
                          height: 40,
                          color: Colors.grey.shade200,
                          child: firstItem.vendorProduct?.product?.images.isNotEmpty ?? false
                              ? Image.network(
                            firstItem.vendorProduct!.product!.images.first.imageUrl,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.image_not_supported,
                              size: 20,
                              color: Colors.grey,
                            ),
                          )
                              : Icon(Icons.image, size: 20, color: Colors.grey),
                        ),
                      ),
                      SizedBox(width: 8),

                      // Product Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              firstItem.productName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Qty: ${firstItem.quantity} × ₹${firstItem.unitPrice.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            if (firstItem.vendorProduct?.product?.genericName != null)
                              Text(
                                firstItem.vendorProduct!.product!.genericName,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),

                      // More items indicator
                      if (totalItems > 1)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '+${totalItems - 1}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: 12),

              // Footer Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Items count and GST
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.inventory_2, size: 14, color: Colors.blue.shade700),
                            SizedBox(width: 4),
                            Text(
                              '$totalItems ${totalItems == 1 ? 'item' : 'items'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (order.gstAmount > 0) ...[
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'GST: ₹${order.gstAmount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.purple.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${order.finalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      if (order.discountAmount > 0)
                        Text(
                          '₹${order.totalAmount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              // Action Buttons based on status
              if (order.orderStatus.toLowerCase() == 'placed') ...[
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => controller.acceptOrder(order.id.toString()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text('Accept'),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => controller.rejectOrder(order.id.toString()),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text('Reject'),
                      ),
                    ),
                  ],
                ),
              ],

              if (order.orderStatus.toLowerCase() == 'confirmed') ...[
                SizedBox(height: 12),
                Row(
                  children: [
                    // Expanded(
                    //   child: ElevatedButton(
                    //     onPressed: () => controller.markAsDispatched(order.id.toString()),
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: Colors.blue,
                    //       foregroundColor: Colors.white,
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(8),
                    //       ),
                    //     ),
                    //     child: Text('Mark as Dispatched'),
                    //   ),
                    // ),
                    // SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => controller.generateInvoice(order.id),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.purple,
                          side: BorderSide(color: Colors.purple),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text('Invoice'),
                      ),
                    ),
                  ],
                ),
              ],

              if (order.orderStatus.toLowerCase() == 'cancelled' &&
                  order.cancellationReason != null) ...[
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 14, color: Colors.red.shade700),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Cancelled: ${order.cancellationReason}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.red.shade700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'placed':
        color = Colors.orange;
        icon = Icons.access_time;
        break;
      case 'confirmed':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'cancelled':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        icon = Icons.info;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
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
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 16),
          Text(
            'No orders found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            controller.searchQuery.value.isNotEmpty
                ? 'Try adjusting your search'
                : 'New orders will appear here',
            style: TextStyle(color: Colors.grey.shade500),
          ),
          if (controller.searchQuery.value.isNotEmpty) ...[
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                controller.searchQuery.value = '';
                controller.fetchOrders(reset: true);
              },
              child: Text('Clear Search'),
            ),
          ],
        ],
      ),
    );
  }

  void _showSearchDialog() {
    final searchController = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Search Orders',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search by order number or customer name...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Cancel'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      controller.searchOrders(searchController.text);
                      Get.back();
                    },
                    child: Text('Search'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Methods
  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime).inDays;

    if (difference == 0) {
      return 'Today, ${DateFormat('hh:mm a').format(dateTime)}';
    } else if (difference == 1) {
      return 'Yesterday, ${DateFormat('hh:mm a').format(dateTime)}';
    } else {
      return DateFormat('dd MMM yyyy').format(dateTime);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'placed':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
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

  IconData _getOrderIcon(String status) {
    switch (status.toLowerCase()) {
      case 'placed':
        return Icons.access_time;
      case 'confirmed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.shopping_bag;
    }
  }
}