import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// ── Same controller & model — no new controller needed ───────────────────────
import '../controllers/orders_controller.dart';
import '../../../../../app/data/models/vendors_orders_model.dart';

class CashOrdersView extends StatelessWidget {
  const CashOrdersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              'Cash Orders',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              'Cash Payment  •  Buyer-wise Grouped',
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

        // ── Filter: only cash payment orders ─────────────────────────────
        final cash = controller.orders
            .where((o) => o.paymentMethod.toLowerCase() == 'cash')
            .toList();

        if (cash.isEmpty) {
          return _buildEmptyState(controller);
        }

        final Map<int, List<OrderModel>> grouped = {};
        for (final o in cash) {
          grouped.putIfAbsent(o.buyerId, () => []).add(o);
        }

        return RefreshIndicator(
          onRefresh: () async => controller.fetchOrders(reset: true),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSummaryStrip(cash, grouped),
              const SizedBox(height: 8),
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
    final totalAmount = all.fold<double>(0, (s, o) => s + o.finalAmount);
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
          _summaryItem('${grouped.length}', 'Buyers', Icons.people),
          _summaryItem('${all.length}', 'Orders', Icons.receipt_long),
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
            style:
                const TextStyle(color: Colors.white70, fontSize: 11)),
      ]);

  Widget _buildEmptyState(VendorsOrdersController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No cash orders found',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text('Cash payment orders will appear here',
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
// BUYER GROUP CARD — unchanged
// ─────────────────────────────────────────────────────────────────────────────

class _BuyerGroupCard extends StatelessWidget {
  final int buyerId;
  final List<OrderModel> orders;

  const _BuyerGroupCard({required this.buyerId, required this.orders});

  @override
  Widget build(BuildContext context) {
    final buyer = orders.first;
    final buyerName =
        buyer.shippingAddress?.contactPerson ?? 'Buyer #$buyerId';
    final buyerAddress = buyer.shippingAddress?.fullAddress ?? '';
    final totalDue = orders.fold<double>(0, (s, o) => s + o.finalAmount);
    final totalQty = orders.fold<int>(
        0,
        (s, o) =>
            s + o.items.fold<int>(0, (ss, i) => ss + i.quantity + i.addon));

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(buyerName,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
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
                            fontSize: 10, color: Colors.grey.shade500)),
                  ],
                ),
              ]),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(children: [
                _pill(Icons.receipt_long, '${orders.length} Orders',
                    Colors.blue),
                const SizedBox(width: 8),
                _pill(Icons.inventory_2, '$totalQty Qty', Colors.purple),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(children: [
                    Icon(Icons.picture_as_pdf,
                        size: 12, color: Colors.orange.shade700),
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
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(o.orderNumber,
                              style: const TextStyle(
                                  fontSize: 10, fontFamily: 'monospace')),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(IconData icon, String label, Color color) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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

  void _selectLastNDays(int n) {
    final cutDate = DateTime.now().subtract(Duration(days: n - 1));
    final cd = DateTime(cutDate.year, cutDate.month, cutDate.day);
    setState(() {
      _selected.clear();
      for (final o in _sorted) {
        final d =
            DateTime(o.createdAt.year, o.createdAt.month, o.createdAt.day);
        if (!d.isBefore(cd)) _selected.add(o.id.toString());
      }
    });
  }

  void _selectAll() =>
      setState(() => _selected.addAll(_sorted.map((o) => o.id.toString())));
  void _clearAll() => setState(() => _selected.clear());

  List<OrderModel> get _selOrders =>
      _sorted.where((o) => _selected.contains(o.id.toString())).toList();

  double get _selTotal =>
      _selOrders.fold(0, (s, o) => s + o.finalAmount);

  int get _selQty => _selOrders.fold(
      0,
      (s, o) =>
          s + o.items.fold<int>(0, (ss, i) => ss + i.quantity + i.addon));

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
            Text('ID: ${widget.buyerId}  •  Cash',
                style:
                    const TextStyle(color: Colors.grey, fontSize: 10)),
          ],
        ),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.date_range, color: Colors.black),
            tooltip: 'Quick select by days',
            onSelected: _selectLastNDays,
            itemBuilder: (_) => const [
              PopupMenuItem(value: 1, child: Text('Today')),
              PopupMenuItem(value: 3, child: Text('Last 3 Days')),
              PopupMenuItem(value: 5, child: Text('Last 5 Days')),
              PopupMenuItem(value: 7, child: Text('Last 7 Days')),
              PopupMenuItem(value: 30, child: Text('Last 30 Days')),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (v) {
              if (v == 'all') _selectAll();
              if (v == 'clear') _clearAll();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'all', child: Text('Select All')),
              PopupMenuItem(value: 'clear', child: Text('Clear Selection')),
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
                            0, (ss, i) => ss + i.quantity + i.addon));

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade600,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(entry.key,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        Text(
                            '${entry.value.length} orders  •  ₹${dayTotal.toStringAsFixed(0)}  •  $dayQty qty',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade700)),
                      ]),
                    ),
                    ...entry.value.map((o) => _buildOrderCard(o)),
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
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: Colors.indigo.shade700,
        child: Row(children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 16),
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
    final isSelected = _selected.contains(order.id.toString());
    final totalQty =
        order.items.fold<int>(0, (s, i) => s + i.quantity + i.addon);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: Colors.indigo.shade500, width: 2)
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
                        DateFormat('hh:mm a').format(order.createdAt),
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500)),
                  ],
                ),
              ]),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
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
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Row(children: [
                          _td(item.productName, flex: 3, bold: true),
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
                          _td('₹${item.unitPrice.toStringAsFixed(2)}',
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
                fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
                color: color ?? Colors.grey.shade800),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      );

  Widget _pill2(IconData icon, String label, Color color) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    '${_selected.length} challans  •  $_selItemCount products  •  $_selQty qty',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
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
                  ? 'Download Invoice (${_selected.length} Orders)'
                  : 'Select Orders to Generate Invoice'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.shade700,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── PDF — Dinkar Pharma / Satguru Enterprises style ───────────────────────

  Future<void> _generateInvoice() async {
    if (_selOrders.isEmpty) return;

    // ── Aggregate GST buckets ─────────────────────────────────────────────
    // Map<gstPercent, {taxable, sgst, cgst}>
    final Map<double, _GstBucket> gstMap = {};
    double subTotal = 0;
    double totalDiscount = 0;

    for (final order in _selOrders) {
      totalDiscount += order.discountAmount;
      for (final item in order.items) {
        final taxable = item.unitPrice *
            (item.quantity + item.addon).toDouble();
        subTotal += taxable;
        final gstPct = item.gstPercentage;
        final gstAmt = taxable * gstPct / 100;
        final half = gstAmt / 2;
        gstMap.putIfAbsent(gstPct, () => _GstBucket()).add(
          taxable: taxable,
          sgst: half,
          cgst: half,
        );
      }
    }

    final totalGst = gstMap.values
        .fold<double>(0, (s, b) => s + b.sgst + b.cgst);
    final grandTotal = subTotal + totalGst - totalDiscount;
    final totalQty = _selQty;
    final totalItemCount = _selItemCount;

    // ── Invoice number (use first order number as base) ───────────────────
    final invoiceNo = 'A${DateTime.now().millisecondsSinceEpoch % 100000}';

    final pdf = pw.Document();
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin:
          const pw.EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      header: (_) => _pdfHeader(invoiceNo),
      footer: (ctx) => _pdfFooter(
        ctx: ctx,
        gstMap: gstMap,
        subTotal: subTotal,
        totalGst: totalGst,
        totalDiscount: totalDiscount,
        grandTotal: grandTotal,
        totalItems: totalItemCount,
        totalQty: totalQty,
      ),
      build: (_) => [_pdfTable()],
    ));

    final bytes = await pdf.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename:
          'Invoice_${widget.buyerName.replaceAll(' ', '_')}_${DateFormat('ddMMyyyy').format(DateTime.now())}.pdf',
    );
  }

  // ── PDF HEADER ────────────────────────────────────────────────────────────
  //
  //  LEFT  : Buyer name + address (M/S ...)
  //  RIGHT : Dinkar Pharma details + Invoice No / Date
  //
  pw.Widget _pdfHeader(String invoiceNo) {
    const ts8 = pw.TextStyle(fontSize: 8);
    final tsBold9 = pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold);
    final tsBold11 =
        pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold);
    final tsBold14 =
        pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold);

    return pw.Column(children: [
      // ── Top two-column header ────────────────────────────────────────────
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // LEFT — Buyer (shop)
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(6),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                    color: PdfColors.grey400, width: 0.5),
              ),
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('M/S ${widget.buyerName}',
                        style: tsBold11),
                    pw.SizedBox(height: 2),
                    pw.Text(widget.buyerAddress, style: ts8),
                    pw.SizedBox(height: 3),
                    pw.Text('Buyer ID : ${widget.buyerId}',
                        style: ts8),
                  ]),
            ),
          ),

          pw.SizedBox(width: 8),

          // RIGHT — Dinkar Pharma (vendor / issuer)
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(6),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                    color: PdfColors.grey400, width: 0.5),
              ),
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment:
                          pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('DINKAR PHARMA', style: tsBold14),
                        pw.Column(
                          crossAxisAlignment:
                              pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text('CASH', style: tsBold9),
                            pw.Text('INVOICE',
                                style: pw.TextStyle(
                                    fontSize: 7,
                                    fontWeight:
                                        pw.FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                        'Near Avanti Bai Chowk, Lodhipara, Raipur C.G.',
                        style: ts8),
                    pw.Text('Ph: 7389185023', style: ts8),
                    pw.Text(
                        'GST: 22GPDPD6771R1ZD  |  D.L.No.: WLF2025CT000351',
                        style: ts8),
                    pw.SizedBox(height: 4),
                    pw.Row(children: [
                      pw.Text('Invoice No : ', style: tsBold9),
                      pw.Text(invoiceNo,
                          style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.indigo700)),
                      pw.Spacer(),
                      pw.Text(
                          'Date : ${DateFormat('dd-MM-yyyy').format(DateTime.now())}',
                          style: ts8),
                    ]),
                    pw.Row(children: [
                      pw.Text(
                          'Due Date : ${DateFormat('dd-MM-yyyy').format(DateTime.now())}',
                          style: ts8),
                      pw.Spacer(),
                      pw.Text('CASH', style: tsBold9),
                    ]),
                    pw.Text(
                        'Total Orders : ${_selOrders.length}',
                        style: ts8),
                  ]),
            ),
          ),
        ],
      ),

      pw.SizedBox(height: 4),
    ]);
  }

  // ── PDF TABLE ─────────────────────────────────────────────────────────────
  //
  //  Columns: Sn | HSN | Item & Packing | Qty | Batch | Exp |
  //           New MRP | Old MRP | Rate | Sch% | Dis% | Taxable Amt | GST% | GST Amt | Total
  //
  pw.Widget _pdfTable() {
    const colWidths = {
      0: pw.FixedColumnWidth(18),  // Sn
      1: pw.FixedColumnWidth(34),  // HSN
      2: pw.FlexColumnWidth(3.0),  // Item & Packing
      3: pw.FixedColumnWidth(22),  // Qty
      4: pw.FixedColumnWidth(36),  // Batch
      5: pw.FixedColumnWidth(24),  // Exp
      6: pw.FixedColumnWidth(32),  // New MRP
      7: pw.FixedColumnWidth(32),  // Old MRP
      8: pw.FixedColumnWidth(36),  // Rate
      9: pw.FixedColumnWidth(22),  // Sch%
      10: pw.FixedColumnWidth(22), // Dis%
      11: pw.FixedColumnWidth(40), // Taxable Amt
      12: pw.FixedColumnWidth(22), // GST%
      13: pw.FixedColumnWidth(32), // GST Amt
      14: pw.FixedColumnWidth(38), // Total
    };

    final headers = [
      'Sn', 'HSN', 'ITEM & PACKING', 'QTY', 'BATCH', 'EXP',
      'NEW\nMRP', 'OLD\nMRP', 'RATE', 'SCH\n%', 'DIS\n%',
      'TAXABLE\nAMT', 'GST\n%', 'GST\nAMT', 'TOTAL',
    ];

    final rows = <pw.TableRow>[
      // Header row
      pw.TableRow(
        decoration:
            const pw.BoxDecoration(color: PdfColors.grey300),
        children: headers
            .map((h) => _pdfCell(h,
                bold: true,
                fontSize: 6.5,
                align: pw.Alignment.center))
            .toList(),
      ),
    ];

    int sn = 1;

    for (final order in _selOrders) {
      // ── Challan separator row ──────────────────────────────────────────
      rows.add(pw.TableRow(
        decoration: const pw.BoxDecoration(
            color: PdfColor.fromInt(0xFFEEF2FF)),
        children: List.generate(15, (i) {
          if (i == 0) {
            return pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                  horizontal: 3, vertical: 2),
              child: pw.Text(
                'Challan: ${order.orderNumber}',
                style: pw.TextStyle(
                    fontSize: 6.5,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.indigo700),
              ),
            );
          }
          if (i == 2) {
            return pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                  horizontal: 3, vertical: 2),
              child: pw.Text(
                DateFormat('dd/MM/yyyy  hh:mm a')
                    .format(order.createdAt),
                style: pw.TextStyle(
                    fontSize: 6.5,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.indigo700),
              ),
            );
          }
          return pw.SizedBox();
        }),
      ));

      // ── Item rows ──────────────────────────────────────────────────────
      for (final item in order.items) {
        final taxable =
            item.unitPrice * (item.quantity + item.addon).toDouble();
        final gstPct = item.gstPercentage;
        final gstAmt = taxable * gstPct / 100;
        final total = taxable + gstAmt;
        final qtyStr = item.addon > 0
            ? '${item.quantity}+${item.addon}'
            : '${item.quantity}';

        rows.add(pw.TableRow(children: [
          _pdfCell('${sn++}', align: pw.Alignment.center),
          _pdfCell(item.vendorProduct?.product?.hsnCode ?? '300490'),
          _pdfCell(item.productName, bold: true),
          _pdfCell(qtyStr, align: pw.Alignment.center),
          _pdfCell(item.batchNumber ?? '-'),
          _pdfCell(item.expiryDate ?? '-'),
          _pdfCell(item.mrpPrice.toStringAsFixed(2),
              align: pw.Alignment.centerRight),
          _pdfCell(item.mrpPrice.toStringAsFixed(2),
              align: pw.Alignment.centerRight),
          _pdfCell(item.unitPrice.toStringAsFixed(2),
              align: pw.Alignment.centerRight, bold: true),
          _pdfCell('0.00', align: pw.Alignment.centerRight),
          _pdfCell(
              item.vendorProduct?.discountPercentage.toStringAsFixed(2) ?? '0',
              align: pw.Alignment.centerRight),
          _pdfCell(taxable.toStringAsFixed(2),
              align: pw.Alignment.centerRight),
          _pdfCell('${gstPct.toStringAsFixed(0)}%',
              align: pw.Alignment.center),
          _pdfCell(gstAmt.toStringAsFixed(2),
              align: pw.Alignment.centerRight),
          _pdfCell(total.toStringAsFixed(2),
              align: pw.Alignment.centerRight, bold: true),
        ]));
      }
    }

    return pw.Table(
      columnWidths: colWidths,
      border: pw.TableBorder.all(
          color: PdfColors.grey400, width: 0.4),
      children: rows,
    );
  }

  pw.Widget _pdfCell(
    String text, {
    bool bold = false,
    double fontSize = 8.0,
    pw.Alignment align = pw.Alignment.centerLeft,
  }) =>
      pw.Container(
        alignment: align,
        padding: const pw.EdgeInsets.symmetric(
            horizontal: 3, vertical: 3),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: fontSize,
            fontWeight:
                bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      );

  // ── PDF FOOTER ────────────────────────────────────────────────────────────
  //
  //  LEFT  : GST class breakdown table (GST 5%, 12%, 18%, 28%)
  //  RIGHT : Sub Total / SGST / CGST / Discount / Grand Total box
  //  BOTTOM: Amount in words | Bank details | Signature
  //
  pw.Widget _pdfFooter({
  required pw.Context ctx,
  required Map<double, _GstBucket> gstMap,
  required double subTotal,
  required double totalGst,
  required double totalDiscount,
  required double grandTotal,
  required int totalItems,
  required int totalQty,
}) {
  // ✅ FIX: const hata diya
  final tsBold8 =
      pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold);
  final ts8 = pw.TextStyle(fontSize: 8);
  final ts7 = pw.TextStyle(fontSize: 7);

  final amtWords = _amountInWords(grandTotal);

  final gstRows = <pw.TableRow>[
    pw.TableRow(
      decoration: pw.BoxDecoration(color: PdfColors.grey200),
      children: ['CLASS', 'TOTAL', 'SCH.', 'DISC.', 'SGST', 'CGST', 'TOTAL GST']
          .map((h) => _footCell(h, bold: true, fs: 7))
          .toList(),
    ),

    for (final pct in [5.0, 12.0, 18.0, 28.0])
      pw.TableRow(children: [
        _footCell('GST ${pct.toStringAsFixed(0)}.00', fs: 7),

        _footCell(
          gstMap[pct]?.taxable.toStringAsFixed(2) ?? '0.00',
          fs: 7,
        ),

        _footCell('0.00', fs: 7),

        _footCell(
          totalDiscount > 0
              ? totalDiscount.toStringAsFixed(2)
              : '0.00',
          fs: 7,
        ),

        _footCell(
          gstMap[pct]?.sgst.toStringAsFixed(2) ?? '0.00',
          fs: 7,
        ),

        _footCell(
          gstMap[pct]?.cgst.toStringAsFixed(2) ?? '0.00',
          fs: 7,
        ),

        _footCell(
          gstMap[pct] != null
              ? (gstMap[pct]!.sgst + gstMap[pct]!.cgst)
                  .toStringAsFixed(2)
              : '0.00',
          fs: 7,
        ),
      ]),

    pw.TableRow(
      decoration: pw.BoxDecoration(color: PdfColors.grey200),
      children: [
        _footCell('TOTAL', bold: true, fs: 7),

        _footCell(subTotal.toStringAsFixed(2), bold: true, fs: 7),

        _footCell('0.00', fs: 7),

        _footCell(totalDiscount.toStringAsFixed(2), fs: 7),

        _footCell((totalGst / 2).toStringAsFixed(2),
            bold: true, fs: 7),

        _footCell((totalGst / 2).toStringAsFixed(2),
            bold: true, fs: 7),

        _footCell(totalGst.toStringAsFixed(2),
            bold: true, fs: 7),
      ],
    ),
  ];

  return pw.Column(children: [
    pw.Divider(thickness: 0.8),

    pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'ITEMS : $totalItems    TOTAL QTY : $totalQty',
            style: tsBold8,
          ),
          pw.Text(
            'TAXABLE AMT : ${subTotal.toStringAsFixed(2)}',
            style: tsBold8,
          ),
        ],
      ),
    ),

    pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 5,
          child: pw.Table(
            border: pw.TableBorder.all(
                color: PdfColors.grey400, width: 0.4),
            children: gstRows,
          ),
        ),
        pw.SizedBox(width: 8),

        pw.Expanded(
          flex: 3,
          child: pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(
                  color: PdfColors.grey400, width: 0.5),
            ),
            child: pw.Column(children: [
              _totalRow('SUB TOTAL',
                  subTotal.toStringAsFixed(2)),
              _totalRow('SGST PAYBLE',
                  (totalGst / 2).toStringAsFixed(2)),
              _totalRow('CGST PAYBLE',
                  (totalGst / 2).toStringAsFixed(2)),
              _totalRow(
                  'DISCOUNT', totalDiscount.toStringAsFixed(2)),
              _totalRow('CR/DR NOTE', '0.00'),

              pw.Container(
                color: PdfColors.grey200,
                child: _totalRow(
                  'GRAND TOTAL',
                  grandTotal.toStringAsFixed(2),
                  bold: true,
                  fs: 10,
                ),
              ),
            ]),
          ),
        ),
      ],
    ),

    pw.SizedBox(height: 6),

    pw.Container(
      width: double.infinity,
      padding:
          const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: pw.BoxDecoration(
        border:
            pw.Border.all(color: PdfColors.grey300, width: 0.4),
      ),
      child: pw.Text(
        'Rs. $amtWords only',
        style: pw.TextStyle(
          fontSize: 8,
          fontStyle: pw.FontStyle.italic,
        ),
      ),
    ),

    pw.SizedBox(height: 4),

    pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 3,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Terms & Conditions',
                style: pw.TextStyle(
                  fontSize: 7,
                  fontWeight: pw.FontWeight.bold,
                  decoration: pw.TextDecoration.underline,
                ),
              ),
              pw.Text(
                'E.&O.E Price difference under drug price control order 1970 will be refunded.',
                style: ts7,
              ),
              pw.Text(
                'Claims of payment without receipt will be accepted.',
                style: ts7,
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'S.B.I BANK, TELIBANDHA\nA/C No.: 39322235441\nIFSC: SBIN0005194',
                style: ts7,
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 8),

        pw.Expanded(
          flex: 2,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('For DINKAR PHARMA', style: tsBold8),
              pw.SizedBox(height: 20),
              pw.Text('Authorised Signatory', style: ts8),
            ],
          ),
        ),
      ],
    ),

    pw.SizedBox(height: 4),

    pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'DELIVERED COPY',
          style: pw.TextStyle(
            fontSize: 8,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
          style: ts8,
        ),
        pw.Text('SIGN BY _______________', style: ts8),
      ],
    ),
  ]);
}  pw.Widget _footCell(String t,
      {bool bold = false, double fs = 8}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(
            horizontal: 3, vertical: 2),
        child: pw.Text(t,
            style: pw.TextStyle(
                fontSize: fs,
                fontWeight: bold
                    ? pw.FontWeight.bold
                    : pw.FontWeight.normal)),
      );

  pw.Widget _totalRow(String label, String value,
      {bool bold = false, double fs = 8.5}) =>
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(
                horizontal: 5, vertical: 3),
            child: pw.Text(label,
                style: pw.TextStyle(
                    fontSize: fs,
                    fontWeight: bold
                        ? pw.FontWeight.bold
                        : pw.FontWeight.normal)),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(
                horizontal: 5, vertical: 3),
            child: pw.Text(value,
                style: pw.TextStyle(
                    fontSize: fs,
                    fontWeight: bold
                        ? pw.FontWeight.bold
                        : pw.FontWeight.normal)),
          ),
        ],
      );

  /// Very simple amount-in-words (handles up to lakhs)
  String _amountInWords(double amount) {
    final int rupees = amount.floor();
    final int paise = ((amount - rupees) * 100).round();

    const ones = [
      '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven',
      'Eight', 'Nine', 'Ten', 'Eleven', 'Twelve', 'Thirteen',
      'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen',
      'Nineteen'
    ];
    const tens = [
      '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty',
      'Sixty', 'Seventy', 'Eighty', 'Ninety'
    ];

    String twoDigits(int n) {
      if (n < 20) return ones[n];
      return '${tens[n ~/ 10]}${n % 10 > 0 ? ' ${ones[n % 10]}' : ''}';
    }

    String threeDigits(int n) {
      if (n >= 100) {
        return '${ones[n ~/ 100]} Hundred${n % 100 > 0 ? ' ${twoDigits(n % 100)}' : ''}';
      }
      return twoDigits(n);
    }

    String convert(int n) {
      if (n == 0) return 'Zero';
      String result = '';
      if (n >= 100000) {
        result += '${twoDigits(n ~/ 100000)} Lakh ';
        n %= 100000;
      }
      if (n >= 1000) {
        result += '${twoDigits(n ~/ 1000)} Thousand ';
        n %= 1000;
      }
      if (n > 0) result += threeDigits(n);
      return result.trim();
    }

    final rupeePart = convert(rupees);
    final paisePart = paise > 0 ? ' and ${convert(paise)} Paise' : '';
    return '$rupeePart$paisePart';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper: GST bucket accumulator
// ─────────────────────────────────────────────────────────────────────────────
class _GstBucket {
  double taxable = 0;
  double sgst = 0;
  double cgst = 0;

  void add(
      {required double taxable,
      required double sgst,
      required double cgst}) {
    this.taxable += taxable;
    this.sgst += sgst;
    this.cgst += cgst;
  }
}