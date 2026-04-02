import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import '../../../../../app/data/models/vendors_orders_model.dart';
import '../../../../utility/vendors_invoice_view.dart';
import '../../orders/controllers/orders_controller.dart';
import '../controllers/orders_controller.dart';

class VendorsOrderDetailView extends StatefulWidget {
  @override
  State<VendorsOrderDetailView> createState() => _VendorsOrderDetailViewState();
}

class _VendorsOrderDetailViewState extends State<VendorsOrderDetailView> {
  final controller = Get.find<VendorsOrdersController>();
  late int orderId;
  final Rx<OrderModel?> orderData = Rx<OrderModel?>(null);
  final isLoading = true.obs;
  final isProcessing = false.obs;

  final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
  final dateFormat = DateFormat('dd MMM yyyy');
  final timeFormat = DateFormat('hh:mm a');

  @override
  void initState() {
    super.initState();
    orderId = Get.arguments as int;
    fetchOrderDetails();
  }

  Future<void> fetchOrderDetails() async {
    try {
      isLoading.value = true;
      final details = await controller.getOrderDetails(orderId);
      orderData.value = details;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load order details: $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Order Details',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.blue),
            onPressed: fetchOrderDetails,
          ),
        ],
      ),
      body: Obx(() {
        if (isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading order details...'),
              ],
            ),
          );
        }

        if (orderData.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Order not found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final order = orderData.value!;

        return Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderHeader(order),
                  _buildCustomerDetails(order),
                  _buildOrderItems(order),
                  _buildPaymentSummary(order),
                  if (order.statusHistory.isNotEmpty)
                    _buildStatusTimeline(order),
                  _buildActionButtons(order),
                  _buildDocumentOptions(order),
                  SizedBox(height: 24),
                ],
              ),
            ),
            if (isProcessing.value)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Processing...'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildOrderHeader(OrderModel order) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Number',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  SizedBox(height: 4),
                  Text(
                    order.orderNumber,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              _buildStatusChip(order.orderStatus),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              SizedBox(width: 8),
              Text(
                'Ordered on: ${dateFormat.format(order.createdAt)} at ${timeFormat.format(order.createdAt)}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          if (order.expectedDeliveryDate != null) ...[
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.local_shipping, size: 16, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Expected delivery: ${dateFormat.format(DateTime.parse(order.expectedDeliveryDate!))}',
                  style: TextStyle(color: Colors.green[700]),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomerDetails(OrderModel order) {
    final shippingAddress = order.shippingAddress;
    final billingAddress = order.billingAddress;

    return Container(
      margin: EdgeInsets.only(top: 16),
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customer Details',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),

          // Customer Name
          if (shippingAddress != null)
            _buildDetailRow(
              Icons.person,
              'Customer Name',
              shippingAddress.contactPerson,
            ),

          if (shippingAddress != null) Divider(height: 24),

          // Shipping Address
          if (shippingAddress != null) ...[
            _buildAddressSection(
              'Shipping Address',
              shippingAddress,
              Icons.location_on,
            ),
            Divider(height: 24),
          ],

          // Billing Address (if different)
          if (billingAddress != null &&
              billingAddress.id != shippingAddress?.id) ...[
            _buildAddressSection(
              'Billing Address',
              billingAddress,
              Icons.receipt,
            ),
            Divider(height: 24),
          ],

          // Contact Info
          if (shippingAddress?.contactPhone.isNotEmpty ?? false) ...[
            _buildDetailRow(
              Icons.phone,
              'Contact Number',
              shippingAddress!.contactPhone,
            ),
            Divider(height: 24),
          ],

          // Email
          if (shippingAddress?.contactEmail != null &&
              shippingAddress!.contactEmail!.isNotEmpty) ...[
            _buildDetailRow(
              Icons.email,
              'Email',
              shippingAddress.contactEmail!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddressSection(String title, Address address, IconData icon) {
    String addressString = address.addressLine1;
    if (address.addressLine2 != null && address.addressLine2!.isNotEmpty) {
      addressString += ', ${address.addressLine2}';
    }
    if (address.landmark != null && address.landmark!.isNotEmpty) {
      addressString += ', ${address.landmark}';
    }
    addressString += '\n${address.city}, ${address.state} - ${address.pincode}\n${address.country}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: Colors.grey),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (address.contactPerson.isNotEmpty)
                    Text(
                      address.contactPerson,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  SizedBox(height: 4),
                  Text(
                    addressString,
                    style: TextStyle(color: Colors.grey[700], height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItems(OrderModel order) {
    if (order.items.isEmpty) {
      return Container(
        margin: EdgeInsets.only(top: 16),
        color: Colors.white,
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text('No items found'),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.only(top: 16),
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Items (${order.items.length})',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),

          // Table Header
          Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text('Product', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 1, child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                Expanded(flex: 2, child: Text('Price', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                Expanded(flex: 2, child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
              ],
            ),
          ),
          SizedBox(height: 8),

          // Items List
          ...order.items.map((item) => _buildOrderItemRow(item)).toList(),

          // Summary
          Divider(height: 24),
          _buildSummaryRow('Subtotal', currencyFormat.format(order.totalAmount)),
          SizedBox(height: 8),
          _buildSummaryRow('GST (${order.items.first.gstPercentage}%)', currencyFormat.format(order.gstAmount)),
          if (order.discountAmount > 0) ...[
            SizedBox(height: 8),
            _buildSummaryRow('Discount', '- ${currencyFormat.format(order.discountAmount)}',
                color: Colors.green),
          ],
          if (order.shippingCharge > 0) ...[
            SizedBox(height: 8),
            _buildSummaryRow('Shipping', currencyFormat.format(order.shippingCharge)),
          ],
          Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                currencyFormat.format(order.finalAmount),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemRow(OrderItem item) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                if (item.vendorProduct?.product?.genericName != null)
                  Text(
                    item.vendorProduct!.product!.genericName,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                if (item.batchNumber != null && item.batchNumber!.isNotEmpty)
                  Text(
                    'Batch: ${item.batchNumber}',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                if (item.expiryDate != null && item.expiryDate!.isNotEmpty)
                  Text(
                    'Expiry: ${dateFormat.format(DateTime.parse(item.expiryDate!))}',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
              ],
            ),
          ),
Expanded(
  flex: 1,
  child: Text(
    item.addon != null && item.addon > 0
        ? '${item.quantity}+${item.addon}'
        : item.quantity.toString(),
    style: TextStyle(fontWeight: FontWeight.w500),
    textAlign: TextAlign.center,
  ),
),
          Expanded(
            flex: 2,
            child: Text(
              currencyFormat.format(item.unitPrice),
              style: TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              currencyFormat.format(item.totalPrice),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(OrderModel order) {
    return Container(
      margin: EdgeInsets.only(top: 16),
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Details',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),

          _buildPaymentDetailRow(
            'Payment Method',
            _getPaymentMethodDisplay(order.paymentMethod),
            Icons.payment,
          ),
          SizedBox(height: 12),

          _buildPaymentDetailRow(
            'Payment Status',
            order.paymentStatus.toUpperCase(),
            Icons.check_circle,
            color: order.paymentStatus.toLowerCase() == 'paid' ? Colors.green : Colors.orange,
          ),

          if (order.paymentMethod.toLowerCase() == 'online' &&
              order.paymentStatus.toLowerCase() == 'paid') ...[
            SizedBox(height: 12),
            _buildPaymentDetailRow(
              'Transaction ID',
              'TXN${order.id}${order.createdAt.millisecondsSinceEpoch}',
              Icons.receipt,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentDetailRow(String label, String value, IconData icon, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color ?? Colors.grey),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color?.withOpacity(0.1) ?? Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTimeline(OrderModel order) {
    return Container(
      margin: EdgeInsets.only(top: 16),
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status Timeline',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),

          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: order.statusHistory.length,
            itemBuilder: (context, index) {
              final history = order.statusHistory[index];
              final isFirst = index == 0;
              final isLast = index == order.statusHistory.length - 1;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeline indicator
                  Column(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getStatusColor(history.status),
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 40,
                          color: Colors.grey.shade300,
                        ),
                    ],
                  ),
                  SizedBox(width: 12),

                  // Status details
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            history.status.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(history.status),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${dateFormat.format(history.createdAt)} at ${timeFormat.format(history.createdAt)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          if (history.notes != null && history.notes!.isNotEmpty) ...[
                            SizedBox(height: 4),
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                history.notes!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(OrderModel order) {
    if (order.orderStatus.toLowerCase() == 'placed') {
      return Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isProcessing.value ? null : () => _handleReject(order),
                icon: Icon(Icons.cancel, color: Colors.white),
                label: Text('Reject Order', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isProcessing.value ? null : () => _handleAccept(order),
                icon: Icon(Icons.check_circle, color: Colors.white),
                label: Text('Accept Order', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (order.orderStatus.toLowerCase() == 'confirmed') {
      return Padding(
        padding: EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isProcessing.value ? null : () => _handleDispatch(order),
            icon: Icon(Icons.local_shipping, color: Colors.white),
            label: Text('Mark as Dispatched', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox.shrink();
  }

  Widget _buildDocumentOptions(OrderModel order) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: isProcessing.value ? null : () => _downloadInvoice(order),
              icon: Icon(Icons.download),
              label: Text('Download Invoice'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: isProcessing.value ? null : () => _viewInvoice(order),
              icon: Icon(Icons.visibility),
              label: Text('View Invoice'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
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
        color = Colors.blue;
        icon = Icons.check_circle;
        break;
      case 'dispatched':
        color = Colors.purple;
        icon = Icons.local_shipping;
        break;
      case 'delivered':
        color = Colors.green;
        icon = Icons.inventory;
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
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[600]),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  String _getPaymentMethodDisplay(String method) {
    switch (method.toLowerCase()) {
      case 'cod':
        return 'Cash on Delivery';
      case 'online':
        return 'Online Payment';
      case 'card':
        return 'Credit/Debit Card';
      case 'upi':
        return 'UPI';
      default:
        return method.toUpperCase();
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'placed':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'dispatched':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _handleAccept(OrderModel order) async {
    try {
      isProcessing.value = true;
      await controller.updateOrderStatus(order.id, 'confirmed',
          notes: 'Order confirmed by vendor');
      await fetchOrderDetails();

      Get.snackbar(
        'Success',
        'Order accepted successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to accept order: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> _handleReject(OrderModel order) async {
    final reasonController = TextEditingController();

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Reject Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Please provide a reason for rejection:'),
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
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.isNotEmpty) {
                Get.back(result: true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        isProcessing.value = true;
        await controller.cancelOrder(order.id, reasonController.text);
        await fetchOrderDetails();

        Get.snackbar(
          'Success',
          'Order rejected successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to reject order: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } finally {
        isProcessing.value = false;
      }
    }
  }

  Future<void> _handleDispatch(OrderModel order) async {
    try {
      isProcessing.value = true;
      await controller.updateOrderStatus(order.id, 'dispatched',
          notes: 'Order has been dispatched');
      await fetchOrderDetails();

      Get.snackbar(
        'Success',
        'Order marked as dispatched',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to dispatch order: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  void _viewInvoice(OrderModel order) {
    Get.to(() => VendorsInvoiceView(order: order));
  }

  Future<void> _downloadInvoice(OrderModel order) async {
    try {
      isProcessing.value = true;

      // Show loading dialog
      Get.dialog(
        AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Generating invoice...'),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      // Generate PDF
      await _generateInvoicePdf(order);

      Get.back(); // Close loading dialog

      Get.snackbar(
        'Success',
        'Invoice downloaded successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.back(); // Close loading dialog if error
      Get.snackbar(
        'Error',
        'Failed to download invoice: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> _generateInvoicePdf(OrderModel order) async {
    final pdf = pw.Document();

    // Load font (make sure you have a font file in assets/fonts/)
    pw.Font? ttf;
    try {
      final ByteData fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
      ttf = pw.Font.ttf(fontData.buffer.asUint8List() as ByteData);
    } catch (e) {
      print('Font loading failed, using default font');
      ttf = null;
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'MEDI SUPPLY PRO',
                        style: pw.TextStyle(
                          font: ttf,
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue700,
                        ),
                      ),
                      pw.Text(
                        'Medical Supplies & Pharmaceuticals',
                        style: pw.TextStyle(font: ttf, fontSize: 10),
                      ),
                    ],
                  ),
                  pw.Text(
                    'INVOICE',
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Invoice details
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Invoice #: ${order.orderNumber}',
                    style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    'Date: ${dateFormat.format(order.createdAt)}',
                    style: pw.TextStyle(font: ttf),
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              // Customer details
              pw.Container(
                padding: pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Bill To:',
                      style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 5),
                    if (order.shippingAddress != null) ...[
                      pw.Text(order.shippingAddress!.contactPerson, style: pw.TextStyle(font: ttf)),
                      pw.Text(order.shippingAddress!.fullAddress, style: pw.TextStyle(font: ttf)),
                      pw.Text('Phone: ${order.shippingAddress!.contactPhone}', style: pw.TextStyle(font: ttf)),
                      if (order.shippingAddress!.contactEmail != null)
                        pw.Text('Email: ${order.shippingAddress!.contactEmail}', style: pw.TextStyle(font: ttf)),
                    ],
                  ],
                ),
              ),
              pw.SizedBox(height: 30),

              // Items table
              pw.Text(
                'Order Items',
                style: pw.TextStyle(font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),

              // Table header
              pw.Container(
                padding: pw.EdgeInsets.all(8),
                color: PdfColors.blue50,
                child: pw.Row(
                  children: [
                    pw.Expanded(child: pw.Text('Product', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(child: pw.Text('Qty', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center)),
                    pw.Expanded(child: pw.Text('Unit Price', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                    pw.Expanded(child: pw.Text('Total', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                  ],
                ),
              ),

              // Table rows
              ...order.items.map((item) => pw.Container(
                padding: pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.grey300),
                  ),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(item.productName, style: pw.TextStyle(font: ttf)),
                          if (item.vendorProduct?.product?.genericName != null)
                            pw.Text(
                              item.vendorProduct!.product!.genericName,
                              style: pw.TextStyle(font: ttf, fontSize: 8, color: PdfColors.grey700),
                            ),
                        ],
                      ),
                    ),
                    pw.Expanded(child: pw.Text(item.quantity.toString(), style: pw.TextStyle(font: ttf), textAlign: pw.TextAlign.center)),
                    pw.Expanded(child: pw.Text(currencyFormat.format(item.unitPrice), style: pw.TextStyle(font: ttf), textAlign: pw.TextAlign.right)),
                    pw.Expanded(child: pw.Text(currencyFormat.format(item.totalPrice), style: pw.TextStyle(font: ttf), textAlign: pw.TextAlign.right)),
                  ],
                ),
              )),

              pw.SizedBox(height: 20),

              // Total
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Subtotal: ${currencyFormat.format(order.totalAmount)}', style: pw.TextStyle(font: ttf)),
                    pw.Text('GST (${order.items.first.gstPercentage}%): ${currencyFormat.format(order.gstAmount)}', style: pw.TextStyle(font: ttf)),
                    if (order.discountAmount > 0)
                      pw.Text('Discount: -${currencyFormat.format(order.discountAmount)}', style: pw.TextStyle(font: ttf)),
                    if (order.shippingCharge > 0)
                      pw.Text('Shipping: ${currencyFormat.format(order.shippingCharge)}', style: pw.TextStyle(font: ttf)),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'Total: ${currencyFormat.format(order.finalAmount)}',
                      style: pw.TextStyle(font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 30),

              // Footer
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text(
                'Thank you for your business!',
                style: pw.TextStyle(font: ttf, fontStyle: pw.FontStyle.italic),
                textAlign: pw.TextAlign.center,
              ),
              pw.Text(
                'This is a computer generated invoice.',
                style: pw.TextStyle(font: ttf, fontSize: 8),
                textAlign: pw.TextAlign.center,
              ),
            ],
          );
        },
      ),
    );

    // Save the PDF file
    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'Invoice_${order.orderNumber}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);

    // Open the file
    await OpenFile.open(file.path);
  }
}