// lib/view/kategori/sub_category_page.dart

import 'package:flutter/material.dart';
import 'package:masak2/view/component/bottom_navbar.dart';
import 'package:masak2/view/component/header_b_n_s.dart'; // Pastikan ini mengacu ke CustomHeader yang baru
import 'package:masak2/models/food_model.dart'; // Import Food model
import 'package:masak2/view/component/food_card_widget.dart'; // Import FoodCard widget
import 'package:masak2/view/component/category_tab.dart'; // Import CategoryTabBar
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../recipe/resep_detail_page.dart'; // Import halaman detail resep

class SubCategoryPage extends StatefulWidget {
  final String categoryName;
  final int categoryId;

  const SubCategoryPage({
    super.key,
    required this.categoryName,
    required this.categoryId,
  });

  @override
  State<SubCategoryPage> createState() => _SubCategoryPageState();
}

class _SubCategoryPageState extends State<SubCategoryPage> {
  final Color primaryColor = const Color(0xFF005A4D);
  final Color accentTeal = const Color(0xFF57B4BA);
  final Color emeraldGreen = const Color(0xFF015551);

  final List<String> _categories = [
    'Terbaru',
    'Populer',
    'Rating Tinggi',
  ];

  int _selectedCategoryIndex = 0;

  late Future<List<Food>> _foodsFuture;

  // Sesuaikan URL BASE_URL ini dengan alamat IP lokal Anda jika di emulator/perangkat fisik
  // Untuk emulator Android, gunakan 10.0.2.2
  // Untuk perangkat fisik, gunakan IP address komputer Anda (contoh: 192.168.1.xxx)
  final String _baseUrl = kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';

  @override
  void initState() {
    super.initState();
    // Panggil fungsi untuk mengambil resep dari CategoryController via endpoint baru
    _foodsFuture = _fetchRecipesByCategoryId(widget.categoryId);
  }

  // Fungsi untuk mengambil resep dari backend menggunakan endpoint CategoryController
  Future<List<Food>> _fetchRecipesByCategoryId(int categoryId) async {
    try {
      // Panggil endpoint /categories/:categoryId/recipes
      final response = await http.get(Uri.parse('$_baseUrl/categories/$categoryId/recipes'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        // Memetakan data JSON dari API ke format yang diharapkan oleh Food.fromJson
        // agar tidak muncul 'Resep Tanpa Nama' atau masalah lainnya.
        return data.map((jsonItem) {
          return Food.fromJson({
            'id': jsonItem['id'],
            'title': jsonItem['name'], // Mengubah 'name' dari API menjadi 'title' yang diharapkan Food.fromJson
            'description': jsonItem['description'],
            'image_url': jsonItem['image'], // Mengubah 'image' dari API menjadi 'image_url'
            'cooking_time': jsonItem['cookingTime'], // Mengubah 'cookingTime' dari API menjadi 'cooking_time'
            'avg_rating': jsonItem['rating'], // Mengubah 'rating' dari API menjadi 'avg_rating'
            'total_reviews': jsonItem['likes'], // Mengubah 'likes' dari API menjadi 'total_reviews'
            'price': jsonItem['price'],
            'difficulty': jsonItem['difficulty'],
            // 'detailRoute' tidak ada di API, jadi bisa diabaikan atau diset null
          });
        }).toList();
      } else {
        throw Exception('Failed to load recipes for category $categoryId: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error fetching recipes: $e');
      throw Exception('Failed to connect to the server or parse data. Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true, // Memungkinkan body meluas di bawah bottomNavigationBar
      body: SafeArea(
        bottom: false, // Tidak mempertimbangkan bottom padding dari SafeArea agar BottomNavbar bisa penuh
        child: Column(
          children: [
            CustomHeader(
              title: widget.categoryName,
              titleColor: primaryColor,
              showBackButton: true, // Tampilkan tombol kembali
              // backRoute: null, // Defaultnya akan pop, jadi tidak perlu disetel
              showNotificationButton: true, // Tampilkan tombol notifikasi (sesuai kebutuhan)
              showSearchButton: true, // Tampilkan tombol pencarian (sesuai kebutuhan)
            ),
            CategoryTabBar(
              categories: _categories,
              selectedIndex: _selectedCategoryIndex,
              onCategorySelected: (index) {
                setState(() {
                  _selectedCategoryIndex = index;
                  // TODO: Implement sorting logic based on selectedCategoryIndex
                  // Misalnya, Anda bisa memanggil ulang _fetchRecipesByCategoryId
                  // dengan parameter sort jika backend mendukungnya, atau
                  // melakukan sorting di sisi klien pada daftar 'foods' yang sudah diambil.
                });
              },
              primaryColor: primaryColor,
            ),
            Expanded(
              child: FutureBuilder<List<Food>>(
                future: _foodsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: primaryColor));
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: primaryColor)));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Tidak ada resep ditemukan untuk kategori ${widget.categoryName}.'));
                  } else {
                    final foods = snapshot.data!;
                    return _buildFoodGridView(foods);
                  }
                },
              ),
            ),
          ],
        ),
      ),
      // BottomNavbar harus di luar `_buildMainContent` jika `extendBody: true`
      bottomNavigationBar: BottomNavbar(
        const SizedBox.shrink(), // Placeholder kosong karena konten sudah ada di body
      ),
    );
  }

  Widget _buildFoodGridView(List<Food> foods) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(2, 20, 2, 110), // Padding bawah agar tidak tertutup BottomNavbar
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 0.50,
        mainAxisSpacing: 5,
        childAspectRatio: 3 / 3.5, // Sesuaikan rasio aspek jika FoodCard terlihat terlalu panjang/pendek
      ),
      itemCount: foods.length,
      itemBuilder: (context, index) {
        final recipe = foods[index]; // Ambil objek Food saat ini
        return FoodCard(
          food: recipe,
          onFavoritePressed: () {
            // TODO: Implement favorite logic (e.g., call API to toggle favorite status)
            setState(() {
              // Update state jika status favorit berubah
            });
          },
          onCardTap: () {
            // Navigasi ke halaman detail resep menggunakan Navigator.push
            // Anda bisa menggunakan MaterialPageRoute jika Anda tidak mendaftarkan named routes
            // atau Navigator.pushNamed jika Anda sudah mendaftarkan '/detail-resep/:id'
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecipeDetailPage(recipeId: recipe.id!), // Pastikan ID tidak null
              ),
            );
            // Atau jika Anda menggunakan named routes (pastikan terdaftar di main.dart):
            // Navigator.pushNamed(context, '/detail-resep/${recipe.id}');
          },
        );
      },
    );
  }
}
