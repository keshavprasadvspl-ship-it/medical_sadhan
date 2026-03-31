// lib/app/data/models/address_model.dart
class AddressModel {
  final int id;
  final int buyerId;
  final String addressType;
  final String addressLabel;
  final String addressLine1;
  final String? addressLine2;
  final String? landmark;
  final String city;
  final String state;
  final String pincode;
  final String country;
  final String contactPerson;
  final String contactPhone;
  final String? contactEmail;
  final bool isDefaultShipping;
  final bool isDefaultBilling;
  final bool isActive;
  final String? locationLat;
  final String? locationLng;
  final DateTime createdAt;
  final DateTime updatedAt;

  AddressModel({
    required this.id,
    required this.buyerId,
    required this.addressType,
    required this.addressLabel,
    required this.addressLine1,
    this.addressLine2,
    this.landmark,
    required this.city,
    required this.state,
    required this.pincode,
    required this.country,
    required this.contactPerson,
    required this.contactPhone,
    this.contactEmail,
    required this.isDefaultShipping,
    required this.isDefaultBilling,
    required this.isActive,
    this.locationLat,
    this.locationLng,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] ?? 0,
      buyerId: json['buyer_id'] ?? 0,
      addressType: json['address_type'] ?? 'shipping',
      addressLabel: json['address_label'] ?? 'Home',
      addressLine1: json['address_line1'] ?? '',
      addressLine2: json['address_line2'],
      landmark: json['landmark'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
      country: json['country'] ?? 'India',
      contactPerson: json['contact_person'] ?? '',
      contactPhone: json['contact_phone'] ?? '',
      contactEmail: json['contact_email'],
      isDefaultShipping: json['is_default_shipping'] ?? false,
      isDefaultBilling: json['is_default_billing'] ?? false,
      isActive: json['is_active'] ?? true,
      locationLat: json['location_lat'],
      locationLng: json['location_lng'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address_type': addressType,
      'address_label': addressLabel,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'landmark': landmark,
      'city': city,
      'state': state,
      'pincode': pincode,
      'country': country,
      'contact_person': contactPerson,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
      'is_default_shipping': isDefaultShipping,
      'is_default_billing': isDefaultBilling,
      'location_lat': locationLat,
      'location_lng': locationLng,
    };
  }

  String get fullAddress {
    final buffer = StringBuffer();
    buffer.write(addressLine1);
    if (addressLine2 != null && addressLine2!.isNotEmpty) {
      buffer.write(', $addressLine2');
    }
    if (landmark != null && landmark!.isNotEmpty) {
      buffer.write(', Near $landmark');
    }
    buffer.write(', $city, $state - $pincode');
    return buffer.toString();
  }
}