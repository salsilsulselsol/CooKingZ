import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import '../../theme/theme.dart';
import '../../view/component/header_back.dart';
import '../../view/component/bottom_navbar.dart';

class ReviewsPage extends StatefulWidget {
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
  Map<String, dynamic>? _recipeData;

  @override
  void initState() {
    super.initState();
    _fetchPageData();
  }

  Future<void> _fetchPageData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Ambil detail resep
      final recipeResponse = await http.get(Uri.parse('$_baseUrl/recipes/${widget.recipeId}'));
      if (recipeResponse.statusCode == 200) {
        _recipeData = json.decode(recipeResponse.body);
        print('Recipe data: $_recipeData'); // Debug print
      } else {
        _errorMessage = 'Gagal mengambil detail resep: ${recipeResponse.statusCode}';
        _isLoading = false;
        if (mounted) setState(() {});
        return;
      }

      // Ambil ulasan
      final reviewsResponse = await http.get(Uri.parse('$_baseUrl/reviews/${widget.recipeId}'));
      if (reviewsResponse.statusCode == 200) {
        _reviews = json.decode(reviewsResponse.body);
        print('Reviews data: $_reviews'); // Debug print
      } else {
        _errorMessage = 'Gagal mengambil ulasan: ${reviewsResponse.statusCode}';
        _isLoading = false;
        if (mounted) setState(() {});
        return;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan jaringan: $e';
      print('Error: $e'); // Debug print
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
        backgroundColor: AppTheme.backgroundColor,
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchPageData,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
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
      padding: const EdgeInsets.only(bottom: 90),
      children: [
        // Recipe Card
        if (_recipeData != null) _buildRecipeCard(_recipeData!),

        // Reviews
        if (_reviews.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Belum ada ulasan untuk resep ini.',
                style: TextStyle(fontSize: 16, color: AppTheme.textBrown),
              ),
            ),
          )
        else
          ..._reviews.map<Widget>((reviewData) {
            // Debug print untuk setiap review
            print('Review data: $reviewData');

            return _buildReviewCard(
              username: reviewData['username']?.toString() ?? 'Pengguna',
              name: reviewData['full_name']?.toString() ?? 'Tidak Dikenal',
              profileImage: reviewData['profile_picture']?.toString(),
              reviewImage: null,
              rating: _parseRating(reviewData['rating']),
              review: reviewData['comment']?.toString() ?? 'Tidak ada komentar.',
              commentCount: 0,
              createdAt: reviewData['created_at']?.toString() ?? DateTime.now().toIso8601String(),
            );
          }).toList(),
      ],
    );
  }

  // Helper method untuk parsing rating
  int _parseRating(dynamic rating) {
    if (rating == null) return 0;
    if (rating is int) return rating;
    if (rating is double) return rating.round();
    if (rating is String) {
      try {
        return double.parse(rating).round();
      } catch (e) {
        return 0;
      }
    }
    return 0;
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe) {
    final String recipeImageUrl = recipe['image_url'] != null && (recipe['image_url'] as String).isNotEmpty
        ? '$_baseUrl${recipe['image_url']}'
        : 'https://via.placeholder.com/100';

    final double averageRating = _parseDouble(recipe['average_rating']);
    final int commentsCount = _parseInt(recipe['comments_count']);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
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
              child: Image.network(
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
                    recipe['title']?.toString() ?? 'Resep Tidak Ditemukan',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // Rating stars untuk rata-rata resep
                      ...List.generate(5, (index) {
                        return Icon(
                          index < averageRating.round() ? Icons.star : Icons.star_border,
                          size: 16,
                          color: Colors.white, // Kembali ke warna putih
                        );
                      }),
                      const SizedBox(width: 4),
                      Text(
                        '($commentsCount Reviews)',
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
                        backgroundImage: recipe['profile_picture'] != null && (recipe['profile_picture'] as String).isNotEmpty
                            ? NetworkImage('$_baseUrl${recipe['profile_picture']}')
                            : null,
                        child: recipe['profile_picture'] == null || (recipe['profile_picture'] as String).isEmpty
                            ? Icon(Icons.person, color: Colors.grey[600], size: 18)
                            : null,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '@${recipe['username']?.toString() ?? 'Pengguna'}', // Username pemilik resep
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              recipe['full_name']?.toString() ?? '', // Nama lengkap pemilik resep
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildReviewCard({
    required String username,
    required String name,
    String? profileImage,
    String? reviewImage,
    required int rating,
    required String review,
    required int commentCount,
    required String createdAt,
  }) {
    String finalProfileImageUrl = '';
    if (profileImage != null && profileImage.isNotEmpty) {
      finalProfileImageUrl = '$_baseUrl$profileImage';
    }

    DateTime parsedCreatedAt;
    try {
      parsedCreatedAt = DateTime.parse(createdAt);
    } catch (e) {
      parsedCreatedAt = DateTime.now();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.searchBarColor,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: finalProfileImageUrl.isNotEmpty
                          ? NetworkImage(finalProfileImageUrl)
                          : null,
                      child: finalProfileImageUrl.isEmpty
                          ? Icon(Icons.person, color: Colors.grey[600], size: 24)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '@$username', // Username yang memberikan review
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        if (name.isNotEmpty)
                          Text(
                            name, // Nama lengkap yang memberikan review
                            style: TextStyle(
                              color: AppTheme.textBrown,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                Text(
                  DateFormat('dd MMM yyyy').format(parsedCreatedAt),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          // Rating stars untuk review individual
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                ...List.generate(5, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 2),
                    child: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      size: 16,
                      color: AppTheme.primaryColor, // Tetap menggunakan warna tema
                    ),
                  );
                }),
                const SizedBox(width: 8),
                Text(
                  '($rating/5)',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Review Image (jika ada)
          if (reviewImage != null && reviewImage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                height: 140,
                width: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(reviewImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

          // Review text
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              review,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textBrown,
              ),
            ),
          ),

          // Comment count (jika ada)
          if (commentCount > 0)
            Align(
              alignment: Alignment.bottomRight,
              child: Transform.translate(
                offset: const Offset(0, 12),
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

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // Helper methods untuk parsing data
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        return 0;
      }
    }
    return 0;
  }
}