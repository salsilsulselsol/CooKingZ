import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'resep_detail_page.dart';

import '../component/food_card_widget.dart';
import '../../theme/theme.dart';
import '../component/header_back_PSN.dart';
import '../../models/food_model.dart';

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

  late Future<Map<String, List<Food>>> _recipesFuture;

  final String _baseUrl = kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';

  @override
  void initState() {
    super.initState();
    _recipesFuture = _initializeAllRecipes();
  }

  // Gabungkan semua logika dalam satu future
  Future<Map<String, List<Food>>> _initializeAllRecipes() async {
    try {
      // Fetch user recipes
      List<Food> allUserRecipes = await _fetchUserRecipes();

      // Sort by rating
      allUserRecipes.sort((a, b) => (b.rating ?? 0.0).compareTo(a.rating ?? 0.0));

      // Get top 2 for most viewed
      List<Food> mostViewedRecipes = allUserRecipes.take(2).toList();

      // Filter out most viewed from main list
      List<Food> filteredUserRecipes = allUserRecipes
          .where((recipe) => !mostViewedRecipes.any((mvRecipe) => mvRecipe.id == recipe.id))
          .toList();

      return {
        'mostViewed': mostViewedRecipes,
        'filtered': filteredUserRecipes,
      };
    } catch (e) {
      print('Error initializing recipes: $e');
      return {
        'mostViewed': <Food>[],
        'filtered': <Food>[],
      };
    }
  }

  Future<List<Food>> _fetchUserRecipes() async {
    const String userId = '1';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: HeaderBackPSN(),
      body: FutureBuilder<Map<String, List<Food>>>(
        future: _recipesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final recipesData = snapshot.data ?? {'mostViewed': <Food>[], 'filtered': <Food>[]};
          final mostViewedRecipes = recipesData['mostViewed']!;
          final filteredUserRecipes = recipesData['filtered']!;

          return SingleChildScrollView(
            padding: const EdgeInsets.only(top: AppTheme.spacingXLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Most Viewed Section
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
                      mostViewedRecipes.isEmpty
                          ? const Center(
                          child: Text(
                              'Tidak ada Rating Tertinggi dari Resep Anda.',
                              style: TextStyle(color: Colors.white)
                          )
                      )
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: mostViewedRecipes.map((food) => Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RecipeDetailPage(recipeId: food.id!),
                                ),
                              );
                            },
                            child: FoodCard(food: food),
                          ),
                        )).toList(),
                      ),
                    ],
                  ),
                ),

                // User Recipes Section
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
                      filteredUserRecipes.isEmpty
                          ? const Center(child: Text('No other user recipes found.'))
                          : GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: AppTheme.spacingMedium,
                        mainAxisSpacing: AppTheme.spacingXLarge,
                        childAspectRatio: 0.75,
                        children: filteredUserRecipes
                            .map((food) => InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecipeDetailPage(recipeId: food.id!),
                              ),
                            );
                          },
                          child: FoodCard(food: food),
                        ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}