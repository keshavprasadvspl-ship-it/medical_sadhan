import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/orders_controller.dart';
import '../../../data/models/order_model.dart';

class OrdersView extends GetView<OrdersController> {
  const OrdersView({super.key});

  // ─── THEME COLORS ──────────────────────────────────────────────────────────
  static const primary   = Color(0xFF043734);
  static const secondary = Color(0xFF21827A);
  static const lightBg   = Color(0xFFF0F7F6);
  static const cardBg    = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Obx(() => controller.isLoggedIn.value
                ? _buildFiltersBar()
                : const SizedBox.shrink()),
            Expanded(
              child: Obx(() {
                if (!controller.isLoggedIn.value) return _buildLoginRequiredView();
                if (controller.isLoading.value)   return _buildLoading();
                if (controller.filteredOrders.isEmpty) return _buildEmptyState();
                return RefreshIndicator(
                  onRefresh: () => controller.refreshOrders(),
                  color: secondary,
                  backgroundColor: Colors.white,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = controller.filteredOrders[index];
                      return _buildOrderCard(order);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ─── APP BAR  (refresh button removed) ────────────────────────────────────
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.receipt_long_rounded, color: Colors.white, size: 26),
          SizedBox(width: 12),
          Text(
            'My Orders',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ─── FILTERS BAR (redesigned) ──────────────────────────────────────────────
  Widget _buildFiltersBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Search bar ──────────────────────────────────────────────────
          _buildSearchBar(),

          const SizedBox(height: 14),

          // ── Row 1: Status filter chips ─────────────────────────────────
          _buildSectionLabel(Icons.filter_list_rounded, 'Status'),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.statusFilters.length,
              itemBuilder: (context, index) {
                final status = controller.statusFilters[index];
                return Obx(() => _buildChip(
                      label: status,
                      icon: _getStatusIcon(status),
                      isSelected: controller.selectedStatus.value == status,
                      onTap: () => controller.updateStatusFilter(status),
                      selectedGradient: true,
                    ));
              },
            ),
          ),

          const SizedBox(height: 14),

          // ── Row 2: Payment Method filter ───────────────────────────────
          _buildSectionLabel(Icons.payments_rounded, 'Payment Type'),
          const SizedBox(height: 8),
          Obx(() => Row(
                children: [
                  _buildPaymentChip(
                    label: 'All',
                    icon: Icons.all_inclusive_rounded,
                    isSelected: controller.selectedPaymentMethod.value == 'all',
                    onTap: () => controller.updatePaymentFilter('all'),
                  ),
                  const SizedBox(width: 8),
                  _buildPaymentChip(
                    label: 'Cash',
                    icon: Icons.currency_rupee_rounded,
                    isSelected: controller.selectedPaymentMethod.value == 'cash',
                    onTap: () => controller.updatePaymentFilter('cash'),
                    activeColor: const Color(0xFF2E7D32),
                    activeBg: const Color(0xFFE8F5E9),
                  ),
                  const SizedBox(width: 8),
                  _buildPaymentChip(
                    label: 'Challan',
                    icon: Icons.receipt_rounded,
                    isSelected: controller.selectedPaymentMethod.value == 'challan',
                    onTap: () => controller.updatePaymentFilter('challan'),
                    activeColor: const Color(0xFF1565C0),
                    activeBg: const Color(0xFFE3F2FD),
                  ),
                ],
              )),

          const SizedBox(height: 14),

          // ── Row 3: Sort + Cancelled + Returned ────────────────────────
// Row(
//             children: [
//               Expanded(
//                 flex: 3,
//                 child: Obx(() => _buildSortDropdown(controller.selectedSort.value)),
//               ),
//               const SizedBox(width: 8),
//               Obx(() => _buildToggleButton(
//                     label: 'Cancelled',
//                     icon: Icons.cancel_rounded,
//                     isActive: controller.showCancelledOrders.value,
//                     onTap: controller.toggleShowCancelled,
//                     color: Colors.red,
//                   )),
//               const SizedBox(width: 8),
//               Obx(() => _buildToggleButton(
//                     label: 'Returned',
//                     icon: Icons.assignment_return_rounded,
//                     isActive: controller.showReturnedOrders.value,
//                     onTap: controller.toggleShowReturned,
//                     color: Colors.orange,
//                   )),
//             ],
//           ),
                  ],
      ),
    );
  }

  // ─── SEARCH BAR ────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: lightBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: secondary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: secondary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                hintText: 'Search by order ID or medicine...',
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(bottom: 2),
              ),
              style: const TextStyle(fontSize: 13, color: primary),
              onChanged: (v) => controller.searchQuery.value = v,
            ),
          ),
          Obx(() => controller.searchQuery.value.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    controller.searchController.clear();
                    controller.searchQuery.value = '';
                  },
                  child: Icon(Icons.close_rounded,
                      size: 18, color: Colors.grey.shade500),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  // ─── SECTION LABEL ─────────────────────────────────────────────────────────
  Widget _buildSectionLabel(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 13, color: secondary),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade500,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }

  // ─── STATUS CHIP ───────────────────────────────────────────────────────────
  Widget _buildChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    bool selectedGradient = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: isSelected && selectedGradient
              ? const LinearGradient(
                  colors: [primary, secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected && !selectedGradient ? secondary : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? Colors.transparent : secondary.withOpacity(0.25),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primary.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 13,
                color: isSelected ? Colors.white : secondary),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── PAYMENT METHOD CHIP ───────────────────────────────────────────────────
  Widget _buildPaymentChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    Color activeColor = secondary,
    Color activeBg = lightBg,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? activeColor : secondary.withOpacity(0.2),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14,
                color: isSelected ? activeColor : Colors.grey.shade400),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── ORDER CARD ────────────────────────────────────────────────────────────
  Widget _buildOrderCard(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary, secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(order.status.icon, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.agency ?? 'Unknown Agency',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.4,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(Icons.receipt_long_rounded,
                                size: 11,
                                color: Colors.white.withOpacity(0.7)),
                            const SizedBox(width: 4),
                            Text(
                              order.orderNumber,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.7),
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_rounded,
                                size: 11,
                                color: Colors.white.withOpacity(0.7)),
                            const SizedBox(width: 4),
                            Text(
                              order.formattedOrderDate,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.7)),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 3,
                              height: 3,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(Icons.payment_rounded,
                                size: 11,
                                color: Colors.white.withOpacity(0.7)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                order.paymentMethod.toUpperCase(),
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white.withOpacity(0.7)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.4), width: 1),
                    ),
                    child: Text(
                      order.status.displayName,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Items ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.medication_rounded, size: 14, color: secondary),
                      const SizedBox(width: 6),
                      const Text(
                        'Items',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: primary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${order.items.length} item${order.items.length > 1 ? 's' : ''}',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...order.items
                      .take(2)
                      .map<Widget>((item) => _buildOrderItem(item))
                      .toList(),
                  if (order.items.length > 2)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 4),
                      child: GestureDetector(
                        onTap: () => controller.showOrderDetails(order),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: secondary.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: secondary.withOpacity(0.2)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '+ ${order.items.length - 2} more item${order.items.length - 2 > 1 ? 's' : ''}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: secondary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_rounded,
                                  size: 14, color: secondary),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Price Summary ────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: lightBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: secondary.withOpacity(0.15)),
              ),
              child: Column(
                children: [
                  _buildSummaryRow(
                      'Subtotal', '₹${order.subtotal.toStringAsFixed(2)}'),
                  if (order.discount > 0)
                    _buildSummaryRow(
                      'Discount',
                      '-₹${order.discount.toStringAsFixed(2)}',
                      isDiscount: true,
                    ),
                  if (order.shippingCharge > 0)
                    _buildSummaryRow('Shipping',
                        '₹${order.shippingCharge.toStringAsFixed(2)}'),
                  _buildSummaryRow(
                      'GST', '₹${order.tax.toStringAsFixed(2)}'),
                  Divider(color: secondary.withOpacity(0.2), height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: primary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [primary, secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '₹${order.finalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Action Buttons ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildActionButton(
                    onPressed: () => controller.showOrderDetails(order),
                    icon: Icons.visibility_rounded,
                    label: 'Details',
                    color: primary,
                  ),
                  if (order.canCancel)
                    _buildActionButton(
                      onPressed: () => controller.showCancelDialog(order),
                      icon: Icons.cancel_rounded,
                      label: 'Cancel',
                      color: Colors.red,
                      isOutlined: true,
                    ),
                  if (order.canReturn)
                    _buildActionButton(
                      onPressed: () => controller.showReturnDialog(order),
                      icon: Icons.assignment_return_rounded,
                      label: 'Return',
                      color: Colors.orange,
                      isOutlined: true,
                    ),
                  if (order.canTrack)
                    _buildActionButton(
                      onPressed: () => controller.trackOrder(order),
                      icon: Icons.local_shipping_rounded,
                      label: 'Track',
                      color: secondary,
                      isOutlined: true,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

 Widget _buildOrderItem(OrderItem item) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: secondary.withOpacity(0.12)),
    ),
    child: Row(
      children: [
        /// 🔹 IMAGE
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: lightBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: secondary.withOpacity(0.15)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: item.productImage != null
                ? Image.network(
                    item.productImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.medication,
                      color: secondary,
                      size: 26,
                    ),
                  )
                : const Icon(Icons.medication, color: secondary, size: 26),
          ),
        ),

        const SizedBox(width: 10),

        /// 🔹 DETAILS
      Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        item.productName,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),

      const SizedBox(height: 6),

      /// 🔥 ROW 1 → Qty + Addon
     Row(
  children: [
    Text(
      item.addon > 0
          ? "Qty: ${item.quantity} + ${item.addon}"
          : "Qty: ${item.quantity}",
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    ),
  ],
),
      const SizedBox(height: 6),

      /// 🔥 ROW 2 → PTR + GST
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'PTR ₹${item.unitPrice.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: primary,
            ),
          ),

          if (item.gstPercentage > 0)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'GST ${item.gstPercentage.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 10,
                  color: secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),

      const SizedBox(height: 4),

      /// 🔥 ROW 3 → MRP + DISCOUNT
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (item.mrpPrice > 0)
            Text(
              'MRP ₹${item.mrpPrice.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                decoration: TextDecoration.lineThrough,
              ),
            ),

          if (item.discountMin > 0)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${item.discountMin.toStringAsFixed(0)}-${item.discountMax.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    ],
  ),
),        /// 🔹 TOTAL
        Text(
          '₹${item.totalPrice.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: primary,
          ),
        ),
      ],
    ),
  );
}  
  Widget _buildItemTag({required String label, required IconData icon}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: secondary),
        const SizedBox(width: 3),
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: isDiscount ? secondary : Colors.grey.shade600)),
          Text(value,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      isDiscount ? FontWeight.w600 : FontWeight.normal,
                  color: isDiscount ? secondary : Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _buildSortDropdown(String selectedValue) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: lightBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: secondary.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down_rounded, color: secondary),
          style: const TextStyle(fontSize: 12, color: primary),
          items: controller.sortOptions.entries.map((entry) {
            return DropdownMenuItem(
              value: entry.key,
              child: Row(
                children: [
                  Icon(_getSortIcon(entry.key), size: 14, color: secondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(entry.value,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (v) {
            if (v != null) controller.updateSort(v);
          },
        ),
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? color : secondary.withOpacity(0.2),
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isActive ? color : Colors.grey.shade400),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.normal,
                color: isActive ? color : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
    bool isOutlined = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isOutlined ? Colors.transparent : color,
        foregroundColor: isOutlined ? color : Colors.white,
        elevation: isOutlined ? 0 : 2,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isOutlined
              ? BorderSide(color: color, width: 1.5)
              : BorderSide.none,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              color: secondary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Loading orders...',
            style: TextStyle(
              fontSize: 14,
              color: secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 130,
                width: 130,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primary.withOpacity(0.1),
                      secondary.withOpacity(0.1)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shopping_bag_outlined,
                    size: 55, color: secondary),
              ),
              const SizedBox(height: 24),
              const Text(
                'No orders found',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start shopping to see your orders here',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 28),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [primary, secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ElevatedButton(
                  onPressed: () => Get.offAllNamed('/main'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Start Shopping',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginRequiredView() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 130,
                width: 130,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primary.withOpacity(0.12),
                      secondary.withOpacity(0.12)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shopping_bag_outlined,
                    size: 55, color: secondary),
              ),
              const SizedBox(height: 28),
              const Text(
                'Login to View Your Orders',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(0.07),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildInstructionItem(
                      icon: Icons.visibility_rounded,
                      title: 'Track Your Orders',
                      description: 'Monitor order status and delivery updates',
                    ),
                    Divider(color: secondary.withOpacity(0.1), height: 24),
                    _buildInstructionItem(
                      icon: Icons.history_rounded,
                      title: 'Order History',
                      description: 'View all past orders and invoices',
                    ),
                    Divider(color: secondary.withOpacity(0.1), height: 24),
                    _buildInstructionItem(
                      icon: Icons.assignment_return_rounded,
                      title: 'Returns & Cancellations',
                      description: 'Manage returns and cancellations easily',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [primary, secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => controller.goToLogin(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.login_rounded, size: 22, color: Colors.white),
                      SizedBox(width: 10),
                      Text('Login to Continue',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextButton(
                onPressed: () => Get.offAllNamed('/main'),
                child: Text('Continue Shopping',
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: secondary, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: primary)),
              const SizedBox(height: 3),
              Text(description,
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade500)),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'all':        return Icons.list_rounded;
      case 'placed':     return Icons.shopping_bag_rounded;
      case 'pending':    return Icons.pending_rounded;
      case 'confirmed':  return Icons.check_circle_rounded;
      case 'processing': return Icons.pending_actions_rounded;
      case 'shipped':    return Icons.local_shipping_rounded;
      case 'delivered':  return Icons.inventory_rounded;
      case 'cancelled':  return Icons.cancel_rounded;
      case 'returned':   return Icons.assignment_return_rounded;
      default:           return Icons.list_rounded;
    }
  }

  IconData _getSortIcon(String sortKey) {
    switch (sortKey) {
      case 'newest':     return Icons.vertical_align_bottom_rounded;
      case 'oldest':     return Icons.vertical_align_top_rounded;
      case 'price_high': return Icons.trending_up_rounded;
      case 'price_low':  return Icons.trending_down_rounded;
      default:           return Icons.sort_rounded;
    }
  }
}