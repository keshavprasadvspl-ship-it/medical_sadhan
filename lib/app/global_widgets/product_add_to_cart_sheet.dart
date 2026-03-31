// product_add_to_cart_sheet.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/cart_item_model.dart';
import '../data/models/packing_model.dart';
import '../data/models/product_details_model.dart';
import '../data/models/vendor_model.dart';
import '../data/providers/api_provider.dart';
import '../modules/product_details/controllers/product_details_controller.dart';
import '../services/storage_service.dart';

class ProductAddToCartSheet extends StatefulWidget {
  final ProductDetail product;
  final ProductDetailController controller;

  const ProductAddToCartSheet({
    Key? key,
    required this.product,
    required this.controller,
  }) : super(key: key);

  @override
  State<ProductAddToCartSheet> createState() => _ProductAddToCartSheetState();
}

class _ProductAddToCartSheetState extends State<ProductAddToCartSheet> {
  final StorageService _storageService = StorageService();
  final ApiService _apiService = ApiService();

  // Form state
  final _formKey = GlobalKey<FormState>();

  // Selected values
  Vendor? _selectedVendor;
  int _quantity = 1;
  Packing? _selectedPacking;
  String? _specialInstructions;

  // Lists
  List<Vendor> _vendors = [];
  List<Packing> _packings = [];

  // Loading states
  bool _isLoadingVendors = false;
  bool _isSubmitting = false;

