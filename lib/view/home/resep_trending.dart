// File: lib/view/home/resep_trending.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../component/header_b_n_s.dart'; // Import CustomHeader
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

  final String _baseUrl = 'http://192.168.100.44:3000'; // <<< GANTI DENGAN IP BACKEND ANDA

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

      // Mengambil data dari endpoint baru untuk semua resep trending (limit 50)
      final uri = Uri.parse('$_baseUrl/home/trending-recipes'); 
      print('DEBUG TRESP: Fetching dari URL: $uri');

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
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> trendingList = responseData['data']; 

        setState(() {
          _trendingRecipes = trendingList.map((jsonItem) => Food.fromJson(jsonItem)).toList();
          _isLoading = false;
        });
        print('DEBUG TRESP: Resep trending berhasil diparsing. Jumlah: ${_trendingRecipes.length}');
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = 'Gagal memuat resep trending: ${response.statusCode} ${response.reasonPhrase}';
          _isLoading = false;
        });
        print('[ERROR] TRESP: Gagal memuat resep trending: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Terjadi kesalahan saat memuat resep trending: $e';
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
            const CustomHeader(
              title: 'Resep Yang Sedang Tren',
              showBackButton: true,
              showNotificationButton: true,
              showSearchButton: true,
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
                                final recipeFoodObject = _trendingRecipes[index]; // Ini adalah objek Food dari API
                                
                                // <<< KONVERSI MANUAL DARI OBJEK FOOD KE MAP<String, dynamic> >>>
                                // Ini dilakukan agar layout lama yang mengharapkan Map<String, dynamic> tetap berfungsi
                                final Map<String, dynamic> recipeMap = {
                                  'id': recipeFoodObject.id,
                                  'name': recipeFoodObject.name,
                                  'image': recipeFoodObject.image, // Ini image_url dari backend, tapi tetap butuh asset lokal
                                  'description': recipeFoodObject.description,
                                  'likes': (recipeFoodObject.likes ?? 0).toString(),
                                  'time': recipeFoodObject.cookingTime != null ? '${recipeFoodObject.cookingTime}menit' : 'N/A',
                                  'price': recipeFoodObject.price,
                                  'difficulty': recipeFoodObject.difficulty,
                                  // 'chef' tidak ada di model Food, jadi tidak akan ada di Map ini kecuali Anda hardcode
                                  // Jika perlu 'chef', Anda harus menambahkan 'usernameCreator' di Food model dan memetakannya di sini
                                  // 'chef': recipeFoodObject.usernameCreator ?? 'Anonim', 
                                };

                                // Tampilkan FeaturedRecipeCard untuk resep pertama
                                if (index == 0) {
                                  return FeaturedRecipeCard(recipe: recipeMap); // Meneruskan Map<String, dynamic>
                                } else { 
                                  // Tampilkan _buildRecipeCard untuk resep lainnya (helper lokal)
                                  return _buildRecipeCard(context, recipeMap); // Meneruskan Map<String, dynamic>
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
    final String name = recipe['name'] ?? 'Resep Tanpa Nama';
    final String description = recipe['description'] ?? 'Tidak ada deskripsi';
    final String imagePath = recipe['image'] ?? 'images/placeholder.png'; // Default placeholder lokal
    final String likes = recipe['likes'] ?? '0';
    final String time = recipe['time'] ?? 'N/A';
    final String price = recipe['price'] ?? '0';
    final String? chef = recipe['chef']; // Ambil dari Map jika ada
    final String difficulty = recipe['difficulty'] ?? 'N/A';

    return GestureDetector(
      onTap: () {
        // Navigasi ke detail resep menggunakan ID
        final recipeId = recipe['id'];
        if (recipeId != null) {
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
                  child: Image.asset( // <<< MENGGUNAKAN Image.asset untuk gambar lokal
                    imagePath,
                    height: 140,
                    width: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey[600]));
                    },
                  ),
                ),
                Positioned(
                  top: 8, right: 8,
                  child: Image.asset( // <<< Icon lokal
                    'images/love.png', width: 24, height: 24,
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
                    Text( name, style: const TextStyle( fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textBrown, ), maxLines: 1, overflow: TextOverflow.ellipsis, ),
                    Text( description, style: AppTheme.foodDescriptionStyle, maxLines: 2, overflow: TextOverflow.ellipsis, ),
                    if (chef != null) 
                      Text( "By $chef", style: TextStyle( fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.accentTeal, ), ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset( 'images/alarm.png', width: 12, height: 12, color: AppTheme.accentTeal, ),
                            const SizedBox(width: 4),
                            Text( time, style: AppTheme.foodInfoStyle, ),
                          ],
                        ),
                        Text( difficulty, style: AppTheme.foodInfoStyle, ),
                        Row(
                          children: [
                            Text( likes, style: AppTheme.foodPriceStyle, ),
                            const SizedBox(width: 4),
                            Image.asset( 'images/star.png', width: 12, height: 12, color: AppTheme.accentTeal, ),
                          ],
                        ),
                        Text( "Rp $price", style: AppTheme.foodPriceStyle, ),
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