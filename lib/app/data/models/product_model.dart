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
  final int maxOrderQuantity;
  final bool isAvailable;
  final bool isVerified;
  final double discountPercentage;
  final String? specialNotes;

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
    required this.maxOrderQuantity,
    required this.isAvailable,
    required this.isVerified,
    required this.discountPercentage,
    this.specialNotes,
  });

  factory VendorProduct.fromJson(Map<String, dynamic> json) {
    return VendorProduct(
      id: (json['id'] as num?)?.toInt() ?? 0,
      vendorId: (json['vendor_id'] as num?)?.toInt() ?? 0,
      productId: (json['product_id'] as num?)?.toInt() ?? 0,
      packingType: json['packing_type']?.toString(),
      packSize: json['pack_size']?.toString(),
      unitsPerPack: (json['units_per_pack'] as num?)?.toInt(),
      mrp: double.tryParse(json['mrp']?.toString() ?? '0') ?? 0.0,
      sellingPrice: double.tryParse(json['selling_price']?.toString() ?? '0') ?? 0.0,
      batchNumber: json['batch_number']?.toString(),
      manufacturingDate: json['manufacturing_date'] != null
          ? DateTime.tryParse(json['manufacturing_date'].toString())
          : null,
      expiryDate: json['expiry_date'] != null
          ? DateTime.tryParse(json['expiry_date'].toString())
          : null,
      stockQuantity: (json['stock_quantity'] as num?)?.toInt() ?? 0,
      minOrderQuantity: (json['min_order_quantity'] as num?)?.toInt() ?? 1,
      maxOrderQuantity: (json['max_order_quantity'] as num?)?.toInt() ?? 100,
      isAvailable: (json['is_available'] as num?)?.toInt() == 1,
      isVerified: (json['is_verified'] as num?)?.toInt() == 1,
      discountPercentage: double.tryParse(json['discount_percentage']?.toString() ?? '0') ?? 0.0,
      specialNotes: json['special_notes']?.toString(),
    );
  }

  bool get hasValidPrice => sellingPrice > 0 && isAvailable;
  bool get isInStock => stockQuantity > 0 && isAvailable;

  String get formattedSellingPrice => '₹${sellingPrice.toStringAsFixed(2)}';
  String get formattedMrp => '₹${mrp.toStringAsFixed(2)}';

  double get discountAmount => mrp - sellingPrice;
  double get discountPercent => mrp > 0 ? ((mrp - sellingPrice) / mrp * 100) : 0;
}

class Company {
  final int id;
  final String name;

  Company({required this.id, required this.name});

  factory Company.fromJson(dynamic json) {
    if (json == null) {
      return Company(id: 0, name: '');
    }

    if (json is String) {
      return Company(id: 0, name: json);
    }

    if (json is Map<String, dynamic>) {
      return Company(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name']?.toString() ?? '',
      );
    }

    return Company(id: 0, name: '');
  }
}

class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(dynamic json) {
    if (json == null) {
      return Category(id: 0, name: 'Unknown');
    }

    if (json is String) {
      return Category(id: 0, name: json);
    }

    if (json is Map<String, dynamic>) {
      return Category(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name']?.toString() ?? 'Unknown',
      );
    }

    return Category(id: 0, name: 'Unknown');
  }
}

class SubCategory {
  final int id;
  final String name;

  SubCategory({required this.id, required this.name});

  factory SubCategory.fromJson(dynamic json) {
    if (json == null) {
      return SubCategory(id: 0, name: 'Unknown');
    }

    if (json is String) {
      return SubCategory(id: 0, name: json);
    }

    if (json is Map<String, dynamic>) {
      return SubCategory(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name']?.toString() ?? 'Unknown',
      );
    }

    return SubCategory(id: 0, name: 'Unknown');
  }
}

class SaltComposition {
  final int id;
  final String name;

  SaltComposition({required this.id, required this.name});

  factory SaltComposition.fromJson(dynamic json) {
    if (json == null) {
      return SaltComposition(id: 0, name: 'Unknown');
    }

    if (json is String) {
      return SaltComposition(id: 0, name: json);
    }

    if (json is Map<String, dynamic>) {
      return SaltComposition(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name']?.toString() ?? 'Unknown',
      );
    }

    return SaltComposition(id: 0, name: 'Unknown');
  }
}

class Unit {
  final int id;
  final String name;

  Unit({required this.id, required this.name});

