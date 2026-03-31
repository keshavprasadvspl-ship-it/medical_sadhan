// notification_model.dart
class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String time;
  final String type;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      time: json['time'] ?? '',
      type: json['type'] ?? 'general',
    );
  }
}