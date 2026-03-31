// lib/app/data/models/company_model.dart

import '../providers/api_endpoints.dart';

class CompanyModel {
  final int id;  // Keep as int
  final String name;
  final String? logo;
  final bool isActive;
  final String? description;
  final String? type;
  final DateTime createdAt;
  final DateTime updatedAt;

  CompanyModel({
    required this.id,
    required this.name,
    this.logo,
    required this.isActive,
    this.description,
    this.type,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    // Handle id that might be String or int
    int parsedId;
    if (json['id'] is String) {
      parsedId = int.parse(json['id'] as String);
    } else if (json['id'] is int) {
      parsedId = json['id'] as int;
    } else {
      parsedId = 0; // Default value if id is missing
    }

    return CompanyModel(
      id: parsedId,
      name: json['name'] as String? ?? '',
      logo: json['logo'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      description: json['description'] as String?,
      type: json['type'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
      'is_active': isActive,
      'description': description,
      'type': type,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Get logo URL
  String get logoUrl {
    if (logo == null || logo!.isEmpty) {
      return '';
    }

    if (logo!.startsWith('http://') || logo!.startsWith('https://')) {
      return logo!;
    }

    // Remove leading slash if present
    String imagePath = logo!;
    if (imagePath.startsWith('/')) {
      imagePath = imagePath.substring(1);
    }

    return '${ApiEndpoints.imgUrl}/$imagePath';
  }
}