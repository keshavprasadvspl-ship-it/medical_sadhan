// models/related_product_model.dart

class RelatedProduct {
  final int id;
  final String name;
  final String genericName;
  final double price;
  final Company company;
  final Category? category;
  final String? image;
  final bool isPrescriptionRequired;
  final int relevanceScore;

  RelatedProduct({
    required this.id,
    required this.name,
    required this.genericName,
    required this.price,
    required this.company,
    this.category,
    this.image,
    required this.isPrescriptionRequired,
    required this.relevanceScore,
  });

  factory RelatedProduct.fromJson(Map<String, dynamic> json) {
    return RelatedProduct(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      genericName: json['generic_name'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      company: Company.fromJson(json['company'] ?? {}),
      category: json['category'] != null
          ? Category.fromJson(json['category'])
          : null,
      image: json['image'],
      isPrescriptionRequired: json['is_prescription_required'] ?? false,
      relevanceScore: json['relevance_score'] ?? 1,
    );
  }

  // Get formatted price
  String get formattedPrice => '₹${price.toStringAsFixed(2)}';

  // Get image URL
  String get imageUrl {
    if (image != null && image!.isNotEmpty) {
      return image!;
    }
    return '';
  }
}

class Company {
  final int id;
  final String name;

  Company({required this.id, required this.name});

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}