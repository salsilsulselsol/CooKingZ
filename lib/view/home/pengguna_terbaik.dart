// File: lib/view/home/pengguna_terbaik.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:masak2/view/component/bottom_navbar.dart';
import 'package:masak2/view/component/header_b_n_s.dart'; 
import 'package:masak2/view/component/grid_pengguna.dart'; // Import ChefCard yang sudah diupdate
import '../../theme/theme.dart';
import '../../models/user_profile_model.dart'; // Import UserProfile model

class PenggunaTerbaik extends StatefulWidget { 
  const PenggunaTerbaik({super.key});

  @override
  State<PenggunaTerbaik> createState() => _PenggunaTerbaikState();
}

class _PenggunaTerbaikState extends State<PenggunaTerbaik> {
  List<UserProfile> _popularUsers = []; 
  List<UserProfile> _latestUsers = []; 
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  final String _baseUrl = 'http://192.168.100.44:3000'; // <<< GANTI DENGAN IP BACKEND ANDA

  @override
  void initState() {
    super.initState();
    _fetchAllUsersData(); 
  }

  Future<void> _fetchAllUsersData() async {
    print('DEBUG PTERBAIK: Mulai fetch semua data pengguna...');
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      // --- Fetch Pengguna Populer (dari /home endpoint) ---
      final uriHome = Uri.parse('$_baseUrl/home'); 
      final responseHome = await http.get(
        uriHome,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (responseHome.statusCode == 200) {
        final Map<String, dynamic> responseDataHome = json.decode(responseHome.body);
        _popularUsers = (responseDataHome['data']['bestUsers'] as List) 
            .map((jsonItem) => UserProfile.fromJson(jsonItem)).toList();
        print('DEBUG PTERBAIK: Pengguna Populer berhasil diparsing. Jumlah: ${_popularUsers.length}');
      } else {
        print('[ERROR] PTERBAIK: Gagal memuat Pengguna Populer: ${responseHome.statusCode} ${responseHome.body}');
        _hasError = true;
        _errorMessage = 'Gagal memuat pengguna populer.';
      }

      // --- Fetch Pengguna Terbaru (dari /users/latest endpoint) ---
      final uriLatestUsers = Uri.parse('$_baseUrl/users/latest'); 
      final responseLatestUsers = await http.get(
        uriLatestUsers,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (responseLatestUsers.statusCode == 200) {
        final Map<String, dynamic> responseDataLatestUsers = json.decode(responseLatestUsers.body);
        _latestUsers = (responseDataLatestUsers['data'] as List) 
            .map((jsonItem) => UserProfile.fromJson(jsonItem)).toList();
        print('DEBUG PTERBAIK: Pengguna Terbaru berhasil diparsing. Jumlah: ${_latestUsers.length}');
      } else {
        print('[ERROR] PTERBAIK: Gagal memuat Pengguna Terbaru: ${responseLatestUsers.statusCode} ${responseLatestUsers.body}');
        _hasError = true;
        _errorMessage = 'Gagal memuat pengguna terbaru.';
      }

      setState(() {
        _isLoading = false;
        if (_hasError) { 
          _errorMessage = _errorMessage.isEmpty ? 'Gagal memuat data pengguna.' : _errorMessage;
        }
      });
      print('DEBUG PTERBAIK: Fetch semua data pengguna selesai.');

    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Terjadi kesalahan saat memuat data pengguna: $e';
        _isLoading = false;
      });
      print('[EXCEPTION] PTERBAIK: Error fetching semua pengguna: $e');
    }
  }

  Future<void> _toggleFollow(int userId) async {
    print('DEBUG PTERBAIK: Toggle follow untuk user ID: $userId');
    // Implementasi API follow/unfollow ada di userController.js
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Follow/Unfollow user ID $userId (belum diimplementasikan)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('DEBUG PTERBAIK: build method dipanggil. isLoading: $_isLoading, hasError: $_hasError');
    return BottomNavbar(
      Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        extendBody: true,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              CustomHeader(
                title: 'Pengguna Terbaik',
                titleColor: AppTheme.primaryColor,
              ),
              Expanded( // Expanded untuk memastikan SingleChildScrollView mengambil ruang yang tersedia
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
                        : SingleChildScrollView( // Scroll vertical untuk keseluruhan konten
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Bagian Pengguna Populer (Horizontal Scroll)
                                Container(
                                  // Tidak perlu fixed height di sini jika ChefCard punya tinggi intrinsic
                                  // atau jika Anda ingin scroll horizontal yang bebas.
                                  // Tinggi disesuaikan dengan tinggi ChefCard dan padding-nya
                                  height: 320, // Tetap gunakan height ini untuk membungkus horizontal list
                                  decoration: const BoxDecoration(
                                    color: AppTheme.primaryColor, 
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(30),
                                      topRight: Radius.circular(30),
                                      bottomLeft: Radius.circular(30),
                                      bottomRight: Radius.circular(30),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildSectionTitle("Pengguna Populer", isGreenBackground: true), 
                                      _buildHorizontalUserList(_popularUsers, useGreenBackground: true), // <<< Horizontal list
                                    ],
                                  ),
                                ),

                                // Bagian Pengguna Terbaru (Vertical Grid)
                                Container(
                                  // Tidak perlu fixed height di sini, biarkan GridView.builder yang shrinkWrap menentukan
                                  margin: EdgeInsets.only(top: AppTheme.spacingXXLarge),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildSectionTitle("Pengguna Terbaru", isGreenBackground: false), 
                                      _buildVerticalUsersGrid(_latestUsers, useGreenBackground: false), // <<< Vertical Grid
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 90), 
                              ],
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper untuk judul bagian
  Widget _buildSectionTitle(String title, {bool isGreenBackground = false}) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppTheme.spacingXXLarge + 10,
        top: AppTheme.spacingLarge,
        bottom: AppTheme.spacingMedium,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isGreenBackground ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  // Helper baru untuk daftar pengguna yang scroll horizontal
  Widget _buildHorizontalUserList(List<UserProfile> users, {required bool useGreenBackground}) {
    if (users.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLarge),
          child: Text(
            'Tidak ada pengguna ditemukan.',
            style: TextStyle(color: useGreenBackground ? Colors.white70 : Colors.grey),
          ),
        ),
      );
    }
    return Expanded( // Expanded agar ListView horizontal mengambil sisa ruang vertikal dalam Column
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // <<< Scroll HORIZONTAL
        padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingXXLarge + 10),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final userProfile = users[index];
          return ChefCard(
            user: userProfile, 
            isFollowing: false, 
            onFollowToggle: () => _toggleFollow(userProfile.id),
            useGreenBackground: useGreenBackground, 
          );
        },
      ),
    );
  }

  // Helper untuk Grid Pengguna Vertikal
  Widget _buildVerticalUsersGrid(List<UserProfile> users, {required bool useGreenBackground}) {
    if (users.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLarge),
          child: Text(
            'Tidak ada pengguna ditemukan.',
            style: TextStyle(color: useGreenBackground ? Colors.white70 : Colors.grey),
          ),
        ),
      );
    }
    return Padding( // Tidak pakai Expanded di sini karena parent SingleChildScrollView
      padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingXXLarge ),
      child: GridView.builder(
        shrinkWrap: true, 
        physics: NeverScrollableScrollPhysics(), 
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, 
          crossAxisSpacing: AppTheme.spacingMedium,
          mainAxisSpacing: AppTheme.spacingMedium,
          childAspectRatio: 0.75, 
        ),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final userProfile = users[index];
          return ChefCard(
            user: userProfile, 
            isFollowing: false, 
            onFollowToggle: () => _toggleFollow(userProfile.id),
            useGreenBackground: useGreenBackground, 
          );
        },
      ),
    );
  }
}