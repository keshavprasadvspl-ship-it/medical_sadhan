// In vendor_model.dart
class Vendor {
  final int id;
  final String name;
  final double price;
  final double? discountPrice;
  final int stock;
  final String deliveryTime;
  final double rating;
  final int vendorProductId; // Add this field

  Vendor({
    required this.id,
    required this.name,
    required this.price,
    this.discountPrice,
    required this.stock,
    required this.deliveryTime,
    required this.rating,
    required this.vendorProductId, // Make it required
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    // Parse vendorProductId from the vendor_product data
    int vendorProductId = 0;
    if (json['vendor_products'] != null &&
        json['vendor_products'] is List &&
        (json['vendor_products'] as List).isNotEmpty) {
      final vendorProduct = (json['vendor_products'] as List).first;
      vendorProductId = int.tryParse(vendorProduct['id']?.toString() ?? '0') ?? 0;
    }

    return Vendor(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      discountPrice: json['discount_price'] != null
          ? double.tryParse(json['discount_price'].toString())
          : null,
      stock: json['stock'] ?? 0,
      deliveryTime: json['delivery_time'] ?? '24 hours',
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      vendorProductId: vendorProductId, // Set the vendor product ID
    );
  }
}