// File: lib/view/home/hasil_pencarian.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/theme.dart';
import '../../models/food_model.dart';
// import '../../models/user_profile_model.dart'; // Tidak langsung digunakan di sini
// import '../../models/category_model.dart'; // Tidak langsung digunakan di sini

import '../component/search_bar_widget.dart';
import '../component/food_card_widget.dart';
import '../component/bottom_navbar.dart';
import '../component/custom_appbar.dart';

import 'popup_filter.dart'; // Untuk menampilkan dialog filter

class HasilPencaharian extends StatefulWidget {
  final Map<String, dynamic> initialSearchParams;

  const HasilPencaharian({Key? key, this.initialSearchParams = const {}}) : super(key: key);

  @override
  State<HasilPencaharian> createState() => _HasilPencaharianState();
}

class _HasilPencaharianState extends State<HasilPencaharian> {
  final TextEditingController _searchController = TextEditingController();
  List<Food> _searchResults = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  Map<String, dynamic> _currentSearchParams = {};

  // Pastikan ini adalah IP backend Anda yang benar dan dapat diakses
  final String _baseUrl = 'http://localhost:3000';

  @override
  void initState() {
    super.initState();
    print('DEBUG HASIL_PENCARIAN: initState dipanggil.');
    // Salin initialSearchParams ke _currentSearchParams agar bisa dimodifikasi
    _currentSearchParams = Map<String, dynamic>.from(widget.initialSearchParams);
    print('DEBUG HASIL_PENCARIAN: initialSearchParams: ${widget.initialSearchParams}');

    // Set keyword dari initialSearchParams ke search controller
    _searchController.text = _currentSearchParams['keyword'] ?? '';
    print('DEBUG HASIL_PENCARIAN: Search bar keyword: ${_searchController.text}');

    _fetchSearchResults(_currentSearchParams); // Lakukan pencarian awal
  }

