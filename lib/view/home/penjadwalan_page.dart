// File: lib/view/home/penjadwalan_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/scheduled_food_model.dart'; // Pastikan path ini benar
import '../component/food_card_jadwal.dart'; // Pastikan path ini benar
import '../../view/component/header_back.dart'; // Pastikan path ini benar
import '../../theme/theme.dart'; // Import AppTheme untuk warna tombol

class PenjadwalanPage extends StatefulWidget {
  const PenjadwalanPage({Key? key}) : super(key: key);

  @override
  State<PenjadwalanPage> createState() => _PenjadwalanPageState();
}

class _PenjadwalanPageState extends State<PenjadwalanPage> {
  List<ScheduledFood> _scheduledMeals = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  int? _currentLoggedInUserId; // Declare it here to hold the user ID
  bool _isLoggedIn = false; // State baru untuk melacak status login

  final String _baseUrl = 'http://localhost:3000'; // <<< GANTI DENGAN IP BACKEND ANDA

  @override
  void initState() {
    super.initState();
    _checkAndFetchMealSchedules(); // Memanggil fungsi baru untuk cek login dan fetch
  }

  // Fungsi yang akan memeriksa status login dan kemudian memanggil _fetchMealSchedules
  Future<void> _checkAndFetchMealSchedules() async {
    print('DEBUG (PenjadwalanPage): Mulai _checkAndFetchMealSchedules...');
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
      _isLoggedIn = false; // Reset status login
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userId = prefs.getInt('user_id'); // Ambil user ID

    // Logika penentuan status login
    if (token == null || userId == null || userId == 0) {
      // Jika tidak ada token atau user ID tidak valid, anggap belum login
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
      print('DEBUG (PenjadwalanPage): Pengguna belum login atau token/ID tidak valid. Menampilkan UI non-login.');
      return; // Hentikan proses karena belum login
    }

    // Jika sudah login, set status dan lanjutkan fetching
    setState(() {
      _isLoggedIn = true;
      _currentLoggedInUserId = userId; // Simpan ID pengguna yang login
    });
    await _fetchMealSchedules(token, userId); // Panggil fungsi fetching dengan token dan ID
  }

