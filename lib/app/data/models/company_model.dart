// lib/app/data/models/company_model.dart

import '../providers/api_endpoints.dart';

class CategoryModel {
  final int id;
  final String name;

  CategoryModel({
    required this.id,
    required this.name,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class CompanyModel {
  final int id;
  final String name;
  final String? image;
  final bool isActive;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<CategoryModel> categories;  // Make sure this is included

  CompanyModel({
    required this.id,
    required this.name,
    this.image,
    required this.isActive,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.categories = const [],
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    // Handle id that might be String or int
    int parsedId;
    if (json['id'] is String) {
      parsedId = int.parse(json['id'] as String);
    } else if (json['id'] is int) {
      parsedId = json['id'] as int;
    } else {
      parsedId = 0;
    }

    // Parse categories - IMPORTANT: Make sure this is being called
    List<CategoryModel> categoriesList = [];
    if (json['categories'] != null && json['categories'] is List) {
      print("Parsing ${(json['categories'] as List).length} categories for company ${json['name']}");
      categoriesList = (json['categories'] as List)
          .map((category) => CategoryModel.fromJson(category))
          .toList();
      print("categorie found for company ${json['name']}");
    } else {
      // print("No categories found for company ${json['name']}");
    }

    return CompanyModel(
      id: parsedId,
      name: json['name'] as String? ?? '',
      image: json['image'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      description: json['description'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      categories: categoriesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'is_active': isActive,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'categories': categories.map((e) => e.toJson()).toList(),
    };
  }

  // Get image URL
  String get imageUrl {
    if (image == null || image!.isEmpty) {
      return '';
    }

    if (image!.startsWith('http://') || image!.startsWith('https://')) {
      return image!;
    }

    String imagePath = image!;
    if (imagePath.startsWith('/')) {
      imagePath = imagePath.substring(1);
    }

    return '${ApiEndpoints.imgUrl}/$imagePath';
  }

  // Helper property for backward compatibility
  String? get logo => image;
}