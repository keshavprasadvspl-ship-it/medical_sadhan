// models/vendors_orders_model.dart

import '../providers/api_endpoints.dart';

class OrderModel {
  final int id;
  final String orderNumber;
  final int buyerId;
  final int vendorId;
  final int shippingAddressId;
  final int billingAddressId;
  final double totalAmount;
  final double discountAmount;
  final double gstAmount;
  final double shippingCharge;
  final double finalAmount;
  final String paymentStatus;
  final String orderStatus;
  final String paymentMethod;
  final String? deliveryInstructions;
  final String? expectedDeliveryDate;
  final String? actualDeliveryDate;
  final String? vendorNotes;
  final String? buyerNotes;
  final String? cancellationReason;
  final String? cancelledBy;
  final String integrationStatus;
  final String? tallyOrderNumber;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Address? shippingAddress;
  final Address? billingAddress;
  final List<OrderItem> items;
  final List<StatusHistory> statusHistory;
  final dynamic buyer;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.buyerId,
    required this.vendorId,
    required this.shippingAddressId,
    required this.billingAddressId,
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
    this.shippingAddress,
    this.billingAddress,
    required this.items,
    required this.statusHistory,
    this.buyer,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: _toInt(json['id']),
      orderNumber: _toString(json['order_number']),
      buyerId: _toInt(json['buyer_id']),
      vendorId: _toInt(json['vendor_id']),
      shippingAddressId: _toInt(json['shipping_address_id']),
      billingAddressId: _toInt(json['billing_address_id']),
      totalAmount: _toDouble(json['total_amount']),
      discountAmount: _toDouble(json['discount_amount']),
      gstAmount: _toDouble(json['gst_amount']),
      shippingCharge: _toDouble(json['shipping_charge']),
      finalAmount: _toDouble(json['final_amount']),
      paymentStatus: _toString(json['payment_status']),
      orderStatus: _toString(json['order_status']),
      paymentMethod: _toString(json['payment_method']),
      deliveryInstructions: _toStringOrNull(json['delivery_instructions']),
      expectedDeliveryDate: _toStringOrNull(json['expected_delivery_date']),
      actualDeliveryDate: _toStringOrNull(json['actual_delivery_date']),
      vendorNotes: _toStringOrNull(json['vendor_notes']),
      buyerNotes: _toStringOrNull(json['buyer_notes']),
      cancellationReason: _toStringOrNull(json['cancellation_reason']),
      cancelledBy: _toStringOrNull(json['cancelled_by']),
      integrationStatus: _toString(json['integration_status']),
      tallyOrderNumber: _toStringOrNull(json['tally_order_number']),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      shippingAddress: json['shipping_address'] != null
          ? Address.fromJson(json['shipping_address'])
          : null,
      billingAddress: json['billing_address'] != null
          ? Address.fromJson(json['billing_address'])
          : null,
      items: (json['items'] as List?)
          ?.map((item) => OrderItem.fromJson(item))
          .toList() ?? [],
      statusHistory: (json['status_history'] as List?)
          ?.map((history) => StatusHistory.fromJson(history))
          .toList() ?? [],
      buyer: json['buyer'],
    );
  }

  // Helper methods for type safety
  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      // Handle string formats like "61.00" or "1,234.56"
      final cleaned = value.replaceAll(',', '');
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }

  static String _toString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  static String? _toStringOrNull(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    final stringValue = value.toString();
    return stringValue.isEmpty ? null : stringValue;
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
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
  final double locationLat;
  final double locationLng;

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
    required this.locationLat,
    required this.locationLng,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: OrderModel._toInt(json['id']),
      buyerId: OrderModel._toInt(json['buyer_id']),
      addressType: OrderModel._toString(json['address_type']),
      addressLabel: OrderModel._toString(json['address_label']),
      addressLine1: OrderModel._toString(json['address_line1']),
      addressLine2: OrderModel._toStringOrNull(json['address_line2']),
      landmark: OrderModel._toStringOrNull(json['landmark']),
      city: OrderModel._toString(json['city']),
      state: OrderModel._toString(json['state']),
      pincode: OrderModel._toString(json['pincode']), // PIN code might be int
      country: OrderModel._toString(json['country']),
      contactPerson: OrderModel._toString(json['contact_person']),
      contactPhone: OrderModel._toString(json['contact_phone']), // Phone might be int
      contactEmail: OrderModel._toStringOrNull(json['contact_email']),
      isDefaultShipping: json['is_default_shipping'] ?? false,
      isDefaultBilling: json['is_default_billing'] ?? false,
      isActive: json['is_active'] ?? true,
      locationLat: OrderModel._toDouble(json['location_lat']),
      locationLng: OrderModel._toDouble(json['location_lng']),
    );
  }

  String get fullAddress {
    final parts = <String>[
      addressLine1,
      if (addressLine2 != null && addressLine2!.isNotEmpty) addressLine2!,
      if (landmark != null && landmark!.isNotEmpty) landmark!,
      city,
      state,
      pincode,
      country,
    ];
    return parts.join(', ');
  }
}

