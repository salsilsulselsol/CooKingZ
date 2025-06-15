import 'package:flutter/material.dart';
import 'package:masak2/view/component/bottom_navbar.dart';
import 'package:masak2/view/component/header_b_n_s.dart';
import 'package:masak2/models/food_model.dart';
import 'package:masak2/view/component/food_card_widget.dart';
import 'package:masak2/view/component/category_tab.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

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
        return data.map((json) => Food.fromJson(json)).toList();
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
    return BottomNavbar(
      _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CustomHeader(
              title: widget.categoryName,
              titleColor: primaryColor,
            ),
            CategoryTabBar(
              categories: _categories,
              selectedIndex: _selectedCategoryIndex,
              onCategorySelected: (index) {
                setState(() {
                  _selectedCategoryIndex = index;
                });
              },
              primaryColor: primaryColor,
            ),
            Expanded(
              child: FutureBuilder<List<Food>>(
                future: _foodsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
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
    );
  }

  Widget _buildFoodGridView(List<Food> foods) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(2, 20, 2, 110),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 0.50,
        mainAxisSpacing: 5,
        childAspectRatio: 3 / 3.5,
      ),
      itemCount: foods.length,
      itemBuilder: (context, index) {
        return FoodCard(
          food: foods[index],
          onFavoritePressed: () {
            setState(() {
            });
          },
          onCardTap: () {
          },
        );
      },
    );
  }
}