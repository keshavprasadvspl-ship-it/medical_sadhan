// lib/app/modules/order_success/views/order_success_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/order_success_controller.dart';

class OrderSuccessView extends GetView<OrderSuccessController> {
  const OrderSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0B630B)),
            );
          }

          return Column(
            children: [
              /// HEADER
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.offAllNamed('/main'),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const Spacer(),
                    const Text(
                      "Order Confirmation",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      /// SUCCESS ICON
                      Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE6F4EA),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          size: 70,
                          color: Color(0xFF0B630B),
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        "Orders Placed Successfully!",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// ORDER CARDS
                      ...controller.orders.map((order) {
                        final items = order['items'] ?? [];
                        final referredBy = order['refferal_note'] ?? '';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              /// ✅ GREEN HEADER BAR
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0B630B),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Order #${order['order_number']}",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        order['order_status']
                                                .toString()
                                                .toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    /// ✅ REFERRED BY
                                    if (referredBy.isNotEmpty) ...[
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFF8E1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: const Color(0xFFFFD54F)),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.person_add_alt_1,
                                              size: 16,
                                              color: Color(0xFFF57F17),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              "Referred By: $referredBy",
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFFF57F17),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                    ],

                                    /// ✅ ITEMS SECTION
                                    const Text(
                                      "Items",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    ...items.map<Widget>((item) {
                                      final qty =
                                          int.tryParse(item['quantity'].toString()) ?? 0;
                                      final addon =
                                          int.tryParse(item['addon'].toString()) ?? 0;
                                      final mrp =
                                          double.tryParse(item['mrp_price'].toString()) ?? 0;
                                      final discountMin =
                                          double.tryParse(item['discount_min'].toString()) ?? 0;
                                      final discountMax =
                                          double.tryParse(item['discount_max'].toString()) ?? 0;
                                      final unitPrice =
                                          double.tryParse(item['unit_price'].toString()) ?? 0;
                                      final totalPrice =
                                          double.tryParse(item['total_price'].toString()) ?? 0;
                                      final gstPct =
                                          double.tryParse(item['gst_percentage'].toString()) ?? 0;
                                      final gstAmt =
                                          double.tryParse(item['gst_amount'].toString()) ?? 0;

                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[50],
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: Colors.grey.shade200),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [

                                            /// Product Name
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.inventory_2,
                                                  size: 18,
                                                  color: Color(0xFF0B630B),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    item['product_name'] ?? '',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  "₹${totalPrice.toStringAsFixed(2)}",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    color: Color(0xFF0B630B),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 10),
                                            const Divider(height: 1),
                                            const SizedBox(height: 10),

                                            /// ✅ Quantity + Addon
                                            _itemDetailRow(
                                              Icons.shopping_basket_outlined,
                                              "Quantity",
                                              addon > 0
                                                  ? "$qty + $addon (Free)"
                                                  : "$qty",
                                            ),

                                            const SizedBox(height: 6),

                                            /// Unit Price
                                            _itemDetailRow(
                                              Icons.currency_rupee,
                                              "Unit Price",
                                              "₹${unitPrice.toStringAsFixed(2)}",
                                            ),

                                            const SizedBox(height: 6),
                                            /// ✅ MRP + Discount same row
                                            _itemDetailRow(
                                              Icons.label_outline,
                                              "MRP",
                                              "₹${mrp.toStringAsFixed(2)}  |  Upto ${discountMin.toStringAsFixed(0)}%-${discountMax.toStringAsFixed(0)}% Off",
                                              valueColor: const Color(0xFFE53935),
                                            ),
                                                                                      

                                            const SizedBox(height: 6),

                                            /// GST
                                            _itemDetailRow(
                                              Icons.receipt_outlined,
                                              "GST (${gstPct.toStringAsFixed(0)}%)",
                                              "₹${gstAmt.toStringAsFixed(2)}",
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),

                                    const Divider(height: 24),

                                    /// ✅ PRICE BREAKDOWN
                                    _priceRow(
                                      "Subtotal",
                                      double.tryParse(
                                              order['total_amount'].toString()) ??
                                          0,
                                    ),
                                    const SizedBox(height: 6),
                                    _priceRow(
                                      "GST",
                                      double.tryParse(
                                              order['gst_amount'].toString()) ??
                                          0,
                                    ),
                                    const SizedBox(height: 6),
                                    _priceRow(
                                      "Total",
                                      double.tryParse(
                                              order['final_amount'].toString()) ??
                                          0,
                                      isTotal: true,
                                    ),

                                    const SizedBox(height: 14),

                                    /// ✅ PAYMENT INFO
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F8E9),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Payment Method",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              Text(
                                                order['payment_method']
                                                    .toString()
                                                    .toUpperCase(),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              const Text(
                                                "Payment Status",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: order['payment_status'] ==
                                                          'paid'
                                                      ? const Color(0xFFE6F4EA)
                                                      : const Color(0xFFFFF3E0),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  order['payment_status']
                                                      .toString()
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: order[
                                                                'payment_status'] ==
                                                            'paid'
                                                        ? const Color(
                                                            0xFF0B630B)
                                                        : const Color(
                                                            0xFFE65100),
                                                  ),
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
                            ],
                          ),
                        );
                      }).toList(),

                      const SizedBox(height: 20),

                      /// CONTINUE BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Get.offAllNamed('/main'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0B630B),
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Continue Shopping",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  /// Item detail row helper
  Widget _itemDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 15, color: Colors.grey[500]),
        const SizedBox(width: 6),
        Text(
          "$label: ",
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  /// Price breakdown row helper
  Widget _priceRow(String title, double value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 15 : 13,
          ),
        ),
        Text(
          "₹${value.toStringAsFixed(2)}",
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 15 : 13,
            color: isTotal ? const Color(0xFF0B630B) : Colors.black87,
          ),
        ),
      ],
    );
  }
}