// lib/app/data/models/order_model.dart

import 'package:flutter/material.dart';
import 'package:medical_b2b_app/app/data/providers/api_endpoints.dart';

class Order {
  final int id;
  final String orderNumber;
  final String? agency;
  final int buyerId;
  final int vendorId;
  final int? shippingAddressId;
  final int? billingAddressId;
  final double totalAmount;
  final double discountAmount;
  final double gstAmount;
  final double shippingCharge;
  final double finalAmount;
  final String paymentStatus;
  final String orderStatus;
  final String paymentMethod;
  final String? deliveryInstructions;
  final DateTime? expectedDeliveryDate;
  final DateTime? actualDeliveryDate;
  final String? vendorNotes;
  final String? buyerNotes;
  final String? cancellationReason;
  final int? cancelledBy;
  final String integrationStatus;
  final String? tallyOrderNumber;
  final DateTime createdAt;
  final DateTime updatedAt;
  final dynamic buyer;
  final List<OrderItem> items;
  final Address? shippingAddress;
  final Address? billingAddress;
  final List<StatusHistory> statusHistory;

  Order({
    required this.id,
    required this.orderNumber,
    required this.agency,

    required this.buyerId,
    required this.vendorId,
    this.shippingAddressId,
    this.billingAddressId,
    required this.totalAmount,
    required this.discountAmount,
    required this.gstAmount,
    required this.shippingCharge,
    required this.finalAmount,
    required this.paymentStatus,
    required this.orderStatus,
    required this.paymentMethod,
    this.deliveryInstructions,
    this.expectedDeliveryDate,
    this.actualDeliveryDate,
    this.vendorNotes,
    this.buyerNotes,
    this.cancellationReason,
    this.cancelledBy,
    required this.integrationStatus,
    this.tallyOrderNumber,
    required this.createdAt,
    required this.updatedAt,
    this.buyer,
    required this.items,
    this.shippingAddress,
    this.billingAddress,
    required this.statusHistory,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      orderNumber: json['order_number'] ?? '',
      agency: json['agency_name'] ?? '',
      buyerId: json['buyer_id'] ?? 0,
      vendorId: json['vendor_id'] ?? 0,
      shippingAddressId: json['shipping_address_id'],
      billingAddressId: json['billing_address_id'],
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0,
      discountAmount: double.tryParse(json['discount_amount']?.toString() ?? '0') ?? 0,
      gstAmount: double.tryParse(json['gst_amount']?.toString() ?? '0') ?? 0,
      shippingCharge: double.tryParse(json['shipping_charge']?.toString() ?? '0') ?? 0,
      finalAmount: double.tryParse(json['final_amount']?.toString() ?? '0') ?? 0,
      paymentStatus: json['payment_status'] ?? 'pending',
      orderStatus: json['order_status'] ?? 'placed',
      paymentMethod: json['payment_method'] ?? 'cod',
      deliveryInstructions: json['delivery_instructions'],
      expectedDeliveryDate: json['expected_delivery_date'] != null
          ? DateTime.tryParse(json['expected_delivery_date'])
          : null,
      actualDeliveryDate: json['actual_delivery_date'] != null
          ? DateTime.tryParse(json['actual_delivery_date'])
          : null,
      vendorNotes: json['vendor_notes'],
      buyerNotes: json['buyer_notes'],
      cancellationReason: json['cancellation_reason'],
      cancelledBy: json['cancelled_by'],
      integrationStatus: json['integration_status'] ?? 'pending',
      tallyOrderNumber: json['tally_order_number'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      buyer: json['buyer'],
      items: (json['items'] as List? ?? [])
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      shippingAddress: json['shipping_address'] != null
          ? Address.fromJson(json['shipping_address'])
          : null,
      billingAddress: json['billing_address'] != null
          ? Address.fromJson(json['billing_address'])
          : null,
      statusHistory: (json['status_history'] as List? ?? [])
          .map((history) => StatusHistory.fromJson(history))
          .toList(),
    );
  }

  String get formattedOrderDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays == 0) {
      return 'Today, ${_formatTime(createdAt)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday, ${_formatTime(createdAt)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  double get subtotal {
    return items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  double get tax => gstAmount;

  double get discount => discountAmount;

  String? get trackingNumber => null; // Add if you have tracking info

  bool get canCancel {
    return orderStatus == 'placed' || orderStatus == 'pending' || orderStatus == 'confirmed';
  }

  bool get canReturn {
    return orderStatus == 'delivered';
  }

  bool get canTrack {
    return orderStatus == 'shipped' || orderStatus == 'processing';
  }

  int get itemCount => items.length;

  OrderStatus get status {
    switch (orderStatus.toLowerCase()) {
      case 'placed':
        return OrderStatus.placed;
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'processing':
        return OrderStatus.processing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'returned':
        return OrderStatus.returned;
      default:
        return OrderStatus.placed;
    }
  }
}

class OrderItem {
  final int id;
  final int orderId;
  final int vendorProductId;
  final String productName;
  final String? batchNumber;
  final DateTime? expiryDate;
  final int quantity;
  final int addon;

