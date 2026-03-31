// lib/app/modules/orders/controllers/orders_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/order_model.dart';
import '../../../data/providers/api_provider.dart';
import '../../../services/storage_service.dart';

class OrdersController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();

  final orders = <Order>[].obs;
  final filteredOrders = <Order>[].obs;
  final isLoading = false.obs;
  final selectedStatus = 'All'.obs;
  final selectedSort = 'newest'.obs;
  final searchQuery = ''.obs;
  final showCancelledOrders = false.obs;
  final showReturnedOrders = false.obs;
  final isLoggedIn = false.obs;
  final selectedPaymentMethod = 'all'.obs; // ← NEW

  final searchController = TextEditingController();
  final searchText = ''.obs;

  final statusFilters = [
    'All',
    'Placed',
    'Confirmed',
    'Cancelled',
  ];

  final sortOptions = {
    'newest': 'Newest First',
    'oldest': 'Oldest First',
    'price_high': 'Amount: High to Low',
    'price_low': 'Amount: Low to High',
  };

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();

    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });

    debounce(
      searchQuery,
      (_) => filterOrders(),
      time: const Duration(milliseconds: 500),
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // ─── AUTH ──────────────────────────────────────────────────────────────────

  Future<void> checkLoginStatus() async {
    final token = await _storageService.getToken();
    isLoggedIn.value = token != null && token.isNotEmpty;
    if (isLoggedIn.value) {
      loadOrders();
    }
  }

  void goToLogin() {
    Get.toNamed('/login');
  }

  // ─── LOAD ──────────────────────────────────────────────────────────────────

  Future<void> loadOrders() async {
    if (!isLoggedIn.value) return;

    isLoading.value = true;

    try {
      final user = await _storageService.getUser();
      final token = await _storageService.getToken();

      if (user == null || token == null) {
        isLoggedIn.value = false;
        throw Exception('User not logged in');
      }

      final buyerId = user['id'];

      final result = await _apiService.getBuyerOrders(
        buyerId: buyerId.toString(),
        token: token,
      );

      print('Orders API Response: $result');

      if (result['success'] == true && result['data'] != null) {
        final List ordersData = result['data'];
        final loadedOrders =
            ordersData.map((json) => Order.fromJson(json)).toList();
        orders.assignAll(loadedOrders);
        filterOrders();
      } else {
        Get.snackbar(
          'Error',
          result['message'] ?? 'Failed to load orders',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Error loading orders: $e');
      Get.snackbar(
        'Error',
        'Failed to load orders. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshOrders() async {
    if (isLoggedIn.value) {
      await loadOrders();
    }
  }

  // ─── FILTER & SORT ─────────────────────────────────────────────────────────

  void filterOrders() {
    var filtered = [...orders];

    // Search
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((order) {
        return order.orderNumber.toLowerCase().contains(query) ||
            order.items
                .any((item) => item.productName.toLowerCase().contains(query));
      }).toList();
    }

    // Status
    if (selectedStatus.value != 'All') {
      filtered = filtered.where((order) {
        return order.status.displayName.toLowerCase() ==
            selectedStatus.value.toLowerCase();
      }).toList();
    }

    // Payment method ← NEW
    if (selectedPaymentMethod.value != 'all') {
      filtered = filtered.where((order) {
        return order.paymentMethod.toLowerCase() ==
            selectedPaymentMethod.value.toLowerCase();
      }).toList();
    }

    // Cancelled toggle
    if (!showCancelledOrders.value) {
      filtered = filtered
          .where((order) => order.orderStatus.toLowerCase() != 'cancelled')
          .toList();
    }

    // Returned toggle
    if (!showReturnedOrders.value) {
      filtered = filtered
          .where((order) => order.orderStatus.toLowerCase() != 'returned')
          .toList();
    }

    // Sort
    switch (selectedSort.value) {
      case 'oldest':
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'price_high':
        filtered.sort((a, b) => b.finalAmount.compareTo(a.finalAmount));
        break;
      case 'price_low':
        filtered.sort((a, b) => a.finalAmount.compareTo(b.finalAmount));
        break;
      case 'newest':
      default:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    filteredOrders.assignAll(filtered);
  }

  void updateStatusFilter(String status) {
    selectedStatus.value = status;
    filterOrders();
  }

  void updatePaymentFilter(String method) { // ← NEW
    selectedPaymentMethod.value = method;
    filterOrders();
  }

  void updateSort(String sort) {
    selectedSort.value = sort;
    filterOrders();
  }

  void toggleShowCancelled() {
    showCancelledOrders.value = !showCancelledOrders.value;
    filterOrders();
  }

  void toggleShowReturned() {
    showReturnedOrders.value = !showReturnedOrders.value;
    filterOrders();
  }

  // ─── ACTIONS ───────────────────────────────────────────────────────────────

  Future<void> cancelOrder(Order order, String reason) async {
    try {
      final user = await _storageService.getUser();
      final token = await _storageService.getToken();

      if (user == null || token == null) throw Exception('Not logged in');

      final result = await _apiService.cancelOrder(
        orderId: '${order.id}',
        reason: reason,
        token: token,
      );

      if (result['success'] == true) {
        await loadOrders();
        Get.snackbar(
          'Order Cancelled',
          'Order ${order.orderNumber} has been cancelled successfully.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to cancel order. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> requestReturn(Order order, String reason) async {
    try {
      final user = await _storageService.getUser();
      final token = await _storageService.getToken();

      if (user == null || token == null) throw Exception('Not logged in');

      final result = await _apiService.requestReturn(
        orderId: '${order.id}',
        reason: reason,
        token: token,
      );

      if (result['success'] == true) {
        await loadOrders();
        Get.snackbar(
          'Return Requested',
          'Return request for order ${order.orderNumber} has been submitted.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to request return. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void downloadInvoice(Order order) {
    Get.snackbar(
      'Invoice Download',
      'Invoice for ${order.orderNumber} will be downloaded.',
      snackPosition: SnackPosition.BOTTOM,
    );
    // Implement actual download logic here
  }

  void trackOrder(Order order) {
    Get.snackbar(
      'Track Order',
      'Tracking functionality coming soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> reorder(Order order) async {
    try {
      for (var item in order.items) {
        await _apiService.addToCart(
          productId: item.vendorProductId,
          quantity: item.quantity,
        );
      }

      Get.snackbar(
        'Reorder',
        'Added ${order.itemCount} items from order ${order.orderNumber} to cart.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.toNamed('/cart');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to reorder items. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ─── STATS ─────────────────────────────────────────────────────────────────

  Map<String, int> getOrderStats() {
    return {
      'total': orders.length,
      'placed': orders.where((o) => o.orderStatus == 'placed').length,
      'pending': orders.where((o) => o.orderStatus == 'pending').length,
      'confirmed': orders.where((o) => o.orderStatus == 'confirmed').length,
      'processing': orders.where((o) => o.orderStatus == 'processing').length,
      'shipped': orders.where((o) => o.orderStatus == 'shipped').length,
      'delivered': orders.where((o) => o.orderStatus == 'delivered').length,
      'cancelled': orders.where((o) => o.orderStatus == 'cancelled').length,
      'returned': orders.where((o) => o.orderStatus == 'returned').length,
    };
  }

  // ─── DIALOGS / BOTTOM SHEETS ───────────────────────────────────────────────

  void showOrderDetails(Order order) {
    Get.bottomSheet(
      OrderDetailsBottomSheet(order: order),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void showCancelDialog(Order order) {
    final reasonController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to cancel this order?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for cancellation',
                border: OutlineInputBorder(),
                hintText: 'Please provide a reason',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.isNotEmpty) {
                cancelOrder(order, reasonController.text);
                Get.back();
              } else {
                Get.snackbar(
                  'Error',
                  'Please provide a reason for cancellation',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void showReturnDialog(Order order) {
    final reasonController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Request Return'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to return this order?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for return',
                border: OutlineInputBorder(),
                hintText: 'Please provide a reason',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.isNotEmpty) {
                requestReturn(order, reasonController.text);
                Get.back();
              } else {
                Get.snackbar(
                  'Error',
                  'Please provide a reason for return',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Yes, Return'),
          ),
        ],
      ),
    );
  }
}

// ─── ORDER DETAILS BOTTOM SHEET ────────────────────────────────────────────────

class OrderDetailsBottomSheet extends StatelessWidget {
  final Order order;

  const OrderDetailsBottomSheet({Key? key, required this.order})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 60,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Order Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111261),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildDetailRow('Order Number', order.orderNumber),
                  _buildDetailRow('Order Date', order.formattedOrderDate),
                  _buildDetailRow('Status', order.status.displayName),
                  _buildDetailRow(
                      'Payment', order.paymentMethod.toUpperCase()),
                  _buildDetailRow('Payment Status', order.paymentStatus),

                  const SizedBox(height: 16),
                  const Text(
                    'Items',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  ...order.items.map((item) => _buildOrderItem(item)).toList(),

                  const Divider(height: 24),

                  _buildDetailRow(
                      'Subtotal', '₹${order.subtotal.toStringAsFixed(2)}'),
                  if (order.discount > 0)
                    _buildDetailRow('Discount',
                        '-₹${order.discount.toStringAsFixed(2)}'),
                  if (order.shippingCharge > 0)
                    _buildDetailRow('Shipping',
                        '₹${order.shippingCharge.toStringAsFixed(2)}'),
                  _buildDetailRow('GST', '₹${order.tax.toStringAsFixed(2)}'),
                  const Divider(height: 8),
                  _buildDetailRow(
                    'Total Amount',
                    '₹${order.finalAmount.toStringAsFixed(2)}',
                    isBold: true,
                  ),

                  const SizedBox(height: 16),

                  if (order.shippingAddress != null) ...[
                    const Text(
                      'Shipping Address',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.shippingAddress!.contactPerson,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500),
                          ),
                          Text(order.shippingAddress!.contactPhone),
                          const SizedBox(height: 4),
                          Text(
                            '${order.shippingAddress!.addressLine1}, '
                            '${order.shippingAddress!.addressLine2 ?? ''}',
                          ),
                          Text(
                            '${order.shippingAddress!.city}, '
                            '${order.shippingAddress!.state} - '
                            '${order.shippingAddress!.pincode}',
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B630B),
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Get.back(),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                            color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isBold ? Colors.black : Colors.grey[600],
              fontWeight:
                  isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight:
                  isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? const Color(0xFF111261) : null,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: item.productImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.productImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.medication,
                          color: Color(0xFF0B630B),
                          size: 30,
                        );
                      },
                    ),
                  )
                : const Icon(
                    Icons.medication,
                    color: Color(0xFF0B630B),
                    size: 30,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Qty: ${item.quantity}',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '₹${item.unitPrice} each',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                if (item.gstPercentage > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'GST: ${item.gstPercentage}%',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF0B630B),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '₹${item.totalPrice.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111261),
            ),
          ),
        ],
      ),
    );
  }
}