  // User login status
  bool _isUserLoggedIn = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
    _loadVendors();
    _loadPackings();
    _loadLastSelectedVendor();
  }

  Future<void> _checkUserStatus() async {
    final isLoggedIn = await _storageService.isLoggedIn();
    final userId = await _storageService.getUserId();
    setState(() {
      _isUserLoggedIn = isLoggedIn;
      _userId = userId;
    });
  }

  Future<void> _loadVendors() async {
    setState(() => _isLoadingVendors = true);

    try {
      // Try to load from API first
      if (_isUserLoggedIn) {
        final response = await _apiService.getVendorsForProduct(
          widget.product.id,
        );
        if (response['success'] == true) {
          final List<dynamic> vendorData = response['data'] ?? [];
          _vendors = vendorData.map((json) => Vendor.fromJson(json)).toList();
        }
      }

      // If no vendors from API or user not logged in, load from local storage or use defaults
      if (_vendors.isEmpty) {
        _vendors = await _storageService.getVendorsForProduct(
          widget.product.id,
        );
      }

      // If still empty, use default vendors
      if (_vendors.isEmpty) {
        _vendors = _getDefaultVendors();
      }

      // Auto-select first vendor if available
      if (_vendors.isNotEmpty && _selectedVendor == null) {
        _selectedVendor = _vendors.first;
      }
    } catch (e) {
      print('Error loading vendors: $e');
      // Use default vendors on error
      _vendors = _getDefaultVendors();
      if (_vendors.isNotEmpty && _selectedVendor == null) {
        _selectedVendor = _vendors.first;
      }
    } finally {
      setState(() => _isLoadingVendors = false);
    }
  }

  Future<void> _loadPackings() async {
    try {
      // Try to load from API first
      if (_isUserLoggedIn) {
        final response = await _apiService.getPackingsForProduct(
          widget.product.id,
        );
        if (response['success'] == true) {
          final List<dynamic> packingData = response['data'] ?? [];
          _packings = packingData
              .map((json) => Packing.fromJson(json))
              .toList();
        }
      }

      // If no packings from API or user not logged in, load from local storage or use defaults
      if (_packings.isEmpty) {
        _packings = await _storageService.getPackingsForProduct(
          widget.product.id,
        );
      }

      // If still empty, use default packings
      if (_packings.isEmpty) {
        _packings = _getDefaultPackings();
      }

      // Auto-select first packing if available
      if (_packings.isNotEmpty && _selectedPacking == null) {
        _selectedPacking = _packings.first;
      }
    } catch (e) {
      print('Error loading packings: $e');
      // Use default packings on error
      _packings = _getDefaultPackings();
      if (_packings.isNotEmpty && _selectedPacking == null) {
        _selectedPacking = _packings.first;
      }
    }
  }

  Future<void> _loadLastSelectedVendor() async {
    final lastVendorId = await _storageService.getLastSelectedVendor(
      widget.product.id,
    );
    if (lastVendorId != null) {
      // Find vendor by ID
      final vendor = _vendors.firstWhereOrNull((v) => v.id == lastVendorId);
      if (vendor != null) {
        setState(() {
          _selectedVendor = vendor;
        });
      }
    }
  }

  List<Vendor> _getDefaultVendors() {
    final double basePrice = widget.product.price ?? 0.0;
    final double? discountPrice = widget.product.discountPrice;

    return [
      Vendor(
        id: 1,
        name: 'MedLife Pharma',
        price: basePrice,
        discountPrice: discountPrice,
        stock: widget.product.stock,
        deliveryTime: '24 hours',
        rating: 4.5,
        vendorProductId: 101, // Add default vendor product ID
      ),
      Vendor(
        id: 2,
        name: 'HealthKart',
        price: basePrice * 1.05,
        discountPrice: discountPrice,
        stock: 45,
        deliveryTime: '48 hours',
        rating: 4.3,
        vendorProductId: 102, // Add default vendor product ID
      ),
      Vendor(
        id: 3,
        name: 'NetMeds',
        price: basePrice * 0.98,
        discountPrice: discountPrice,
        stock: 30,
        deliveryTime: '36 hours',
        rating: 4.7,
        vendorProductId: 103, // Add default vendor product ID
      ),
    ];
  }

  List<Packing> _getDefaultPackings() {
    return [
      Packing(id: 1, name: 'Strip', quantity: 10, unit: 'tablets'),
      Packing(id: 2, name: 'Bottle', quantity: 30, unit: 'tablets'),
      Packing(id: 3, name: 'Box', quantity: 60, unit: 'tablets'),
      Packing(id: 4, name: 'Combo Pack', quantity: 90, unit: 'tablets'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Container(
        height: screenHeight * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            /// Drag Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            /// Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Add to Cart',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111261),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            /// Body (Scrollable)
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductPreview(),
                    const SizedBox(height: 20),

                    _buildVendorSection(),
                    const SizedBox(height: 20),

                    _buildPackingSection(),
                    const SizedBox(height: 20),

                    _buildQuantitySelector(),
                    const SizedBox(height: 20),

                    _buildSpecialInstructions(),
                    const SizedBox(height: 20),

                    _buildPriceSummary(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            /// Fixed Bottom Buttons (NOT scrollable)
            Padding(
              padding: const EdgeInsets.only(bottom: 60,left: 16,right: 16),
              child: _buildActionButtons(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductPreview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: widget.product.images.isNotEmpty
                  ? Image.network(
                      widget.product.images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.medical_services,
                        color: Color(0xFF111261),
                      ),
                    )
                  : const Icon(
                      Icons.medical_services,
                      color: Color(0xFF111261),
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111261),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (widget.product.genericName.isNotEmpty)
                  Text(
                    widget.product.genericName,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Vendor',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111261),
          ),
        ),
        const SizedBox(height: 12),

        if (_isLoadingVendors)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: Color(0xFF0B630B)),
            ),
          )
        else if (_vendors.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'No vendors available',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ..._vendors.map((vendor) => _buildVendorTile(vendor)).toList(),
      ],
    );
  }

  Widget _buildVendorTile(Vendor vendor) {
    final isSelected = _selectedVendor?.id == vendor.id;
    final price = vendor.discountPrice ?? vendor.price;
    final originalPrice = vendor.price;
    final hasDiscount =
        vendor.discountPrice != null && vendor.discountPrice! < vendor.price;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedVendor = vendor;
        });
        // Save to shared preferences
        _storageService.saveLastSelectedVendor(widget.product.id, vendor.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0B630B).withOpacity(0.1)
              : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF0B630B) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Radio button
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF0B630B)
                      : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF0B630B),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Vendor details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vendor.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111261),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // Rating
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: Color(0xFF0B630B),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            vendor.rating.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),

                      // Delivery time
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            vendor.deliveryTime,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? const Color(0xFF0B630B)
                        : const Color(0xFF111261),
                  ),
                ),
                if (hasDiscount)
                  Text(
                    '₹${originalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12,
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey[400],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Packing',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111261),
          ),
        ),
        const SizedBox(height: 12),

        if (_packings.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'No packing options available',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _packings.map((packing) {
              final isSelected = _selectedPacking?.id == packing.id;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPacking = packing;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF0B630B) : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF0B630B)
                          : Colors.grey[300]!,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${packing.name} (${packing.quantity} ${packing.unit})',
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF111261),
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        const Text(
          'Quantity:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111261),
          ),
        ),
        const Spacer(),

        // Decrease button
        GestureDetector(
          onTap: () {
            if (_quantity > 1) {
              setState(() {
                _quantity--;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.remove, size: 18, color: Color(0xFF111261)),
          ),
        ),

        // Quantity display
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '$_quantity',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111261),
            ),
          ),
        ),

        // Increase button
        GestureDetector(
          onTap: () {
            if (_selectedVendor != null && _quantity < _selectedVendor!.stock) {
              setState(() {
                _quantity++;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0B630B),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.add, size: 18, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Special Instructions (Optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111261),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Any special requests or instructions...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF0B630B)),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
          onChanged: (value) {
            _specialInstructions = value;
          },
        ),
      ],
    );
  }

  Widget _buildPriceSummary() {
    if (_selectedVendor == null) return const SizedBox();

    final itemPrice =
        (_selectedVendor!.discountPrice ?? _selectedVendor!.price) * _quantity;
    final tax = itemPrice * (widget.product.gstPercentage / 100);
    final total = itemPrice + tax;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Item price
          Row(
            children: [
              const Text('Item Price:', style: TextStyle(color: Colors.grey)),
              const Spacer(),
              Text(
                '₹${itemPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // GST
          Row(
            children: [
              Text(
                'GST (${widget.product.gstPercentage}%):',
                style: const TextStyle(color: Colors.grey),
              ),
              const Spacer(),
              Text(
                '₹${tax.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(),
          ),

          // Total
          Row(
            children: [
              const Text(
                'Total:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111261),
                ),
              ),
              const Spacer(),
              Text(
                '₹${total.toStringAsFixed(2)}',
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
    );
  }

  Widget _buildActionButtons() {
    final isFormValid = _selectedVendor != null && _selectedPacking != null;

    return Row(
      children: [
        // Cancel button
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF111261),
              side: const BorderSide(color: Color(0xFF111261)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 12),

        // Add to cart button
        Expanded(
          child: ElevatedButton(
            onPressed: isFormValid && !_isSubmitting ? _submitOrder : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0B630B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Add to Cart'),
          ),
        ),
      ],
    );
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // Validate that we have a vendor product ID
      if (_selectedVendor!.vendorProductId == 0) {
        print('Warning: vendorProductId is 0, this might cause issues');
        // You might want to show a warning or try to fetch it again
      }

      // Create cart item
      final cartItem = CartItem(
        productId: widget.product.id,
        productName: widget.product.name,
        vendorId: _selectedVendor!.id,
        vendorName: _selectedVendor!.name,
        packingId: _selectedPacking!.id,
        vendorProductId: _selectedVendor!.vendorProductId, // Now this is correct
        packingName: _selectedPacking!.name,
        quantity: _quantity,
        price: _selectedVendor!.discountPrice ?? _selectedVendor!.price,
        gstPercentage: widget.product.gstPercentage,
        specialInstructions: _specialInstructions,
        image: widget.product.images.isNotEmpty
            ? widget.product.images.first
            : null,
      );

      // Save to local storage
      await _storageService.addToCart(cartItem);

      // If user is logged in, sync with API
      if (_isUserLoggedIn && _userId != null) {
        try {
          await _apiService.syncCartItem(_userId!, cartItem);
        } catch (e) {
          print('Error syncing cart with API: $e');
          // Don't fail if API sync fails - item is already saved locally
        }
      }

      // Show success message
      Get.snackbar(
        'Success',
        'Item added to cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF0B630B),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );

      // Close bottom sheet
      Navigator.pop(context);

      // Update cart count in controller if needed
      widget.controller.updateCartCount();
    } catch (e) {
      print('Error adding to cart: $e');
      Get.snackbar(
        'Error',
        'Failed to add item to cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}
