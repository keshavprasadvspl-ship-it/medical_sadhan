// lib/app/modules/order_report/controllers/order_report_controller.dart

import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import '../../../data/models/order_model.dart';
import '../../../data/providers/api_provider.dart';
import '../../../services/storage_service.dart';

class OrderReportController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();

  // Data
  final allOrders = <Order>[].obs;
  final filteredOrders = <Order>[].obs;
  final isLoading = false.obs;
  final isExporting = false.obs;

  // Filters
  final selectedPeriod = 'all'.obs;
  final selectedAgency = 'all'.obs;
  final selectedPaymentMethod = 'all'.obs;

  // Custom date range
  final startDate = DateTime.now().obs;
  final endDate = DateTime.now().obs;
  final isCustomRange = false.obs;

  // Available agencies
  final agencies = <String>[].obs;

  // Filter options
  final periodOptions = {
    'all': 'All',
    'today': 'Today',
    'week': 'Week',
    'month': 'Month',
    'custom': 'Custom',
  };

  final paymentMethods = [
    'all',
    'cash',
    'challan',
  ];

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    try {
      final token = await _storageService.getToken();
      final user = await _storageService.getUser();

      if (token == null || user == null) {
        throw Exception('Not logged in');
      }

      isLoading.value = true;

      final buyerId = user['id'];
      final result = await _apiService.getBuyerOrders(
        buyerId: buyerId.toString(),
        token: token,
      );

      if (result['success'] == true && result['data'] != null) {
        final List ordersData = result['data'];
        final loadedOrders = ordersData.map((json) => Order.fromJson(json)).toList();
        allOrders.assignAll(loadedOrders);

        // Extract unique agencies (filter out null/empty)
        final uniqueAgencies = loadedOrders
            .map((order) => order.agency)
            .where((agency) => agency != null && agency.isNotEmpty)
            .toSet()
            .toList();

        // Always add 'all' and agencies - removed the length check
        agencies.assignAll(['all', ...uniqueAgencies.cast<String>()]);

        applyFilters();
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
    await loadOrders();
  }

  void applyFilters() {
    var filtered = [...allOrders];

    // Period filter
    filtered = _filterByPeriod(filtered);

    // Agency filter
    if (selectedAgency.value != 'all') {
      filtered = filtered.where((order) =>
      order.agency == selectedAgency.value
      ).toList();
    }

    // Payment method filter
    if (selectedPaymentMethod.value != 'all') {
      filtered = filtered.where((order) =>
      order.paymentMethod.toLowerCase() == selectedPaymentMethod.value.toLowerCase()
      ).toList();
    }

    // Sort by date (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    filteredOrders.assignAll(filtered);
  }

  List<Order> _filterByPeriod(List<Order> orders) {
    final now = DateTime.now();

    switch (selectedPeriod.value) {
      case 'today':
        final today = DateTime(now.year, now.month, now.day);
        return orders.where((order) {
          final orderDate = order.createdAt;
          return orderDate.year == today.year &&
              orderDate.month == today.month &&
              orderDate.day == today.day;
        }).toList();

      case 'week':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        return orders.where((order) {
          final orderDate = order.createdAt;
          return orderDate.isAfter(start) &&
              orderDate.isBefore(start.add(const Duration(days: 7)));
        }).toList();

      case 'month':
        final start = DateTime(now.year, now.month, 1);
        return orders.where((order) {
          final orderDate = order.createdAt;
          return orderDate.year == start.year && orderDate.month == start.month;
        }).toList();

      case 'custom':
        if (isCustomRange.value) {
          return orders.where((order) {
            final orderDate = order.createdAt;
            return orderDate.isAfter(startDate.value) &&
                orderDate.isBefore(endDate.value.add(const Duration(days: 1)));
          }).toList();
        }
        return orders;

      default:
        return orders;
    }
  }

  void updatePeriod(String period) {
    selectedPeriod.value = period;
    isCustomRange.value = period == 'custom';
    applyFilters();
  }

  void updateCustomRange(DateTime start, DateTime end) {
    startDate.value = start;
    endDate.value = end;
    applyFilters();
  }

  void updateAgency(String agency) {
    selectedAgency.value = agency;
    applyFilters();
  }

  void updatePaymentMethod(String method) {
    selectedPaymentMethod.value = method;
    applyFilters();
  }

  void resetFilters() {
    selectedPeriod.value = 'all';
    selectedAgency.value = 'all';
    selectedPaymentMethod.value = 'all';
    isCustomRange.value = false;
    applyFilters();
  }

  Map<String, dynamic> getStats() {
    final orders = filteredOrders;

    double totalAmount = 0;
    double totalDiscount = 0;
    double totalTax = 0;
    int totalItems = 0;

    int cashCount = 0;
    int challanCount = 0;

    for (var order in orders) {
      totalAmount += order.finalAmount;
      totalDiscount += order.discount;
      totalTax += order.tax;
      totalItems += order.items.fold(0, (sum, item) => sum + item.quantity);

      if (order.paymentMethod.toLowerCase() == 'cash') {
        cashCount++;
      } else if (order.paymentMethod.toLowerCase() == 'challan') {
        challanCount++;
      }
    }

    return {
      'totalOrders': orders.length,
      'totalAmount': totalAmount,
      'totalDiscount': totalDiscount,
      'totalTax': totalTax,
      'totalItems': totalItems,
      'cashOrders': cashCount,
      'challanOrders': challanCount,
      'averageOrderValue': orders.isEmpty ? 0 : totalAmount / orders.length,
    };
  }

  // Enhanced PDF export with open file option
  Future<void> exportAsPDF() async {
    try {
      isExporting.value = true;

      // Request permissions
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          throw Exception('Storage permission denied');
        }
      }

      final pdf = await _generatePDF();

      // Save to Downloads/Documents directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final fileName = 'order_report_${DateFormat('ddMMyyyy_HHmmss').format(DateTime.now())}.pdf';
      final filePath = '${directory!.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(pdf);

      // Show success message with open option
      Get.snackbar(
        'Success',
        'PDF saved to: $fileName',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        mainButton: TextButton(
          onPressed: () => OpenFile.open(filePath),
          child: const Text('OPEN', style: TextStyle(color: Colors.white)),
        ),
      );
    } catch (e) {
      print('Error generating PDF: $e');
      Get.snackbar(
        'Error',
        'Failed to generate PDF: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isExporting.value = false;
    }
  }

