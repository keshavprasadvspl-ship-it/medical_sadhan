// lib/app/data/models/medicine_model.dart
class MedicineModel {
  final int id;
  final String name;
  final String genericName;
  final String? description;
  final double price;
  final double gstPercentage;
  final String? companyName;
  final String? categoryName;
  final String? subCategoryName;
  final String? saltComposition;
  final String? power;
  final String? unit;
  final bool isPrescriptionRequired;
  final int? vendorProductsCount;
  final String? hsnCode;
  final Map<String, dynamic>? attributes;

  MedicineModel({
    required this.id,
    required this.name,
    required this.genericName,
    this.description,
    required this.price,
    required this.gstPercentage,
    this.companyName,
    this.categoryName,
    this.subCategoryName,
    this.saltComposition,
    this.power,
    this.unit,
    required this.isPrescriptionRequired,
    this.vendorProductsCount,
    this.hsnCode,
    this.attributes,
  });

  factory MedicineModel.fromSuggestionJson(Map<String, dynamic> json) {
    return MedicineModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      genericName: json['generic_name'] ?? '',
      description: json['description'],
      price: 0.0, // Price not available in suggestions
      gstPercentage: double.tryParse(json['gst_percentage']?.toString() ?? '0') ?? 0,
      companyName: json['company_name'],
      categoryName: json['category_name'],
      subCategoryName: json['sub_category_name'],
      saltComposition: json['salt_composition'],
      power: json['power'],
      unit: json['unit'],
      isPrescriptionRequired: json['is_prescription_required'] == 1,
      vendorProductsCount: json['vendor_products_count'],
      hsnCode: json['hsn_code'],
      attributes: json['attributes'],
    );
  }

  factory MedicineModel.fromSearchJson(Map<String, dynamic> json) {
    return MedicineModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      genericName: json['generic_name'] ?? '',
      description: json['description'],
      price: 0.0, // Price not available in search
      gstPercentage: double.tryParse(json['gst_percentage']?.toString() ?? '0') ?? 0,
      companyName: json['company']?['name'] ?? json['company_name'],
      categoryName: json['category']?['name'] ?? json['category_name'],
      subCategoryName: json['sub_category']?['name'] ?? json['sub_category_name'],
      saltComposition: json['salt_composition']?['name'],
      power: json['power']?['name'],
      unit: json['unit']?['name'],
      isPrescriptionRequired: json['is_prescription_required'] == 1,
      vendorProductsCount: json['active_vendor_products']?.length ?? 0,
      hsnCode: json['hsn_code'],
      attributes: json['attributes'],
    );
  }

  String get prescriptionType => isPrescriptionRequired ? 'Rx' : 'OTC';
  String get displayName => name;
  String get displayManufacturer => companyName ?? 'Generic';
  String get displayCategory => categoryName ?? 'Medicine';

  String get imageUrl {
    // Return a default image or placeholder
    return 'https://cdn-icons-png.flaticon.com/512/3022/3022823.png';
  }
}