import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

class PenjadwalanPage extends StatefulWidget {
  const PenjadwalanPage({Key? key}) : super(key: key);

  @override
  State<PenjadwalanPage> createState() => _PenjadwalanPageState();
}

class _PenjadwalanPageState extends State<PenjadwalanPage> {
  // Sample data for scheduled recipes
  final List<ScheduledRecipe> scheduledRecipes = [
    ScheduledRecipe(
      date: DateTime(2025, 4, 1),
      recipe: Recipe(
      id: 1,
      name: 'Croffle Ice Cream',
      imageUrl: 'images/croffle.png',
      cookingTime: 15,
      rating: 4.2,
      likes: 213,
      price: 20,
      description: 'Croffle dengan es krim yang lezat.',
      ),
    ),
    ScheduledRecipe(
      date: DateTime(2025, 12, 11),
      recipe: Recipe(
      id: 2,
      name: 'Telur Dadar',
      imageUrl: 'images/telur_dadar.png',
      cookingTime: 30,
      rating: 4.5,
      likes: 89,
      price: 15,
      description: 'Telur dadar sederhana dan nikmat.',
      ),
    ),
  ];

 @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    appBar: PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.only(top: 30, left: 16, right: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Image.asset('images/arrow.png', width: 24, height: 24),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const Text(
              'Penjadwalan',
              style: TextStyle(
                color: Color(0xFF006666),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            IconButton(
              icon: Image.asset('images/calendar.png', width: 28, height: 28),
              onPressed: _showDatePicker,
            ),
          ],
        ),
      ),
    ),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 30, right: 16, top: 10),
        child: ListView.builder(
          itemCount: scheduledRecipes.length,
          itemBuilder: (context, index) {
            final scheduledRecipe = scheduledRecipes[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(scheduledRecipe.date),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF006666),
                  ),
                ),
                _buildRecipeCard(scheduledRecipe),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    ),
  );
}


  

  Widget _buildRecipeCard(ScheduledRecipe scheduledRecipe) {
    final recipe = scheduledRecipe.recipe;
    final currencyFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'RP',
      decimalDigits: 0,
    );
    
    return Container(
      margin: const EdgeInsets.only(right: 10, bottom: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF006666),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Stack(
          children: [
            InkWell(
              onTap: () {
                // Navigate to recipe detail page
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => RecipeDetailPage(),
                //   ),
                // );
              },
              child: Container(
                height: 265,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    // Recipe image with favorite button
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                          child: Image.asset(
                            recipe.imageUrl,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                            child: GestureDetector(
                            onTap: () {
                              // Handle favorite button press
                              //print('Favorite button pressed');
                            },
                            child: Container(
                              
                              child: Image.asset(
                              'images/love.png',
                              width: 24,
                              height: 24,
                              
                              ),
                            ),
                            
                          ),
                        ),
                      ],
                    ),
                    // Recipe info
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                            Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                              Text(
                                recipe.name,
                                style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                recipe.description.replaceAll('\n', ' '),
                                style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${recipe.likes}',
                                    style: const TextStyle(
                                      color: Color(0xFF65B0B0),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.star,
                                    color: Color(0xFF65B0B0),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 5),
                                  const Icon(
                                    Icons.access_time,
                                    color: Color(0xFF65B0B0),
                                    size: 16,
                                  ),
                                  Text(
                                    ' ${recipe.cookingTime}menit',
                                    style: const TextStyle(
                                      color: Color(0xFF65B0B0),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                ' ${currencyFormat.format(recipe.price)} RB',
                                style: const TextStyle(
                                  color: Color(0xFF65B0B0),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Delete button
            Positioned(
              top: 210,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF65B0B0),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isSelected) {
    return IconButton(
      icon: Icon(
        icon,
        color: isSelected ? const Color(0xFF006666) : Colors.grey,
        size: 28,
      ),
      onPressed: () {
        // Handle navigation
      },
    );
  }
  
  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    
    return '$day-$month-$year'.toLowerCase();
  }
  
  void _showDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF006666),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF006666),
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate != null) {
      // Handle the selected date
      // For example, add a new scheduled recipe for this date
    }
  }
}

// Data models
class Recipe {
  final int id;
  final String name;
  final String imageUrl;
  final int cookingTime;
  final double rating;
  final int likes;
  final double price;
  final String description;

  Recipe({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.cookingTime,
    required this.rating,
    required this.likes,
    required this.price,
    required this.description,
  });
}

class ScheduledRecipe {
  final DateTime date;
  final Recipe recipe;

  ScheduledRecipe({
    required this.date,
    required this.recipe,
  });
}