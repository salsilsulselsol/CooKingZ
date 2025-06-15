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
  final Color accentTeal = const Color(0xFF57B4BA);

  late Future<List<Map<String, dynamic>>> _categoriesFuture;
  List<Map<String, dynamic>> _categories = [];

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
        throw Exception('Failed to load categories: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error fetching categories: $e');
      throw Exception('Failed to connect to the server or parse data. Error: $e');
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
      extendBody: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CustomHeader(
              title: 'Kategori',
              titleColor: primaryColor,
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _categoriesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: primaryColor)));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Tidak ada kategori ditemukan.'));
                  } else {
                    _categories = snapshot.data!;
                    return _buildCategoryGrid();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    if (_categories.isEmpty) {
      return const Center(child: Text('Tidak ada kategori untuk ditampilkan.'));
    }

    List<Widget> gridItems = [];

    // Kategori pertama (besar)
    if (_categories.isNotEmpty) {
      gridItems.add(_buildLargeCategory(_categories[0]));
      gridItems.add(const SizedBox(height: 16));
    }

    // Kategori lainnya (kecil, dua kolom)
    for (int i = 1; i < _categories.length; i += 2) {
      if (i + 1 < _categories.length) {
        gridItems.add(
          Row(
            children: [
              Expanded(child: _buildSmallCategory(_categories[i])),
              const SizedBox(width: 16),
              Expanded(child: _buildSmallCategory(_categories[i + 1])),
            ],
          ),
        );
      } else {
        gridItems.add(
          Row(
            children: [
              Expanded(child: _buildSmallCategory(_categories[i])),
              const Spacer(),
            ],
          ),
        );
      }
      if (i + 2 < _categories.length || (i + 1 < _categories.length && _categories.length % 2 != 0)) {
        gridItems.add(const SizedBox(height: 16));
      }
    }

    gridItems.add(const SizedBox(height: 90));

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: gridItems,
      ),
    );
  }

  Widget _buildLargeCategory(Map<String, dynamic> category) {
    final int categoryId = category['id'] as int? ?? 0;
    final String categoryName = category['name'] as String? ?? 'Unknown Category';
    final String imageUrl = category['image_url'] as String? ?? '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BottomNavbar(
              SubCategoryPage(
                categoryName: categoryName,
                categoryId: categoryId,
              ),
            ),
          ),
        );
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Center(
              child: Text(
                categoryName,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                      color: primaryColor,
                    ),
                  );
                },
                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                  return Image.asset('images/placeholder_image.png', fit: BoxFit.cover);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallCategory(Map<String, dynamic> category) {
    final int categoryId = category['id'] as int? ?? 0;
    final String categoryName = category['name'] as String? ?? 'Unknown Category';
    final String imageUrl = category['image_url'] as String? ?? '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BottomNavbar(
              SubCategoryPage(
                categoryName: categoryName,
                categoryId: categoryId,
              ),
            ),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                      color: primaryColor,
                    ),
                  );
                },
                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                  return Image.asset('images/placeholder_image.png', fit: BoxFit.cover);
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Center(
              child: Text(
                categoryName,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}