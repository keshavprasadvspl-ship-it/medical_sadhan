// lib/app/data/models/notification_model.dart

import 'package:flutter/material.dart';

enum NotificationType {
  test,
  order,
  promotion,
  delivery,
  payment,
  prescription,
  system,
  security,
  reminder,
}

enum NotificationPriority {
  low,
  medium,
  high,
  urgent,
}

class NotificationModel {
  final int id;
  final int userId;
  final String type;
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime? readAt;
  final String? channel;
  final String sentStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  bool isArchived; // Local property for archive functionality

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.data,
    required this.isRead,
    this.readAt,
    this.channel,
    required this.sentStatus,
    required this.createdAt,
    required this.updatedAt,
    this.isArchived = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      type: json['type']?.toString() ?? 'test',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map ? Map<String, dynamic>.from(json['data']) : null,
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      channel: json['channel']?.toString(),
      sentStatus: json['sent_status']?.toString() ?? 'sent',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Helper getters for UI
  NotificationType get notificationType {
    switch (type.toLowerCase()) {
      case 'order':
        return NotificationType.order;
      case 'promotion':
        return NotificationType.promotion;
      case 'delivery':
        return NotificationType.delivery;
      case 'payment':
        return NotificationType.payment;
      case 'prescription':
        return NotificationType.prescription;
      case 'system':
        return NotificationType.system;
      case 'security':
        return NotificationType.security;
      case 'reminder':
        return NotificationType.reminder;
      default:
        return NotificationType.test;
    }
  }

  NotificationPriority get priority {
    // You can determine priority based on type or data
    if (type == 'urgent' || type == 'security') return NotificationPriority.urgent;
    if (type == 'payment' || type == 'order') return NotificationPriority.high;
    if (type == 'delivery' || type == 'prescription') return NotificationPriority.medium;
    return NotificationPriority.low;
  }

  String get typeLabel {
    return type[0].toUpperCase() + type.substring(1);
  }

  Color get typeColor {
    switch (notificationType) {
      case NotificationType.order:
        return Colors.blue;
      case NotificationType.promotion:
        return Colors.purple;
      case NotificationType.delivery:
        return Colors.green;
      case NotificationType.payment:
        return Colors.orange;
      case NotificationType.prescription:
        return Colors.teal;
      case NotificationType.system:
        return Colors.grey;
      case NotificationType.security:
        return Colors.red;
      case NotificationType.reminder:
        return Colors.amber;
      default:
        return Colors.blueGrey;
    }
  }

  IconData get typeIcon {
    switch (notificationType) {
      case NotificationType.order:
        return Icons.shopping_bag;
      case NotificationType.promotion:
        return Icons.local_offer;
      case NotificationType.delivery:
        return Icons.local_shipping;
      case NotificationType.payment:
        return Icons.payment;
      case NotificationType.prescription:
        return Icons.medical_services;
      case NotificationType.system:
        return Icons.settings;
      case NotificationType.security:
        return Icons.security;
      case NotificationType.reminder:
        return Icons.notifications;
      default:
        return Icons.notifications;
    }
  }

  Color get priorityColor {
    switch (priority) {
      case NotificationPriority.low:
        return Colors.grey;
      case NotificationPriority.medium:
        return Colors.blue;
      case NotificationPriority.high:
        return Colors.orange;
      case NotificationPriority.urgent:
        return Colors.red;
    }
  }

  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  String get detailedTime {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year} at ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  NotificationModel copyWith({
    bool? isRead,
    bool? isArchived,
  }) {
    return NotificationModel(
      id: id,
      userId: userId,
      type: type,
      title: title,
      message: message,
      data: data,
      isRead: isRead ?? this.isRead,
      readAt: isRead == true ? DateTime.now() : readAt,
      channel: channel,
      sentStatus: sentStatus,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}