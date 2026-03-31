import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../../app/data/models/vendors_orders_model.dart';
import '../../../../../app/data/providers/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VendorsOrdersController extends GetxController {
  final orders = <OrderModel>[].obs;
  final filteredOrders = <OrderModel>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMoreData = true.obs;

  // Pagination
  final currentPage = 1.obs;
  final perPage = 20.obs;
  final totalOrders = 0.obs;

  // Filters
  final selectedFilter = 'all'.obs;
  final selectedFilterNotifier = ValueNotifier<String>('all');
  final searchQuery = ''.obs;

  // Vendor ID
  late SharedPreferences _prefs;
  final vendorId = 0.obs;

  final filterOptions = [
    'all',
    'placed',
    'confirmed',
    'cancelled',
  ];

  @override
  void onInit() {
    super.onInit();
    initializePrefs();
  }

  @override
  void onClose() {
    selectedFilterNotifier.dispose();
    super.onClose();
  }

  Future<void> initializePrefs() async {
    _prefs = await SharedPreferences.getInstance();
    loadVendorId();
    fetchOrders(reset: true);
  }

  void loadVendorId() {
    final userDataString = _prefs.getString('user_data');
    if (userDataString != null && userDataString.isNotEmpty) {
      final userData = json.decode(userDataString);
      final id = userData['id'] ?? userData['vendor_id'];
      vendorId.value = int.tryParse(id.toString()) ?? 0;
    }
  }

  Future<void> fetchOrders({bool reset = false, bool showLoader = true}) async {
    if (reset) {
      currentPage.value = 1;
      orders.clear();
      filteredOrders.clear();
      hasMoreData.value = true;
    }

    if (!hasMoreData.value || (isLoading.value && !reset)) return;

    try {
      if (showLoader) {
        if (reset) {
          isLoading.value = true;
        } else {
          isLoadingMore.value = true;
        }
      }

      final queryParams = {
        'vendor_id': vendorId.value.toString(),
        'page': currentPage.value.toString(),
        'per_page': perPage.value.toString(),
      };

      // Add status filter if not 'all'
      if (selectedFilter.value != 'all') {
        queryParams['status'] = selectedFilter.value;
      }

      if (searchQuery.value.isNotEmpty) {
        queryParams['search'] = searchQuery.value;
      }

      final uri = Uri.parse('${ApiEndpoints.baseUrl}/vendor-orders/list')
          .replace(queryParameters: queryParams);

      print('Fetching orders from: $uri'); // Debug print

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == true) {
          final data = jsonData['data'];
          final List<dynamic> ordersJson = data['data'];

          final newOrders = ordersJson.map((json) =>
              OrderModel.fromJson(json)).toList();

          if (reset) {
            orders.value = newOrders;
          } else {
            orders.addAll(newOrders);
          }

          // Apply current filter to update filtered orders
          applyFilter();

          totalOrders.value = data['total'];
          currentPage.value = data['current_page'];
          hasMoreData.value = data['current_page'] < data['last_page'];

          print('Loaded ${newOrders.length} orders, total: ${orders.length}'); // Debug print
        }
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching orders: $e'); // Debug print

      // Only show error if we have no data
      if (orders.isEmpty) {
        Get.snackbar(
          'Error',
          'Failed to load orders: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
          duration: Duration(seconds: 3),
        );
      }
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  void loadMoreOrders() {
    if (hasMoreData.value && !isLoadingMore.value && !isLoading.value) {
      currentPage.value++;
      fetchOrders(showLoader: true);
    }
  }

  void searchOrders(String query) {
    searchQuery.value = query;
    fetchOrders(reset: true);
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    selectedFilterNotifier.value = filter;
    // Fetch orders with new filter
    fetchOrders(reset: true);
  }

  void applyFilter() {
    if (selectedFilter.value == 'all') {
      filteredOrders.value = orders;
    } else {
      filteredOrders.value = orders
          .where((o) => o.orderStatus.toLowerCase() == selectedFilter.value.toLowerCase())
          .toList();
    }
    // Force UI update
    filteredOrders.refresh();
  }

  Future<void> updateOrderStatus(int orderId, String status, {String? notes}) async {
    try {
      // Show loading indicator
      Get.dialog(
        Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                // SizedBox(height: 16),
                // Text('Updating order...'),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/vendor-orders/update-status/$orderId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'status': status,
          'notes': notes ?? 'Order $status by vendor',
          'changed_by': vendorId.value,
        }),
      );

      // Close loading dialog
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == true) {
          // Update the order in local list immediately
          final index = orders.indexWhere((o) => o.id == orderId);
          if (index != -1) {
            // Create updated order with new status
            final updatedOrder = orders[index].copyWith(
              orderStatus: status,
              statusHistory: [
                ...orders[index].statusHistory,
                StatusHistory(
                  id: DateTime.now().millisecondsSinceEpoch,
                  orderId: orderId,
                  status: status,
                  notes: notes,
                  createdAt: DateTime.now(),
                ),
              ],
            );
            orders[index] = updatedOrder;

            // Reapply filter to update filtered orders
            applyFilter();
          }

          Get.snackbar(
            'Success',
            'Order $status successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade100,
            colorText: Colors.green.shade800,
            duration: Duration(seconds: 2),
          );

          // Refresh from server in background (without showing loader)
          Future.delayed(Duration(milliseconds: 500), () {
            fetchOrders(reset: true, showLoader: false);
          });
        } else {
          throw Exception(jsonData['message'] ?? 'Failed to update order status');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      // Close loading dialog if open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        'Error',
        'Failed to update order: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: Duration(seconds: 3),
      );
    }
  }

  Future<void> cancelOrder(int orderId, String reason) async {
    try {
      // Show loading indicator
      Get.dialog(
        Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Cancelling order...'),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/vendor-orders/cancel/$orderId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'reason': reason,
          'cancelled_by': vendorId.value,
        }),
      );

      // Close loading dialog
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == true) {
          // Update the order in local list immediately
          final index = orders.indexWhere((o) => o.id == orderId);
          if (index != -1) {
            final updatedOrder = orders[index].copyWith(
              orderStatus: 'cancelled',
              cancellationReason: reason,
              cancelledBy: vendorId.value.toString(),
              statusHistory: [
                ...orders[index].statusHistory,
                StatusHistory(
                  id: DateTime.now().millisecondsSinceEpoch,
                  orderId: orderId,
                  status: 'cancelled',
                  notes: reason,
                  createdAt: DateTime.now(),
                ),
              ],
            );
            orders[index] = updatedOrder;

            // Reapply filter to update filtered orders
            applyFilter();
          }

          Get.snackbar(
            'Success',
            'Order cancelled successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade100,
            colorText: Colors.green.shade800,
            duration: Duration(seconds: 2),
          );

          // Refresh from server in background (without showing loader)
          Future.delayed(Duration(milliseconds: 500), () {
            fetchOrders(reset: true, showLoader: false);
          });
        } else {
          throw Exception(jsonData['message'] ?? 'Failed to cancel order');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      // Close loading dialog if open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        'Error',
        'Failed to cancel order: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: Duration(seconds: 3),
      );
    }
  }

  Future<void> generateInvoice(int orderId) async {
    try {
      // Show loading indicator
      Get.dialog(
        Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generating invoice...'),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/vendor-orders/generate-invoice/$orderId'),
      );

      // Close loading dialog
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == true) {
          Get.snackbar(
            'Success',
            'Invoice generated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade100,
            colorText: Colors.green.shade800,
          );
        } else {
          throw Exception(jsonData['message'] ?? 'Failed to generate invoice');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      // Close loading dialog if open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        'Error',
        'Failed to generate invoice: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  Future<OrderModel?> getOrderDetails(int orderId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/vendor-orders/details/$orderId'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == true) {
          return OrderModel.fromJson(jsonData['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching order details: $e');
      return null;
    }
  }

  // Statistics getters
  int get totalOrdersCount => totalOrders.value;

  int get pendingCount => orders.where((o) => o.orderStatus.toLowerCase() == 'placed').length;
  int get confirmedCount => orders.where((o) => o.orderStatus.toLowerCase() == 'confirmed').length;
  int get cancelledCount => orders.where((o) => o.orderStatus.toLowerCase() == 'cancelled').length;

  double get totalRevenue {
    return orders.fold(0.0, (sum, order) => sum + order.finalAmount);
  }

  // Convenience methods for UI
  void acceptOrder(String orderId) {
    updateOrderStatus(int.parse(orderId), 'confirmed', notes: 'Order confirmed by vendor');
  }

  void rejectOrder(String orderId) {
    showCancelDialog(int.parse(orderId));
  }

  void markAsDispatched(String orderId) {
    updateOrderStatus(int.parse(orderId), 'dispatched', notes: 'Order dispatched');
  }

  void showCancelDialog(int orderId) {
    final reasonController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('Cancel Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Please provide a reason for cancellation:'),
            SizedBox(height: 16),
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
            child: Text('Back'),
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
            ),
            child: Text('Cancel Order', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void refreshOrders() {
    fetchOrders(reset: true);
  }
}

