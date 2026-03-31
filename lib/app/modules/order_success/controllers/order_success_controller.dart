// lib/app/modules/order_success/controllers/order_success_controller.dart

import 'package:get/get.dart';

class OrderSuccessController extends GetxController {
  final orders = <Map<String, dynamic>>[].obs;
  final items = <dynamic>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _processArguments();
  }

  void _processArguments() {
    try {
      final args = Get.arguments;
      print('OrderSuccessController args: $args');

      if (args != null && args['orderData'] != null) {
        final orderData = args['orderData'];

        // ✅ MULTIPLE ORDERS
        if (orderData is List) {
          for (var order in orderData) {
            late Map<String, dynamic> extractedOrder;

            if (order['data'] != null) {
              if (order['data']['data'] != null) {
                extractedOrder =
                Map<String, dynamic>.from(order['data']['data']);
              } else {
                extractedOrder =
                Map<String, dynamic>.from(order['data']);
              }
            } else {
              extractedOrder =
              Map<String, dynamic>.from(order);
            }

            orders.add(extractedOrder);

            if (extractedOrder['items'] != null) {
              items.addAll(
                List<dynamic>.from(extractedOrder['items']),
              );
            }
          }
        }

        // ✅ SINGLE ORDER (Backward compatibility)
        else if (orderData is Map) {
          late Map<String, dynamic> extractedOrder;

          if (orderData['data'] != null) {
            if (orderData['data']['data'] != null) {
              extractedOrder =
              Map<String, dynamic>.from(orderData['data']['data']);
            } else {
              extractedOrder =
              Map<String, dynamic>.from(orderData['data']);
            }
          } else {
            extractedOrder =
            Map<String, dynamic>.from(orderData);
          }

          orders.add(extractedOrder);

          if (extractedOrder['items'] != null) {
            items.addAll(
              List<dynamic>.from(extractedOrder['items']),
            );
          }
        }
      }
    } catch (e) {
      print('Error processing order data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Order Numbers (Multi safe)
  String get orderNumbers {
    if (orders.isEmpty) return 'N/A';
    return orders
        .map((o) => o['order_number']?.toString() ?? '')
        .join(', ');
  }

  // ✅ Order Date (use first order)
  String get formattedDate {
    if (orders.isEmpty) return '';
    try {
      final dateTime =
      DateTime.parse(orders.first['created_at'] ?? '');
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (_) {
      return '';
    }
  }

  String get paymentMethod {
    if (orders.isEmpty) return 'COD';
    return orders.first['payment_method']
        ?.toString()
        .toUpperCase() ??
        'COD';
  }

  String get paymentStatus {
    if (orders.isEmpty) return 'Pending';
    final status =
        orders.first['payment_status']?.toString() ??
            'pending';
    return status[0].toUpperCase() + status.substring(1);
  }

  // ✅ Combined totals
  double get subtotal {
    return orders.fold(0.0, (sum, order) {
      return sum +
          (double.tryParse(
              order['total_amount']?.toString() ??
                  '0') ??
              0);
    });
  }

  double get gstAmount {
    return orders.fold(0.0, (sum, order) {
      return sum +
          (double.tryParse(
              order['gst_amount']?.toString() ??
                  '0') ??
              0);
    });
  }

  double get totalAmount {
    return orders.fold(0.0, (sum, order) {
      return sum +
          (double.tryParse(
              order['final_amount']?.toString() ??
                  '0') ??
              0);
    });
  }

  int get itemCount => items.length;
}