  @override
  void dispose() {
    print('DEBUG HASIL_PENCARIAN: dispose dipanggil.');
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchSearchResults(Map<String, dynamic> params) async {
    print('DEBUG HASIL_PENCARIAN: _fetchSearchResults dipanggil dengan params: $params');
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
      _searchResults = []; // Bersihkan hasil sebelumnya saat pencarian baru
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final Map<String, String> queryParams = {};
      if (params['keyword'] != null && params['keyword'].isNotEmpty) {
        queryParams['keyword'] = params['keyword'];
      }
      
      // Mengonversi kategori jika ada (asumsi hanya satu kategori yang dipilih atau elemen pertama dari list)
      if (params['categories'] != null && (params['categories'] as List).isNotEmpty) {
        queryParams['category_name'] = (params['categories'] as List<dynamic>).first.toString();
      }

      // Menambahkan parameter filter lainnya
      if (params['difficulty'] != null && params['difficulty'].isNotEmpty && params['difficulty'] != 'Semua') {
        queryParams['difficulty'] = params['difficulty'].toString();
      }
      if (params['min_rating'] != null && params['min_rating'] > 0) {
        queryParams['min_rating'] = params['min_rating'].toString();
      }
      
      // Max price dan max time dikirim apa adanya (sudah divalidasi di SearchPopup)
      if (params['max_price'] != null) {
        queryParams['max_price'] = params['max_price'].toString();
      }
      if (params['max_time'] != null) {
        queryParams['max_time'] = params['max_time'].toString();
      }
      // Mengirim alergen sebagai string yang dipisahkan koma (sesuai ekspektasi backend)
      if (params['allergens'] != null && (params['allergens'] as List).isNotEmpty) {
        queryParams['allergens'] = (params['allergens'] as List).join(',');
      }

      // Parameter limit dan offset
      queryParams['limit'] = '20';
      queryParams['offset'] = '0'; // Anda bisa membuat offset dinamis untuk pagination

      final uri = Uri.parse('$_baseUrl/home/search').replace(queryParameters: queryParams);
      print('DEBUG HASIL_PENCARIAN: Searching URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print('DEBUG HASIL_PENCARIAN: Search API Status Code: ${response.statusCode}');
      // Tampilkan sebagian response body jika terlalu panjang
      print('DEBUG HASIL_PENCARIAN: Search API Response Body: ${response.body.length > 500 ? response.body.substring(0, 500) + '...' : response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        // PERBAIKAN FINAL UNTUK TYPERROR:
        // Berdasarkan log terakhir `data:[]` atau `data:[{...}]`, 
        // `responseData['data']` seharusnya adalah sebuah List langsung.
        final List<dynamic> recipeListJson = responseData['data']; 

        setState(() {
          _searchResults = recipeListJson.map((jsonItem) => Food.fromJson(jsonItem)).toList();
          _isLoading = false;
          _hasError = false; // Pastikan ini diset false jika berhasil
        });
        print('DEBUG HASIL_PENCARIAN: Search results parsed. Count: ${_searchResults.length}');
      } else {
        setState(() {
          _hasError = true;
          // Pesan error lebih informatif jika ada 'message' dari backend
          _errorMessage = 'Gagal memuat hasil pencarian: ${response.statusCode} ${response.reasonPhrase ?? (json.decode(response.body)['message'] ?? '')}';
          _isLoading = false;
        });
        print('[ERROR] Search API failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Terjadi kesalahan saat pencarian: $e';
        _isLoading = false;
      });
      print('[EXCEPTION] Error during search: $e');
    }
  }

  // Fungsi yang dipanggil ketika tombol filter di SearchBarWidget ditekan
  Future<void> _onFilterButtonTapped() async {
    print('DEBUG HASIL_PENCARIAN: Filter button tapped. Current params: $_currentSearchParams');
    // Kirim salinan _currentSearchParams agar FilterPopup tidak langsung memodifikasi state ini
    final Map<String, dynamic>? result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => FilterPopup(initialParams: Map<String, dynamic>.from(_currentSearchParams)),
    );

    if (result != null) {
      print('DEBUG HASIL_PENCARIAN: Filter result received: $result');
      setState(() {
        // Gabungkan hasil filter baru dengan parameter yang sudah ada
        _currentSearchParams.addAll(result);
        // Hapus parameter yang null atau list/string kosong
        _currentSearchParams.removeWhere((key, value) => value == null || (value is List && value.isEmpty) || (value is String && value.isEmpty));
      });
      _fetchSearchResults(_currentSearchParams); // Lakukan pencarian ulang dengan filter baru
    } else {
      print('DEBUG HASIL_PENCARIAN: Filter dialog closed without result.');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('DEBUG HASIL_PENCARIAN: build method dipanggil. isLoading: $_isLoading, hasError: $_hasError, searchResults.length: ${_searchResults.length}');
    return BottomNavbar( // Asumsi dibungkus BottomNavbar
      Scaffold(
        appBar: CustomAppBar(
          title: 'Hasil Pencarian',
          onBackPressed: () {
            print('DEBUG HASIL_PENCARIAN: Back button pressed.');
            Navigator.pop(context); // Kembali ke halaman sebelumnya
          },
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(AppTheme.spacingXLarge),
              child: SearchBarWidget(
                controller: _searchController,
                hintText: 'Cari Resep...',
                onSearchSubmitted: (keyword) {
                  print('DEBUG HASIL_PENCARIAN: Search submitted: $keyword');
                  setState(() {
                    _currentSearchParams['keyword'] = keyword;
                    if (keyword.isEmpty) { // Hapus keyword jika kosong
                      _currentSearchParams.remove('keyword');
                    }
                    // Bersihkan parameter null/kosong lainnya
                    _currentSearchParams.removeWhere((key, value) => value == null || (value is List && value.isEmpty) || (value is String && value.isEmpty));
                  });
                  _fetchSearchResults(_currentSearchParams); // Lakukan pencarian ulang
                },
                onFilterTap: _onFilterButtonTapped, // Panggil fungsi filter
              ),
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
                      : _searchResults.isEmpty
                          ? const Center(
                                child: Text(
                                  'Tidak ada resep ditemukan.',
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                )
                              )
                          : GridView.builder(
                                padding: EdgeInsets.all(AppTheme.spacingXLarge),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16.0,
                                  mainAxisSpacing: 16.0,
                                  childAspectRatio: 0.75, // Sesuaikan rasio aspek jika FoodCard terlalu panjang/pendek
                                ),
                                itemCount: _searchResults.length,
                                itemBuilder: (context, index) {
                                  final recipe = _searchResults[index];
                                  return FoodCard( // Asumsi FoodCard bisa menerima model Food
                                    food: recipe,
                                    onCardTap: () {
                                      if (recipe.id != null) {
                                        print('DEBUG HASIL_PENCARIAN: Tapped recipe ID: ${recipe.id}');
                                        Navigator.pushNamed(context, '/detail-resep/${recipe.id}');
                                      } else {
                                        print('ERROR: Recipe ID is null for search result at index $index.');
                                      }
                                    },
                                    onFavoritePressed: () {
                                      print('Favorite pressed for ${recipe.name}');
                                      // Implementasi logika favorit (misalnya, panggil API)
                                    },
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