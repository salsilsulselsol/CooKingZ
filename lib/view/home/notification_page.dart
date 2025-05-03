import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'notification_widget.dart'; // Import widget NotificationItem

class NotificationPage extends StatelessWidget {
  NotificationPage ({super.key}); 
  // Daftar notifikasi dengan data yang sesuai
  final List<Map<String, String>> _notifications = [
    {
      'title': 'Resep Baru Mingguan!',
      'description': 'Temukan resep terbaru kami minggu ini.',
      'time': '2 Menit Lalu',
      'date': DateTime.now().subtract(const Duration(minutes: 2)).toString(),
      'icon': 'images/bintang_besar.png', // Menggunakan bintang_besar.png
    },
    {
      'title': 'Yuk, Masak Sekarang!',
      'description': 'Saatnya menyiapkan makanan sehat untuk hari ini.',
      'time': '35 Menit Lalu',
      'date': DateTime.now().subtract(const Duration(minutes: 35)).toString(),
      'icon': 'images/notifikasi_besar.png', // Menggunakan notifikasi_besar.png
    },
    {
      'title': 'Pembaruan Baru Tersedia',
      'description': 'Peningkatan performa dan perbaikan bug.',
      'time': '25 April 2025',
      'date': DateTime(2025, 4, 25).toString(),
      'icon': 'images/notifikasi_besar.png',
    },
    {
      'title': 'Pengingat',
      'description':
          'Jangan lupa lengkapi profilmu untuk mengakses semua fitur aplikasi.',
      'time': '25 April 2025',
      'date': DateTime(2025, 4, 25).toString(),
      'icon': 'images/bintang_besar.png',
    },
    {
      'title': 'Pemberitahuan Penting',
      'description':
          'Ingat untuk rutin mengganti kata sandi agar akunmu tetap aman.',
      'time': '25 April 2025',
      'date': DateTime(2025, 4, 25).toString(),
      'icon': 'images/notifikasi_besar.png',
    },
    {
      'title': 'Pembaruan Baru Tersedia',
      'description': 'Peningkatan performa dan perbaikan bug.',
      'time': '23 April 2025',
      'date': DateTime(2025, 4, 23).toString(),
      'icon': 'images/notifikasi_besar.png',
    },
  ];

  // Fungsi untuk mengelompokkan notifikasi berdasarkan hari
  Map<String, List<Map<String, String>>> _groupNotificationsByDay() {
    Map<String, List<Map<String, String>>> grouped = {};
    for (var notification in _notifications) {
      // Menggunakan format yang lebih sederhana untuk pengelompokan
      String day =
          DateFormat('yyyy-MM-dd').format(DateTime.parse(notification['date']!));
      if (!grouped.containsKey(day)) {
        grouped[day] = [];
      }
      grouped[day]!.add(notification);
    }
    return grouped;
  }

  // Fungsi untuk mendapatkan teks hari yang diformat
  String _getDayText(String date) {
    DateTime dateTime = DateTime.parse(date);
    DateTime today = DateTime.now();
    DateTime yesterday = today.subtract(const Duration(days: 1));

    if (dateTime.year == today.year &&
        dateTime.month == today.month &&
        dateTime.day == today.day) {
      return 'Hari Ini';
    } else if (dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day) {
      return 'Kemarin';
    } else {
      // Format tanggal ke format yang diinginkan (contoh: Rabu, 25 April 2025)
      return DateFormat('EEEE, dd MMMM', 'id_ID').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mengelompokkan notifikasi
    final Map<String, List<Map<String, String>>> groupedNotifications =
        _groupNotificationsByDay();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notifikasi',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: groupedNotifications.length,
        itemBuilder: (context, index) {
          // Mendapatkan hari dari key
          String day = groupedNotifications.keys.elementAt(index);
          // Mendapatkan daftar notifikasi untuk hari tersebut
          List<Map<String, String>> notificationsForDay =
              groupedNotifications[day]!;

          return Padding(
            padding: const EdgeInsets.symmetric(
                vertical:
                    16.0), // Increased padding, sebelumnya hanya di bottom
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    _getDayText(
                        day), // Menggunakan fungsi _getDayText untuk mendapatkan format hari
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
                //const SizedBox(height: 12), // Removed SizedBox
                // Iterasi dan tampilkan setiap notifikasi untuk hari ini
                ...notificationsForDay.map((notification) {
                  // Adjust icon size here as well, if needed.
                  Map<String, String> modifiedNotification =
                      Map<String, String>.from(notification);
                  if (modifiedNotification['icon'] == 'images/bintang_besar.png') {
                    modifiedNotification['icon'] =
                        'images/bintang_besar.png'; // Keep the same path
                  }
                  return Padding(
                    padding:
                        const EdgeInsets.only(bottom: 8.0), // Add spacing between items
                    child: NotificationItem(
                      notification: modifiedNotification,
                    ),
                  ); // Menggunakan NotificationItem widget
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}