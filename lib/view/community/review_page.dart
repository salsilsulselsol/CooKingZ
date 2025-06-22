// File: lib/view/community/review_page.dart (Versi Final - Khusus untuk Balasan Diskusi)

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import '../../theme/theme.dart';
import '../../view/component/header_back.dart'; // Ganti dengan path Anda
import '../../view/component/bottom_navbar.dart'; // Ganti dengan path Anda

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
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic>? _recipeData;

  @override
  void initState() {
    super.initState();
    _fetchPageData();
  }

  Future<void> _fetchPageData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Ambil detail resep untuk ditampilkan di card atas
      final recipeResponse = await http.get(Uri.parse('$_baseUrl/recipes/${widget.recipeId}'));
      if (recipeResponse.statusCode == 200) {
        if (mounted) setState(() => _recipeData = json.decode(recipeResponse.body));
      } else {
        throw Exception('Gagal mengambil detail resep: ${recipeResponse.statusCode}');
      }

      // Ambil semua ulasan dan balasannya
      final reviewsResponse = await http.get(Uri.parse('$_baseUrl/reviews/${widget.recipeId}'));
      if (reviewsResponse.statusCode == 200) {
        if (mounted) setState(() => _reviews = List<Map<String, dynamic>>.from(json.decode(reviewsResponse.body)));
      } else {
        throw Exception('Gagal mengambil ulasan: ${reviewsResponse.statusCode}');
      }
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'Terjadi kesalahan: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                onBackPressed: () => Navigator.pop(context),
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
                        Text(_errorMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _fetchPageData, child: const Text('Coba Lagi')),
                      ],
                    ),
                  ),
                )
                    : RefreshIndicator(
                  onRefresh: _fetchPageData,
                  child: _buildReviewsList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewsList() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 90, top: 8),
      children: [
        if (_recipeData != null) _buildRecipeCard(_recipeData!),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Text(
            'Balas diskusi pada ulasan di bawah ini.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: AppTheme.textBrown.withOpacity(0.8)),
          ),
        ),

        if (_reviews.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Belum ada ulasan. Jadilah yang pertama dari halaman detail resep!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          )
        else
          ..._reviews.map<Widget>((comment) {
            return _buildCommentThread(comment: comment, depth: 0);
          }).toList(),
      ],
    );
  }

  Widget _buildCommentThread({required Map<String, dynamic> comment, required int depth}) {
    final List<dynamic> replies = comment['replies'] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: (depth * 16.0), right: 16.0, top: 8, bottom: 8),
          child: _buildReviewCard(
            commentData: comment,
            onReply: () => _showReplyDialog(
              context: context,
              parentId: comment['id'],
              recipeId: widget.recipeId,
            ),
          ),
        ),
        if (replies.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(left: (depth * 16.0) + 16.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: Colors.grey.shade300, width: 2)),
              ),
              child: Column(
                children: replies.map<Widget>((reply) {
                  return _buildCommentThread(comment: reply, depth: depth + 1);
                }).toList(),
              ),
            ),
          )
      ],
    );
  }

  void _showReplyDialog({required BuildContext context, required int recipeId, required int parentId}) {
    final TextEditingController _commentController = TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tulis Balasan'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _commentController,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Balasan Anda...'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Balasan tidak boleh kosong.';
                return null;
              },
              maxLines: 3,
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _postComment(
                    recipeId: recipeId,
                    comment: _commentController.text,
                    parentId: parentId,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Kirim'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _postComment({required int recipeId, required String comment, int? parentId, int? rating}) async {
    // ==============================================================================
    // !! PENTING: Ganti `1` dengan ID pengguna yang sedang login dari state management Anda !!
    const int currentUserId = 1; // <-- INI HANYA CONTOH, HARUS DINAMIS
    // ==============================================================================

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/reviews'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': currentUserId,
          'recipe_id': recipeId,
          'comment': comment,
          'parent_id': parentId,
          'rating': rating,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Balasan berhasil dikirim!'), backgroundColor: Colors.green));
        _fetchPageData();
      } else if (response.statusCode == 409) {
        final error = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error['message'] ?? 'Anda sudah pernah mengulas resep ini.'), backgroundColor: Colors.orange[800]));
      } else {
        final error = json.decode(response.body);
        throw Exception('Gagal mengirim: ${error['message']}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    }
  }

  // --- Widget-widget dan fungsi helper lainnya ---

  Widget _buildRecipeCard(Map<String, dynamic> recipe) {
    final String recipeImageUrl = recipe['image_url'] != null && (recipe['image_url'] as String).isNotEmpty
        ? '$_baseUrl${recipe['image_url']}'
        : 'https://via.placeholder.com/100';
    final double averageRating = _parseDouble(recipe['average_rating'] ?? 0.0);
    final int commentsCount = _parseInt(recipe['comments_count'] ?? 0);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe['title']?.toString() ?? 'Resep Tidak Ditemukan',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ...List.generate(5, (index) {
                      return Icon(index < averageRating.round() ? Icons.star : Icons.star_border, size: 16, color: Colors.white);
                    }),
                    const SizedBox(width: 4),
                    Text('($commentsCount Ulasan)', style: const TextStyle(fontSize: 12, color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard({required Map<String, dynamic> commentData, required VoidCallback onReply}) {
    final String username = commentData['username']?.toString() ?? 'Pengguna';
    final String name = commentData['full_name']?.toString() ?? 'Tidak Dikenal';
    final String? profileImage = commentData['profile_picture']?.toString();
    final int rating = _parseRating(commentData['rating']);
    final String review = commentData['comment']?.toString() ?? '';
    final String createdAt = commentData['created_at']?.toString() ?? DateTime.now().toIso8601String();
    String finalProfileImageUrl = profileImage != null && profileImage.isNotEmpty ? '$_baseUrl$profileImage' : '';
    DateTime parsedCreatedAt;
    try {
      parsedCreatedAt = DateTime.parse(createdAt).toLocal();
    } catch (e) {
      parsedCreatedAt = DateTime.now();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.searchBarColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: finalProfileImageUrl.isNotEmpty ? NetworkImage(finalProfileImageUrl) : null,
                  child: finalProfileImageUrl.isEmpty ? Icon(Icons.person, color: Colors.grey[600], size: 24) : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('@$username', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryColor)),
                      if (name.isNotEmpty) Text(name, style: TextStyle(color: AppTheme.textBrown, fontSize: 12)),
                    ],
                  ),
                ),
                Text(DateFormat('dd MMM kk:mm').format(parsedCreatedAt), style: const TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          ),
          if (rating > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: List.generate(5, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 2),
                    child: Icon(index < rating ? Icons.star : Icons.star_border, size: 16, color: AppTheme.primaryColor),
                  );
                }),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(review, style: TextStyle(fontSize: 14, color: AppTheme.textBrown)),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 4.0, bottom: 4.0),
              child: TextButton.icon(
                icon: Icon(Icons.reply, size: 16, color: AppTheme.primaryColor),
                label: Text('Balas', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                onPressed: onReply,
                style: TextButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _parseRating(dynamic rating) {
    if (rating == null) return 0;
    if (rating is int) return rating;
    if (rating is String) return int.tryParse(rating) ?? 0;
    return 0;
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}