// lib/data/models/packing_model.dart
class Packing {
  final int id;
  final String name;
  final int quantity;
  final String unit;

  Packing({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
  });

  factory Packing.fromJson(Map<String, dynamic> json) {
    return Packing(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      unit: json['unit'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
    };
  }
}