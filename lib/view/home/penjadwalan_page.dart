// File: lib/view/home/penjadwalan_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/scheduled_food_model.dart';
import '../component/food_card_jadwal.dart';

class PenjadwalanPage extends StatefulWidget {
  // We no longer need userId as a constructor argument if we're fetching it internally
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

  final String _baseUrl = 'http://localhost:3000';

  @override
  void initState() {
    super.initState();
    _fetchMealSchedules();
  }

  // Function to get the user ID from SharedPreferences
  Future<int?> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id'); // Ensure 'user_id' is the correct key
  }

  Future<void> _fetchMealSchedules() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      // Get the current logged-in user ID
      _currentLoggedInUserId = await _getCurrentUserId();

      print('DEBUG (PenjadwalanPage): Token retrieved: $token');
      print('DEBUG (PenjadwalanPage): User ID for API call: $_currentLoggedInUserId');

      if (token == null) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Anda harus login untuk melihat jadwal makan.';
          _isLoading = false;
        });
        return;
      }

      if (_currentLoggedInUserId == null) {
        setState(() {
          _hasError = true;
          _errorMessage = 'User ID tidak ditemukan. Harap login ulang.';
          _isLoading = false;
        });
        return;
      }

      // Construct the URL with the retrieved user ID
      final uri = Uri.parse('$_baseUrl/api/utilities/get_meal-schedules/$_currentLoggedInUserId');
      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      print('DEBUG (PenjadwalanPage): Response status code: ${response.statusCode}');
      print('DEBUG (PenjadwalanPage): Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> scheduleList = data['data'];
        setState(() {
          _scheduledMeals = scheduleList
              .map((item) => ScheduledFood.fromJson(item))
              .toList();
          _scheduledMeals.sort((a, b) => a.date.compareTo(b.date));
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage =
              'Gagal memuat jadwal makan: ${response.statusCode} ${response.reasonPhrase} - ${json.decode(response.body)['message'] ?? ''}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteMealSchedule(int scheduleId,int user_Id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) return;

      final uri = Uri.parse('$_baseUrl/api/utilities/meal-schedules/$scheduleId/$user_Id');
      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _fetchMealSchedules(); // Refresh schedules after deletion
      } else {
        print('[ERROR] Hapus jadwal gagal: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('[EXCEPTION] Hapus jadwal error: $e');
    }
  }

  String _formatDateForGrouping(DateTime date) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    if (_isSameDay(date, now)) return 'Hari Ini';
    if (_isSameDay(date, yesterday)) return 'Kemarin';
    return DateFormat('EEEE, dd MMMM', 'id_ID').format(date);
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  @override
  Widget build(BuildContext context) {
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
                      ? const Center(
                          child: Text('Tidak ada jadwal makan.',
                              style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          itemCount: _scheduledMeals.length,
                          itemBuilder: (context, index) {
                            final scheduledMeal = _scheduledMeals[index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (index == 0 ||
                                    !_isSameDay(scheduledMeal.date,
                                        _scheduledMeals[index - 1].date))
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 8.0),
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
                                  onDelete: () => _deleteMealSchedule(scheduledMeal.id,scheduledMeal.userId),
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