  Future<void> _fetchMealSchedules(String token, int userId) async {
    print('DEBUG (PenjadwalanPage): Mulai fetch jadwal makan dengan token dan user ID...');
    try {
      final uri = Uri.parse('$_baseUrl/api/utilities/get_meal-schedules/$userId');
      print('DEBUG (PenjadwalanPage): Fetching dari URL: $uri');

      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      print('DEBUG (PenjadwalanPage): Response status code: ${response.statusCode}');
      print('DEBUG (PenjadwalanPage): Response body: ${response.body.length > 500 ? response.body.substring(0, 500) + '...' : response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Pastikan 'data' ada dan merupakan list
        final List<dynamic> scheduleList = data['data'] is List ? data['data'] : [];

        setState(() {
          _scheduledMeals = scheduleList
              .map((item) => ScheduledFood.fromJson(item))
              .toList();
          _scheduledMeals.sort((a, b) => a.date.compareTo(b.date));
          _isLoading = false;
          _hasError = false; // Pastikan ini diset false jika berhasil
        });
        print('DEBUG (PenjadwalanPage): Jadwal berhasil diparsing. Jumlah: ${_scheduledMeals.length}');
      } else {
        setState(() {
          _hasError = true;
          _errorMessage =
              'Gagal memuat jadwal makan: ${response.statusCode} ${response.reasonPhrase ?? json.decode(response.body)['message'] ?? ''}';
          _isLoading = false;
        });
        print('[ERROR] (PenjadwalanPage): Gagal memuat jadwal: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
      print('[EXCEPTION] (PenjadwalanPage): Error fetching jadwal: $e');
    }
  }

  Future<void> _deleteMealSchedule(int scheduleId, int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        print('DEBUG (PenjadwalanPage): Tidak ada token untuk menghapus jadwal.');
        return;
      }

      final uri = Uri.parse('$_baseUrl/api/utilities/meal-schedules/$scheduleId/$userId');
      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('DEBUG (PenjadwalanPage): Jadwal $scheduleId berhasil dihapus.');
        _checkAndFetchMealSchedules(); // Refresh schedules after deletion
      } else {
        print('[ERROR] (PenjadwalanPage): Hapus jadwal gagal: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('[EXCEPTION] (PenjadwalanPage): Hapus jadwal error: $e');
    }
  }

  String _formatDateForGrouping(DateTime date) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    if (_isSameDay(date, now)) return 'Hari Ini';
    if (_isSameDay(date, yesterday)) return 'Kemarin';
    return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date); // Tambahkan tahun
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  @override
  Widget build(BuildContext context) {
    print('DEBUG (PenjadwalanPage): build method dipanggil. isLoading: $_isLoading, hasError: $_hasError, isLoggedIn: $_isLoggedIn, scheduledMeals.length: ${_scheduledMeals.length}');

    // Tentukan konten utama berdasarkan status _isLoading dan _isLoggedIn
    Widget mainContent;
    if (_isLoading) {
      mainContent = const Center(child: CircularProgressIndicator());
    } else if (!_isLoggedIn) {
      // Jika belum login, tampilkan UI login/daftar
      mainContent = _buildLoggedOutContent(context);
    } else if (_hasError) {
      // Jika login tapi ada error saat fetching jadwal
      mainContent = Center(
        child: Text(
          _errorMessage,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    } else if (_scheduledMeals.isEmpty) {
      // Jika sudah login dan tidak ada jadwal
      mainContent = const Center(
          child: Text('Tidak ada jadwal makan.',
              style: TextStyle(color: Colors.grey)));
    } else {
      // Jika sudah login dan ada jadwal
      // Grouping logic
      Map<String, List<ScheduledFood>> groupedMeals = {};
      for (var meal in _scheduledMeals) {
        String dateKey = _formatDateForGrouping(meal.date);
        if (!groupedMeals.containsKey(dateKey)) {
          groupedMeals[dateKey] = [];
        }
        groupedMeals[dateKey]!.add(meal);
      }

      final List<String> sortedDateKeys = groupedMeals.keys.toList()
        ..sort((a, b) =>
            DateTime.parse(groupedMeals[a]!.first.date.toIso8601String().substring(0, 10))
                .compareTo(DateTime.parse(groupedMeals[b]!.first.date.toIso8601String().substring(0, 10)))); // Sort by date ascending

      mainContent = ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        itemCount: sortedDateKeys.length,
        itemBuilder: (context, index) {
          String dateKey = sortedDateKeys[index];
          List<ScheduledFood> mealsForDay = groupedMeals[dateKey]!;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 0),
                child: Text(
                  dateKey, // Sudah diformat oleh _formatDateForGrouping
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF006666),
                  ),
                ),
              ),
              ...mealsForDay.map((scheduledMeal) {
                return Column(
                  children: [
                    FoodCardJadwal(
                      scheduledMeal: scheduledMeal,
                      onDelete: () => _deleteMealSchedule(
                          scheduledMeal.id, scheduledMeal.userId!), // Pastikan userId tidak null
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
            ],
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          padding: const EdgeInsets.only(top: 30, left: 16, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Image.asset('images/arrow.png', width: 24, height: 24),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                'Penjadwalan',
                style: TextStyle(
                  color: Color(0xFF006666),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(width: 48), // Keep spacing consistent
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 30, right: 16, top: 10), // Padding disisihkan agar tidak mengganggu mainContent
          child: mainContent, // Tampilkan konten utama yang sudah ditentukan
        ),
      ),
    );
  }

  // Widget untuk tampilan ketika belum login
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // Pusatkan tombol secara horizontal
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login').then((_) {
                    _checkAndFetchMealSchedules(); // Panggil ulang setelah kembali dari login
                  });
                },
                style: TextButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor, // Menggunakan tema warna Anda
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: const Text('Login'),
              ),
              const SizedBox(width: 16), // Spasi horizontal antar tombol
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register').then((_) {
                    _checkAndFetchMealSchedules(); // Panggil ulang setelah kembali dari register
                  });
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey[300], // Warna abu-abu untuk tombol daftar
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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