  factory Unit.fromJson(dynamic json) {
    if (json == null) {
      return Unit(id: 0, name: 'Piece');
    }

    if (json is String) {
      return Unit(id: 0, name: json);
    }

    if (json is Map<String, dynamic>) {
      return Unit(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name']?.toString() ?? 'Piece',
      );
    }

    return Unit(id: 0, name: 'Piece');
  }
}

class Product {
  final int id;
  final String name;
  final String genericName;
  final Company company;
  final Category category;
  final SubCategory subCategory;
  final SaltComposition saltComposition;
  final String power;
  final Unit unit;
  final String hsnCode;
  final double gstPercentage;
  final String description;
  final String sideEffects;
  final String storageInstructions;
  final bool isPrescriptionRequired;
  final bool isActive;
  final String attributes;
  final List<String> images;

  // Additional fields for UI (will be 0 if no vendor data)
  double price;
  double discountPrice;
  int stock;
  double rating;
  int ratingCount;
  bool isFavorite;

  // Optional fields
  String brand;
  String manufacturer;
  String form;
  String packSize;
  List<String> benefits;
  List<String> usage;

  // Vendor products data
  final List<VendorProduct> vendorProducts;

  // NEW FIELDS ADDED FROM API
  final String mrpPrice;           // From API: mrp_price
  final int discountMin;           // From API: discount_min
  final int discountMax;           // From API: discount_max
  final int discountPercent;       // From API: discount_percent

