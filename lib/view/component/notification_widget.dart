// File: lib/view/component/notification_widget.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import '../../theme/theme.dart';
import '../../models/notification_model.dart'; // <<< IMPOR MODEL YANG BARU (AppNotification)

class NotificationItem extends StatelessWidget { // Ini adalah widget NotificationItem
  final AppNotification notification; // <<< Menerima objek model AppNotification
  final VoidCallback? onMarkAsRead; 

  const NotificationItem({
    Key? key,
    required this.notification,
    this.onMarkAsRead,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String iconAsset = 'images/notifikasi_besar.png'; 
    if (notification.message.toLowerCase().contains('review baru')) {
      iconAsset = 'images/bintang_besar.png'; 
    } else if (notification.message.toLowerCase().contains('mengikuti')) {
      iconAsset = 'images/person_add.png'; 
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.grey[100] : Colors.white, 
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            iconAsset,
            width: 24,
            height: 24,
            color: notification.isRead ? Colors.grey : AppTheme.primaryColor,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.notifications, color: notification.isRead ? Colors.grey : AppTheme.primaryColor, size: 24);
            },
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.message, // Menggunakan properti dari objek model
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _formatTimeAgo(notification.createdAt), // Menggunakan properti dari objek model
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (!notification.isRead && onMarkAsRead != null)
            IconButton(
              icon: Icon(Icons.check_circle_outline, color: AppTheme.primaryColor),
              onPressed: onMarkAsRead, 
            ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final Duration diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) { return 'Baru Saja'; } else if (diff.inHours < 1) { return '${diff.inMinutes} Menit Lalu'; } else if (diff.inDays < 1) { return '${diff.inHours} Jam Lalu'; } else if (diff.inDays < 7) { return '${diff.inDays} Hari Lalu'; } else { return '${diff.inDays ~/ 7} Minggu Lalu'; }
  }
}