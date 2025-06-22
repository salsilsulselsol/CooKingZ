import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:timeago/timeago.dart' as timeago;

import '../../models/recipe_model.dart';

// Import komponen UI Anda
import '../../view/component/header_b_n_s.dart';
import '../../view/component/bottom_navbar.dart';
import '../../theme/theme.dart';

import '../recipe/resep_detail_page.dart';

class KomunitasPage extends StatefulWidget {
  const KomunitasPage({Key? key}) : super(key: key);
  @override
  State<KomunitasPage> createState() => _KomunitasPageState();
}

class _KomunitasPageState extends State<KomunitasPage> {
  // === STATE MANAGEMENT BARU ===
  bool _isLoading = true;
  List<Recipe> _recipes = [];
  String? _errorMessage;

  // Define tab options
  final List<String> _tabs = ['Trending', 'Terbaru', 'Terlama'];
  // Map tab names to API sort parameters
  final List<String> _sortParams = ['trending', 'newest', 'oldest'];

  // Track the currently selected tab
  int _selectedTabIndex = 0;

  // Alamat IP backend Anda (JANGAN GUNAKAN LOCALHOST)
  final String _baseUrl = 'http://localhost:3000';

  @override
  void initState() {
    super.initState();
    // Atur locale untuk timeago
    timeago.setLocaleMessages('id', timeago.IdMessages());
    // Ambil data pertama kali saat halaman dimuat
    _fetchRecipes();
  }

  // === FUNGSI PENGAMBIL DATA DARI API ===
  Future<void> _fetchRecipes() async {
    // Set state loading menjadi true sebelum request
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Ambil parameter sort berdasarkan tab yang dipilih
      final sortParam = _sortParams[_selectedTabIndex];
      final url = Uri.parse('$_baseUrl/recipes?sort=$sortParam');

      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      }).timeout(const Duration(seconds: 15)); // Timeout setelah 15 detik

      if (response.statusCode == 200) {
        final List<dynamic> decodedData = json.decode(response.body);

        // Konversi data JSON menjadi list objek Recipe
        final List<Recipe> fetchedRecipes = decodedData
            .map((json) => Recipe.fromJson(json))
            .toList();

        setState(() {
          _recipes = fetchedRecipes;
          _isLoading = false;
        });
      } else {
        // Jika server merespon dengan error
        setState(() {
          _errorMessage = "Gagal memuat data. Status: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      // Jika terjadi error (timeout, tidak ada koneksi, dll)
      setState(() {
        _errorMessage = "Terjadi kesalahan: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  // Handler untuk tab selection
  void _onTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
    // Panggil kembali API untuk mendapatkan data yang sudah disortir
    _fetchRecipes();
  }


  @override
  Widget build(BuildContext context) {
    return BottomNavbar(
      _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CustomHeader(
              title: 'Komunitas',
              titleColor: const Color(0xFF035E53),
            ),
            _buildTabBar(),
            Expanded(
              // Ganti pemanggilan _buildRecipeList dengan _buildContentBody
              child: _buildContentBody(),
            ),
          ],
        ),
      ),
    );
  }

  // Widget baru untuk menampilkan konten berdasarkan state (loading, error, data)
  Widget _buildContentBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF035E53)));
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: Colors.red[700])),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchRecipes,
                child: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF035E53)),
              )
            ],
          ),
        ),
      );
    }
    if (_recipes.isEmpty) {
      return const Center(child: Text('Belum ada resep yang dibagikan.'));
    }
    // Jika data ada, tampilkan list resep
    return _buildRecipeList();
  }

  // Tab bar untuk Trending, Newest, Oldest (Tidak ada perubahan di sini)
  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_tabs.length, (index) {
            return Row(
              children: [
                _buildTab(_tabs[index],
                    isSelected: _selectedTabIndex == index,
                    onTap: () => _onTabSelected(index)
                ),
                if (index < _tabs.length - 1) const SizedBox(width: 16),
              ],
            );
          }),
        ),
      ),
    );
  }

  // Build individual tab with tap functionality (Tidak ada perubahan di sini)
  Widget _buildTab(String text, {required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF035E53) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF035E53),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }


  // Recipe list (sekarang menggunakan _recipes dari state)
  Widget _buildRecipeList() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 90),
      itemCount: _recipes.length,
      itemBuilder: (context, index) {
        final recipe = _recipes[index];
        // Gunakan objek Recipe untuk membangun card
        return _buildRecipeCard(recipe: recipe);
      },
    );
  }

  // Individual recipe card (sekarang menerima objek Recipe)
  // Letakkan fungsi ini di dalam class _KomunitasPageState di file komunitas_page.dart

  Widget _buildRecipeCard({ required Recipe recipe }) {
    // URL gambar profil, dengan gambar default jika dari API null
    final profileImageUrl = recipe.profilePicture != null && recipe.profilePicture!.isNotEmpty
        ? '$_baseUrl${recipe.profilePicture}'
        : 'assets/images/default_avatar.png'; // Pastikan path gambar default benar

    // Bungkus seluruh kartu dengan InkWell agar bisa di-tap
    return InkWell(
      onTap: () {
        // Aksi ketika kartu di-tap: Navigasi ke halaman detail
        print('Navigasi ke detail untuk resep ID: ${recipe.id}');
        Navigator.push(
          context,
          MaterialPageRoute(
            // Kirim 'recipeId' yang dibutuhkan oleh RecipeDetailPage
            builder: (context) => RecipeDetailPage(recipeId: recipe.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian Info Pengguna (Avatar, Username, Waktu)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: recipe.profilePicture != null && recipe.profilePicture!.isNotEmpty
                        ? NetworkImage(profileImageUrl)
                        : const AssetImage('images/default_avatar.png') as ImageProvider,
                    onBackgroundImageError: (e, s) { /* handle error jika perlu */ },
                    backgroundColor: Colors.grey[200],
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '@${recipe.username}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        // Gunakan package timeago untuk format waktu
                        recipe.createdAt != null ? timeago.format(recipe.createdAt!, locale: 'id') : 'Baru saja',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Bagian Gambar Resep
            Stack(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      // Ambil gambar dari URL API
                      image: NetworkImage('$_baseUrl${recipe.imageUrl}'),
                      fit: BoxFit.cover,
                      // Tampilkan icon error jika gambar gagal dimuat
                      onError: (e, stackTrace) => const Icon(Icons.error),
                    ),
                  ),
                ),
                // Tombol Favorit (sesuai desain awal Anda)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    child: Image.asset(
                      'images/love.png', // Pastikan path ini benar
                      width: 30,
                      height: 30,
                    ),
                  ),
                ),
              ],
            ),
            // Bagian Info Resep (Judul, Deskripsi, Likes, Komentar)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFF035E53),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recipe.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              recipe.description,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Bagian Likes dan Komentar
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.favorite,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                recipe.favoritesCount.toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.comment,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                recipe.commentsCount.toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}