import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// ── Same controller & model — no new controller needed ───────────────────────
import '../controllers/orders_controller.dart';
import '../../../../../app/data/models/vendors_orders_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PAGE 1 — Challan Orders: Buyer-Grouped
// Filter logic: confirmed orders = challan orders
// ─────────────────────────────────────────────────────────────────────────────

class ChallanOrdersView extends StatelessWidget {
  const ChallanOrdersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ── Reuse same controller already in memory ───────────────────────────
    final controller = Get.isRegistered<VendorsOrdersController>()
    ? Get.find<VendorsOrdersController>()
    : Get.put(VendorsOrdersController());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Challan Orders',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              'Confirmed  •  Buyer-wise Grouped',
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () => controller.fetchOrders(reset: true),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // ── Filter: only confirmed orders are challan orders ──────────────
        final challanOrders = controller.orders
            .where((o) =>
                o.orderStatus.toLowerCase() == 'confirmed')
            .toList();

        if (challanOrders.isEmpty) {
          return _buildEmptyState(controller);
        }

        // ── Group by buyerId ──────────────────────────────────────────────
        final Map<int, List<OrderModel>> grouped = {};
        for (final o in challanOrders) {
          grouped.putIfAbsent(o.buyerId, () => []).add(o);
        }

        return RefreshIndicator(
          onRefresh: () async =>
              controller.fetchOrders(reset: true),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Summary strip ─────────────────────────────────────────
              _buildSummaryStrip(challanOrders, grouped),
              const SizedBox(height: 8),
              // ── Buyer cards ───────────────────────────────────────────
              ...grouped.entries.map((e) => _BuyerGroupCard(
                    buyerId: e.key,
                    orders: e.value,
                  )),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSummaryStrip(
      List<OrderModel> all, Map<int, List<OrderModel>> grouped) {
    final totalAmount =
        all.fold<double>(0, (s, o) => s + o.finalAmount);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade500, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryItem(
              '${grouped.length}', 'Buyers', Icons.people),
          _summaryItem(
              '${all.length}', 'Challans', Icons.receipt_long),
          _summaryItem('₹${(totalAmount / 1000).toStringAsFixed(1)}K',
              'Due', Icons.currency_rupee),
        ],
      ),
    );
  }

  Widget _summaryItem(String val, String label, IconData icon) =>
      Column(children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(height: 4),
        Text(val,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(
                color: Colors.white70, fontSize: 11)),
      ]);

  Widget _buildEmptyState(VendorsOrdersController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No challan orders found',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text('Confirmed orders will appear here',
              style: TextStyle(color: Colors.grey.shade500)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => controller.fetchOrders(reset: true),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BUYER GROUP CARD
// ─────────────────────────────────────────────────────────────────────────────

class _BuyerGroupCard extends StatelessWidget {
  final int buyerId;
  final List<OrderModel> orders;

  const _BuyerGroupCard(
      {required this.buyerId, required this.orders});

  @override
  Widget build(BuildContext context) {
    final buyer = orders.first;
    final buyerName =
        buyer.shippingAddress?.contactPerson ?? 'Buyer #$buyerId';
    final buyerAddress =
        buyer.shippingAddress?.fullAddress ?? '';
    final totalDue =
        orders.fold<double>(0, (s, o) => s + o.finalAmount);
    final totalQty = orders.fold<int>(
        0,
        (s, o) => s +
            o.items.fold<int>(
                0, (ss, i) => ss + i.quantity + i.addon));

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Get.to(() => BuyerChallanDetailView(
              buyerId: buyerId,
              orders: orders,
              buyerName: buyerName,
              buyerAddress: buyerAddress,
            )),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.blue.shade400,
                      Colors.indigo.shade700,
                    ]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      buyerName[0].toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(buyerName,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      if (buyerAddress.isNotEmpty)
                        Text(buyerAddress,
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      Text('Buyer ID: $buyerId',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('₹${totalDue.toStringAsFixed(0)}',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700)),
                    Text('Total Due',
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500)),
                  ],
                ),
              ]),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),

              Row(children: [
                _pill(Icons.receipt_long,
                    '${orders.length} Challans', Colors.blue),
                const SizedBox(width: 8),
                _pill(Icons.inventory_2, '$totalQty Qty',
                    Colors.purple),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(children: [
                    Icon(Icons.picture_as_pdf,
                        size: 12,
                        color: Colors.orange.shade700),
                    const SizedBox(width: 4),
                    Text('View & Invoice',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w600)),
                  ]),
                ),
              ]),

              const SizedBox(height: 10),

              // Order numbers preview
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: orders
                    .take(3)
                    .map((o) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius:
                                BorderRadius.circular(6),
                          ),
                          child: Text(o.orderNumber,
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontFamily: 'monospace')),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(IconData icon, String label, Color color) =>
      Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600)),
        ]),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGE 2 — Buyer Challan Detail: Day-wise + Invoice