// Add this extension to OrderModel for copyWith functionality
extension OrderModelCopy on OrderModel {
  OrderModel copyWith({
    int? id,
    String? orderNumber,
    int? buyerId,
    int? vendorId,
    int? shippingAddressId,
    int? billingAddressId,
    double? totalAmount,
    double? discountAmount,
    double? gstAmount,
    double? shippingCharge,
    double? finalAmount,
    String? paymentStatus,
    String? orderStatus,
    String? paymentMethod,
    String? deliveryInstructions,
    String? expectedDeliveryDate,
    String? actualDeliveryDate,
    String? vendorNotes,
    String? buyerNotes,
    String? cancellationReason,
    String? cancelledBy,
    String? integrationStatus,
    String? tallyOrderNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
    Address? shippingAddress,
    Address? billingAddress,
    List<OrderItem>? items,
    List<StatusHistory>? statusHistory,
    dynamic buyer,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      buyerId: buyerId ?? this.buyerId,
      vendorId: vendorId ?? this.vendorId,
      shippingAddressId: shippingAddressId ?? this.shippingAddressId,
      billingAddressId: billingAddressId ?? this.billingAddressId,
      totalAmount: totalAmount ?? this.totalAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      gstAmount: gstAmount ?? this.gstAmount,
      shippingCharge: shippingCharge ?? this.shippingCharge,
      finalAmount: finalAmount ?? this.finalAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      orderStatus: orderStatus ?? this.orderStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
      expectedDeliveryDate: expectedDeliveryDate ?? this.expectedDeliveryDate,
      actualDeliveryDate: actualDeliveryDate ?? this.actualDeliveryDate,
      vendorNotes: vendorNotes ?? this.vendorNotes,
      buyerNotes: buyerNotes ?? this.buyerNotes,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancelledBy: cancelledBy ?? this.cancelledBy,
      integrationStatus: integrationStatus ?? this.integrationStatus,
      tallyOrderNumber: tallyOrderNumber ?? this.tallyOrderNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      billingAddress: billingAddress ?? this.billingAddress,
      items: items ?? this.items,
      statusHistory: statusHistory ?? this.statusHistory,
      buyer: buyer ?? this.buyer,
    );
  }
}