import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'resep_detail_page.dart';

import '../component/food_card_widget.dart';
import '../../theme/theme.dart';
import '../component/header_back_PSN.dart';
import '../../models/food_model.dart'; // Pastikan path ini benar ke model Food Anda

class ResepAndaPage extends StatefulWidget {
  const ResepAndaPage({super.key});

  @override
  State<ResepAndaPage> createState() => _ResepAndaPageState();
}

class _ResepAndaPageState extends State<ResepAndaPage> {
  final EdgeInsets paddingGridView = const EdgeInsets.symmetric(
    horizontal: AppTheme.spacingXLarge,
    vertical: AppTheme.spacingXLarge,
  );

  late Future<List<Food>> _userRecipesFuture;
  late Future<List<Food>> _mostViewedRecipesFuture;
  List<Food>? _userRecipesData; // Variabel untuk menyimpan data resep pengguna
  List<Food>? _filteredUserRecipesData; // Variabel untuk menyimpan data resep pengguna yang sudah difilter

  // Gunakan logika deteksi web/emulator untuk menentukan base URL API
  final String _baseUrl = kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000'; // ATAU gunakan IP komputer Anda jika di perangkat fisik

  @override
  void initState() {
    super.initState();
    _initializeRecipes();
  }

  void _initializeRecipes() {
    _userRecipesFuture = _fetchUserRecipes().then((recipes) {
      // Sort all user recipes by rating (highest first)
      recipes.sort((a, b) => (b.rating ?? 0.0).compareTo(a.rating ?? 0.0));
      _userRecipesData = recipes; // Store all fetched recipes
      return recipes;
    }).catchError((error) {
      print('Error fetching user recipes in initState: $error');
      return <Food>[];
    }).whenComplete(() {
      // After all user recipes are fetched and sorted, determine most viewed
      _mostViewedRecipesFuture = _fetchMostViewedRecipes();
      // Filter out the most viewed recipes from the main list
      _filterUserRecipesForDisplay();
    });
    _mostViewedRecipesFuture = Future.value([]); // Initialize with an empty future
  }

  // Function to fetch user recipes from the API
  Future<List<Food>> _fetchUserRecipes() async {
    const String userId = '1'; // Ganti dengan ID pengguna yang sebenarnya saat sudah ada sistem autentikasi

    if (userId == null) {
      throw Exception('User not authenticated. Please log in.');
    }

    try {
      final response = await http.get(Uri.parse('$_baseUrl/users/$userId/recipes'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Food.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load user recipes: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error fetching user recipes: $e');
      throw Exception('Failed to connect to the server or parse data. Error: $e');
    }
  }

  // Function to get the top 2 most viewed recipes (based on rating)
  Future<List<Food>> _fetchMostViewedRecipes() async {
    if (_userRecipesData != null && _userRecipesData!.isNotEmpty) {
      // Since _userRecipesData is already sorted by rating, just take the top 2
      return _userRecipesData!.take(2).toList();
    } else {
      return [];
    }
  }

  // Function to filter out the most viewed recipes from the main list
  void _filterUserRecipesForDisplay() {
    if (_userRecipesData == null) {
      _filteredUserRecipesData = [];
      return;
    }

    List<Food> mostViewed = [];
    if (_userRecipesData!.isNotEmpty) {
      mostViewed = _userRecipesData!.take(2).toList();
    }

    // Create a new list containing recipes that are NOT in the mostViewed list
    _filteredUserRecipesData = _userRecipesData!
        .where((recipe) => !mostViewed.any((mvRecipe) => mvRecipe.id == recipe.id))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: HeaderBackPSN(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: AppTheme.spacingXLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 0),
              padding: const EdgeInsets.all(AppTheme.mostViewedContainerPadding),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(AppTheme.recipeCardBorderRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rating Tertinggi dari Resep Anda',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppTheme.spacingXLarge),
                  FutureBuilder<List<Food>>(
                    future: _mostViewedRecipesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator(color: Colors.white));
                      } else if (snapshot.hasError) {
                        return Center(
                            child: Text('Error: ${snapshot.error}',
                                style: const TextStyle(color: Colors.white)));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child: Text('Tidak ada Rating Tertinggi dari Resep Anda.',
                                style: TextStyle(color: Colors.white)));
                      } else {
                        final mostViewedRecipes = snapshot.data!;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: mostViewedRecipes.map((food) => Expanded(
                            child: InkWell( // <-- DIBUNGKUS DENGAN INKWELL

                              // Ini adalah perintah yang dijalankan saat kartu diklik
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RecipeDetailPage(recipeId: food.id!),
                                  ),
                                );
                              },

                              // Ini adalah kartu resep Anda
                              child: FoodCard(food: food),
                            ),
                          ))
                              .toList(),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: paddingGridView,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resep Anda',
                    style: AppTheme.foodTitleStyle,
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  FutureBuilder<List<Food>>(
                    future: _userRecipesFuture, // Still use the original future to wait for all data
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (_filteredUserRecipesData == null || _filteredUserRecipesData!.isEmpty) {
                        // Use _filteredUserRecipesData for rendering the main list
                        return const Center(child: Text('No other user recipes found.'));
                      } else {
                        final userRecipesToDisplay = _filteredUserRecipesData!;
                        return GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: AppTheme.spacingMedium,
                          mainAxisSpacing: AppTheme.spacingXLarge,
                          childAspectRatio: 0.75,
                          children: userRecipesToDisplay
                              .map((food) => InkWell( // <-- DIBUNGKUS DENGAN INKWELL
                            // Perintah untuk pindah halaman saat diklik
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RecipeDetailPage(recipeId: food.id!),
                                ),
                              );
                            },
                            // Kartu resep Anda
                            child: FoodCard(food: food),
                          ))
                              .toList(),
                        );
                      }
                    },
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