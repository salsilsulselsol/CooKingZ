// File: lib/models/notification_model.dart
import 'dart:convert';

AppNotification appNotificationFromJson(String str) => AppNotification.fromJson(json.decode(str));
String appNotificationToJson(AppNotification data) => json.encode(data.toJson());

class AppNotification { // <<< NAMA KELAS DIUBAH DARI NotificationItem MENJADI AppNotification
  final int id;
  final int userId;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({ // <<< SESUAIKAN CONSTRUCTOR
    required this.id,
    required this.userId,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification( // <<< SESUAIKAN FACTORY CONSTRUCTOR
      id: json['id'] as int,
      userId: json['user_id'] as int,
      message: json['message'] as String,
      isRead: (json['is_read'] as int) == 1, 
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "message": message,
        "is_read": isRead ? 1 : 0,
        "created_at": createdAt.toIso8601String(),
      };
}