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
  int? _loggedInUserId; // Menyimpan ID pengguna yang login dari SharedPreferences

  final String _baseUrl = 'http://localhost:3000'; // <<< GANTI DENGAN IP BACKEND ANDA

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'id'; // Set locale default untuk DateFormat
    _checkAndFetchNotifications(); // Panggil fungsi yang lebih kompleks
  }

  // Fungsi ini akan memeriksa status login dan kemudian memanggil _fetchNotifications
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
    final userIdFromPrefs = prefs.getInt('user_id'); // Ambil user ID dari SharedPreferences

    // Logika penentuan status login: Harus ada token DAN userId yang valid
    if (token == null || token.isEmpty || userIdFromPrefs == null || userIdFromPrefs == 0) {
      setState(() {
        _isLoggedIn = false; // Set status belum login
        _isLoading = false; // Hentikan loading
      });
      print('DEBUG NOTIF: Pengguna belum login atau token/ID tidak valid. Menampilkan UI non-login.');
      return; // Hentikan proses fetching karena tidak login
    }

    // Jika sudah login (ada token dan userId valid), set status dan lanjutkan fetching
    setState(() {
      _isLoggedIn = true; // Set status sudah login
      _loggedInUserId = userIdFromPrefs; // Simpan user ID
    });
    // Panggil _fetchNotifications dengan token DAN user ID yang didapat
    await _fetchNotifications(token, userIdFromPrefs);
  }

  // Fungsi untuk mengambil notifikasi dari API berdasarkan token dan user ID
  Future<void> _fetchNotifications(String token, int userId) async {
    print('DEBUG NOTIF: Mulai fetch notifikasi dengan token dan user ID: $userId...');
    try {
      // Ubah URI untuk menyertakan user ID yang sedang login
      final uri = Uri.parse('$_baseUrl/api/utilities/notifications/$userId');
      print('DEBUG NOTIF: Fetching dari URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('DEBUG NOTIF: Status Code API: ${response.statusCode}');
      // Tampilkan sebagian response body jika terlalu panjang agar tidak memenuhi konsol
      print('DEBUG NOTIF: Response Body API: ${response.body.length > 500 ? response.body.substring(0, 500) + '...' : response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // Pastikan 'data' ada dan merupakan List langsung dari notifikasi (sesuai controller baru)
        final List<dynamic> notificationList = responseData['data'] is List ? responseData['data'] : [];

        setState(() {
          _notifications = notificationList.map((jsonItem) => AppNotification.fromJson(jsonItem)).toList();
          _isLoading = false;
          _hasError = false; // Pastikan ini diset false jika fetching berhasil
        });
        print('DEBUG NOTIF: Notifikasi berhasil diparsing. Jumlah: ${_notifications.length}');
      } else {
        setState(() {
          _hasError = true;
          // Gunakan response.reasonPhrase atau pesan dari body jika tersedia
          _errorMessage = 'Gagal memuat notifikasi: ${response.statusCode} ${response.reasonPhrase ?? (json.decode(response.body)['message'] ?? '')}';
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

  // Fungsi untuk menandai notifikasi sebagai sudah dibaca (PUT request)
  Future<void> _markNotificationAsRead(int notificationId) async {
    print('DEBUG NOTIF: Menandai notifikasi ID: $notificationId sebagai sudah dibaca.');
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        print('DEBUG NOTIF: Tidak ada token, tidak bisa menandai notifikasi sebagai sudah dibaca.');
        return; // Tidak bisa menandai jika tidak login
      }

      // Pastikan URL untuk menandai sudah dibaca juga benar di backend Anda
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
            // Perbarui objek notifikasi di list menjadi isRead: true tanpa memanggil ulang API
            return notif.id == notificationId ? AppNotification(
              id: notif.id,
              userId: notif.userId,
              title: notif.title, // Pastikan model AppNotification memiliki 'title'
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

  // Fungsi untuk mengelompokkan notifikasi berdasarkan hari
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

  // Fungsi untuk mendapatkan teks hari (Hari Ini, Kemarin, atau tanggal lengkap)
  String _getDayText(String dateKey) {
    DateTime dateTime = DateTime.parse(dateKey);
    DateTime today = DateTime.now();
    DateTime yesterday = today.subtract(const Duration(days: 1));

    if (_isSameDay(dateTime, today)) {
      return 'Hari Ini';
    } else if (_isSameDay(dateTime, yesterday)) {
      return 'Kemarin';
    } else {
      // Menggunakan locale 'id_ID' yang sudah diatur di initState untuk format tanggal lokal
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(dateTime); 
    }
  }

  // Fungsi helper untuk memeriksa apakah dua tanggal adalah hari yang sama
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    print('DEBUG NOTIF: build method dipanggil. isLoading: $_isLoading, hasError: $_hasError, isLoggedIn: $_isLoggedIn, notifications.length: ${_notifications.length}');

    // Tentukan konten utama yang akan ditampilkan di dalam Expanded
    Widget mainContent;
    if (_isLoading) {
      mainContent = const Center(child: CircularProgressIndicator());
    } else if (!_isLoggedIn) {
      // Jika belum login, tampilkan UI logo dan tombol login/daftar
      mainContent = _buildLoggedOutContent(context);
    } else if (_hasError) {
      // Jika sudah login tapi ada error saat fetching notifikasi
      mainContent = Center(
        child: Text(
          _errorMessage,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    } else if (_notifications.isEmpty) {
      // Jika sudah login tapi tidak ada notifikasi yang ditemukan
      mainContent = const Center(
        child: Text(
          'Tidak ada notifikasi.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    } else {
      // Jika sudah login dan ada notifikasi, tampilkan daftar notifikasi
      final Map<String, List<AppNotification>> groupedNotifications = _groupNotificationsByDay(_notifications);
      // Urutkan kunci hari dari terbaru ke terlama
      final List<String> sortedDayKeys = groupedNotifications.keys.toList()..sort((a, b) => b.compareTo(a));

      mainContent = ListView.builder(
        itemCount: sortedDayKeys.length,
        itemBuilder: (context, index) {
          String dayKey = sortedDayKeys[index];
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
                // Map setiap notifikasi ke NotificationItem widget
                ...notificationsForDay.map((notification) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: NotificationItem(
                      notification: notification, // Meneruskan objek model AppNotification
                      // onMarkAsRead akan null jika notifikasi sudah dibaca (agar tombol tidak aktif)
                      onMarkAsRead: notification.isRead ? null : () => _markNotificationAsRead(notification.id),
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
      body: SafeArea( // Menggunakan SafeArea untuk menghindari overlap dengan status bar
        child: Column(
          children: [
            HeaderWidget(
              title: 'Notifikasi',
              onBackPressed: () => Navigator.of(context).pop(), // Tombol kembali
            ),
            Expanded( // Memastikan konten utama mengambil sisa ruang yang tersedia
              child: mainContent, // Menampilkan konten yang sudah ditentukan sebelumnya
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk tampilan ketika pengguna belum login
  Widget _buildLoggedOutContent(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'images/logo.png', // Pastikan path ke logo ini benar
            width: 150, // Sesuaikan ukuran logo
            height: 150,
          ),
          const SizedBox(height: 32), // Spasi antara logo dan tombol
          Row( // Menggunakan Row untuk menempatkan tombol berdampingan
            mainAxisAlignment: MainAxisAlignment.center, // Pusatkan tombol secara horizontal
            children: [
              TextButton(
                onPressed: () {
                  // Navigasi ke halaman login, lalu setelah kembali, periksa status notifikasi lagi
                  Navigator.pushNamed(context, '/login').then((_) {
                    _checkAndFetchNotifications();
                  });
                },
                style: TextButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor, // Menggunakan warna dari tema aplikasi
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
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
                  // Navigasi ke halaman register, lalu setelah kembali, periksa status notifikasi lagi
                  Navigator.pushNamed(context, '/register').then((_) {
                    _checkAndFetchNotifications();
                  });
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey[300], // Warna abu-abu untuk tombol daftar
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
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
        ],
      ),
    );
  }
}