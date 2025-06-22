// File: lib/view/home/notification_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pastikan intl sudah ditambahkan di pubspec.yaml
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../component/notification_widget.dart'; // Pastikan path ini benar
import '../../view/component/header_back.dart'; // Pastikan path ini benar
import '../../models/notification_model.dart'; // Pastikan path ini benar dan modelnya AppNotification
import '../../theme/theme.dart'; // Pastikan path ini benar jika ingin menggunakan AppTheme.primaryColor

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isLoggedIn = false; // State untuk melacak status login

  final String _baseUrl =
      'http://localhost:3000'; // <<< GANTI DENGAN IP BACKEND ANDA

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'id'; // Set locale default untuk DateFormat
    _checkAndFetchNotifications(); // Panggil fungsi yang lebih kompleks
  }

  Future<void> _checkAndFetchNotifications() async {
    print('DEBUG NOTIF: Mulai _checkAndFetchNotifications...');
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
      _isLoggedIn = false; // Reset status login sebelum memeriksa
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userId = prefs.getInt('user_id'); // Ambil juga user ID

    // Logika penentuan status login
    if (token == null || userId == null || userId == 0) {
      // Jika tidak ada token atau user ID tidak valid/0, anggap belum login
      setState(() {
        _isLoggedIn = false; // Set status belum login
        _isLoading = false; // Hentikan loading
        // Tidak perlu set _hasError di sini karena kita akan menampilkan UI yang berbeda
      });
      print(
        'DEBUG NOTIF: Pengguna belum login atau token tidak valid. Menampilkan UI non-login.',
      );
      return; // Hentikan proses fetching karena tidak login
    }

    // Jika sudah login (ada token dan userId valid), set status dan lanjutkan fetching
    setState(() {
      _isLoggedIn = true; // Set status sudah login
    });
    await _fetchNotifications(
      token,
    ); // Lanjutkan fetching dengan token yang valid
  }

  Future<void> _fetchNotifications(String token) async {
    print('DEBUG NOTIF: Mulai fetch notifikasi dengan token...');
    try {
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
      print(
        'DEBUG NOTIF: Response Body API: ${response.body.length > 500 ? response.body.substring(0, 500) + '...' : response.body}',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // Pastikan 'data' ada dan merupakan List
        final List<dynamic> notificationList =
            responseData['data'] is List ? responseData['data'] : [];

        setState(() {
          _notifications =
              notificationList
                  .map((jsonItem) => AppNotification.fromJson(jsonItem))
                  .toList();
          _isLoading = false;
          _hasError = false; // Pastikan ini diset false jika berhasil
        });
        print(
          'DEBUG NOTIF: Notifikasi berhasil diparsing. Jumlah: ${_notifications.length}',
        );
      } else {
        setState(() {
          _hasError = true;
          // Gunakan response.reasonPhrase atau response.body sebagai fallback
          _errorMessage =
              'Gagal memuat notifikasi: ${response.statusCode} ${response.reasonPhrase ?? response.body}';
          _isLoading = false;
        });
        print(
          '[ERROR] NOTIF: Gagal memuat notifikasi: ${response.statusCode} ${response.body}',
        );
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
    print(
      'DEBUG NOTIF: Menandai notifikasi ID: $notificationId sebagai sudah dibaca.',
    );
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        print(
          'DEBUG NOTIF: Tidak ada token untuk menandai notifikasi sebagai sudah dibaca.',
        );
        return; // Tidak bisa menandai jika tidak login
      }

      final uri = Uri.parse(
        '$_baseUrl/api/utilities/notifications/$notificationId/read',
      );
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print(
          'DEBUG: Notifikasi $notificationId berhasil ditandai sudah dibaca.',
        );
        setState(() {
          _notifications =
              _notifications.map((notif) {
                // Perbarui objek notifikasi menjadi isRead: true
                return notif.id == notificationId
                    ? AppNotification(
                      id: notif.id,
                      userId: notif.userId,
                      message: notif.message,
                      isRead: true,
                      createdAt: notif.createdAt,
                    )
                    : notif;
              }).toList();
        });
      } else {
        print(
          '[ERROR] NOTIF: Gagal menandai notifikasi $notificationId sebagai sudah dibaca: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      print(
        '[EXCEPTION] NOTIF: Error menandai notifikasi sebagai sudah dibaca: $e',
      );
    }
  }

  Map<String, List<AppNotification>> _groupNotificationsByDay(
    List<AppNotification> notifications,
  ) {
    Map<String, List<AppNotification>> grouped = {};
    for (var notification in notifications) {
      // Pastikan createdAt tidak null sebelum format
      if (notification.createdAt != null) {
        String day = DateFormat('yyyy-MM-dd').format(notification.createdAt!);
        if (!grouped.containsKey(day)) {
          grouped[day] = [];
        }
        grouped[day]!.add(notification);
      }
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
      // Menggunakan locale 'id' yang sudah diatur di initState
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(dateTime);
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    print(
      'DEBUG NOTIF: build method dipanggil. isLoading: $_isLoading, hasError: $_hasError, isLoggedIn: $_isLoggedIn, notifications.length: ${_notifications.length}',
    );

    // Tentukan konten utama berdasarkan status _isLoading dan _isLoggedIn
    Widget mainContent;
    if (_isLoading) {
      mainContent = const Center(child: CircularProgressIndicator());
    } else if (!_isLoggedIn) {
      // Jika belum login, tampilkan UI login/daftar
      mainContent = _buildLoggedOutContent(context);
    } else if (_hasError) {
      // Jika login tapi ada error saat fetching notifikasi
      mainContent = Center(
        child: Text(
          _errorMessage,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    } else if (_notifications.isEmpty) {
      // Jika sudah login dan tidak ada notifikasi
      mainContent = Center(
        child: Text(
          'Tidak ada notifikasi.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    } else {
      // Jika sudah login dan ada notifikasi
      final Map<String, List<AppNotification>> groupedNotifications =
          _groupNotificationsByDay(_notifications);
      final List<String> sortedDayKeys =
          groupedNotifications.keys.toList()
            ..sort((a, b) => b.compareTo(a)); // Urutkan dari terbaru

      mainContent = ListView.builder(
        itemCount: sortedDayKeys.length,
        itemBuilder: (context, index) {
          String dayKey = sortedDayKeys[index];
          List<AppNotification> notificationsForDay =
              groupedNotifications[dayKey]!;

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
                      notification:
                          notification, // Meneruskan objek model AppNotification
                      // onMarkAsRead akan null jika notifikasi sudah dibaca
                      onMarkAsRead:
                          notification.isRead
                              ? null
                              : () => _markNotificationAsRead(notification.id),
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        },
      );
    }

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
              child:
                  mainContent, // Tampilkan konten utama yang sudah ditentukan
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoggedOutContent(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'images/logo.png', // Pastikan path ini benar
            width: 150, // Sesuaikan ukuran logo
            height: 150,
          ),
          const SizedBox(height: 32), // Spasi antara logo dan tombol
          // --- START MODIFIKASI UNTUK TOMBOL BERDAMPINGAN ---
          Row(
            mainAxisAlignment:
                MainAxisAlignment.center, // Pusatkan tombol secara horizontal
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login').then((_) {
                    _checkAndFetchNotifications();
                  });
                },
                style: TextButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ), // Kurangi padding horizontal jika perlu
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Login'),
              ),
              const SizedBox(width: 16), // Spasi horizontal antar tombol
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register').then((_) {
                    _checkAndFetchNotifications();
                  });
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ), // Sesuaikan padding agar terlihat serasi
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Daftar'),
              ),
            ],
          ),
          // --- END MODIFIKASI UNTUK TOMBOL BERDAMPINGAN ---
        ],
      ),
    );
  }
}
