import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart'; // Untuk format tanggal
import '../../theme/theme.dart';
import '../../view/component/header_back.dart'; // Import the HeaderWidget
import '../../view/component/bottom_navbar.dart'; // Import BottomNavbar

class ReviewsPage extends StatefulWidget { // Nama kelas tetap ReviewsPage, bukan ReviewPage
  final int recipeId;
  final String recipeTitle;

  const ReviewsPage({
    super.key,
    required this.recipeId,
    required this.recipeTitle,
  });

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  final String _baseUrl = kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';
  List<dynamic> _reviews = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // Data resep untuk _buildRecipeCard
  Map<String, dynamic>? _recipeData;

  @override
  void initState() {
    super.initState();
    _fetchPageData(); // Panggil fungsi baru untuk ambil semua data
  }

  // Fungsi untuk mengambil semua data yang dibutuhkan (resep dan ulasan)
  Future<void> _fetchPageData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Ambil detail resep (untuk _buildRecipeCard)
      final recipeResponse = await http.get(Uri.parse('$_baseUrl/recipes/${widget.recipeId}'));
      if (recipeResponse.statusCode == 200) {
        _recipeData = json.decode(recipeResponse.body);
      } else {
        _errorMessage = 'Gagal mengambil detail resep: ${recipeResponse.statusCode} - ${json.decode(recipeResponse.body)['message'] ?? 'Unknown error'}';
        _isLoading = false;
        if (mounted) setState(() {});
        return;
      }

