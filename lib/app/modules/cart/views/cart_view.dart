// lib/app/modules/cart/views/cart_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../data/providers/api_endpoints.dart';
import '../../../global_widgets/payment_method_dialog.dart';
import '../controllers/cart_controller.dart';

class CartView extends GetView<CartController> {
  const CartView({Key? key}) : super(key: key);

  static const Color _primaryDark = Color(0xFF043734);
  static const Color _primaryLight = Color(0xFF21827A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F7),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) return _buildLoading();
                if (controller.cartItems.isEmpty) return _buildEmptyCart();
                return RefreshIndicator(
                  onRefresh: controller.refreshCart,
                  color: _primaryDark,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildVendorGroupedItems(),
                        const SizedBox(height: 100), // Bottom padding for scrolling
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ─── App Bar ──────────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_primaryDark, _primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryDark.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text(
            'My Cart',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Obx(() => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
            ),
            child: Text(
              '${controller.cartItems.length} ${controller.cartItems.length == 1 ? 'item' : 'items'}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          )),
        ],
      ),
    );
  }

  // ─── Loading ──────────────────────────────────────────────────────────────────

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: _primaryDark),
          SizedBox(height: 16),
          Text('Loading your cart...', style: TextStyle(color: _primaryDark, fontSize: 14)),
        ],
      ),
    );
  }

  // ─── Empty Cart ───────────────────────────────────────────────────────────────

  Widget _buildEmptyCart() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 200,
              width: 200,
              child: Lottie.asset(
                'assets/animations/empty_cart.json',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: _primaryDark.withOpacity(0.07),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shopping_cart_outlined, size: 80, color: _primaryDark),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your cart is empty',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _primaryDark),
            ),
            const SizedBox(height: 8),
            Text(
              'Looks like you haven\'t added anything yet',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_primaryDark, _primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: _primaryDark.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.offAllNamed('/main', arguments: 2);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Start Shopping', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Referred By Field ────────────────────────────────────────────────────────

  Widget _buildReferredByField() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _primaryDark.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _primaryLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.person_add_alt_1,
              size: 20,
              color: _primaryDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Referred by',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _primaryDark.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: controller.referredByController,
                  decoration: InputDecoration(
                    hintText: 'Enter referrer name',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _primaryDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Vendor Grouped Items ─────────────────────────────────────────────────────

  Widget _buildVendorGroupedItems() {
    return Obx(() {
      final Map<String, List<CartItemModel>> vendorMap = {};
      for (final item in controller.cartItems) {
        vendorMap.putIfAbsent(item.vendorName, () => []).add(item);
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: vendorMap.entries
              .map((entry) => _buildVendorCard(vendorName: entry.key, items: entry.value))
              .toList(),
        ),
      );
    });
  }

  Widget _buildVendorCard({required String vendorName, required List<CartItemModel> items}) {
    final double vendorSubtotal = items.fold(0.0, (sum, i) => sum + (i.price * i.quantity));
    final double vendorGst = items.fold(0.0, (sum, i) {
      final itemTotal = i.price * i.quantity;
      final itemGst = itemTotal * (i.gstPercentage / 100);
      return sum + itemGst;
    });
    final double vendorTotal = vendorSubtotal + vendorGst;

    // Get discount for this vendor (if any - you might need to track discounts per vendor)
    final double vendorDiscount = 0.0; // This would need to be tracked per vendor in your controller
    final double vendorFinalTotal = vendorTotal - vendorDiscount;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: _primaryDark.withOpacity(0.10), blurRadius: 14, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Vendor Header ──────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_primaryDark, _primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.store_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    vendorName,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.4)),
                  ),
                  child: Text(
                    '${items.length} ${items.length == 1 ? 'item' : 'items'}',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          // ── Items List ─────────────────────────────────────────────────────
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: _primaryDark.withOpacity(0.07),
              indent: 16,
              endIndent: 16,
            ),
            itemBuilder: (context, index) => _buildCartItemRow(items[index]),
          ),

          // ── Vendor Price Summary ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _primaryDark.withOpacity(0.04),
              border: Border(
                top: BorderSide(color: _primaryDark.withOpacity(0.1)),
                bottom: BorderSide(color: _primaryDark.withOpacity(0.1)),
              ),
            ),
            child: Column(
              children: [
                _buildVendorPriceRow('Subtotal', vendorSubtotal),
                const SizedBox(height: 8),
                _buildVendorPriceRow('GST', vendorGst),
                if (vendorDiscount > 0) ...[
                  const SizedBox(height: 8),
                  _buildVendorPriceRow('Discount', vendorDiscount, isDiscount: true),
                ],
                const SizedBox(height: 12),
                Container(height: 1, color: _primaryDark.withOpacity(0.1)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _primaryDark,
                      ),
                    ),
                    Text(
                      '₹${vendorFinalTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _primaryLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Vendor Checkout Button ────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: Obx(() => ElevatedButton(
              onPressed: controller.isCheckingOut.value
                  ? null
                  : () => _checkoutVendor(vendorName, items, vendorFinalTotal),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryLight,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: controller.isCheckingOut.value
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_bag_outlined, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'Checkout',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '₹${vendorFinalTotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            )),
          ),
        ],
      ),
    );
  }

  // ─── Vendor Price Row Helper ─────────────────────────────────────────────────

  Widget _buildVendorPriceRow(String label, double amount, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: _primaryDark.withOpacity(0.7),
          ),
        ),
        Text(
          '${isDiscount ? '-' : ''}₹${amount.abs().toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDiscount ? Colors.orange : _primaryDark,
          ),
        ),
      ],
    );
  }

  // ─── Checkout Vendor Method ──────────────────────────────────────────────────

  Future<void> _checkoutVendor(String vendorName, List<CartItemModel> items, double total) async {
    if (items.isEmpty) return;

    // Show payment method dialog for this vendor
    final result = await Get.dialog<String>(
      PaymentMethodDialog(),
    );

    if (result != null) {
      // Get referral text
      final String referralText = controller.referredByController.text.trim();

      // Navigate to checkout with vendor-specific items
      Get.toNamed('/checkout', arguments: {
        'cartItems': items,
        'vendorName': vendorName,
        'subtotal': items.fold(0.0, (sum, i) => sum + (i.price * i.quantity)),
        'gstTotal': items.fold(0.0, (sum, i) {
          final itemTotal = i.price * i.quantity;
          final itemGst = itemTotal * (i.gstPercentage / 100);
          return sum + itemGst;
        }),
        'total': total,
        'paymentMethod': result,
        'referredBy': referralText,
        'isVendorSpecific': true,
      });
    }
  }

  // ─── Single Item Row ──────────────────────────────────────────────────────────

  Widget _buildCartItemRow(CartItemModel item) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_primaryDark.withOpacity(0.05), _primaryLight.withOpacity(0.08)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: item.image.isNotEmpty
                  ? Image.network(
                _getFullImageUrl(item.image),
                height: 52,
                errorBuilder: (_, __, ___) =>
                const Icon(Icons.medical_services, size: 36, color: _primaryDark),
              )
                  : const Icon(Icons.medical_services, size: 36, color: _primaryDark),
            ),
          ),
          const SizedBox(width: 12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                GestureDetector(
                  onTap: () {
                    Get.toNamed('/product-details/${item.productId}');
                  },
                  child: Text(
                    item.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _primaryDark),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),

                // Packing Type badge
                if (item.packingType != null && item.packingType!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _primaryLight.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.packingType!,
                      style: const TextStyle(fontSize: 10, color: _primaryDark, fontWeight: FontWeight.w600),
                    ),
                  ),
                const SizedBox(height: 6),

                // ── Selling Price + MRP strikethrough ──────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PTR ₹${item.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _primaryLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // ── Discount Min – Max badge ────────────────────────────────
                    if (item.discountMin > 0 || item.discountMax > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.orange.withOpacity(0.35)),
                        ),
                        child: Text(
                          '${item.discountMin.toStringAsFixed(0)}% – ${item.discountMax.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(height: 2),
                    if (item.mrpPrice > 0)
                      Text(
                        'MRP ₹${item.mrpPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),

                // GST
                if (item.gstPercentage > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    'GST: ${item.gstPercentage.toStringAsFixed(0)}%',
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Delete + [Quantity Control | Addon Box]
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Delete Button
              GestureDetector(
                onTap: () => controller.removeItem(item.id),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                ),
              ),
              const SizedBox(height: 10),
              // Quantity + Addon side by side — same intrinsic height
              IntrinsicHeight(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildQuantityControl(item),
                    const SizedBox(width: 6),
                    _buildInlineAddonBox(item),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Inline Addon Box — same height as quantity control via IntrinsicHeight ───
  Widget _buildInlineAddonBox(CartItemModel item) {
    final TextEditingController addonCtrl =
    TextEditingController(text: item.addon ?? '');

    addonCtrl.selection =
        TextSelection.fromPosition(TextPosition(offset: addonCtrl.text.length));

    return SizedBox(
      width: 36,
      height: 40, // 🔥 yaha height control karo (40–52 best)
      child: TextField(
        controller: addonCtrl,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12, // thoda readable
          fontWeight: FontWeight.w500,
          color: _primaryDark,
        ),
        decoration: const InputDecoration(
          isDense: false, // ❌ dense hata diya (important)
          contentPadding: EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 10, // 🔥 height yaha se aati hai
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(6)),
            borderSide: BorderSide(color: Colors.black, width: 1.2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(6)),
            borderSide: BorderSide(color: Colors.black, width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(6)),
            borderSide: BorderSide(color: Colors.black, width: 1.5),
          ),
        ),
        maxLines: 1,

        onSubmitted: (val) async {
          final trimmed = val.trim();
          if (trimmed.isNotEmpty) {
            await controller.addAddonToItem(item.id, trimmed);
          } else {
            await controller.removeAddonFromItem(item.id);
          }
          await controller.refreshCart();
        },

        onTapOutside: (_) async {
          final trimmed = addonCtrl.text.trim();
          if (trimmed.isNotEmpty) {
            await controller.addAddonToItem(item.id, trimmed);
          } else {
            await controller.removeAddonFromItem(item.id);
          }
          await controller.refreshCart();
        },
      ),
    );
  }

  // ─── Quantity Control (−  [editable field]  +) ────────────────────────────────

  Widget _buildQuantityControl(CartItemModel item) {
    return StatefulBuilder(
      builder: (context, setState) {
        final qtyTextController = TextEditingController(text: '${item.quantity}');
        qtyTextController.selection =
            TextSelection.fromPosition(TextPosition(offset: qtyTextController.text.length));

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF0F7F7),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _primaryDark.withOpacity(0.15)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Decrease ──────────────────────────
              GestureDetector(
                onTap: () async {
                  await controller.decreaseQuantity(item.id);
                  setState(() => qtyTextController.text = '${item.quantity}');
                },
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  child: const Icon(Icons.remove, size: 14, color: _primaryDark),
                ),
              ),

              // ── Type-in Qty Field (numbers only) ──
              SizedBox(
                width: 44,
                child: TextField(
                  controller: qtyTextController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _primaryDark,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 6),
                    border: InputBorder.none,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  onSubmitted: (val) async {
                    final int? newQty = int.tryParse(val);
                    if (newQty != null && newQty > 0) {
                      await controller.setQuantity(item.id, newQty);
                    }
                    setState(() => qtyTextController.text = '${item.quantity}');
                  },
                  onTapOutside: (_) async {
                    final int? newQty = int.tryParse(qtyTextController.text);
                    if (newQty != null && newQty > 0) {
                      await controller.setQuantity(item.id, newQty);
                    }
                    setState(() => qtyTextController.text = '${item.quantity}');
                  },
                ),
              ),

              // ── Increase ──────────────────────────
              GestureDetector(
                onTap: () async {
                  await controller.increaseQuantity(item.id);
                  setState(() => qtyTextController.text = '${item.quantity}');
                },
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_primaryDark, _primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: const Icon(Icons.add, size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Helper ───────────────────────────────────────────────────────────────────

  String _getFullImageUrl(String? imagePath) {
    const String baseUrl = '${ApiEndpoints.imgUrl}/';
    if (imagePath == null || imagePath.isEmpty) return '';
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) return imagePath;
    final String cleanPath = imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;
    return baseUrl + cleanPath;
  }
}