// ─────────────────────────────────────────────────────────────────────────────

class BuyerChallanDetailView extends StatefulWidget {
  final int buyerId;
  final List<OrderModel> orders;
  final String buyerName;
  final String buyerAddress;

  const BuyerChallanDetailView({
    Key? key,
    required this.buyerId,
    required this.orders,
    required this.buyerName,
    required this.buyerAddress,
  }) : super(key: key);

  @override
  State<BuyerChallanDetailView> createState() =>
      _BuyerChallanDetailViewState();
}

class _BuyerChallanDetailViewState
    extends State<BuyerChallanDetailView> {
  final Set<String> _selected = {};
  late final List<OrderModel> _sorted;

  @override
  void initState() {
    super.initState();
    _sorted = [...widget.orders]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _selectLastNDays(int n) {
    final cutDate = DateTime.now().subtract(Duration(days: n - 1));
    final cd =
        DateTime(cutDate.year, cutDate.month, cutDate.day);
    setState(() {
      _selected.clear();
      for (final o in _sorted) {
        final d = DateTime(
            o.createdAt.year, o.createdAt.month, o.createdAt.day);
        if (!d.isBefore(cd)) _selected.add(o.id.toString());
      }
    });
  }

  void _selectAll() => setState(
      () => _selected.addAll(_sorted.map((o) => o.id.toString())));
  void _clearAll() => setState(() => _selected.clear());

  List<OrderModel> get _selOrders => _sorted
      .where((o) => _selected.contains(o.id.toString()))
      .toList();

  double get _selTotal =>
      _selOrders.fold(0, (s, o) => s + o.finalAmount);

  int get _selQty => _selOrders.fold(
      0,
      (s, o) => s +
          o.items
              .fold<int>(0, (ss, i) => ss + i.quantity + i.addon));

  int get _selItemCount =>
      _selOrders.fold(0, (s, o) => s + o.items.length);

  Map<String, List<OrderModel>> get _byDate {
    final map = <String, List<OrderModel>>{};
    for (final o in _sorted) {
      final key = DateFormat('dd MMM yyyy').format(o.createdAt);
      map.putIfAbsent(key, () => []).add(o);
    }
    return map;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.buyerName,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Text('ID: ${widget.buyerId}',
                style: const TextStyle(
                    color: Colors.grey, fontSize: 10)),
          ],
        ),
        actions: [
          PopupMenuButton<int>(
            icon:
                const Icon(Icons.date_range, color: Colors.black),
            tooltip: 'Quick select by days',
            onSelected: _selectLastNDays,
            itemBuilder: (_) => const [
              PopupMenuItem(value: 1, child: Text('Today')),
              PopupMenuItem(
                  value: 3, child: Text('Last 3 Days')),
              PopupMenuItem(
                  value: 5, child: Text('Last 5 Days')),
              PopupMenuItem(
                  value: 7, child: Text('Last 7 Days')),
              PopupMenuItem(
                  value: 30, child: Text('Last 30 Days')),
            ],
          ),
          PopupMenuButton<String>(
            icon:
                const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (v) {
              if (v == 'all') _selectAll();
              if (v == 'clear') _clearAll();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                  value: 'all', child: Text('Select All')),
              PopupMenuItem(
                  value: 'clear',
                  child: Text('Clear Selection')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (_selected.isNotEmpty) _buildSelectionBanner(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: _byDate.entries.map((entry) {
                final dayTotal = entry.value
                    .fold<double>(0, (s, o) => s + o.finalAmount);
                final dayQty = entry.value.fold<int>(
                    0,
                    (s, o) => s +
                        o.items.fold<int>(
                            0,
                            (ss, i) =>
                                ss + i.quantity + i.addon));

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: 8),
                      child: Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade600,
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: Text(entry.key,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight:
                                      FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        Text(
                            '${entry.value.length} challans  •  ₹${dayTotal.toStringAsFixed(0)}  •  $dayQty qty',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade700)),
                      ]),
                    ),
                    ...entry.value
                        .map((o) => _buildOrderCard(o)),
                    const SizedBox(height: 4),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSelectionBanner() => Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 10),
        color: Colors.indigo.shade700,
        child: Row(children: [
          const Icon(Icons.check_circle,
              color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${_selected.length} selected  •  $_selItemCount products  •  $_selQty qty  •  ₹${_selTotal.toStringAsFixed(2)}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold),
            ),
          ),
          GestureDetector(
            onTap: _clearAll,
            child: const Icon(Icons.close,
                color: Colors.white70, size: 18),
          ),
        ]),
      );

  Widget _buildOrderCard(OrderModel order) {
    final isSelected =
        _selected.contains(order.id.toString());
    final totalQty = order.items
        .fold<int>(0, (s, i) => s + i.quantity + i.addon);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(
                color: Colors.indigo.shade500, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => isSelected
            ? _selected.remove(order.id.toString())
            : _selected.add(order.id.toString())),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.indigo.shade600
                        : Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check,
                          color: Colors.white, size: 15)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(order.orderNumber,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          fontFamily: 'monospace')),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('₹${order.finalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700)),
                    Text(
                        DateFormat('hh:mm a')
                            .format(order.createdAt),
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500)),
                  ],
                ),
              ]),

              const SizedBox(height: 10),

              // Items table
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: Colors.grey.shade200),
                ),
                child: Column(children: [
                  Row(children: [
                    _th('Particulars', flex: 3),
                    _th('Pack'),
                    _th('Batch'),
                    _th('Exp'),
                    _th('Qty'),
                    _th('MRP'),
                    _th('Rate'),
                  ]),
                  const Divider(height: 6, thickness: 0.5),
                  ...order.items.map((item) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: 3),
                        child: Row(children: [
                          _td(item.productName,
                              flex: 3, bold: true),
                          _td(item.vendorProduct?.packSize ?? '-'),
                          _td(item.batchNumber ?? '-'),
                          _td(item.expiryDate ?? '-'),
                          _td(
                            item.addon > 0
                                ? '${item.quantity}+${item.addon}'
                                : '${item.quantity}',
                            color: Colors.blue.shade700,
                          ),
                          _td('₹${item.mrpPrice.toStringAsFixed(0)}'),
                          _td(
                              '₹${item.unitPrice.toStringAsFixed(2)}',
                              bold: true),
                        ]),
                      )),
                ]),
              ),

              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    if (order.gstAmount > 0) ...[
                      _pill2(Icons.percent,
                          'GST ₹${order.gstAmount.toStringAsFixed(0)}',
                          Colors.purple),
                      const SizedBox(width: 6),
                    ],
                    _pill2(Icons.inventory_2_outlined,
                        '$totalQty qty', Colors.teal),
                  ]),
                  if (order.discountAmount > 0)
                    Text(
                      'Disc: ₹${order.discountAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _th(String t, {int flex = 1}) => Expanded(
        flex: flex,
        child: Text(t,
            style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600)),
      );

  Widget _td(String t,
          {int flex = 1, bool bold = false, Color? color}) =>
      Expanded(
        flex: flex,
        child: Text(t,
            style: TextStyle(
                fontSize: 10,
                fontWeight:
                    bold ? FontWeight.w600 : FontWeight.normal,
                color: color ?? Colors.grey.shade800),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      );

  Widget _pill2(IconData icon, String label, Color color) =>
      Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w600)),
        ]),
      );

  Widget _buildBottomBar() {
    final has = _selected.isNotEmpty;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (has) ...[
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    '${_selected.length} challans  •  $_selItemCount products  •  $_selQty qty',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                Text('₹${_selTotal.toStringAsFixed(2)}',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700)),
              ],
            ),
            const SizedBox(height: 10),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: has ? _generateInvoice : null,
              icon: const Icon(Icons.picture_as_pdf, size: 18),
              label: Text(has
                  ? 'Download Invoice (${_selected.length} Challans)'
                  : 'Select Challans to Generate Invoice'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.shade700,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    Colors.grey.shade300,
                padding:
                    const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── PDF — Dinkar Pharma style ─────────────────────────────────────────────

  Future<void> _generateInvoice() async {
    if (_selOrders.isEmpty) return;

    final grandTotal = _selTotal;
    final totalQty = _selQty;
    final totalItemCount = _selItemCount;

    final pdf = pw.Document();
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(
          horizontal: 20, vertical: 20),
      header: (_) => _pdfHeader(),
      footer: (ctx) => _pdfFooter(
          ctx, totalItemCount, totalQty, grandTotal),
      build: (_) => [_pdfTable()],
    ));

    final bytes = await pdf.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename:
          'Invoice_${widget.buyerName.replaceAll(' ', '_')}_${DateFormat('ddMMyyyy').format(DateTime.now())}.pdf',
    );
  }

  pw.Widget _pdfHeader() => pw.Column(children: [
        pw.Row(
          mainAxisAlignment:
              pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
                crossAxisAlignment:
                    pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('DINKAR PHARMA',
                      style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold)),
                  pw.Text('M/S ${widget.buyerName}',
                      style:
                          const pw.TextStyle(fontSize: 11)),
                  pw.Text(widget.buyerAddress,
                      style:
                          const pw.TextStyle(fontSize: 10)),
                ]),
            pw.Column(
                crossAxisAlignment:
                    pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('CREDIT',
                      style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold)),
                  pw.Text('CHALLAN INVOICE',
                      style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                      'Date: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                      style:
                          const pw.TextStyle(fontSize: 9)),
                  pw.Text(
                      'Total Challans: ${_selOrders.length}',
                      style:
                          const pw.TextStyle(fontSize: 9)),
                ]),
          ],
        ),
        pw.SizedBox(height: 6),
        pw.Divider(thickness: 1.5),
        pw.SizedBox(height: 3),
      ]);

  pw.Widget _pdfTable() {
    final colW = {
      0: const pw.FlexColumnWidth(3.2),
      1: const pw.FlexColumnWidth(1.1),
      2: const pw.FlexColumnWidth(1.5),
      3: const pw.FlexColumnWidth(0.9),
      4: const pw.FlexColumnWidth(0.7),
      5: const pw.FlexColumnWidth(0.5),
      6: const pw.FlexColumnWidth(1.1),
      7: const pw.FlexColumnWidth(1.1),
      8: const pw.FlexColumnWidth(0.6),
    };

    final rows = <pw.TableRow>[
      // Header
      pw.TableRow(
        decoration:
            const pw.BoxDecoration(color: PdfColors.grey200),
        children: [
          'PARTICULARS',
          'PACK',
          'BATCH',
          'EXP',
          'QTY',
          'FR',
          'MRP',
          'RATE',
          'GST'
        ].map((h) => _pdfCell(h, bold: true, fontSize: 7.5)).toList(),
      ),
    ];

    for (final order in _selOrders) {
      // Challan separator
      rows.add(pw.TableRow(
        decoration: const pw.BoxDecoration(
            color: PdfColor.fromInt(0xFFEEF2FF)),
        children: List.generate(
            9,
            (i) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 4, vertical: 3),
                  child: i == 0
                      ? pw.Text(
                          'Challan: ${order.orderNumber}   |   ${DateFormat('dd/MM/yyyy  hh:mm a').format(order.createdAt)}',
                          style: pw.TextStyle(
                              fontSize: 7,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.indigo700))
                      : pw.SizedBox(),
                )),
      ));

      // Items
      for (final item in order.items) {
        rows.add(pw.TableRow(children: [
          _pdfCell(item.productName),
          _pdfCell(
              item.vendorProduct?.packSize ?? '-'),
          _pdfCell(item.batchNumber ?? '-'),
          _pdfCell(item.expiryDate ?? '-'),
          _pdfCell(item.addon > 0
              ? '${item.quantity}+${item.addon}'
              : '${item.quantity}'),
          _pdfCell(item.addon > 0 ? '${item.addon}' : ''),
          _pdfCell(item.mrpPrice.toStringAsFixed(2)),
          _pdfCell(item.unitPrice.toStringAsFixed(2)),
          // _pdfCell(
          //     item.gstPercent?.toStringAsFixed(0) ?? '5'),
        ]));
      }
    }

    return pw.Table(
        columnWidths: colW,
        border: pw.TableBorder.all(
            color: PdfColors.grey300, width: 0.5),
        children: rows);
  }

  pw.Widget _pdfCell(String text,
          {bool bold = false, double fontSize = 8.5}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(
            horizontal: 4, vertical: 4),
        child: pw.Text(text,
            style: pw.TextStyle(
                fontSize: fontSize,
                fontWeight: bold
                    ? pw.FontWeight.bold
                    : pw.FontWeight.normal)),
      );

  pw.Widget _pdfFooter(pw.Context ctx, int items, int qty,
          double total) =>
      pw.Column(children: [
        pw.Divider(thickness: 1),
        pw.Row(
          mainAxisAlignment:
              pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
                'ITEMS : $items    TOTAL QTY : $qty    DISC AMT.  0.00',
                style: const pw.TextStyle(fontSize: 9)),
            pw.Text(
                'AMOUNT : ₹${total.toStringAsFixed(2)}',
                style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold)),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment:
              pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('DELIVERD COPY',
                style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold)),
            pw.Text(
                'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
                style: const pw.TextStyle(fontSize: 8)),
            pw.Text('SING BY _______________',
                style: const pw.TextStyle(fontSize: 9)),
          ],
        ),
      ]);
}