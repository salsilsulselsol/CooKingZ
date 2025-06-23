// lib/view/kategori/category_page.dart

import 'package:flutter/material.dart';
import 'package:masak2/view/kategori/sub_category_page.dart';
import 'package:masak2/view/component/bottom_navbar.dart';
import 'package:masak2/view/component/header_b_n_s.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final Color primaryColor = const Color(0xFF005A4D);
  late Future<List<Map<String, dynamic>>> _categoriesFuture;
  final String _baseUrl = kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _fetchCategories();
  }

  Future<List<Map<String, dynamic>>> _fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/categories'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Gagal memuat kategori: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching categories: $e');
      throw Exception('Gagal terkoneksi ke server. Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavbar(
      _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(
              title: 'Kategori',
              titleColor: primaryColor,
              showBackButton: false,
              showNotificationButton: true,
              showSearchButton: true,
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _categoriesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: primaryColor));
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: primaryColor)));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Tidak ada kategori ditemukan.'));
                  } else {
                    final categories = snapshot.data!;
                    return _buildCategoryGrid(categories);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(List<Map<String, dynamic>> categories) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        if (categories.isNotEmpty) _buildLargeCategory(categories[0]),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.9,
          ),
          itemCount: categories.length - 1,
          itemBuilder: (context, index) {
            return _buildSmallCategory(categories[index + 1]);
          },
        ),
        const SizedBox(height: 90),
      ],
    );
  }

  Widget _buildCardContent(Map<String, dynamic> category, bool isLarge) {
    final int categoryId = category['id'] ?? 0;
    final String categoryName = category['name'] ?? 'Kategori Tidak Dikenal';
    
    // --- PERBAIKAN DI SINI ---
    final String relativePath = category['image_url'] ?? '';
    final String fullImageUrl = relativePath.isNotEmpty ? '$_baseUrl$relativePath' : '';
    
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubCategoryPage(
            categoryId: categoryId,
            categoryName: categoryName,
          ),
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildImage(fullImageUrl),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Text(
              categoryName,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isLarge ? 18 : 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLargeCategory(Map<String, dynamic> category) {
    return Container(
      height: 180,
      width: double.infinity,
      child: _buildCardContent(category, true),
    );
  }

  Widget _buildSmallCategory(Map<String, dynamic> category) {
    return _buildCardContent(category, false);
  }

  Widget _buildImage(String url) {
    if (url.isEmpty) {
      return Image.asset('images/placeholder_image.png', fit: BoxFit.cover);
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Center(child: CircularProgressIndicator(color: primaryColor));
      },
      errorBuilder: (context, error, stackTrace) {
        print("Error loading image: $url - $error");
        return Image.asset('images/placeholder_image.png', fit: BoxFit.cover);
      },
    );
  }
}