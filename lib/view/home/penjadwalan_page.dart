// File: lib/view/home/penjadwalan_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/food_model.dart'; 
import '../../models/scheduled_food_model.dart'; // Import model ScheduledFood yang baru
import '../component/food_card_jadwal.dart'; // Import widget FoodCardJadwal
import '../../view/component/header_back.dart'; // Import HeaderWidget

class PenjadwalanPage extends StatefulWidget {
  const PenjadwalanPage({Key? key}) : super(key: key);

  @override
  State<PenjadwalanPage> createState() => _PenjadwalanPageState();
}

class _PenjadwalanPageState extends State<PenjadwalanPage> {
  List<ScheduledFood> _scheduledMeals = []; // Menggunakan ScheduledFood
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  final String _baseUrl = 'http://192.168.100.44:3000'; // <<< GANTI DENGAN IP BACKEND ANDA

  @override
  void initState() {
    super.initState();
    _fetchMealSchedules();
  }

  Future<void> _fetchMealSchedules() async {
    print('DEBUG PENJADWALAN: Mulai fetch jadwal makan...');
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
          _errorMessage = 'Anda harus login untuk melihat jadwal makan.';
          _isLoading = false;
        });
        print('DEBUG PENJADWALAN: Tidak ada token, tidak bisa fetch jadwal.');
        return;
      }

      final uri = Uri.parse('$_baseUrl/api/utilities/meal-schedules');
      print('DEBUG PENJADWALAN: Fetching dari URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('DEBUG PENJADWALAN: Status Code API: ${response.statusCode}');
      print('DEBUG PENJADWALAN: Response Body API: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> scheduleList = responseData['data'];

        setState(() {
          _scheduledMeals = scheduleList.map((jsonItem) => ScheduledFood.fromJson(jsonItem)).toList();
          // Sort the scheduled meals by date (ascending)
          _scheduledMeals.sort((a, b) => a.date.compareTo(b.date));
          _isLoading = false;
        });
        print('DEBUG PENJADWALAN: Jadwal makan berhasil diparsing. Count: ${_scheduledMeals.length}');
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = 'Gagal memuat jadwal makan: ${response.statusCode} ${response.reasonPhrase}';
          _isLoading = false;
        });
        print('[ERROR] PENJADWALAN: Gagal memuat jadwal: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Terjadi kesalahan saat memuat jadwal makan: $e';
        _isLoading = false;
      });
      print('[EXCEPTION] PENJADWALAN: Error fetching jadwal: $e');
    }
  }

  Future<void> _addMealSchedule(int recipeId, String mealType, DateTime date) async {
    print('DEBUG PENJADWALAN: Menambahkan jadwal: Recipe ID: $recipeId, Meal Type: $mealType, Date: $date');
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        print('ERROR: Tidak login. Tidak bisa menambahkan jadwal makan.');
        return;
      }

      final uri = Uri.parse('$_baseUrl/api/utilities/meal-schedules');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'recipe_id': recipeId,
          'meal_type': mealType,
          'date': DateFormat('yyyy-MM-dd').format(date), // Format tanggal sesuai backend
        }),
      );

      if (response.statusCode == 201) {
        print('DEBUG: Jadwal makan berhasil ditambahkan. Refreshing list.');
        _fetchMealSchedules(); // Fetch ulang untuk memperbarui daftar
      } else {
        print('[ERROR] PENJADWALAN: Gagal menambahkan jadwal: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('[EXCEPTION] PENJADWALAN: Error menambahkan jadwal: $e');
    }
  }

  Future<void> _deleteMealSchedule(int scheduleId) async {
    print('DEBUG PENJADWALAN: Menghapus jadwal ID: $scheduleId');
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) return;

      final uri = Uri.parse('$_baseUrl/api/utilities/meal-schedules/$scheduleId');
      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('DEBUG: Jadwal makan $scheduleId berhasil dihapus. Refreshing list.');
        _fetchMealSchedules(); // Fetch ulang untuk memperbarui daftar
      } else {
        print('[ERROR] PENJADWALAN: Gagal menghapus jadwal $scheduleId: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('[EXCEPTION] PENJADWALAN: Error menghapus jadwal: $e');
    }
  }

  // Fungsi untuk menampilkan date picker
  void _showDatePicker() async {
    print('DEBUG PENJADWALAN: showDatePicker dipanggil.');
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF006666),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF006666),
            ),
            dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      print('DEBUG PENJADWALAN: Tanggal dipilih: $pickedDate');
      // TODO: Di sini Anda perlu cara untuk memilih RECIPE ID dan MEAL_TYPE
      // Untuk tujuan testing awal, Anda bisa hardcode recipeId dan mealType,
      // atau memunculkan dialog/bottom sheet lain untuk memilih resep.
      
      // Contoh hardcode untuk testing:
      final int testRecipeId = 1; // Ganti dengan ID resep yang ada di DB Anda
      final String testMealType = 'Sarapan'; // Ganti dengan jenis makan yang valid (Sarapan, Makan Siang, Makan Malam, Camilan)

      _addMealSchedule(testRecipeId, testMealType, pickedDate);
    } else {
      print('DEBUG PENJADWALAN: Date picker dibatalkan.');
    }
  }

  // Helper untuk format tanggal pengelompokan (Hari Ini, Kemarin, atau tanggal penuh)
  String _formatDateForGrouping(DateTime date) {
    final DateTime now = DateTime.now();
    final DateTime yesterday = now.subtract(const Duration(days: 1));

    if (_isSameDay(date, now)) {
      return 'Hari Ini';
    } else if (_isSameDay(date, yesterday)) {
      return 'Kemarin';
    } else {
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date); // Tambahkan tahun untuk kejelasan
    }
  }

  // Helper untuk membandingkan apakah dua tanggal adalah hari yang sama
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    print('DEBUG PENJADWALAN: build method dipanggil. isLoading: $_isLoading, hasError: $_hasError, scheduledMeals.length: ${_scheduledMeals.length}');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.only(top: 30, left: 16, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Image.asset('images/arrow.png', width: 24, height: 24),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const Text(
                'Penjadwalan',
                style: TextStyle(
                  color: Color(0xFF006666),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              IconButton(
                icon: Image.asset('images/calendar.png', width: 28, height: 28),
                onPressed: _showDatePicker, // Tombol untuk menambah jadwal
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 30, right: 16, top: 10),
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
                  : _scheduledMeals.isEmpty
                      ? Center(child: Text('Tidak ada jadwal makan.', style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          itemCount: _scheduledMeals.length,
                          itemBuilder: (context, index) {
                            final scheduledMeal = _scheduledMeals[index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Tampilkan tanggal hanya sekali jika ada perubahan hari
                                // Perhatikan: ini akan berfungsi jika _scheduledMeals sudah diurutkan berdasarkan tanggal
                                if (index == 0 || !_isSameDay(scheduledMeal.date, _scheduledMeals[index - 1].date))
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Text(
                                      _formatDateForGrouping(scheduledMeal.date),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF006666),
                                      ),
                                    ),
                                  ),
                                FoodCardJadwal(
                                  scheduledMeal: scheduledMeal,
                                  onDelete: () => _deleteMealSchedule(scheduledMeal.id),
                                ),
                                const SizedBox(height: 16),
                              ],
                            );
                          },
                        ),
        ),
      ),
    );
  }
}