class OrderItem {
  final int id;
  final int orderId;
  final int vendorProductId;
  final String productName;
  final String? batchNumber;
  final String? expiryDate;
  final int quantity;
  final double unitPrice;
  final double gstPercentage;
  final double gstAmount;
  final double totalPrice;
  final int returnQuantity;
  final String? returnReason;
  final VendorProduct? vendorProduct;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.vendorProductId,
    required this.productName,
    this.batchNumber,
    this.expiryDate,
    required this.quantity,
    required this.unitPrice,
    required this.gstPercentage,
    required this.gstAmount,
    required this.totalPrice,
    required this.returnQuantity,
    this.returnReason,
    this.vendorProduct,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: OrderModel._toInt(json['id']),
      orderId: OrderModel._toInt(json['order_id']),
      vendorProductId: OrderModel._toInt(json['vendor_product_id']),
      productName: OrderModel._toString(json['product_name']),
      batchNumber: OrderModel._toStringOrNull(json['batch_number']),
      expiryDate: OrderModel._toStringOrNull(json['expiry_date']),
      quantity: OrderModel._toInt(json['quantity']),
      unitPrice: OrderModel._toDouble(json['unit_price']),
      gstPercentage: OrderModel._toDouble(json['gst_percentage']),
      gstAmount: OrderModel._toDouble(json['gst_amount']),
      totalPrice: OrderModel._toDouble(json['total_price']),
      returnQuantity: OrderModel._toInt(json['return_quantity']),
      returnReason: OrderModel._toStringOrNull(json['return_reason']),
      vendorProduct: json['vendor_product'] != null
          ? VendorProduct.fromJson(json['vendor_product'])
          : null,
    );
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
  final String? manufacturingDate;
  final String? expiryDate;
  final int stockQuantity;
  final int minOrderQuantity;
  final int? maxOrderQuantity;
  final bool isAvailable;
  final bool isVerified;
  final double discountPercentage;
  final String? specialNotes;
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
    this.product,
  });

  factory VendorProduct.fromJson(Map<String, dynamic> json) {
    return VendorProduct(
      id: OrderModel._toInt(json['id']),
      vendorId: OrderModel._toInt(json['vendor_id']),
      productId: OrderModel._toInt(json['product_id']),
      packingType: OrderModel._toStringOrNull(json['packing_type']),
      packSize: OrderModel._toStringOrNull(json['pack_size']),
      unitsPerPack: OrderModel._toInt(json['units_per_pack']),
      mrp: OrderModel._toDouble(json['mrp']),
      sellingPrice: OrderModel._toDouble(json['selling_price']),
      batchNumber: OrderModel._toStringOrNull(json['batch_number']),
      manufacturingDate: OrderModel._toStringOrNull(json['manufacturing_date']),
      expiryDate: OrderModel._toStringOrNull(json['expiry_date']),
      stockQuantity: OrderModel._toInt(json['stock_quantity']),
      minOrderQuantity: OrderModel._toInt(json['min_order_quantity']) ?? 1,
      maxOrderQuantity: OrderModel._toInt(json['max_order_quantity']),
      isAvailable: json['is_available'] ?? true,
      isVerified: json['is_verified'] ?? false,
      discountPercentage: OrderModel._toDouble(json['discount_percentage']),
      specialNotes: OrderModel._toStringOrNull(json['special_notes']),
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
    );
  }
}

