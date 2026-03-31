import 'dart:ui';

class FAQ {
  final String id;
  final String question;
  final String answer;
  final String category;
  final bool isExpanded;

  FAQ({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    this.isExpanded = false,
  });

  FAQ copyWith({
    String? id,
    String? question,
    String? answer,
    String? category,
    bool? isExpanded,
  }) {
    return FAQ(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      category: category ?? this.category,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

class SupportContact {
  final String id;
  final String type;
  final String title;
  final String value;
  final String icon;
  final Color color;

  SupportContact({
    required this.id,
    required this.type,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class SupportTicket {
  final String id;
  final String title;
  final String description;
  final String category;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? resolution;

  SupportTicket({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.resolution,
  });
}