  final double unitPrice;
  final double gstPercentage;
  final double gstAmount;
  final double totalPrice;

  // 🔥 NEW FIELDS
  final double mrpPrice;
  final double discountMin;
  final double discountMax;

  final int returnQuantity;
  final String? returnReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final VendorProduct? vendorProduct;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.vendorProductId,
    required this.productName,
    this.batchNumber,
    this.expiryDate,
    required this.quantity,
    required this.addon,
    required this.unitPrice,
    required this.gstPercentage,
    required this.gstAmount,
    required this.totalPrice,

    // 🔥 NEW
    required this.mrpPrice,
    required this.discountMin,
    required this.discountMax,

    required this.returnQuantity,
    this.returnReason,
    required this.createdAt,
    required this.updatedAt,
    this.vendorProduct,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      vendorProductId: json['vendor_product_id'] ?? 0,
      productName: json['product_name'] ?? '',
      batchNumber: json['batch_number'],

      expiryDate: json['expiry_date'] != null
          ? DateTime.tryParse(json['expiry_date'])
          : null,

      quantity: json['quantity'] ?? 0,

      addon: json['addon'] ?? 0,

      unitPrice:
          double.tryParse(json['unit_price']?.toString() ?? '0') ?? 0,

      gstPercentage:
          double.tryParse(json['gst_percentage']?.toString() ?? '0') ?? 0,

      gstAmount:
          double.tryParse(json['gst_amount']?.toString() ?? '0') ?? 0,

      totalPrice:
          double.tryParse(json['total_price']?.toString() ?? '0') ?? 0,

      // 🔥 NEW PARSING
      mrpPrice:
          double.tryParse(json['mrp_price']?.toString() ?? '0') ?? 0,

      discountMin:
          double.tryParse(json['discount_min']?.toString() ?? '0') ?? 0,

      discountMax:
          double.tryParse(json['discount_max']?.toString() ?? '0') ?? 0,

      returnQuantity: json['return_quantity'] ?? 0,
      returnReason: json['return_reason'],

      createdAt:
          DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),

      updatedAt:
          DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),

      vendorProduct: json['vendor_product'] != null
          ? VendorProduct.fromJson(json['vendor_product'])
          : null,
    );
  }

  // 🔥 Product Image Getter
  String? get productImage {
    if (vendorProduct?.product?.images != null &&
        vendorProduct!.product!.images!.isNotEmpty) {
      return vendorProduct!.product!.images!.first.imageUrl;
    }
    return null;
  }

  // 🔥 Discount % (calculated)
  double get discountPercent {
    if (mrpPrice == 0) return 0;
    return ((mrpPrice - unitPrice) / mrpPrice) * 100;
  }

  // 🔥 You can use this for showing range text
  String get discountRangeText {
    return "${discountMin.toInt()}% - ${discountMax.toInt()}% OFF";
  }
}
class VendorProduct {
  final int id;
  final int vendorId;
  final int productId;
  final String? packingType;
  final String? packSize;
  final int? unitsPerPack;
  final double mrp;
  final double sellingPrice;
  final String? batchNumber;
  final DateTime? manufacturingDate;
  final DateTime? expiryDate;
  final int stockQuantity;
  final int minOrderQuantity;
  final int? maxOrderQuantity;
  final bool isAvailable;
  final bool isVerified;
  final double discountPercentage;
  final String? specialNotes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Product? product;

  VendorProduct({
    required this.id,
    required this.vendorId,
    required this.productId,
    this.packingType,
    this.packSize,
    this.unitsPerPack,
    required this.mrp,
    required this.sellingPrice,
    this.batchNumber,
    this.manufacturingDate,
    this.expiryDate,
    required this.stockQuantity,
    required this.minOrderQuantity,
    this.maxOrderQuantity,
    required this.isAvailable,
    required this.isVerified,
    required this.discountPercentage,
    this.specialNotes,
    required this.createdAt,
    required this.updatedAt,
    this.product,
  });

