// File: lib/view/home/notification_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http; 
import 'dart:convert'; 
import 'package:shared_preferences/shared_preferences.dart'; 

import '../component/notification_widget.dart'; // <<< IMPOR WIDGET NOTIFICATIONITEM
import '../../view/component/header_back.dart'; 
import '../../models/notification_model.dart'; // <<< IMPOR MODEL AppNotification YANG BARU

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<AppNotification> _notifications = []; // <<< Menggunakan AppNotification
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  final String _baseUrl = 'http://192.168.100.44:3000'; // <<< GANTI DENGAN IP BACKEND ANDA

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    print('DEBUG NOTIF: Mulai fetch notifikasi...');
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Anda harus login untuk melihat notifikasi.';
          _isLoading = false;
        });
        print('DEBUG NOTIF: Tidak ada token, tidak bisa fetch notifikasi.');
        return;
      }

      final uri = Uri.parse('$_baseUrl/api/utilities/notifications');
      print('DEBUG NOTIF: Fetching dari URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('DEBUG NOTIF: Status Code API: ${response.statusCode}');
      print('DEBUG NOTIF: Response Body API: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> notificationList = responseData['data'];

        setState(() {
          _notifications = notificationList.map((jsonItem) => AppNotification.fromJson(jsonItem)).toList(); // <<< Menggunakan AppNotification.fromJson
          _isLoading = false;
        });
        print('DEBUG NOTIF: Notifikasi berhasil diparsing. Jumlah: ${_notifications.length}');
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = 'Gagal memuat notifikasi: ${response.statusCode} ${response.reasonPhrase}';
          _isLoading = false;
        });
        print('[ERROR] NOTIF: Gagal memuat notifikasi: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Terjadi kesalahan saat memuat notifikasi: $e';
        _isLoading = false;
      });
      print('[EXCEPTION] NOTIF: Error fetching notifikasi: $e');
    }
  }

  Future<void> _markNotificationAsRead(int notificationId) async {
    print('DEBUG NOTIF: Menandai notifikasi ID: $notificationId sebagai sudah dibaca.');
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) return;

      final uri = Uri.parse('$_baseUrl/api/utilities/notifications/$notificationId/read');
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('DEBUG: Notifikasi $notificationId berhasil ditandai sudah dibaca.');
        setState(() {
          _notifications = _notifications.map((notif) {
            return notif.id == notificationId ? AppNotification( // <<< Menggunakan AppNotification
              id: notif.id,
              userId: notif.userId,
              message: notif.message,
              isRead: true, 
              createdAt: notif.createdAt,
            ) : notif;
          }).toList();
        });
      } else {
        print('[ERROR] NOTIF: Gagal menandai notifikasi $notificationId sebagai sudah dibaca: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('[EXCEPTION] NOTIF: Error menandai notifikasi sebagai sudah dibaca: $e');
    }
  }

  Map<String, List<AppNotification>> _groupNotificationsByDay(List<AppNotification> notifications) { // <<< Menggunakan AppNotification
    Map<String, List<AppNotification>> grouped = {};
    for (var notification in notifications) {
      String day = DateFormat('yyyy-MM-dd').format(notification.createdAt);
      if (!grouped.containsKey(day)) {
        grouped[day] = [];
      }
      grouped[day]!.add(notification);
    }
    return grouped;
  }

  String _getDayText(String dateKey) {
    DateTime dateTime = DateTime.parse(dateKey);
    DateTime today = DateTime.now();
    DateTime yesterday = today.subtract(const Duration(days: 1));

    if (_isSameDay(dateTime, today)) {
      return 'Hari Ini';
    } else if (_isSameDay(dateTime, yesterday)) {
      return 'Kemarin';
    } else {
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(dateTime); // Tambahkan tahun untuk kejelasan
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    print('DEBUG NOTIF: build method dipanggil. isLoading: $_isLoading, hasError: $_hasError, notifications.length: ${_notifications.length}');
    final Map<String, List<AppNotification>> groupedNotifications = _groupNotificationsByDay(_notifications);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            HeaderWidget(
              title: 'Notifikasi',
              onBackPressed: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _hasError
                      ? Center(
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : _notifications.isEmpty
                          ? Center(child: Text('Tidak ada notifikasi.', style: TextStyle(color: Colors.grey)))
                          : ListView.builder(
                              itemCount: groupedNotifications.length,
                              itemBuilder: (context, index) {
                                String dayKey = groupedNotifications.keys.elementAt(index);
                                List<AppNotification> notificationsForDay = groupedNotifications[dayKey]!;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                        child: Text(
                                          _getDayText(dayKey),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      ...notificationsForDay.map((notification) {
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 8.0),
                                          child: NotificationItem(
                                            notification: notification, // Meneruskan objek model AppNotification
                                            onMarkAsRead: notification.isRead ? null : () => _markNotificationAsRead(notification.id),
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}