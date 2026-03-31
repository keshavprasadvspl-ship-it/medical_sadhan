import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// import '../../../../../app/data/models/venders_products_model.dart';
import '../../../../../app/data/models/vendors_orders_model.dart';
import '../../../../../app/data/providers/api_endpoints.dart';
import '../../../../../app/data/providers/cart_service.dart';
// import '../../../../../app/routes/app_pages.dart';

class DashboardController extends GetxController {
  // Stats
  final totalOrders = 0.obs;
  final pendingOrders = 0.obs;
  final deliveredOrders = 0.obs;
  final cancelledOrders = 0.obs;

  // Revenue
  final totalRevenue = 0.0.obs;
  final todayRevenue = 0.0.obs;
  final monthlyRevenue = 0.0.obs;

  // Products
  final totalProducts = 0.obs;
  final lowStockProducts = 0.obs;

  // Pending Orders
  final pendingOrdersList = <OrderModel>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMoreData = true.obs;

  // Pagination
  final currentPage = 1.obs;
  final perPage = 10.obs;

  // Vendor ID
  late SharedPreferences _prefs;
  final vendorId = 0.obs;

  final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  @override
  void onInit() {
    super.onInit();
    initializePrefs();
  }

  Future<void> initializePrefs() async {
    _prefs = await SharedPreferences.getInstance();
    loadVendorId();
    fetchDashboardData();
  }

  void loadVendorId() {
    final userDataString = _prefs.getString('user_data');
    if (userDataString != null && userDataString.isNotEmpty) {
      final userData = json.decode(userDataString);
      final id = userData['id'] ?? userData['vendor_id'];
      vendorId.value = int.tryParse(id.toString()) ?? 0;
    }
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;

      // Fetch stats
      await fetchStats();

      // Fetch pending orders
      await fetchPendingOrders(reset: true);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load dashboard data: $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchStats() async {
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}/vendor-dashboard/stats')
          .replace(queryParameters: {'vendor_id': vendorId.value.toString()});

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == true) {
          final data = jsonData['data'];

          // Orders stats
          totalOrders.value = data['orders']['total'] ?? 0;
          pendingOrders.value = data['orders']['pending'] ?? 0;
          deliveredOrders.value = data['orders']['delivered'] ?? 0;
          cancelledOrders.value = data['orders']['cancelled'] ?? 0;

          // Revenue stats
          totalRevenue.value = (data['revenue']['total'] ?? 0).toDouble();
          todayRevenue.value = (data['revenue']['today'] ?? 0).toDouble();
          monthlyRevenue.value = (data['revenue']['monthly'] ?? 0).toDouble();

          // Products stats
          totalProducts.value = data['products']['total'] ?? 0;
          lowStockProducts.value = data['products']['low_stock'] ?? 0;
        }
      }
    } catch (e) {
      print('Error fetching stats: $e');
    }
  }

  Future<void> fetchPendingOrders({bool reset = false}) async {
    if (reset) {
      currentPage.value = 1;
      pendingOrdersList.clear();
      hasMoreData.value = true;
    }

    if (!hasMoreData.value || isLoadingMore.value) return;

    try {
      isLoadingMore.value = true;

      final uri =
          Uri.parse('${ApiEndpoints.baseUrl}/vendor-orders/pending').replace(
              queryParameters: {
            'vendor_id': vendorId.value.toString(),
            'status': "placed",
            'page': currentPage.value.toString(),
            'per_page': perPage.value.toString(),
          });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == true) {
          final data = jsonData['data'];
          final List<dynamic> ordersJson = data['data'];

          final newOrders =
              ordersJson.map((json) => OrderModel.fromJson(json)).toList();

          if (reset) {
            pendingOrdersList.value = newOrders;
          } else {
            pendingOrdersList.addAll(newOrders);
          }

          currentPage.value = data['current_page'];
          hasMoreData.value = data['current_page'] < data['last_page'];
        }
      }
    } catch (e) {
      print('Error fetching pending orders: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  void loadMorePendingOrders() {
    if (hasMoreData.value && !isLoadingMore.value) {
      currentPage.value++;
      fetchPendingOrders();
    }
  }

  Future<void> updateOrderStatus(int orderId, String status,
      {String? notes}) async {
    try {
      final response = await http.post(
        Uri.parse(
            '${ApiEndpoints.baseUrl}/vendor-orders/update-status/$orderId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'status': status,
          'notes': notes ?? 'Order $status by vendor',
          'changed_by': vendorId.value,
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == true) {
          Get.snackbar(
            'Success',
            'Order $status successfully',
            backgroundColor: Colors.green.shade100,
            colorText: Colors.green.shade800,
            snackPosition: SnackPosition.BOTTOM,
          );

          // Refresh data
          await fetchStats();
          await fetchPendingOrders(reset: true);
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update order: $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> cancelOrder(int orderId, String reason) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/vendor-orders/cancel/$orderId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'reason': reason,
          'cancelled_by': vendorId.value,
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == true) {
          Get.snackbar(
            'Success',
            'Order cancelled successfully',
            backgroundColor: Colors.green.shade100,
            colorText: Colors.green.shade800,
            snackPosition: SnackPosition.BOTTOM,
          );

          // Refresh data
          await fetchStats();
          await fetchPendingOrders(reset: true);
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to cancel order: $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ─── Accept Order ────────────────────────────────────────────────────────────
  void acceptOrder(int orderId) {
    updateOrderStatus(orderId, 'confirmed',
        notes: 'Order confirmed by vendor');
  }

  // ─── Overdue Order ───────────────────────────────────────────────────────────
 void overdueOrder(int orderId) {
  print('🟠 overdueOrder called — orderId: $orderId');

  Get.dialog(
    AlertDialog(
      title: const Text('Mark as Overdue'),
      content: const Text(
        'Are you sure you want to mark this order as overdue?',
      ),
      actions: [
        TextButton(
          onPressed: () {
            print('❌ Overdue dialog cancelled — orderId: $orderId');
            Get.back();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            print('✅ Overdue confirmed — orderId: $orderId, status: overdue');
            Get.back();
            updateOrderStatus(
              orderId,
              'overdue',
              notes: 'Order marked as overdue by vendor',
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade700,
            foregroundColor: Colors.white,
          ),
          child: const Text('Mark Overdue'),
        ),
      ],
    ),
  );
}  // ─── Reject / Cancel Dialog ──────────────────────────────────────────────────
  void showRejectDialog(int orderId) {
    final reasonController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Reject Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: 'e.g., Out of stock',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.isNotEmpty) {
                Get.back();
                cancelOrder(orderId, reasonController.text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void refreshDashboard() {
    fetchDashboardData();
  }

  String getFormattedRevenue(double revenue) {
    if (revenue >= 100000) {
      return '₹${(revenue / 100000).toStringAsFixed(1)}L';
    } else if (revenue >= 1000) {
      return '₹${(revenue / 1000).toStringAsFixed(1)}K';
    }
    return currencyFormat.format(revenue);
  }

  Future<void> logout() async {
    try {
      // Clear cart data
      final cartService = Get.find<CartService>();
      await cartService.clearAllCartData();

      // Clear user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Navigate to login
      Get.offAllNamed('/login');
    } catch (e) {
      print('Logout error: $e');
    }
  }
}