class Product {
  final int id;
  final String name;
  final String genericName;
  final int companyId;
  final int saltCompositionId;
  final int? subCategoryId;
  final int powerId;
  final int unitId;
  final int categoryId;
  final double price;
  final String hsnCode;
  final double gstPercentage;
  final String description;
  final String sideEffects;
  final String storageInstructions;
  final int isPrescriptionRequired;
  final int isActive;
  final dynamic attributes;
  final List<ProductImage> images;

  Product({
    required this.id,
    required this.name,
    required this.genericName,
    required this.companyId,
    required this.saltCompositionId,
    this.subCategoryId,
    required this.powerId,
    required this.unitId,
    required this.categoryId,
    required this.price,
    required this.hsnCode,
    required this.gstPercentage,
    required this.description,
    required this.sideEffects,
    required this.storageInstructions,
    required this.isPrescriptionRequired,
    required this.isActive,
    this.attributes,
    required this.images,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: OrderModel._toInt(json['id']),
      name: OrderModel._toString(json['name']),
      genericName: OrderModel._toString(json['generic_name']),
      companyId: OrderModel._toInt(json['company_id']),
      saltCompositionId: OrderModel._toInt(json['salt_composition_id']),
      subCategoryId: OrderModel._toInt(json['sub_category_id']),
      powerId: OrderModel._toInt(json['power_id']),
      unitId: OrderModel._toInt(json['unit_id']),
      categoryId: OrderModel._toInt(json['category_id']),
      price: OrderModel._toDouble(json['price']),
      hsnCode: OrderModel._toString(json['hsn_code']), // HSN code might be int
      gstPercentage: OrderModel._toDouble(json['gst_percentage']),
      description: OrderModel._toString(json['description']),
      sideEffects: OrderModel._toString(json['side_effects']),
      storageInstructions: OrderModel._toString(json['storage_instructions']),
      isPrescriptionRequired: OrderModel._toInt(json['is_prescription_required']),
      isActive: OrderModel._toInt(json['is_active']) ?? 1,
      attributes: json['attributes'],
      images: (json['images'] as List?)
          ?.map((img) => ProductImage.fromJson(img))
          .toList() ?? [],
    );
  }
}

class ProductImage {
  final int id;
  final int productId;
  final String images;
  final DateTime createdAt;

  ProductImage({
    required this.id,
    required this.productId,
    required this.images,
    required this.createdAt,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: OrderModel._toInt(json['id']),
      productId: OrderModel._toInt(json['product_id']),
      images: OrderModel._toString(json['images']),
      createdAt: OrderModel._parseDate(json['created_at']),
    );
  }

  String get imageUrl => '${ApiEndpoints.imgUrl}/$images';
}

class StatusHistory {
  final int id;
  final int orderId;
  final String status;
  final String? notes;
  final DateTime createdAt;

  StatusHistory({
    required this.id,
    required this.orderId,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  factory StatusHistory.fromJson(Map<String, dynamic> json) {
    return StatusHistory(
      id: OrderModel._toInt(json['id']),
      orderId: OrderModel._toInt(json['order_id']),
      status: OrderModel._toString(json['status']),
      notes: OrderModel._toStringOrNull(json['notes']),
      createdAt: OrderModel._parseDate(json['created_at']),
    );
  }
}