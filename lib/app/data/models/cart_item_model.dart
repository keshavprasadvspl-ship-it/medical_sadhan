// lib/data/models/cart_item_model.dart
class CartItem {
  final int productId;
  final String productName;
  final int vendorId;
  final String vendorName;
  final int packingId;
  final int vendorProductId;
  final String packingName;
  final int quantity;
  final double price;
  final double mrpPrice;       // ─── NEW: from api mrp_price ──────────────────
  final double discountMin;    // ─── NEW: from api discount_min ───────────────
  final double discountMax;    // ─── NEW: from api discount_max ───────────────
  final double gstPercentage;
  final String? specialInstructions;
  final String? image;
  final DateTime addedAt;
  final String? addon;

  CartItem({
    required this.productId,
    required this.productName,
    required this.vendorId,
    required this.vendorName,
    required this.packingId,
    required this.vendorProductId,
    required this.packingName,
    required this.quantity,
    required this.price,
    this.mrpPrice = 0.0,       // ─── NEW ──────────────────────────────────────
    this.discountMin = 0.0,    // ─── NEW ──────────────────────────────────────
    this.discountMax = 0.0,    // ─── NEW ──────────────────────────────────────
    required this.gstPercentage,
    this.specialInstructions,
    this.image,
    DateTime? addedAt,
    this.addon,
  }) : addedAt = addedAt ?? DateTime.now();

  double get subtotal => price * quantity;

  double get tax => subtotal * (gstPercentage / 100);

  double get total => subtotal + tax;

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'vendorId': vendorId,
      'vendorName': vendorName,
      'packingId': packingId,
      'vendorProductId': vendorProductId,
      'packingName': packingName,
      'quantity': quantity,
      'price': price,
      'mrpPrice': mrpPrice,       // ─── NEW ──────────────────────────────────
      'discountMin': discountMin, // ─── NEW ──────────────────────────────────
      'discountMax': discountMax, // ─── NEW ──────────────────────────────────
      'gstPercentage': gstPercentage,
      'specialInstructions': specialInstructions,
      'image': image,
      'addedAt': addedAt.toIso8601String(),
      'addon': addon,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'] ?? 0,
      productName: json['productName'] ?? '',
      vendorId: json['vendorId'] ?? 0,
      vendorName: json['vendorName'] ?? '',
      packingId: json['packingId'] ?? 0,
      vendorProductId: json['vendorProductId'] ?? 0,
      packingName: json['packingName'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      mrpPrice: (json['mrpPrice'] ?? json['mrp_price'] ?? 0).toDouble(),           // ─── NEW ───
      discountMin: (json['discountMin'] ?? json['discount_min'] ?? 0).toDouble(),  // ─── NEW ───
      discountMax: (json['discountMax'] ?? json['discount_max'] ?? 0).toDouble(),  // ─── NEW ───
      gstPercentage: (json['gstPercentage'] ?? 0).toDouble(),
      specialInstructions: json['specialInstructions'],
      image: json['image'],
      addedAt: json['addedAt'] != null
          ? DateTime.parse(json['addedAt'])
          : DateTime.now(),
      addon: json['addon']?.toString(),
    );
  }
}