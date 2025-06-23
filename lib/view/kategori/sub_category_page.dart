// lib/view/kategori/sub_category_page.dart

import 'package:flutter/material.dart';
import 'package:masak2/view/component/bottom_navbar.dart';
import 'package:masak2/view/component/header_b_n_s.dart';
import 'package:masak2/models/food_model.dart';
import 'package:masak2/view/component/food_card_widget.dart';
import 'package:masak2/view/component/category_tab.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../recipe/resep_detail_page.dart';

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
    _foodsFuture = _fetchRecipesByCategoryId(widget.categoryId);
  }

  Future<List<Food>> _fetchRecipesByCategoryId(int categoryId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/categories/$categoryId/recipes'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        // --- PERBAIKAN DI SINI ---
        // Karena backend sudah mengirim key yang benar (title, image_url, dll),
        // kita bisa langsung menggunakan Food.fromJson
        return data.map((jsonItem) => Food.fromJson(jsonItem)).toList();
      } else {
        throw Exception('Gagal memuat resep: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching recipes: $e');
      throw Exception('Gagal konek ke server. Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
              showBackButton: true,
              showNotificationButton: true,
              showSearchButton: true,
            ),
            CategoryTabBar(
              categories: _categories,
              selectedIndex: _selectedCategoryIndex,
              onCategorySelected: (index) {
                // TODO: Implementasi logika sorting
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
      bottomNavigationBar: const BottomNavbar(SizedBox.shrink()),
    );
  }

  Widget _buildFoodGridView(List<Food> foods) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.75,
      ),
      itemCount: foods.length,
      itemBuilder: (context, index) {
        final recipe = foods[index];
        return FoodCard(
          food: recipe,
          onFavoritePressed: () {},
          onCardTap: () {
            if (recipe.id != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeDetailPage(recipeId: recipe.id!),
                ),
              );
            }
          },
        );
      },
    );
  }
}