// Simplified PDF generation with single table for orders and products
  Future<Uint8List> _generatePDF() async {
    try {
      final pdf = pw.Document();
      final stats = getStats();
      final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

      // Prepare data for single table
      final List<List<String>> tableData = [];

      for (var order in filteredOrders) {
        // Add order header row
        tableData.add([
          order.orderNumber,
          dateFormat.format(order.createdAt),
          order.agency ?? '-',
          order.status.displayName,
          order.paymentMethod.toUpperCase(),
          'ORDER TOTAL',
          order.itemCount.toString(),
          order.finalAmount.toStringAsFixed(2),
        ]);

        // Add product rows for this order
        for (var item in order.items) {
          tableData.add([
            '', // Empty order number for product rows
            '', // Empty date
            '', // Empty agency
            '', // Empty status
            '', // Empty payment
            item.productName,
            '${item.quantity}${item.addon > 0 ? ' +${item.addon}' : ''}',
            (item.quantity * item.unitPrice).toStringAsFixed(2),
          ]);
        }

        // Add separator row (optional)
        if (order != filteredOrders.last) {
          tableData.add([
            '---', '---', '---', '---', '---', '---', '---', '---'
          ]);
        }
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Text(
                'Order Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Generated: ${dateFormat.format(DateTime.now())}',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
              pw.Text(
                'Period: ${_getFilterText()}',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
              if (selectedAgency.value != 'all')
                pw.Text(
                  'Agency: ${selectedAgency.value}',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                ),
              if (selectedPaymentMethod.value != 'all')
                pw.Text(
                  'Payment: ${selectedPaymentMethod.value.toUpperCase()}',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                ),
              pw.SizedBox(height: 20),

              // Summary Row
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildSimpleSummary('Total Orders', '${stats['totalOrders']}'),
                  _buildSimpleSummary('Total Items', '${stats['totalItems']}'),
                  _buildSimpleSummary('Total Amount', '${stats['totalAmount'].toStringAsFixed(0)}'),
                ],
              ),

              pw.SizedBox(height: 24),

              // Combined Orders & Products Table
              pw.TableHelper.fromTextArray(
                headers: ['Order ID', 'Date', 'Agency', 'Status', 'Payment', 'Product/Total', 'Qty', 'Amount'],
                data: tableData,
                border: pw.TableBorder.all(color: PdfColors.grey400),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 9,
                ),
                cellStyle: pw.TextStyle(
                  fontSize: 8,
                ),
                cellAlignment: pw.Alignment.centerLeft,
                headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
                headerHeight: 30,
                cellHeight: 20,
              ),
            ],
          ),
        ),
      );

      return await pdf.save();
    } catch (e) {
      print('Error in PDF generation: $e');
      rethrow;
    }
  }

  pw.Widget _buildSimpleSummary(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Column(
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildOrderSummaryLine(String label, String value, {bool isBold = false}) {
    return pw.Row(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 9, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal),
        ),
        pw.SizedBox(width: 8),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 9, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal),
        ),
      ],
    );
  }

  PdfColor _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return PdfColors.green;
      case 'pending':
        return PdfColors.orange;
      case 'cancelled':
        return PdfColors.red;
      default:
        return PdfColors.grey;
    }
  }

  // Enhanced CSV export with open file option
  Future<void> exportAsCSV() async {
    try {
      isExporting.value = true;

      // Request permissions
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          throw Exception('Storage permission denied');
        }
      }

      final csvData = _generateCSV();
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final fileName = 'order_report_${DateFormat('ddMMyyyy_HHmmss').format(DateTime.now())}.csv';
      final filePath = '${directory!.path}/$fileName';
      final file = File(filePath);
      await file.writeAsString(csvData);

      Get.snackbar(
        'Success',
        'CSV saved to: $fileName',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        mainButton: TextButton(
          onPressed: () => OpenFile.open(filePath),
          child: const Text('OPEN', style: TextStyle(color: Colors.white)),
        ),
      );
    } catch (e) {
      print('Error exporting CSV: $e');
      Get.snackbar(
        'Error',
        'Failed to export CSV: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isExporting.value = false;
    }
  }

  String _generateCSV() {
    try {
      final headers = [
        'Order ID',
        'Order Date',
        'Agency',
        'Status',
        'Payment Method',
        'Product Name',
        'Quantity',
        'Unit Price',
        'Total Price',
        'Discount',
        'Tax',
        'Shipping',
        'Order Total',
      ];

      final rows = <List<String>>[];

      for (var order in filteredOrders) {
        for (var item in order.items) {
          rows.add([
            order.orderNumber,
            DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt),
            order.agency ?? 'N/A',
            order.status.displayName,
            order.paymentMethod.toUpperCase(),
            item.productName,
            '${item.quantity}${item.addon > 0 ? ' +${item.addon}' : ''}',
            '₹${item.unitPrice.toStringAsFixed(2)}',
            '₹${(item.quantity * item.unitPrice).toStringAsFixed(2)}',
            order.discount > 0 ? '₹${order.discount.toStringAsFixed(2)}' : '',
            order.tax > 0 ? '₹${order.tax.toStringAsFixed(2)}' : '',
            order.shippingCharge > 0 ? '₹${order.shippingCharge.toStringAsFixed(2)}' : '',
            '₹${order.finalAmount.toStringAsFixed(2)}',
          ]);
        }
      }

      final csv = const ListToCsvConverter().convert([headers, ...rows]);
      return csv;
    } catch (e) {
      print('Error generating CSV: $e');
      return 'Error generating CSV: $e';
    }
  }

  String _getFilterText() {
    switch (selectedPeriod.value) {
      case 'today':
        return 'Today (${DateFormat('dd/MM/yyyy').format(DateTime.now())})';
      case 'week':
        final startOfWeek = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return 'Week (${DateFormat('dd/MM').format(startOfWeek)} - ${DateFormat('dd/MM/yyyy').format(endOfWeek)})';
      case 'month':
        return 'Month (${DateFormat('MMMM yyyy').format(DateTime.now())})';
      case 'custom':
        return '${DateFormat('dd/MM/yyyy').format(startDate.value)} to ${DateFormat('dd/MM/yyyy').format(endDate.value)}';
      default:
        return 'All Orders';
    }
  }
}