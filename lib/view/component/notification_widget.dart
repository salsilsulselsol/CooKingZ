// File: lib/view/component/notification_widget.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pastikan intl sudah ditambahkan di pubspec.yaml
import '../../theme/theme.dart';
import '../../models/notification_model.dart'; // Mengimpor objek model AppNotification

class NotificationItem extends StatelessWidget {
  final AppNotification notification; // Menerima objek model AppNotification
  final VoidCallback? onMarkAsRead; // Callback untuk menandai sudah dibaca

  const NotificationItem({
    Key? key, // Tetap Key? key seperti di kode Anda
    required this.notification,
    this.onMarkAsRead,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Logika untuk menentukan ikon berdasarkan isi pesan
    String iconAsset = 'images/notifikasi_besar.png'; 
    if (notification.message.toLowerCase().contains('review baru')) {
      iconAsset = 'images/bintang_besar.png'; 
    } else if (notification.message.toLowerCase().contains('mengikuti')) {
      iconAsset = 'images/person_add.png'; 
    }
    // Asumsi: Anda juga bisa menentukan ikon berdasarkan notification.title atau tipe notifikasi lainnya jika ada.

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      // Membungkus Container dengan InkWell untuk membuat seluruh area bisa ditekan
      // Ini juga memberikan efek ripple visual
      child: InkWell( 
        onTap: () {
          // Ketika card ditekan, panggil onMarkAsRead jika notifikasi belum dibaca
          if (!notification.isRead && onMarkAsRead != null) {
            onMarkAsRead!();
          }
          // Opsional: tambahkan navigasi atau aksi lain saat notifikasi ditekan
          // Contoh: Navigator.pushNamed(context, '/detail-notifikasi/${notification.id}');
        },
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), // Pastikan borderRadius cocok
        child: Padding( // Padding di dalam InkWell
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                iconAsset,
                width: 24,
                height: 24,
                color: notification.isRead ? Colors.grey : AppTheme.primaryColor, // Warna ikon berdasarkan isRead
                errorBuilder: (context, error, stackTrace) {
                  // Fallback jika gambar ikon tidak ditemukan
                  return Icon(Icons.notifications, color: notification.isRead ? Colors.grey : AppTheme.primaryColor, size: 24);
                },
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- MENAMPILKAN TITLE NOTIFIKASI DI SINI ---
                    Text(
                      notification.title, // Menggunakan properti 'title' dari objek model
                      style: TextStyle(
                        fontSize: 15, // Ukuran font untuk judul
                        fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold, // Bold jika belum dibaca
                        color: notification.isRead ? Colors.black54 : Colors.black87, // Warna berdasarkan isRead
                      ),
                    ),
                    const SizedBox(height: 4), // Spasi antara judul dan pesan

                    Text(
                      notification.message, // Menggunakan properti 'message' dari objek model
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal, // Pesan tidak perlu bold
                        color: notification.isRead ? Colors.grey : Colors.black54, // Warna berdasarkan isRead
                      ),
                    ),
                    SizedBox(height: 4), // Spasi antara pesan dan waktu

                    Text(
                      _formatDateTime(notification.createdAt), // Memanggil fungsi baru untuk format tanggal/waktu
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              // Tombol centang untuk menandai sudah dibaca, hanya muncul jika belum dibaca
              if (!notification.isRead && onMarkAsRead != null)
                IconButton(
                  icon: Icon(Icons.check_circle_outline, color: AppTheme.primaryColor),
                  onPressed: onMarkAsRead, // Memanggil callback saat tombol ditekan
                  tooltip: 'Tandai sudah dibaca', // Tooltip saat di-hover
                ),
            ],
          ),
        ),
      ),
      // Dekorasi BoxDecoration untuk Container (terpisah dari InkWell agar InkWell punya efek ripple yang benar)
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.grey[100] : Colors.white, // Warna latar belakang card berdasarkan isRead
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
    );
  }

  // Fungsi yang lebih robust untuk memformat tanggal dan waktu
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
    final notificationDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (notificationDate == today) {
      return DateFormat('HH:mm').format(dateTime); // Hanya waktu jika hari ini
    } else if (notificationDate == yesterday) {
      return 'Kemarin, ${DateFormat('HH:mm').format(dateTime)}';
    } else {
      // Untuk tanggal yang lebih lama, tampilkan tanggal lengkap
      return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(dateTime);
    }
  }
}