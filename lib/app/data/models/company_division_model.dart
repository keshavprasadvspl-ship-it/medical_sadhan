// lib/data/models/company_division_model.dart

class CompanyDivisionModel {
  final int id;
  final int companyId;
  final String companyName;
  final String name;
  final String? image;
  final String? imageUrl;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  CompanyDivisionModel({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.name,
    this.image,
    this.imageUrl,
    this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CompanyDivisionModel.fromJson(Map<String, dynamic> json) {
    return CompanyDivisionModel(
      id: json['id'] ?? 0,
      companyId: json['company_id'] ?? 0,
      companyName: json['company_name'] ?? '',
      name: json['name'] ?? '',
      image: json['image'],
      imageUrl: json['image_url'],
      description: json['description'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'company_name': companyName,
      'name': name,
      'image': image,
      'image_url': imageUrl,
      'description': description,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}