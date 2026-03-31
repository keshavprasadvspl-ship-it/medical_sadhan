// lib/app/modules/products/views/add_to_cart_popup.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:medical_b2b_app/app/global_widgets/controller/agency_controller.dart';
import 'package:medical_b2b_app/app/modules/main/controllers/main_controller.dart';

import '../data/models/product_model.dart';
import '../data/models/product_details_model.dart';
import '../data/models/venders_products_model.dart';
import '../data/providers/api_endpoints.dart';
import '../data/providers/api_provider.dart';
import '../data/providers/cart_service.dart';

class AddToCartPopup extends StatefulWidget {
  final dynamic product; // Can be either Product or ProductDetail

  const AddToCartPopup({Key? key, required this.product}) : super(key: key);

  @override
  State<AddToCartPopup> createState() => _AddToCartPopupState();
}

class _AddToCartPopupState extends State<AddToCartPopup> {
  final CartService _cartService = Get.find<CartService>();
  final TextEditingController _qtyController = TextEditingController();
  final FocusNode _qtyFocusNode = FocusNode();

  // ── Add-on qty field ──────────────────────────────────────────────────────
  final TextEditingController _addonController = TextEditingController();
  int _addonQty = 0;

  // State variables
  int _selectedVendorId = -1;
  String _selectedVendorName = '';
  double _selectedVendorPrice = 0.0;
  int _selectedVendorStock = 0;
  int _selectedVendorProductId = 0;

  int _selectedPackingId = -1;
  String _selectedPackingType = '';
  double _selectedPackingPrice = 0.0;

  int _quantity = 1;
  int _maxStock = 999;

  bool _isLoadingVendors = true;
  bool _isLoadingPackings = false;
  bool _isAddingToCart = false;

  // Data lists
  List<Map<String, dynamic>> _vendors = [];
  List<Map<String, dynamic>> _packings = [];

  // Helper methods to get product properties regardless of type
  int get _productId {
    final product = widget.product;
    if (product is Product) {
      print("product.id");
      print(product.id);
      return product.id;
    }
    if (product is ProductModel) {
      print("ProductModel.id");
      print(product.productId);
      return product.productId;
    }
    if (product is ProductDetail) {
      print("ProductDetail.id");
      print(product.id);
      return product.id;
    }
    return 0;
  }

  String get _productName {
    if (widget.product is Product) {
      return (widget.product as Product).name;
    } else if (widget.product is ProductDetail) {
      return (widget.product as ProductDetail).name;
    } else if (widget.product is ProductModel) {
      return (widget.product as ProductModel).name;
    }
    return '';
  }

  List<String> get _productImages {
    if (widget.product is Product) {
      return (widget.product as Product).images;
    } else if (widget.product is ProductDetail) {
      return (widget.product as ProductDetail).images;
    } else if (widget.product is ProductModel) {
      final img = (widget.product as ProductModel).image;
      return img != null && img.isNotEmpty ? [img] : [];
    }
    return [];
  }

  double get _productPrice {
    if (widget.product is Product) {
      return (widget.product as Product).price;
    } else if (widget.product is ProductDetail) {
      return (widget.product as ProductDetail).displayPrice;
    } else if (widget.product is ProductModel) {
      return (widget.product as ProductModel).mrp ?? 0.0;
    }
    return 0.0;
  }

  double? get _productGstPercentage {
    if (widget.product is Product) {
      return (widget.product as Product).gstPercentage;
    } else if (widget.product is ProductDetail) {
      return (widget.product as ProductDetail).gstPercentage;
    }
    return null;
  }

  String get _manufacturerName {
    if (widget.product is Product) {
      return (widget.product as Product).company.name;
    } else if (widget.product is ProductDetail) {
      return (widget.product as ProductDetail).company.name;
    }
    return '';
  }

