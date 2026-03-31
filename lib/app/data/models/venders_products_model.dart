class ProductModel {
  final int vendorProductId;
  final int productId;
  final String name;
  final String? genericName;
  final String? image;
  final double? mrp;
  final double? sellingPrice;
  final int? stockQuantity;
  final bool? isAvailable;

  ProductModel({
    required this.vendorProductId,
    required this.productId,
    required this.name,
    this.genericName,
    this.image,
    this.mrp,
    this.sellingPrice,
    this.stockQuantity,
    this.isAvailable,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      vendorProductId: json['vendor_product_id'],
      productId: json['product_id'],
      name: json['name'] ?? '',
      genericName: json['generic_name'],
      image: json['image'],
      mrp: double.tryParse(json['mrp'].toString()) ?? 0.0,
      sellingPrice: double.tryParse(json['selling_price'].toString()) ?? 0.0,
      stockQuantity: json['stock_quantity'],
      isAvailable: json['is_available'],
    );
  }

  ProductModel copyWith({
    int? stockQuantity,
  }) {
    return ProductModel(
      vendorProductId: vendorProductId,
      productId: productId,
      name: name,
      genericName: genericName,
      image: image,
      mrp: mrp,
      sellingPrice: sellingPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      isAvailable: isAvailable,
    );
  }
}