  factory VendorProduct.fromJson(Map<String, dynamic> json) {
    return VendorProduct(
      id: json['id'] ?? 0,
      vendorId: json['vendor_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      packingType: json['packing_type'],
      packSize: json['pack_size'],
      unitsPerPack: json['units_per_pack'],
      mrp: double.tryParse(json['mrp']?.toString() ?? '0') ?? 0,
      sellingPrice: double.tryParse(json['selling_price']?.toString() ?? '0') ?? 0,
      batchNumber: json['batch_number'],
      manufacturingDate: json['manufacturing_date'] != null
          ? DateTime.tryParse(json['manufacturing_date'])
          : null,
      expiryDate: json['expiry_date'] != null
          ? DateTime.tryParse(json['expiry_date'])
          : null,
      stockQuantity: json['stock_quantity'] ?? 0,
      minOrderQuantity: json['min_order_quantity'] ?? 1,
      maxOrderQuantity: json['max_order_quantity'],
      isAvailable: json['is_available'] ?? true,
      isVerified: json['is_verified'] ?? false,
      discountPercentage: double.tryParse(json['discount_percentage']?.toString() ?? '0') ?? 0,
      specialNotes: json['special_notes'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
    );
  }
}

class Product {
  final int id;
  final String name;
  final String? genericName;
  final int? companyId;
  final int? saltCompositionId;
  final int? subCategoryId;
  final int? powerId;
  final int? unitId;
  final int? categoryId;
  final double price;
  final String? hsnCode;
  final double gstPercentage;
  final String? description;
  final String? sideEffects;
  final String? storageInstructions;
  final int isPrescriptionRequired;
  final int isActive;
  final String? attributes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ProductImage>? images;

  Product({
    required this.id,
    required this.name,
    this.genericName,
    this.companyId,
    this.saltCompositionId,
    this.subCategoryId,
    this.powerId,
    this.unitId,
    this.categoryId,
    required this.price,
    this.hsnCode,
    required this.gstPercentage,
    this.description,
    this.sideEffects,
    this.storageInstructions,
    required this.isPrescriptionRequired,
    required this.isActive,
    this.attributes,
    required this.createdAt,
    required this.updatedAt,
    this.images,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      genericName: json['generic_name'],
      companyId: json['company_id'],
      saltCompositionId: json['salt_composition_id'],
      subCategoryId: json['sub_category_id'],
      powerId: json['power_id'],
      unitId: json['unit_id'],
      categoryId: json['category_id'],
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      hsnCode: json['hsn_code'],
      gstPercentage: double.tryParse(json['gst_percentage']?.toString() ?? '0') ?? 0,
      description: json['description'],
      sideEffects: json['side_effects'],
      storageInstructions: json['storage_instructions'],
      isPrescriptionRequired: json['is_prescription_required'] ?? 0,
      isActive: json['is_active'] ?? 1,
      attributes: json['attributes'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      images: (json['images'] as List? ?? [])
          .map((img) => ProductImage.fromJson(img))
          .toList(),
    );
  }
}

class ProductImage {
  final int id;
  final int productId;
  final String images;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductImage({
    required this.id,
    required this.productId,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      images: json['images'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  String get imageUrl {
    // You'll need to prepend your base URL here
    return '${ApiEndpoints.imgUrl}/$images';
  }
}

class Address {
  final int id;
  final int buyerId;
  final String addressType;
  final String addressLabel;
  final String addressLine1;
  final String? addressLine2;
  final String? landmark;
  final String city;
  final String state;
  final String pincode;
  final String country;
  final String contactPerson;
  final String contactPhone;
  final String? contactEmail;
  final bool isDefaultShipping;
  final bool isDefaultBilling;
  final bool isActive;
  final double? locationLat;
  final double? locationLng;
  final DateTime createdAt;
  final DateTime updatedAt;

  Address({
    required this.id,
    required this.buyerId,
    required this.addressType,
    required this.addressLabel,
    required this.addressLine1,
    this.addressLine2,
    this.landmark,
    required this.city,
    required this.state,
    required this.pincode,
    required this.country,
    required this.contactPerson,
    required this.contactPhone,
    this.contactEmail,
    required this.isDefaultShipping,
    required this.isDefaultBilling,
    required this.isActive,
    this.locationLat,
    this.locationLng,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] ?? 0,
      buyerId: json['buyer_id'] ?? 0,
      addressType: json['address_type'] ?? '',
      addressLabel: json['address_label'] ?? '',
      addressLine1: json['address_line1'] ?? '',
      addressLine2: json['address_line2'],
      landmark: json['landmark'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
      country: json['country'] ?? 'India',
      contactPerson: json['contact_person'] ?? '',
      contactPhone: json['contact_phone'] ?? '',
      contactEmail: json['contact_email'],
      isDefaultShipping: json['is_default_shipping'] ?? false,
      isDefaultBilling: json['is_default_billing'] ?? false,
      isActive: json['is_active'] ?? true,
      locationLat: json['location_lat'] != null
          ? double.tryParse(json['location_lat'].toString())
          : null,
      locationLng: json['location_lng'] != null
          ? double.tryParse(json['location_lng'].toString())
          : null,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class StatusHistory {
  final int id;
  final int orderId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status;
  final String notes;

  StatusHistory({
    required this.id,
    required this.orderId,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.notes,
  });

  factory StatusHistory.fromJson(Map<String, dynamic> json) {
    return StatusHistory(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? '',
      notes: json['notes'] ?? '',
    );
  }
}

enum OrderStatus {
  placed,
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  returned;

  String get displayName {
    switch (this) {
      case OrderStatus.placed:
        return 'Placed';
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.returned:
        return 'Returned';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.placed:
        return Colors.blue;
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.teal;
      case OrderStatus.processing:
        return Colors.purple;
      case OrderStatus.shipped:
        return Colors.indigo;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.returned:
        return Colors.grey;
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.placed:
        return Icons.shopping_bag_outlined;
      case OrderStatus.pending:
        return Icons.pending_outlined;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline;
      case OrderStatus.processing:
        return Icons.pending_actions_outlined;
      case OrderStatus.shipped:
        return Icons.local_shipping_outlined;
      case OrderStatus.delivered:
        return Icons.inventory_outlined;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
      case OrderStatus.returned:
        return Icons.assignment_return_outlined;
    }
  }
}