  // Get packing information from product if available
  List<Map<String, dynamic>> get _productPackings {
    List<Map<String, dynamic>> packings = [];

    if (widget.product is ProductDetail) {
      final product = widget.product as ProductDetail;
      if (product.attributes != null && product.attributes!.isNotEmpty) {
        for (var attr in product.attributes!) {
          if (attr.name?.toLowerCase().contains('pack') == true ||
              attr.value?.toLowerCase().contains('pack') == true) {
            packings.add({
              'id': attr.id ?? 0,
              'type': attr.value ?? 'Standard',
              'price': _selectedVendorPrice > 0 ? _selectedVendorPrice : _productPrice,
            });
          }
        }
      }
    }

    if (packings.isEmpty) {
      if (widget.product is ProductDetail) {
        final product = widget.product as ProductDetail;
        if (product.power?.name != null) {
          packings.add({
            'id': 1,
            'type': product.power!.name!,
            'price': _selectedVendorPrice > 0 ? _selectedVendorPrice : _productPrice,
          });
        }
      }
    }

    if (packings.isEmpty) {
      packings.add({
        'id': 1,
        'type': 'Standard',
        'price': _selectedVendorPrice > 0 ? _selectedVendorPrice : _productPrice,
      });
    }

    return packings;
  }

  double get _currentPrice {
    if (_selectedVendorPrice > 0) {
      return _selectedVendorPrice;
    }
    return _productPrice;
  }

  @override
  void initState() {
    super.initState();
    _quantity = 1;
    _qtyController.text = '1';
    _addonController.text = '';
    _loadVendors();

    // Listen to focus: when user leaves the field, validate and fix the value
    _qtyFocusNode.addListener(() {
      if (!_qtyFocusNode.hasFocus) {
        _onQtyFieldSubmitted(_qtyController.text);
      }
    });
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _qtyFocusNode.dispose();
    _addonController.dispose();
    super.dispose();
  }

  // Called when user types in the qty field or submits
  void _onQtyFieldSubmitted(String value) {
    int parsed = int.tryParse(value) ?? 1;
    _updateQuantity(parsed);
  }

  // Central quantity update — clamps, syncs controller & state
  void _updateQuantity(int value) {
    if (value < 1) value = 1;
    if (value > _maxStock) value = _maxStock;

    setState(() {
      _quantity = value;
    });

    // Only update controller text if it doesn't already match (avoids cursor jump)
    if (_qtyController.text != value.toString()) {
      _qtyController.text = value.toString();
      _qtyController.selection = TextSelection.collapsed(
        offset: _qtyController.text.length,
      );
    }
  }

  void _decreaseQuantity() {
    _updateQuantity(_quantity - 1);
  }

  void _increaseQuantity() {
    _updateQuantity(_quantity + 1);
  }

