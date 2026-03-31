// product_detail_model.dart
import 'dart:convert';

class ProductDetail {
  final int id;
  final String name;
  final String genericName;
  final String? agency;
  final Company company;
  final Category? category;
  final SubCategory? subCategory;
  final SaltComposition? saltComposition;
  final Power power;
  final Unit? unit;
  final String hsnCode;
  final double gstPercentage;
  final String description;
  final String sideEffects;
  final String storageInstructions;
  final bool isPrescriptionRequired;
  final bool isActive;
  final List<dynamic> attributes;
  final List<String> images;
  final double? price;
  final double? mrp;
  final double? discount_min;
  final double? discount_max;
  final double? discountPrice;
  final int stock;
  final double rating;
  final int ratingCount;
  final String? brand;
  final String? manufacturer;
  final bool isFavorite;

  ProductDetail({
    required this.id,
    required this.name,
    required this.genericName,
    required this.agency,
    required this.company,
    this.category,
    this.subCategory,
    this.saltComposition,
    required this.power,
    this.unit,
    required this.hsnCode,
    required this.gstPercentage,
    required this.description,
    required this.sideEffects,
    required this.storageInstructions,
    required this.isPrescriptionRequired,
    required this.isActive,
    required this.attributes,
    required this.images,
    this.price,
    this.mrp,
    this.discount_min,
    this.discount_max,
    this.discountPrice,
    this.stock = 0,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.brand,
    this.manufacturer,
    this.isFavorite = false,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    // Parse company
    Company company;
    if (json['company'] is Map) {
      company = Company.fromJson(json['company']);
    } else if (json['company'] is String) {
      company = Company(id: 0, name: json['company']);
    } else {
      company = Company(id: 0, name: 'Unknown');
    }

    // Parse category
    Category? category;
    if (json['category'] != null && json['category'] is Map) {
      category = Category.fromJson(json['category']);
    } else if (json['category'] is String) {
      category = Category(id: 0, name: json['category']);
    }

    // Parse power
    Power? power;
    if (json['power'] != null && json['power'] is Map) {
      power = Power.fromJson(json['power']);
    } else if (json['power'] is String) {
      power = Power(id: 0, name: json['power']);
    } else {
      power = Power(id: 0, name: '');
    }


    // Parse sub category
    SubCategory? subCategory;
    if (json['sub_category'] != null && json['sub_category'] is Map) {
      subCategory = SubCategory.fromJson(json['sub_category']);
    } else if (json['sub_category'] is String) {
      subCategory = SubCategory(id: 0, name: json['sub_category']);
    }

    // Parse salt composition
    SaltComposition? saltComposition;
    if (json['salt_composition'] != null && json['salt_composition'] is Map) {
      saltComposition = SaltComposition.fromJson(json['salt_composition']);
    } else if (json['salt_composition'] is String) {
      saltComposition = SaltComposition(id: 0, name: json['salt_composition']);
    }

    // Parse unit
    Unit? unit;
    if (json['unit'] != null && json['unit'] is Map) {
      unit = Unit.fromJson(json['unit']);
    } else if (json['unit'] is String) {
      unit = Unit(id: 0, name: json['unit']);
    }

    // Parse images
    List<String> images = [];
    if (json['images'] is List) {
      images = List<String>.from(json['images'].map((x) => x.toString()));
    }

    return ProductDetail(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      genericName: json['generic_name']?.toString() ?? '',
      agency: json['agency']?.toString() ?? '',
      company: company,
      category: category,
      subCategory: subCategory,
      saltComposition: saltComposition,
      power: power ?? Power(id: 0, name: ''),
      unit: unit,
      hsnCode: json['hsn_code']?.toString() ?? '',
      gstPercentage: double.tryParse(json['gst_percentage']?.toString() ?? '0.0') ?? 0.0,
      description: json['description']?.toString() ?? '',
      sideEffects: json['side_effects']?.toString() ?? '',
      storageInstructions: json['storage_instructions']?.toString() ?? '',
      isPrescriptionRequired: json['is_prescription_required'] == true,
      isActive: json['is_active'] == true,
      attributes: json['attributes'] is List ? json['attributes'] : [],
      images: images,
      price: double.tryParse(json['price']?.toString() ?? '0'),
      mrp: double.tryParse(json['mrp_price']?.toString() ?? '0'),
      discount_min: double.tryParse(json['discount_min']?.toString() ?? '0'),
      discount_max: double.tryParse(json['discount_max']?.toString() ?? '0'),
      discountPrice: double.tryParse(json['discount_price']?.toString() ?? '0'),
      stock: json['stock'] is int ? json['stock'] : int.tryParse(json['stock']?.toString() ?? '0') ?? 0,
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      ratingCount: json['rating_count'] is int ? json['rating_count'] : int.tryParse(json['rating_count']?.toString() ?? '0') ?? 0,
      brand: json['brand']?.toString(),
      manufacturer: json['manufacturer']?.toString(),
      isFavorite: json['is_favorite'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'generic_name': genericName,
    'company': company.toJson(),
    'agency': agency,
    'category': category?.toJson(),
    'sub_category': subCategory?.toJson(),
    'salt_composition': saltComposition?.toJson(),
    'power': power?.toJson(),
    'unit': unit?.toJson(),
    'hsn_code': hsnCode,
    'gst_percentage': gstPercentage,
    'description': description,
    'side_effects': sideEffects,
    'storage_instructions': storageInstructions,
    'is_prescription_required': isPrescriptionRequired,
    'is_active': isActive,
    'attributes': attributes,
    'images': images,
    'price': price,
    'mrp_price': mrp,
    'discount_min': discount_min,
    'discount_max': discount_max,
    'discount_price': discountPrice,
    'stock': stock,
    'rating': rating,
    'rating_count': ratingCount,
    'brand': brand,
    'manufacturer': manufacturer,
    'is_favorite': isFavorite,
  };

  // Helper methods
  ProductDetail copyWith({
    int? id,
    String? name,
    String? genericName,
    String? agency,
    Company? company,
    Category? category,
    SubCategory? subCategory,
    SaltComposition? saltComposition,
    Power? power,
    Unit? unit,
    String? hsnCode,
    double? gstPercentage,
    String? description,
    String? sideEffects,
    String? storageInstructions,
    bool? isPrescriptionRequired,
    bool? isActive,
    List<dynamic>? attributes,
    List<String>? images,
    double? price,
    double? mrp,
    double? discount_min,
    double? discount_max,
    double? discountPrice,
    int? stock,
    double? rating,
    int? ratingCount,
    String? brand,
    String? manufacturer,
    bool? isFavorite,
  }) {
    return ProductDetail(
      id: id ?? this.id,
      name: name ?? this.name,
      genericName: genericName ?? this.genericName,
      agency: agency ?? this.agency,
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
      mrp: mrp ?? this.mrp,
      discount_min: discount_min ?? this.discount_min,
      discount_max: discount_max ?? this.discount_max,
      discountPrice: discountPrice ?? this.discountPrice,
      stock: stock ?? this.stock,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      brand: brand ?? this.brand,
      manufacturer: manufacturer ?? this.manufacturer,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  // Helper properties
  bool get hasImages => images.isNotEmpty;
  bool get isOutOfStock => stock <= 0;
  bool get isLowStock => stock > 0 && stock <= 10;
  bool get hasDiscount {
    if (price == null || price == 0) return false;
    if (discountPrice == null || discountPrice == 0) return false;
    return discountPrice! < price!;
  }

  double get discountPercent {
    if (!hasDiscount || price == null || price == 0) return 0;
    return ((price! - discountPrice!) / price!) * 100;
  }

  double get displayPrice => discountPrice ?? price ?? 0;
  double get originalPrice => price ?? 0;
}

// Supporting model classes (if not already defined)
class Company {
  final int id;
  final String name;

  Company({required this.id, required this.name});

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}

class Power {
  final int id;
  final String name;

  Power({required this.id, required this.name});

  factory Power.fromJson(Map<String, dynamic> json) {
    return Power(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}


class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}

class SubCategory {
  final int id;
  final String name;

  SubCategory({required this.id, required this.name});

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}

class SaltComposition {
  final int id;
  final String name;

  SaltComposition({required this.id, required this.name});

  factory SaltComposition.fromJson(Map<String, dynamic> json) {
    return SaltComposition(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}

class Unit {
  final int id;
  final String name;

  Unit({required this.id, required this.name});

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}