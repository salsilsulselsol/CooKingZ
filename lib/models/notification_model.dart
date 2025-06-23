// File: lib/models/notification_model.dart

import 'dart:convert';

// Fungsi helper untuk konversi dari/ke JSON String (opsional, tergantung penggunaan di luar model)
AppNotification appNotificationFromJson(String str) => AppNotification.fromJson(json.decode(str));
String appNotificationToJson(AppNotification data) => json.encode(data.toJson());

class AppNotification {
  final int id;
  final int userId;
  final String title;   // <<< TAMBAHKAN INI
  final String message;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,   // <<< TAMBAHKAN INI
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      title: json['title'] as String,   // <<< TAMBAHKAN INI
      message: json['message'] as String,
      isRead: (json['is_read'] as int) == 1, // Konversi int (0/1) dari DB ke bool
      createdAt: DateTime.parse(json['created_at']), // Pastikan format tanggal dari DB adalah ISO 8601
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "title": title,   // <<< TAMBAHKAN INI
        "message": message,
        "is_read": isRead ? 1 : 0, // Konversi bool ke int (0/1) untuk DB
        "created_at": createdAt.toIso8601String(),
      };
}