  // Load vendors for this product
  Future<void> _loadVendors() async {
    setState(() {
      _isLoadingVendors = true;
    });

    try {
      final global = Get.isRegistered<GlobalController>()
          ? Get.find<GlobalController>()
          : null;

      final agencyId = global?.selectedAgencyId.value;

      print("PRODUCT ID: $_productId");
      print("AGENCY ID: $agencyId");

      final response = await Get.find<ApiService>().getVendorsForProduct(
        _productId,
        agencyId: agencyId,
      );

      print('Vendors API Response: $response');

      if (response == null) {
        setState(() {
          _vendors = [];
          _isLoadingVendors = false;
        });
        return;
      }

      bool status = false;
      dynamic vendorsData;

      if (response is Map) {
        status = response['status'] == true;
        vendorsData = response['data'];
      } else if (response is List) {
        status = true;
        vendorsData = response;
      }

      if (!status || vendorsData == null) {
        print('API returned no valid data');
        setState(() {
          _vendors = [];
          _isLoadingVendors = false;
        });
        return;
      }

      if (vendorsData is String) {
        try {
          vendorsData = jsonDecode(vendorsData);
        } catch (e) {
          print('Error parsing vendors data string: $e');
        }
      }

      List<Map<String, dynamic>> processedVendors = [];

      if (vendorsData is List) {
        for (var vendorItem in vendorsData) {
          if (vendorItem is! Map) continue;

          int vendorId = 0;
          String vendorName = 'Unknown Vendor';
          double vendorPrice = 0.0;
          int vendorStock = 0;
          int vendorProductId = 0;

          // CASE 1: vendor_products
          if (vendorItem['vendor_products'] is List) {
            vendorId = vendorItem['id'] ?? 0;
            vendorName = vendorItem['name'] ?? 'Unknown Vendor';

            final vp = vendorItem['vendor_products'];
            if (vp.isNotEmpty) {
              final p = vp[0];
              vendorPrice = double.tryParse(
                      (p['selling_price'] ?? p['price'] ?? 0).toString()) ??
                  0.0;
              vendorStock = int.tryParse(
                      (p['stock_quantity'] ?? p['stock'] ?? 0).toString()) ??
                  0;
              vendorProductId =
                  int.tryParse(p['id']?.toString() ?? '0') ?? 0;
            }
          }
          // CASE 2: vendor nested
          else if (vendorItem['vendor'] is Map) {
            final vendorInfo = vendorItem['vendor'];
            vendorId = vendorInfo['id'] ?? vendorItem['vendor_id'] ?? 0;
            vendorName = vendorInfo['name'] ?? 'Unknown Vendor';
            vendorProductId = vendorItem['id'] ?? 0;
            vendorPrice = double.tryParse(
                    (vendorItem['selling_price'] ?? vendorItem['price'] ?? 0)
                        .toString()) ??
                0.0;
            vendorStock = int.tryParse(
                    (vendorItem['stock_quantity'] ?? vendorItem['stock'] ?? 0)
                        .toString()) ??
                0;
          }
          // CASE 3: simple
          else {
            vendorId = vendorItem['id'] ?? vendorItem['vendor_id'] ?? 0;
            vendorName =
                vendorItem['name'] ?? vendorItem['vendor_name'] ?? 'Unknown Vendor';
            vendorPrice = double.tryParse(
                    (vendorItem['selling_price'] ??
                            vendorItem['price'] ??
                            vendorItem['pivot']?['selling_price'] ??
                            0)
                        .toString()) ??
                0.0;
            vendorStock = int.tryParse(
                    (vendorItem['stock_quantity'] ??
                            vendorItem['stock'] ??
                            vendorItem['pivot']?['stock_quantity'] ??
                            0)
                        .toString()) ??
                0;
            vendorProductId = int.tryParse(
                    vendorItem['pivot']?['id']?.toString() ??
                        vendorItem['id']?.toString() ??
                        '0') ??
                0;
          }

          if (vendorId > 0) {
            processedVendors.add({
              'id': vendorId,
              'name': vendorName,
              'vendor_product_id': vendorProductId,
              'price': vendorPrice,
              'stock': vendorStock,
            });
            print('Processed: $vendorName | ₹$vendorPrice | Stock: $vendorStock');
          }
        }
      }

      setState(() {
        _vendors = processedVendors;
        _isLoadingVendors = false;
      });

      if (_vendors.isNotEmpty) {
        if (agencyId != null) {
          final matched = _vendors.firstWhereOrNull(
            (v) => v['id'] == agencyId,
          );
          if (matched != null) {
            _selectVendor(matched);
          } else {
            _selectVendor(_vendors.first);
          }
        } else {
          _selectVendor(_vendors.first);
        }
      }

      if (_vendors.isEmpty) {
        print('No vendors found');
      }
    } catch (e) {
      print('Error loading vendors: $e');
      setState(() {
        _vendors = [];
        _isLoadingVendors = false;
      });
    }
  }

  // Load fallback vendors
  Future<void> _loadFallbackVendors() async {
    setState(() {
      _vendors = [
        {
          'id': 1,
          'name': 'MedLife Pharma',
          'price': _productPrice,
          'stock': 100,
          'vendor_product_id': 101,
        },
        {
          'id': 2,
          'name': 'HealthCare Solutions',
          'price': _productPrice * 0.95,
          'stock': 75,
          'vendor_product_id': 102,
        },
        {
          'id': 3,
          'name': 'City Medical Store',
          'price': _productPrice * 1.05,
          'stock': 50,
          'vendor_product_id': 103,
        },
      ];
      _isLoadingVendors = false;

      if (_vendors.isNotEmpty && _selectedVendorId == -1) {
        _selectVendor(_vendors.first);
      }
    });
  }

