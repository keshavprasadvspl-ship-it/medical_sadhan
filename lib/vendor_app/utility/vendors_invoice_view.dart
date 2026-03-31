import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:open_file/open_file.dart';

import '../../../../../app/data/models/vendors_orders_model.dart';

class VendorsInvoiceView extends StatelessWidget {
  final OrderModel order;

  VendorsInvoiceView({required this.order});

  final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
  final dateFormat = DateFormat('dd MMM yyyy');
  final timeFormat = DateFormat('hh:mm a');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Invoice #${order.orderNumber}',
          style: TextStyle(fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.download, color: Colors.blue),
            onPressed: () => _generateAndSavePdf(context),
            tooltip: 'Download PDF',
          ),
          IconButton(
            icon: Icon(Icons.share, color: Colors.green),
            onPressed: () => _shareInvoice(context),
            tooltip: 'Share Invoice',
          ),
          IconButton(
            icon: Icon(Icons.print, color: Colors.purple),
            onPressed: () => _printInvoice(context),
            tooltip: 'Print Invoice',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Company Brand Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.purple.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
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
                            'MEDI SUPPLY PRO',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                          Text(
                            'Medical Supplies & Pharmaceuticals',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.medical_services,
                          color: Colors.blue.shade700,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Invoice Header
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TAX INVOICE',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                              letterSpacing: 1,
                            ),
                          ),
                          SizedBox(height: 4),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Invoice #: ${order.orderNumber}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Date: ${dateFormat.format(order.createdAt)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Time: ${timeFormat.format(order.createdAt)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(order.orderStatus).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _getStatusColor(order.orderStatus),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getStatusIcon(order.orderStatus),
                                  size: 16,
                                  color: _getStatusColor(order.orderStatus),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  order.orderStatus.toUpperCase(),
                                  style: TextStyle(
                                    color: _getStatusColor(order.orderStatus),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Divider(thickness: 1, color: Colors.grey.shade300),
                  SizedBox(height: 16),

                  // Bill To & Ship To Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bill To
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BILL TO',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                                letterSpacing: 1,
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order.shippingAddress?.contactPerson ?? 'Customer',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  if (order.shippingAddress != null) ...[
                                    SizedBox(height: 4),
                                    Text(
                                      order.shippingAddress!.fullAddress,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                  if (order.shippingAddress?.contactPhone.isNotEmpty ?? false) ...[
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.phone,
                                          size: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          order.shippingAddress!.contactPhone,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  if (order.shippingAddress?.contactEmail != null &&
                                      order.shippingAddress!.contactEmail!.isNotEmpty) ...[
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.email,
                                          size: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          order.shippingAddress!.contactEmail!,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16),

                      // Ship To (if different from billing)
                      if (order.shippingAddress != null &&
                          order.billingAddress != null &&
                          order.shippingAddress!.id != order.billingAddress!.id)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SHIP TO',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600,
                                  letterSpacing: 1,
                                ),
                              ),
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      order.shippingAddress!.contactPerson,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      order.shippingAddress!.fullAddress,
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Order Items Table
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ORDER ITEMS',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
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
                        Expanded(flex: 4, child: Text('Product', style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(flex: 1, child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                        Expanded(flex: 2, child: Text('Unit Price', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                        Expanded(flex: 2, child: Text('GST', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                        Expanded(flex: 2, child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),

                  // Table Items
                  if (order.items.isNotEmpty)
                    ...order.items.map((item) => _buildInvoiceItemRow(item)).toList()
                  else
                    _buildInvoiceItemRow(null),

                  SizedBox(height: 16),
                  Divider(thickness: 1, color: Colors.grey.shade300),

                  // Totals Section
                  _buildTotalsSection(),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Payment Details
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PAYMENT DETAILS',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _buildPaymentDetail(
                          'Payment Method',
                          _getPaymentMethodDisplay(order.paymentMethod),
                          Icons.payment,
                        ),
                        Divider(height: 16),
                        _buildPaymentDetail(
                          'Payment Status',
                          order.paymentStatus.toUpperCase(),
                          Icons.check_circle,
                          color: order.paymentStatus.toLowerCase() == 'paid'
                              ? Colors.green
                              : Colors.orange,
                        ),
                        if (order.paymentMethod.toLowerCase() == 'online' &&
                            order.paymentStatus.toLowerCase() == 'paid') ...[
                          Divider(height: 16),
                          _buildPaymentDetail(
                            'Transaction ID',
                            'TXN${order.id}${order.createdAt.millisecondsSinceEpoch}',
                            Icons.receipt,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Terms & Notes
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TERMS & CONDITIONS',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '• Goods once sold will not be taken back.\n'
                                '• Payment is due within 15 days of invoice date.\n'
                                '• Late payments are subject to 2% monthly interest.\n'
                                '• All disputes are subject to Mumbai jurisdiction.',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              height: 1.5,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (order.vendorNotes != null && order.vendorNotes!.isNotEmpty) ...[
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'VENDOR NOTES',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber.shade200),
                            ),
                            child: Text(
                              order.vendorNotes!,
                              style: TextStyle(
                                color: Colors.amber.shade900,
                                fontSize: 12,
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
            SizedBox(height: 16),

            // Footer
            Container(
              padding: EdgeInsets.symmetric(vertical: 24, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildFooterItem(Icons.email, 'billing@medisupply.com'),
                      _buildFooterItem(Icons.phone, '+91 98765 43210'),
                      _buildFooterItem(Icons.web, 'www.medisupply.com'),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'This is a computer generated invoice - no signature required',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 11,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Thank you for your business!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceItemRow(OrderItem? item) {
    if (item == null) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'No items available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          // Product
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                if (item.vendorProduct?.product?.genericName != null)
                  Text(
                    item.vendorProduct!.product!.genericName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                if (item.batchNumber != null && item.batchNumber!.isNotEmpty)
                  Text(
                    'Batch: ${item.batchNumber}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                if (item.expiryDate != null && item.expiryDate!.isNotEmpty)
                  Text(
                    'Expiry: ${dateFormat.format(DateTime.parse(item.expiryDate!))}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
              ],
            ),
          ),

          // Quantity
          Expanded(
            flex: 1,
            child: Text(
              item.quantity.toString(),
              style: TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),

          // Unit Price
          Expanded(
            flex: 2,
            child: Text(
              currencyFormat.format(item.unitPrice),
              style: TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
            ),
          ),

          // GST
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${item.gstPercentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  currencyFormat.format(item.gstAmount),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Total
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

  Widget _buildTotalsSection() {
    double subtotal = order.totalAmount;
    double gstTotal = order.gstAmount;
    double discount = order.discountAmount;
    double shipping = order.shippingCharge;
    double finalAmount = order.finalAmount;

    return Column(
      children: [
        _buildTotalRow('Subtotal', currencyFormat.format(subtotal)),
        _buildTotalRow(
          'GST (Total)',
          currencyFormat.format(gstTotal),
          isHighlighted: true,
        ),
        if (discount > 0)
          _buildTotalRow(
            'Discount',
            '- ${currencyFormat.format(discount)}',
            color: Colors.green,
          ),
        if (shipping > 0)
          _buildTotalRow('Shipping', currencyFormat.format(shipping)),
        Divider(height: 24, thickness: 1),
        Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.purple.shade50],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.account_balance_wallet, color: Colors.blue.shade700),
                  SizedBox(width: 8),
                  Text(
                    'TOTAL AMOUNT',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ],
              ),
              Text(
                currencyFormat.format(finalAmount),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
        ),
        if (order.finalAmount.toString().length > 0) ...[
          SizedBox(height: 8),
          Text(
            'Amount in words: ${_convertToWords(finalAmount)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTotalRow(String label, String value, {
    bool isHighlighted = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
              color: color ?? Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetail(String label, String value, IconData icon, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color ?? Colors.blue.shade700),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
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
              fontSize: 14,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade400, size: 16),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 12,
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

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'placed':
        return Icons.access_time;
      case 'confirmed':
        return Icons.check_circle;
      case 'dispatched':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.inventory;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _convertToWords(double amount) {
    // Simple implementation - you might want to use a package for this
    int rupees = amount.floor();
    int paise = ((amount - rupees) * 100).round();

    String result = '$rupees Rupees';
    if (paise > 0) {
      result += ' and $paise Paise';
    }
    result += ' Only';

    return result;
  }

  // PDF Generation Methods
  Future<void> _generateAndSavePdf(BuildContext context) async {
    try {
      // Show loading
      Get.dialog(
        AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Generating PDF...'),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      // Create PDF document
      final PdfDocument document = PdfDocument();

      // Add cover page
      _addCoverPage(document);

      // Add invoice content
      await _addPdfContent(document);

      // Save the document
      final List<int> bytes = await document.save();
      document.dispose();

      // Get directory
      final Directory directory = await getApplicationDocumentsDirectory();
      final String fileName = 'Invoice_${order.orderNumber}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
      final String path = '${directory.path}/$fileName';
      final File file = File(path);
      await file.writeAsBytes(bytes, flush: true);

      // Close loading dialog
      Get.back();

      // Show success message
      Get.snackbar(
        'Success',
        'Invoice downloaded successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      // Open the file
      OpenFile.open(path);
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Failed to generate PDF: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      print(e);
    }
  }

  void _addCoverPage(PdfDocument document) {
    final PdfPage coverPage = document.pages.add();
    final PdfGraphics graphics = coverPage.graphics;

    // Draw background
    graphics.drawRectangle(
      brush: PdfSolidBrush(PdfColor(33, 150, 243)),
      bounds: Rect.fromLTWH(0, 0, coverPage.size.width, coverPage.size.height),
    );

    // Add text on cover page
    graphics.drawString(
      'MEDI SUPPLY PRO',
      PdfStandardFont(PdfFontFamily.helvetica, 30, style: PdfFontStyle.bold),
      brush: PdfBrushes.white,
      bounds: Rect.fromLTWH(50, coverPage.size.height / 2 - 50, coverPage.size.width - 100, 50),
    );

    graphics.drawString(
      'Medical Supplies & Pharmaceuticals',
      PdfStandardFont(PdfFontFamily.helvetica, 16),
      brush: PdfBrushes.white,
      bounds: Rect.fromLTWH(50, coverPage.size.height / 2, coverPage.size.width - 100, 30),
    );
  }

  Future<void> _addPdfContent(PdfDocument document) async {
    final PdfPage page = document.pages.add();
    final PdfGraphics graphics = page.graphics;
    double yPos = 50;

    // Load fonts
    final PdfFont regularFont = PdfStandardFont(PdfFontFamily.helvetica, 10);
    final PdfFont boldFont = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
    final PdfFont headerFont = PdfStandardFont(PdfFontFamily.helvetica, 16, style: PdfFontStyle.bold);
    final PdfFont titleFont = PdfStandardFont(PdfFontFamily.helvetica, 24, style: PdfFontStyle.bold);

    // Company Header
    graphics.drawString(
      'MEDI SUPPLY PRO',
      titleFont,
      brush: PdfBrushes.blue,
      bounds: Rect.fromLTWH(50, yPos, 300, 30),
    );
    yPos += 30;

    graphics.drawString(
      'Medical Supplies & Pharmaceuticals',
      regularFont,
      brush: PdfBrushes.gray,
      bounds: Rect.fromLTWH(50, yPos, 300, 20),
    );
    yPos += 30;

    // Invoice Title
    graphics.drawString(
      'TAX INVOICE',
      headerFont,
      brush: PdfBrushes.blue,
      bounds: Rect.fromLTWH(50, yPos, 200, 20),
    );
    yPos += 30;

    // Invoice Details
    graphics.drawString(
      'Invoice #: ${order.orderNumber}',
      boldFont,
      bounds: Rect.fromLTWH(50, yPos, 200, 20),
    );
    graphics.drawString(
      'Date: ${dateFormat.format(order.createdAt)}',
      regularFont,
      bounds: Rect.fromLTWH(300, yPos, 200, 20),
    );
    yPos += 20;

    // Bill To Section
    yPos += 20;
    graphics.drawString(
      'BILL TO:',
      boldFont,
      bounds: Rect.fromLTWH(50, yPos, 100, 20),
    );
    yPos += 20;

    if (order.shippingAddress != null) {
      graphics.drawString(
        order.shippingAddress!.contactPerson,
        boldFont,
        bounds: Rect.fromLTWH(50, yPos, 300, 20),
      );
      yPos += 20;

      // Split address into multiple lines if needed
      String address = order.shippingAddress!.fullAddress;
      List<String> addressLines = _splitAddress(address);
      for (String line in addressLines) {
        graphics.drawString(
          line,
          regularFont,
          bounds: Rect.fromLTWH(50, yPos, 400, 20),
        );
        yPos += 20;
      }

      if (order.shippingAddress!.contactPhone.isNotEmpty) {
        graphics.drawString(
          'Phone: ${order.shippingAddress!.contactPhone}',
          regularFont,
          bounds: Rect.fromLTWH(50, yPos, 300, 20),
        );
        yPos += 20;
      }
    }

    yPos += 20;

    // Items Table
    _addPdfTable(document, page, graphics, regularFont, boldFont, yPos);

    // Footer
    final double pageHeight = page.getClientSize().height;
    graphics.drawString(
      'Thank you for your business!',
      boldFont,
      brush: PdfBrushes.blue,
      bounds: Rect.fromLTWH(50, pageHeight - 50, 300, 20),
    );
    graphics.drawString(
      'This is a computer generated invoice',
      regularFont,
      brush: PdfBrushes.gray,
      bounds: Rect.fromLTWH(50, pageHeight - 30, 300, 20),
    );
  }

  List<String> _splitAddress(String address) {
    // Split address into lines of max 50 characters
    List<String> lines = [];
    final words = address.split(' ');
    String currentLine = '';

    for (String word in words) {
      if ((currentLine + ' ' + word).length <= 50) {
        if (currentLine.isEmpty) {
          currentLine = word;
        } else {
          currentLine += ' $word';
        }
      } else {
        if (currentLine.isNotEmpty) {
          lines.add(currentLine);
        }
        currentLine = word;
      }
    }

    if (currentLine.isNotEmpty) {
      lines.add(currentLine);
    }

    return lines;
  }

  void _addPdfTable(
      PdfDocument document,
      PdfPage page,
      PdfGraphics graphics,
      PdfFont regularFont,
      PdfFont boldFont,
      double yPos,
      ) {
    // Create table
    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: 5);
    grid.headers.add(1);

    // Set column widths
    grid.columns[0].width = 200; // Product
    grid.columns[1].width = 40;  // Qty
    grid.columns[2].width = 80;  // Unit Price
    grid.columns[3].width = 80;  // GST Amt
    grid.columns[4].width = 80;  // Total

    // Add headers
    final PdfGridRow headerRow = grid.headers[0];
    headerRow.cells[0].value = 'Product';
    headerRow.cells[1].value = 'Qty';
    headerRow.cells[2].value = 'Unit Price';
    headerRow.cells[3].value = 'GST Amt';
    headerRow.cells[4].value = 'Total';

    // Style header
    for (int i = 0; i < 5; i++) {
      headerRow.cells[i].style.font = boldFont;
      headerRow.cells[i].style.backgroundBrush = PdfSolidBrush(PdfColor(33, 150, 243));
      headerRow.cells[i].style.textBrush = PdfBrushes.white;
      headerRow.cells[i].style.stringFormat = PdfStringFormat(
        alignment: i == 0 ? PdfTextAlignment.left : PdfTextAlignment.right,
      );
    }

    // Add items
    if (order.items.isNotEmpty) {
      for (var item in order.items) {
        final PdfGridRow row = grid.rows.add();
        String productDisplay = item.productName;
        if (item.vendorProduct?.product?.genericName != null) {
          productDisplay += '\n${item.vendorProduct!.product!.genericName}';
        }

        row.cells[0].value = productDisplay;
        row.cells[1].value = item.quantity.toString();
        row.cells[2].value = currencyFormat.format(item.unitPrice);
        row.cells[3].value = currencyFormat.format(item.gstAmount);
        row.cells[4].value = currencyFormat.format(item.totalPrice);

        // Style cells
        for (int i = 1; i < 5; i++) {
          row.cells[i].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.right);
        }

        // Allow multiline for product name
        row.cells[0].style.stringFormat = PdfStringFormat(
          alignment: PdfTextAlignment.left,
          wordWrap: PdfWordWrapType.word,
        );
      }
    } else {
      final PdfGridRow row = grid.rows.add();
      row.cells[0].value = 'No items available';
      row.cells[0].columnSpan = 5;
    }

    // Style the grid
    grid.style.cellPadding = PdfPaddings(left: 5, top: 5, right: 5, bottom: 5);
    grid.style.font = regularFont;

    // Calculate height based on number of rows
    double gridHeight = 30 + (grid.rows.count * 25);

    // Draw grid
    grid.draw(
      page: page,
      bounds: Rect.fromLTWH(50, yPos, 500, gridHeight),
    );

    // Add totals after the grid
    yPos += gridHeight + 20;

    double subtotal = order.totalAmount;
    double gstTotal = order.gstAmount;
    double finalAmount = order.finalAmount;

    graphics.drawString(
      'Subtotal: ${currencyFormat.format(subtotal)}',
      regularFont,
      bounds: Rect.fromLTWH(350, yPos, 200, 20),
    );
    yPos += 20;

    graphics.drawString(
      'GST Total: ${currencyFormat.format(gstTotal)}',
      regularFont,
      bounds: Rect.fromLTWH(350, yPos, 200, 20),
    );
    yPos += 20;

    graphics.drawString(
      'TOTAL: ${currencyFormat.format(finalAmount)}',
      boldFont,
      brush: PdfBrushes.blue,
      bounds: Rect.fromLTWH(350, yPos, 200, 20),
    );
  }

  void _shareInvoice(BuildContext context) {
    Get.snackbar(
      'Share',
      'Sharing functionality will be available soon',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _printInvoice(BuildContext context) {
    Get.snackbar(
      'Print',
      'Print functionality will be available soon',
      backgroundColor: Colors.purple,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}