  Product({
    required this.id,
    required this.name,
    required this.genericName,
    required this.company,
    required this.category,
    required this.subCategory,
    required this.saltComposition,
    required this.power,
    required this.unit,
    required this.hsnCode,
    required this.gstPercentage,
    required this.description,
    required this.sideEffects,
    required this.storageInstructions,
    required this.isPrescriptionRequired,
    required this.isActive,
    required this.attributes,
    required this.images,

    // Additional fields with defaults (0 for no data)
    this.price = 0.0,
    this.discountPrice = 0.0,
    this.stock = 0,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.isFavorite = false,

    // Optional fields
    this.brand = '',
    this.manufacturer = '',
    this.form = '',
    this.packSize = '',
    this.benefits = const [],
    this.usage = const [],

    // Vendor products
    this.vendorProducts = const [],

    // NEW FIELDS
    required this.mrpPrice,
    required this.discountMin,
    required this.discountMax,
    required this.discountPercent,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Parse nested objects
    final company = Company.fromJson(json['company']);
    final category = Category.fromJson(json['category']);
    final subCategory = SubCategory.fromJson(json['sub_category']);
    final saltComposition = SaltComposition.fromJson(json['salt_composition']);
    final unit = Unit.fromJson(json['unit']);

    // Parse images
    final List<dynamic> imagesData = json['images'] ?? [];
    final images = imagesData.map((img) => img.toString()).toList();

    // Parse vendor products - this is the REAL data
    final List<dynamic> vendorProductsData = json['vendor_products'] ?? [];
    final vendorProducts = vendorProductsData
        .map((vp) => VendorProduct.fromJson(vp as Map<String, dynamic>))
        .where((vp) => vp.isAvailable)
        .toList();

    // Get ID safely
    final id = (json['id'] as num?)?.toInt() ?? 0;

    // Get brand from company name
    final brandName = company.name.split(' ').first;

    // Set values from vendor products if available, otherwise 0
    double actualPrice = 0.0;
    double actualDiscountPrice = 0.0;
    int actualStock = 0;

    if (vendorProducts.isNotEmpty) {
      // Find the cheapest available vendor product
      final availableVendors = vendorProducts.where((vp) => vp.hasValidPrice).toList();

      if (availableVendors.isNotEmpty) {
        final cheapestVendor = availableVendors.reduce(
                (a, b) => a.sellingPrice < b.sellingPrice ? a : b
        );

        actualPrice = cheapestVendor.sellingPrice;
        actualDiscountPrice = cheapestVendor.mrp > cheapestVendor.sellingPrice
            ? cheapestVendor.mrp
            : 0.0;
        actualStock = vendorProducts.fold(0, (sum, vp) => sum + vp.stockQuantity);
      }
    }

    return Product(
      id: id,
      name: json['name']?.toString() ?? 'Unknown Product',
      genericName: json['generic_name']?.toString() ?? '',
      company: company,
      category: category,
      subCategory: subCategory,
      saltComposition: saltComposition,
      power: json['power']?.toString() ?? 'NA',
      unit: unit,
      hsnCode: json['hsn_code']?.toString() ?? '',
      gstPercentage: double.tryParse(json['gst_percentage']?.toString() ?? '0') ?? 0.0,
      description: json['description']?.toString() ?? 'No description available',
      sideEffects: json['side_effects']?.toString() ?? 'No side effects information',
      storageInstructions: json['storage_instructions']?.toString() ?? 'Store in cool dry place',
      isPrescriptionRequired: (json['is_prescription_required'] as num?)?.toInt() == 1,
      isActive: (json['is_active'] as num?)?.toInt() == 1,
      attributes: json['attributes']?.toString() ?? 'NA',
      images: images,

      // Use actual values from vendor products (0 if no data)
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      discountPrice: actualDiscountPrice,
      stock: actualStock,
      rating: 0.0, // API doesn't provide rating
      ratingCount: 0, // API doesn't provide rating count

      // Optional fields
      brand: brandName,
      manufacturer: company.name,
      form: unit.name,
      packSize: vendorProducts.isNotEmpty && vendorProducts.first.packSize != null
          ? vendorProducts.first.packSize!
          : 'Standard Pack',
      benefits: [],
      usage: json['description']?.toString() != null && json['description'].toString().isNotEmpty
          ? [json['description'].toString()]
          : [],

      // Store vendor products
      vendorProducts: vendorProducts,

      // NEW FIELDS
      mrpPrice: json['mrp_price']?.toString() ?? '0',
      discountMin: (json['discount_min'] as num?)?.toInt() ?? 0,
      discountMax: (json['discount_max'] as num?)?.toInt() ?? 0,
      discountPercent: (json['discount_percent'] as num?)?.toInt() ?? 0,
    );
  }

  // Helper methods using vendor data

  bool get hasVendors => vendorProducts.isNotEmpty;

  bool get hasValidPrice => vendorProducts.any((vp) => vp.hasValidPrice);

  bool get isAvailable => vendorProducts.any((vp) => vp.isInStock);

  VendorProduct? get cheapestVendor {
    if (vendorProducts.isEmpty) return null;
    final available = vendorProducts.where((vp) => vp.hasValidPrice).toList();
    if (available.isEmpty) return null;
    return available.reduce((a, b) => a.sellingPrice < b.sellingPrice ? a : b);
  }

  String get priceDisplay {
    if (!hasValidPrice) {
      return 'Price not available';
    }

    final cheapest = cheapestVendor;
    if (cheapest == null) return 'Price not available';

    // Check if there are multiple vendors with different prices
    final uniquePrices = vendorProducts
        .where((vp) => vp.hasValidPrice)
        .map((vp) => vp.sellingPrice)
        .toSet()
        .length;

    if (uniquePrices > 1) {
      final highestPrice = vendorProducts
          .where((vp) => vp.hasValidPrice)
          .map((vp) => vp.sellingPrice)
          .reduce((a, b) => a > b ? a : b);

      return '₹${cheapest.sellingPrice.toStringAsFixed(2)} - ₹${highestPrice.toStringAsFixed(2)}';
    }

    return '₹${cheapest.sellingPrice.toStringAsFixed(2)}';
  }

  String get mrpDisplay {
    if (!hasValidPrice) return '';
    final cheapest = cheapestVendor;
    if (cheapest == null) return '';
    return 'MRP: ₹${cheapest.mrp.toStringAsFixed(2)}';
  }

  double? get discountPercentage {
    if (!hasValidPrice) return null;
    final cheapest = cheapestVendor;
    if (cheapest == null) return null;
    return cheapest.discountPercent;
  }

  int get totalStock {
    return vendorProducts.fold(0, (sum, vp) => sum + vp.stockQuantity);
  }

  bool get isOutOfStock {
    if (!hasVendors) return true;
    return !vendorProducts.any((vp) => vp.isInStock);
  }

  bool get isLowStock {
    if (!hasVendors) return false;
    final totalStock = vendorProducts.fold(0, (sum, vp) => sum + vp.stockQuantity);
    return totalStock > 0 && totalStock <= 10;
  }

  bool get hasDiscount {
    if (!hasValidPrice) return false;
    final cheapest = cheapestVendor;
    if (cheapest == null) return false;
    return cheapest.mrp > cheapest.sellingPrice;
  }

  double get discountPercentValue {
    if (!hasValidPrice) return 0.0;
    final cheapest = cheapestVendor;
    if (cheapest == null) return 0.0;
    return cheapest.discountPercent;
  }

  String get stockDisplay {
    if (!hasVendors) return 'No vendors';
    if (isOutOfStock) return 'Out of Stock';
    if (isLowStock) return 'Low Stock';
    return 'In Stock';
  }

  String get prescriptionType => isPrescriptionRequired ? 'Rx' : 'OTC';

  // For filtering
  String get categoryName => category.name;
  String get companyName => company.name;

  // Get available vendors for this product
  List<VendorProduct> get availableVendors {
    return vendorProducts.where((vp) => vp.isAvailable && vp.isInStock).toList();
  }

  Product copyWith({
    int? id,
    String? name,
    String? genericName,
    Company? company,
    Category? category,
    SubCategory? subCategory,
    SaltComposition? saltComposition,
    String? power,
    Unit? unit,
    String? hsnCode,
    double? gstPercentage,
    String? description,
    String? sideEffects,
    String? storageInstructions,
    bool? isPrescriptionRequired,
    bool? isActive,
    String? attributes,
    List<String>? images,
    double? price,
    double? discountPrice,
    int? stock,
    double? rating,
    int? ratingCount,
    bool? isFavorite,
    String? brand,
    String? manufacturer,
    String? form,
    String? packSize,
    List<String>? benefits,
    List<String>? usage,
    List<VendorProduct>? vendorProducts,
    String? mrpPrice,
    int? discountMin,
    int? discountMax,
    int? discountPercent,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      genericName: genericName ?? this.genericName,
      company: company ?? this.company,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      saltComposition: saltComposition ?? this.saltComposition,
      power: power ?? this.power,
      unit: unit ?? this.unit,
      hsnCode: hsnCode ?? this.hsnCode,
      gstPercentage: gstPercentage ?? this.gstPercentage,
      description: description ?? this.description,
      sideEffects: sideEffects ?? this.sideEffects,
      storageInstructions: storageInstructions ?? this.storageInstructions,
      isPrescriptionRequired: isPrescriptionRequired ?? this.isPrescriptionRequired,
      isActive: isActive ?? this.isActive,
      attributes: attributes ?? this.attributes,
      images: images ?? this.images,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      stock: stock ?? this.stock,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      isFavorite: isFavorite ?? this.isFavorite,
      brand: brand ?? this.brand,
      manufacturer: manufacturer ?? this.manufacturer,
      form: form ?? this.form,
      packSize: packSize ?? this.packSize,
      benefits: benefits ?? this.benefits,
      usage: usage ?? this.usage,
      vendorProducts: vendorProducts ?? this.vendorProducts,
      mrpPrice: mrpPrice ?? this.mrpPrice,
      discountMin: discountMin ?? this.discountMin,
      discountMax: discountMax ?? this.discountMax,
      discountPercent: discountPercent ?? this.discountPercent,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'generic_name': genericName,
      'company': {
        'id': company.id,
        'name': company.name,
      },
      'category': {
        'id': category.id,
        'name': category.name,
      },
      'sub_category': {
        'id': subCategory.id,
        'name': subCategory.name,
      },
      'salt_composition': {
        'id': saltComposition.id,
        'name': saltComposition.name,
      },
      'power': power,
      'unit': {
        'id': unit.id,
        'name': unit.name,
      },
      'hsn_code': hsnCode,
      'gst_percentage': gstPercentage,
      'description': description,
      'side_effects': sideEffects,
      'storage_instructions': storageInstructions,
      'is_prescription_required': isPrescriptionRequired ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'attributes': attributes,
      'images': images,
      'price': price,
      'discount_price': discountPrice,
      'stock': stock,
      'rating': rating,
      'rating_count': ratingCount,
      'is_favorite': isFavorite,
      'brand': brand,
      'manufacturer': manufacturer,
      'form': form,
      'pack_size': packSize,
      'benefits': benefits,
      'usage': usage,
      'vendor_products': vendorProducts.map((vp) => {
        'id': vp.id,
        'vendor_id': vp.vendorId,
        'selling_price': vp.sellingPrice,
        'mrp': vp.mrp,
        'stock_quantity': vp.stockQuantity,
        'is_available': vp.isAvailable ? 1 : 0,
      }).toList(),
      'mrp_price': mrpPrice,
      'discount_min': discountMin,
      'discount_max': discountMax,
      'discount_percent': discountPercent,
    };
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $priceDisplay, vendors: ${vendorProducts.length})';
  }
}