  // Select vendor
  void _selectVendor(Map<String, dynamic> vendor) {
    setState(() {
      _selectedVendorId = vendor['id'];
      _selectedVendorName = vendor['name'];
      _selectedVendorPrice = (vendor['price'] ?? _productPrice).toDouble();
      _selectedVendorStock = vendor['stock'] ?? 0;
      _selectedVendorProductId = vendor['vendor_product_id'] ?? 0;

      if (_productPackings.isNotEmpty) {
        _selectedPackingId = _productPackings.first['id'];
        _selectedPackingType = _productPackings.first['type'];
        _selectedPackingPrice = _productPackings.first['price'];
      }

      _maxStock = _selectedVendorStock > 0 ? _selectedVendorStock : 999;

      // Reset quantity to 1 when vendor changes
      _quantity = 1;
      _qtyController.text = '1';

      print(
          'Vendor selected: $_selectedVendorName, Price: $_selectedVendorPrice, Max stock: $_maxStock, Vendor Product ID: $_selectedVendorProductId');
    });
  }

  void _addToCart() {
    // Commit any pending text field value before adding
    _onQtyFieldSubmitted(_qtyController.text);

    // Capture addon qty
    _addonQty = int.tryParse(_addonController.text.trim()) ?? 0;

    if (_selectedVendorId == -1) {
      Get.snackbar(
        'Error',
        'Please select an Agency',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_selectedVendorProductId == 0) {
      print('Warning: vendorProductId is 0, this might cause issues');
    }

    setState(() {
      _isAddingToCart = true;
    });

    final cartService = Get.find<CartService>();

    String? productImage;
    if (_productImages.isNotEmpty) {
      productImage = _productImages[0];
    }

    print("_selectedVendorProductId");
    print(_selectedVendorProductId);

    cartService
        .addToCart(
      productId: _productId,
      productName: _productName,
      vendorId: _selectedVendorId,
      vendorName: _selectedVendorName,
      packingId: _selectedPackingId != -1 ? _selectedPackingId : 1,
      vendorProductId: _selectedVendorProductId,
      packingType:
          _selectedPackingType.isNotEmpty ? _selectedPackingType : 'Standard',
      quantity: _quantity,
      price: _currentPrice,
      gstPercentage: _productGstPercentage ?? 0,
      image: productImage,
      addon: _addonQty > 0 ? _addonQty : null,
    )
        .then((_) {
      Get.snackbar(
        'Success',
        'Item added to cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      Get.find<MainController>().onProductAddedToCart();
      setState(() {
        _isAddingToCart = false;
      });
      Navigator.of(context).pop();
    }).catchError((error) {
      setState(() {
        _isAddingToCart = false;
      });
      print('Failed to add item to cart: $error');
      Get.snackbar(
        'Error',
        'Failed to add item to cart: $error',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.maxFinite,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add to Cart',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111261),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),

              const Divider(),

              // ── Product Info ─────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _productImages.isNotEmpty
                        ? Image.network(
                            _getFullImageUrl(_productImages[0]),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.medical_services_outlined,
                                size: 30,
                                color: Color(0xFF6B7280),
                              );
                            },
                          )
                        : const Icon(
                            Icons.medical_services_outlined,
                            size: 30,
                            color: Color(0xFF6B7280),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _productName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111261),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _manufacturerName,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Vendor / Agency Selection ─────────────────────────────────
              const Text(
                'Select Agency',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111261),
                ),
              ),
              const SizedBox(height: 8),

              _isLoadingVendors
                  ? const Center(
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : _vendors.isEmpty
                      ? const Text('No Agency available')
                      : SizedBox(
                          height: 100,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _vendors.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final vendor = _vendors[index];
                              final isSelected =
                                  _selectedVendorId == vendor['id'];
                              final vendorPrice =
                                  (vendor['price'] ?? _productPrice).toDouble();

                              return GestureDetector(
                                onTap: () => _selectVendor(vendor),
                                child: Container(
                                  width: 140,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF043734)
                                          : Colors.grey.shade300,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    color: isSelected
                                        ? const Color(0xFF043734)
                                            .withOpacity(0.05)
                                        : Colors.white,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        vendor['name'],
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                          color: isSelected
                                              ? const Color(0xFF043734)
                                              : const Color(0xFF111261),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '₹${vendorPrice.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? const Color(0xFF043734)
                                              : const Color(0xFF111261),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

              const SizedBox(height: 16),

              // ── Packing Details ──────────────────────────────────────────
              if (_productPackings.isNotEmpty) ...[
                const Text(
                  'Packing Details',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111261),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.inventory_2_outlined,
                        size: 20,
                        color: Color(0xFF043734),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedPackingType.isNotEmpty
                                  ? _selectedPackingType
                                  : _productPackings.first['type'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111261),
                              ),
                            ),
                            Text(
                              'Price: ₹${_currentPrice.toStringAsFixed(2)} per unit',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── Quantity + Add-on row ─────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Qty label + stepper
                  Expanded(
                    child: Row(
                      children: [
                        const Text(
                          'Qty',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111261),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // ── Decrease button ────────────────────────
                              InkWell(
                                onTap: _decreaseQuantity,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(7),
                                  bottomLeft: Radius.circular(7),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: _quantity > 1
                                        ? const Color(0xFF043734)
                                            .withOpacity(0.1)
                                        : Colors.grey.shade100,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(7),
                                      bottomLeft: Radius.circular(7),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.remove,
                                    size: 16,
                                    color: _quantity > 1
                                        ? const Color(0xFF043734)
                                        : Colors.grey,
                                  ),
                                ),
                              ),

                              // ── Editable Qty TextField ─────────────────
                              Container(
                                width: 48,
                                decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                        color: Colors.grey.shade300),
                                    right: BorderSide(
                                        color: Colors.grey.shade300),
                                  ),
                                ),
                                child: TextField(
                                  controller: _qtyController,
                                  focusNode: _qtyFocusNode,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF111261),
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 8),
                                    isDense: true,
                                  ),
                                  onSubmitted: _onQtyFieldSubmitted,
                                  onChanged: (value) {
                                    if (value.isNotEmpty) {
                                      final parsed = int.tryParse(value);
                                      if (parsed != null) {
                                        int clamped =
                                            parsed.clamp(1, _maxStock);
                                        if (clamped != _quantity) {
                                          setState(() {
                                            _quantity = clamped;
                                          });
                                        }
                                      }
                                    }
                                  },
                                ),
                              ),