      // Ambil ulasan
      final reviewsResponse = await http.get(Uri.parse('$_baseUrl/reviews/${widget.recipeId}'));
      if (reviewsResponse.statusCode == 200) {
        _reviews = json.decode(reviewsResponse.body);
      } else {
        _errorMessage = 'Gagal mengambil ulasan: ${reviewsResponse.statusCode} - ${json.decode(reviewsResponse.body)['message'] ?? 'Unknown error'}';
        _isLoading = false;
        if (mounted) setState(() {});
        return;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan jaringan: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return BottomNavbar(
      Scaffold(
        backgroundColor: AppTheme.backgroundColor, // Menggunakan AppTheme.backgroundColor
        body: SafeArea(
          child: Column(
            children: [
              HeaderWidget(
                title: 'Ulasan & Diskusi',
                onBackPressed: () {
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                    : _errorMessage.isNotEmpty
                    ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                )
                    : _buildReviewsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewsList() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 90), // Padding untuk navbar
      children: [
        // Recipe Card - Sekarang menggunakan data dinamis
        _recipeData != null ? _buildRecipeCard(_recipeData!) : const SizedBox.shrink(),

        // Reviews - Sekarang menggunakan data dinamis
        if (_reviews.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Belum ada ulasan untuk resep ini.',
                style: TextStyle(fontSize: 16, color: AppTheme.textBrown),
              ),
            ),
          ),
        ..._reviews.map<Widget>((reviewData) {
          return _buildReviewCard(
            username: reviewData['username'] ?? 'Pengguna',
            name: reviewData['full_name'] ?? 'Tidak Dikenal',
            profileImage: reviewData['profile_picture'], // Ini akan diolah di dalam _buildReviewCard
            reviewImage: null, // Asumsi: tidak ada reviewImage dari backend untuk saat ini
            rating: reviewData['rating'] ?? 0,
            review: reviewData['comment'] ?? 'Tidak ada komentar.',
            commentCount: 0, // Backend Anda saat ini tidak mengembalikan ini untuk setiap review.
            // Jika perlu, Anda harus memodifikasi backend untuk menghitung balasan komentar.
            createdAt: reviewData['created_at'],
          );
        }).toList(),
      ],
    );
  }

  // Recipe info card with image on left, text on right
  // Menerima data resep sebagai parameter
  Widget _buildRecipeCard(Map<String, dynamic> recipe) {
    final String recipeImageUrl = recipe['image_url'] != null && (recipe['image_url'] as String).isNotEmpty
        ? '$_baseUrl${recipe['image_url']}'
        : 'https://via.placeholder.com/100'; // Placeholder jika tidak ada gambar

    final double averageRating = recipe['average_rating'] as double? ?? 0.0;
    final int commentsCount = recipe['comments_count'] as int? ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor, // Menggunakan warna dari AppTheme
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
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network( // Menggunakan Image.network untuk gambar dari URL
                recipeImageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe['title'] as String? ?? 'Resep Tidak Ditemukan',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      for (int i = 0; i < 5; i++)
                        Icon(
                          i < averageRating.round() ? Icons.star : Icons.star_border, // Pembulatan rating
                          size: 16,
                          color: Colors.white,
                        ),
                      const SizedBox(width: 4),
                      Text(
                        '(${commentsCount} Reviews)', // comments_count dari backend
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        // Untuk gambar profil penulis resep (dari recipeData), Anda juga perlu URL lengkapnya
                        backgroundImage: recipe['profile_picture'] != null && (recipe['profile_picture'] as String).isNotEmpty
                            ? NetworkImage('$_baseUrl${recipe['profile_picture']}')
                            : null,
                        child: recipe['profile_picture'] == null || (recipe['profile_picture'] as String).isEmpty
                            ? Icon(Icons.person, color: Colors.grey[600], size: 18)
                            : null,
                      ),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '@${recipe['username'] ?? 'Pengguna'}', // Username penulis resep
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            recipe['full_name'] ?? '', // Nama lengkap penulis resep
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Individual review card
  // Menerima data dinamis dari backend
  Widget _buildReviewCard({
    required String username,
    required String name,
    String? profileImage, // Nullable karena bisa jadi tidak ada
    String? reviewImage, // Nullable karena belum ada di backend
    required int rating,
    required String review,
    required int commentCount, // Tetap ada meski data dari backend belum mengembalikan ini
    required String createdAt, // Tambahkan ini
  }) {
    String finalProfileImageUrl = '';
    if (profileImage != null && profileImage.isNotEmpty) {
      finalProfileImageUrl = kIsWeb ? 'http://localhost:3000$profileImage' : 'http://10.0.2.2:3000$profileImage';
    }

    // Untuk reviewImage, jika ada dari backend, Anda bisa membuat URL serupa
    // final String? finalReviewImageUrl = reviewImage != null && reviewImage.isNotEmpty
    //     ? (kIsWeb ? 'http://localhost:3000$reviewImage' : 'http://10.0.2.2:3000$reviewImage')
    //     : null;

    final DateTime parsedCreatedAt = DateTime.parse(createdAt);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.searchBarColor, // Menggunakan warna dari AppTheme
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
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Agar tanggal di kanan
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20, // Mengurangi radius agar tidak terlalu besar
                      backgroundImage: finalProfileImageUrl.isNotEmpty
                          ? NetworkImage(finalProfileImageUrl)
                          : null,
                      child: finalProfileImageUrl.isEmpty
                          ? Icon(Icons.person, color: Colors.grey[600], size: 24) // Ukuran ikon disesuaikan
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14, // Ukuran font disesuaikan
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        Text(
                          name,
                          style: TextStyle(
                            color: AppTheme.textBrown, // Warna disesuaikan
                            fontSize: 12, // Ukuran font disesuaikan
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  DateFormat('dd MMMM yyyy').format(parsedCreatedAt), // Format tanggal
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          // Review Image (jika ada)
          if (reviewImage != null && reviewImage.isNotEmpty) // Tampilkan hanya jika ada reviewImage
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8), // Padding ditambahkan
              child: Container(
                height: 140,
                width: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(reviewImage), // Menggunakan NetworkImage
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    for (int i = 0; i < 5; i++) // Selalu tampilkan 5 bintang
                      Padding(
                        padding: const EdgeInsets.only(right: 2),
                        child: Icon(
                          i < rating ? Icons.star : Icons.star_border,
                          size: 16,
                          color: AppTheme.primaryColor, // Warna bintang
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  review,
                  style: TextStyle(fontSize: 14, color: AppTheme.textBrown), // Ukuran font dan warna disesuaikan
                ),
              ],
            ),
          ),
          // Bagian Komentar
          if (commentCount > 0) // Hanya tampilkan jika ada komentar
            Align(
              alignment: Alignment.bottomRight,
              child: Transform.translate(
                offset: const Offset(0, 12), // Menggeser ke bawah
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline,
                        size: 20,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$commentCount Komentar',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12), // Tambahkan sedikit spasi di bawah card review
        ],
      ),
    );
  }
}