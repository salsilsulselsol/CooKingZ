// File: lib/view/home/resep_trending.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../component/header_back.dart'; // Import CustomHeader
import '../component/featured_resep_card.dart'; // <<< Import FeaturedRecipeCard yang sudah diupdate
import '../../theme/theme.dart';
import '../../models/food_model.dart'; // Import Food model (untuk parsing API)
// FoodCard tidak diperlukan karena kita akan menggunakan _buildRecipeCard lokal

class ResepTrending extends StatefulWidget {
  const ResepTrending({super.key});

  @override
  State<ResepTrending> createState() => _ResepTrendingState();
}

class _ResepTrendingState extends State<ResepTrending> {
  // _trendingRecipes sekarang akan menyimpan objek Food dari API
  List<Food> _trendingRecipes = []; 
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  final String _baseUrl = 'http://localhost:3000'; // <<< GANTI DENGAN IP BACKEND ANDA

  @override
  void initState() {
    super.initState();
    _fetchTrendingRecipes();
  }

  Future<void> _fetchTrendingRecipes() async {
    print('DEBUG TRESP: Mulai fetch resep trending...');
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      // --- BAGIAN PALING PENTING ADA DI SINI ---
      // Pastikan path-nya persis seperti ini, tanpa typo.
      final uri = Uri.parse('$_baseUrl/home/trending-recipes'); 
      
      // Cetak URL final untuk debugging, untuk memastikan tidak ada kesalahan.
      print('<<<<< URL YANG SEDANG DIPANGGIL: $uri >>>>>'); 
      // --- AKHIR DARI BAGIAN PENTING ---

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print('DEBUG TRESP: Status Code API: ${response.statusCode}');
      print('DEBUG TRESP: Response Body API: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...');

      if (response.statusCode == 200) {
        // 1. Decode seluruh body response sebagai Map
        final Map<String, dynamic> responseData = json.decode(response.body);

        // 2. Lakukan pengecekan apakah 'data' benar-benar sebuah List
        if (responseData['data'] is List) {
          // 3. Ambil List dari dalam Map menggunakan kuncinya, yaitu 'data'
          final List<dynamic> trendingList = responseData['data']; 

          setState(() {
            _trendingRecipes = trendingList.map((jsonItem) => Food.fromJson(jsonItem)).toList();
            _isLoading = false;
          });
          print('DEBUG TRESP: Resep trending berhasil diparsing. Jumlah: ${_trendingRecipes.length}');
        } else {
          // Ini terjadi jika server mengirim format yang salah (misal: 'data' bukan List)
          throw Exception("Format data dari server tidak valid.");
        }
      } else {
        setState(() {
          _hasError = true;
          // Tampilkan pesan error dari backend jika ada, agar lebih informatif
          _errorMessage = 'Gagal memuat resep: ${response.statusCode} - ${response.body}';
          _isLoading = false;
        });
        print('[ERROR] TRESP: Gagal memuat resep trending: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Terjadi kesalahan saat memuat resep: $e';
        _isLoading = false;
      });
      print('[EXCEPTION] TRESP: Error fetching resep trending: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    print('DEBUG TRESP: build method dipanggil. isLoading: $_isLoading, hasError: $_hasError, trendingRecipes.length: ${_trendingRecipes.length}');
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            HeaderWidget(
              title: 'Resep Yang Sedang Tren',
              onBackPressed: () {
                // Fungsi untuk kembali ke halaman sebelumnya
                Navigator.of(context).pop();
              },
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
                      : _trendingRecipes.isEmpty
                          ? Center(child: Text('Tidak ada resep trending ditemukan.', style: TextStyle(color: Colors.grey)))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              physics: const BouncingScrollPhysics(),
                              itemCount: _trendingRecipes.length, 
                              itemBuilder: (context, index) {
                                final recipeFoodObject = _trendingRecipes[index];

                                // 1. Buat URL gambar yang lengkap di sini
                                final String fullImageUrl = (recipeFoodObject.image != null && recipeFoodObject.image!.isNotEmpty)
                                    ? _baseUrl + recipeFoodObject.image!
                                    : ""; // Sediakan string kosong jika tidak ada gambar

                                // 2. Buat map yang konsisten untuk kedua jenis kartu
                                final Map<String, dynamic> recipeMap = {
                                  'id': recipeFoodObject.id,
                                  'name': recipeFoodObject.name,
                                  'imageUrl': fullImageUrl, // <<< GUNAKAN KUNCI 'imageUrl' DENGAN URL LENGKAP
                                  'description': recipeFoodObject.description,
                                  'likes': (recipeFoodObject.likes ?? 0).toString(),
                                  'time': recipeFoodObject.cookingTime != null ? '${recipeFoodObject.cookingTime} menit' : 'N/A',
                                  'price': recipeFoodObject.price?.toString() ?? 'Gratis',
                                  'difficulty': recipeFoodObject.difficulty,
                                  // 'chef' bisa diambil dari usernameCreator jika ada di model Food
                                  // 'chef': recipeFoodObject.usernameCreator, 
                                };

                                // Tampilkan FeaturedRecipeCard untuk resep pertama
                                if (index == 0) {
                                  // Kirim map yang sudah diperbarui
                                  return FeaturedRecipeCard(recipe: recipeMap);
                                } else { 
                                  // Kirim map yang sama ke helper method
                                  return _buildRecipeCard(context, recipeMap);
                                }
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method untuk membangun kartu resep umum (digunakan untuk daftar di bawah FeaturedRecipeCard)
  // Ini akan menggunakan Map<String, dynamic> dan Image.asset seperti yang Anda inginkan
  Widget _buildRecipeCard(BuildContext context, Map<String, dynamic> recipe) {
    // Ekstrak data dari map, pastikan semua kunci aman dari null
    final String name = recipe['name'] ?? 'Resep Tanpa Nama';
    final String description = recipe['description'] ?? 'Tidak ada deskripsi';
    // <<< UBAH: Ambil 'imageUrl' yang berisi URL lengkap >>>
    final String imageUrl = recipe['imageUrl'] ?? '';
    final String likes = recipe['likes']?.toString() ?? '0';
    final String time = recipe['time'] ?? 'N/A';
    final String price = recipe['price']?.toString() ?? '0';
    final String? chef = recipe['chef']; // Ambil dari Map jika ada
    final String difficulty = recipe['difficulty'] ?? 'N/A';
    final recipeId = recipe['id'];

    return GestureDetector(
      onTap: () {
        if (recipeId != null) {
          // Navigasi ke detail resep menggunakan ID
          Navigator.pushNamed(context, '/detail-resep/$recipeId');
        } else {
          print('ERROR: Recipe ID is null for regular recipe card.');
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 140,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(AppTheme.recipeCardBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                  // --- PERBAIKAN UTAMA ADA DI SINI ---
                  // <<< UBAH: Gunakan Image.network dengan imageUrl >>>
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl, // Gunakan URL lengkap
                          height: 140,
                          width: 120,
                          fit: BoxFit.cover,
                          // Tampilkan loading indicator
                          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 140,
                              width: 120,
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          },
                          // Tampilkan ikon error jika gagal
                          errorBuilder: (context, error, stackTrace) {
                            return Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey[600]));
                          },
                        )
                      : Image.asset( // Tampilkan placeholder jika URL kosong
                          'images/placeholder.png',
                          height: 140,
                          width: 120,
                          fit: BoxFit.cover,
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Image.asset( // Icon love lokal
                    'images/love.png',
                    width: 24,
                    height: 24,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textBrown),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      description,
                      style: AppTheme.foodDescriptionStyle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (chef != null)
                      Text(
                        "By $chef",
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.accentTeal),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset('images/alarm.png', width: 12, height: 12, color: AppTheme.accentTeal),
                            const SizedBox(width: 4),
                            Text(time, style: AppTheme.foodInfoStyle),
                          ],
                        ),
                        Text(difficulty, style: AppTheme.foodInfoStyle),
                        Row(
                          children: [
                            Text(likes, style: AppTheme.foodPriceStyle),
                            const SizedBox(width: 4),
                            Image.asset('images/star.png', width: 12, height: 12, color: AppTheme.accentTeal),
                          ],
                        ),
                        Text("Rp $price", style: AppTheme.foodPriceStyle),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}