                              // ── Increase button ────────────────────────
                              InkWell(
                                onTap: _increaseQuantity,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(7),
                                  bottomRight: Radius.circular(7),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: _quantity < _maxStock
                                        ? const Color(0xFF043734)
                                            .withOpacity(0.1)
                                        : Colors.grey.shade100,
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(7),
                                      bottomRight: Radius.circular(7),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    size: 16,
                                    color: _quantity < _maxStock
                                        ? const Color(0xFF043734)
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // ── Add-on number box ──────────────────────────────────
                  Row(
                    children: [
                      // const Text(
                      //   'Add-on',
                      //   style: TextStyle(
                      //     fontSize: 14,
                      //     fontWeight: FontWeight.w600,
                      //     color: Color(0xFF111261),
                      //   ),
                      // ),
                      // const SizedBox(width: 8),
                      Container(
                        width: 64,
                        height: 38,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _addonController,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111261),
                          ),
                          decoration: InputDecoration(
                            hintText: '0',
                            hintStyle: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[400],
                              fontWeight: FontWeight.normal,
                            ),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 8),
                            isDense: true,
                          ),
                          onChanged: (value) {
                            _addonQty = int.tryParse(value) ?? 0;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Total Price + Add Button ──────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Price',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '₹${(_currentPrice * _quantity).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF043734),
                          ),
                        ),
                        if (_selectedVendorPrice > 0)
                          Text(
                            '(₹${_selectedVendorPrice.toStringAsFixed(2)} × $_quantity)',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isAddingToCart ? null : _addToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF043734),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _isAddingToCart
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Add to Cart'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFullImageUrl(String? imagePath) {
    const String baseUrl = '${ApiEndpoints.imgUrl}/';
    if (imagePath == null || imagePath.isEmpty) return '';
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    if (imagePath.startsWith('/')) {
      imagePath = imagePath.substring(1);
    }
    return baseUrl + imagePath;
  }
}