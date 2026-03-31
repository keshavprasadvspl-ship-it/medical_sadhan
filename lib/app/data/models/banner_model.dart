// lib/app/data/models/banner_model.dart

import 'dart:ui';

import '../providers/api_endpoints.dart';

class BannerModel {
  final int id;
  final String title;
  final String? subtitle;
  final String? description;
  final String imageUrl;
  final String? buttonText;
  final String? buttonAction;
  final String? backgroundColor;
  final String? textColor;
  final int displayOrder;
  final bool isActive;

  BannerModel({
    required this.id,
    required this.title,
    this.subtitle,
    this.description,
    required this.imageUrl,
    this.buttonText,
    this.buttonAction,
    this.backgroundColor,
    this.textColor,
    required this.displayOrder,
    required this.isActive,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] is String ? int.parse(json['id']) : (json['id'] as int? ?? 0),
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
      description: json['description'] as String?,
      imageUrl: json['image'] as String? ?? json['image_url'] as String? ?? '',
      buttonText: json['button_text'] as String?,
      buttonAction: json['button_action'] as String?,
      backgroundColor: json['background_color'] as String?,
      textColor: json['text_color'] as String?,
      displayOrder: json['display_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  // Get full image URL
  String get fullImageUrl {
    if (imageUrl.isEmpty) return '';

    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }

    // Remove leading slash if present
    String path = imageUrl;
    if (path.startsWith('/')) {
      path = path.substring(1);
    }

    return '${ApiEndpoints.imgUrl}/$path';
  }

  // Parse background color
  Color? get backgroundParsedColor {
    if (backgroundColor == null) return null;
    try {
      return Color(int.parse(backgroundColor!.replaceFirst('#', '0xff')));
    } catch (e) {
      return null;
    }
  }

  // Parse text color
  Color? get textParsedColor {
    if (textColor == null) return null;
    try {
      return Color(int.parse(textColor!.replaceFirst('#', '0xff')));
    } catch (e) {
      return null;
    }
  }
}