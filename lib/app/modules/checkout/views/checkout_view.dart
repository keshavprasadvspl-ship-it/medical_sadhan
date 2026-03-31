// lib/app/modules/checkout/views/checkout_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/address_model.dart';
import '../../../data/providers/api_endpoints.dart';
import '../controllers/checkout_controller.dart';
import 'checkout_address_view.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoading();
        }
        return RefreshIndicator(
          onRefresh: controller.loadAddresses,
          color: const Color(0xFF0B630B),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                if (controller.isVendorSpecific)
                  _buildVendorInfo(),
                _buildDeliveryAddress(),
                const SizedBox(height: 12),
                _buildOrderSummary(),
                const SizedBox(height: 12),
                if (controller.referredBy.value.isNotEmpty)
                  _buildReferralSection(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: _buildPlaceOrderButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Color(0xFF111261),
          ),
        ),
        onPressed: () => Get.back(),
      ),
      title: Text(
        controller.isVendorSpecific && controller.vendorName != null
            ? 'Checkout - ${controller.vendorName}'
            : 'Checkout',
      ),
      centerTitle: true,
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF0B630B)),
          SizedBox(height: 16),
          Text(
            'Loading checkout...',
            style: TextStyle(color: Color(0xFF111261), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF0B630B), const Color(0xFF0B630B).withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.store_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Checking out from',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  controller.vendorName ?? 'Vendor',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${controller.cartItems.length} ${controller.cartItems.length == 1 ? 'item' : 'items'}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF111261).withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B630B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Color(0xFF0B630B),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Delivery Address',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111261),
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => Get.to(() => const AddAddressView()),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add New'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF0B630B),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Obx(() {
            if (controller.addresses.isEmpty) {
              return _buildEmptyAddress();
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.addresses.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final address = controller.addresses[index];
                return _buildAddressTile(address);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyAddress() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF111261).withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_off,
              size: 40,
              color: Color(0xFF111261),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'No delivery address added',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF111261),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Please add an address to continue',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Get.to(() => const AddAddressView()),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0B630B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Add New Address'),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressTile(AddressModel address) {
    return Obx(() {
      final isSelected = controller.selectedAddressId.value == address.id;
      return InkWell(
        onTap: () {
          controller.selectedAddressId.value = address.id;
          if (!address.isDefaultShipping) {
            controller.setDefaultShippingAddress(address.id);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          color: isSelected ? const Color(0xFF0B630B).withOpacity(0.05) : null,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Radio
              Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF0B630B)
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF0B630B),
                    ),
                  ),
                )
                    : null,
              ),
              const SizedBox(width: 12),

              /// Address Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: address.addressLabel == 'Home'
                                ? Colors.blue.withOpacity(0.1)
                                : address.addressLabel == 'Office'
                                ? Colors.orange.withOpacity(0.1)
                                : Colors.purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            address.addressLabel.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: address.addressLabel == 'Home'
                                  ? Colors.blue
                                  : address.addressLabel == 'Office'
                                  ? Colors.orange
                                  : Colors.purple,
                            ),
                          ),
                        ),
                        if (address.isDefaultShipping) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0B630B).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'DEFAULT',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0B630B),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      address.contactPerson,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111261),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      address.contactPhone,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address.fullAddress,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF111261)),
                    ),
                    if (address.landmark != null &&
                        address.landmark!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Landmark: ${address.landmark}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              /// Menu
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'edit') {
                    Get.to(() => AddAddressView(address: address));
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(address.id);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildOrderSummary() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF111261).withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.shopping_bag, color: Color(0xFF0B630B), size: 20),
                SizedBox(width: 12),
                Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111261),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          /// Items
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: controller.cartItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = controller.cartItems[index];

              final double mrp =
                  double.tryParse(item.mrpPrice.toString()) ?? 0;
              final double discountMin =
                  double.tryParse(item.discountMin.toString()) ?? 0;
              final double discountMax =
                  double.tryParse(item.discountMax.toString()) ?? 0;
              final double gstPercentage =
                  double.tryParse(item.gstPercentage.toString()) ?? 0;
              final double gstAmount =
                  item.price * item.quantity * gstPercentage / 100;
              final int addon =
                  int.tryParse(item.addon.toString()) ?? 0;

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// Product Image + Name + Total
                    Row(
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: item.image.isNotEmpty
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _getFullImageUrl(item.image),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.medical_services,
                                color: Color(0xFF111261),
                              ),
                            ),
                          )
                              : const Icon(
                            Icons.medical_services,
                            color: Color(0xFF111261),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111261),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0B630B),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    const Divider(height: 1),
                    const SizedBox(height: 10),

                    /// ✅ Quantity + Addon
                    _buildDetailRow(
                      Icons.shopping_basket_outlined,
                      'Quantity',
                      addon > 0
                          ? '${item.quantity} + $addon (Free)'
                          : '${item.quantity}',
                    ),

                    const SizedBox(height: 6),

                    /// ✅ Unit Price
                    _buildDetailRow(
                      Icons.currency_rupee,
                      'PTR Price',
                      '₹${item.price.toStringAsFixed(2)}',
                    ),

                    const SizedBox(height: 6),

                    /// ✅ MRP + Discount same row
                    _buildDetailRow(
                      Icons.label_outline,
                      'MRP',
                      '₹${mrp.toStringAsFixed(2)}  |  Upto ${discountMin.toStringAsFixed(0)}%-${discountMax.toStringAsFixed(0)}% Off',
                      valueColor: const Color(0xFFE53935),
                    ),

                    const SizedBox(height: 6),

                    /// ✅ GST
                    _buildDetailRow(
                      Icons.receipt_outlined,
                      'GST (${gstPercentage.toStringAsFixed(0)}%)',
                      '₹${gstAmount.toStringAsFixed(2)}',
                    ),
                  ],
                ),
              );
            },
          ),

          const Divider(height: 1),

          /// Price Summary
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSummaryRow(
                    'Subtotal', controller.subtotal),
                const SizedBox(height: 8),
                if (controller.discount > 0) ...[
                  _buildSummaryRow(
                      'Discount', -controller.discount,
                      isDiscount: true),
                  const SizedBox(height: 8),
                ],
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111261),
                      ),
                    ),
                    Text(
                      '₹${controller.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0B630B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF111261).withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0B630B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.person_add,
              color: Color(0xFF0B630B),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Referred By',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                controller.referredBy.value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111261),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount,
      {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
        Text(
          '${isDiscount ? '-' : ''}₹${amount.abs().toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDiscount
                ? const Color(0xFF0B630B)
                : const Color(0xFF111261),
          ),
        ),
      ],
    );
  }

  /// ✅ Item detail row helper
  Widget _buildDetailRow(
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
          '$label: ',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceOrderButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF111261).withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Obx(() {
          final isEnabled = !controller.isPlacingOrder.value &&
              controller.selectedAddressId.value != null;

          return ElevatedButton(
            onPressed: isEnabled ? controller.placeOrder : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0B630B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              disabledBackgroundColor: Colors.grey.shade300,
            ),
            child: controller.isPlacingOrder.value
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Request Order',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '₹${controller.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _showDeleteConfirmation(int addressId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Remove Address'),
        content:
        const Text('Are you sure you want to remove this address?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF111261)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteAddress(addressId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  String _getFullImageUrl(String? imagePath) {
    const String baseUrl = '${ApiEndpoints.imgUrl}/';
    if (imagePath == null || imagePath.isEmpty) return '';
    if (imagePath.startsWith('http://') ||
        imagePath.startsWith('https://')) {
      return imagePath;
    }
    String cleanPath =
    imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;
    return baseUrl + cleanPath;
  }
}