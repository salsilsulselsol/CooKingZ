import 'package:flutter/material.dart';
import '../component/header_b_n_s.dart'; // Import the CustomHeader widget
import '../component/featured_resep_card.dart'; // Import the new FeaturedRecipeCard widget
import '../../theme/theme.dart';

class TrendingResep extends StatefulWidget {
  const TrendingResep({super.key});

  @override
  State<TrendingResep> createState() => _TrendingResepState();
}

class _TrendingResepState extends State<TrendingResep> {
  // Data resep trending
  final List<Map<String, dynamic>> _trendingRecipes = [
    {
      'name': 'Croffle Ice Cream',
      'image': 'images/croffle.png',
      'description': 'Berikut adalah ikhtisar singkat bahan-bahannya...',
      'likes': '213',
      'time': '15menit',
      'price': '20RB'
    },
    {
      'name': 'Kari Ayam',
      'image': 'images/kari_ayam_komunitas.png',
      'description': 'Nikmat: Kari Ayam yang aromatik—campuran rempah-rempah yang kaya...',
      'likes': '45',
      'chef': 'Chef Josh Ryan',
      'difficulty': 'Mudah',
      'time': '45menit',
      'price': '50RB'
    },
    {
      'name': 'Gulai',
      'image': 'images/gulai.jpg',
      'description': 'Nikmat: Gulai yang lezat: ayam berbumbu...',
      'likes': '15',
      'chef': 'Chef Andre',
      'difficulty': 'Mudah',
      'time': '50menit',
      'price': '50RB'
    },
    {
      'name': 'Martabak Manis',
      'image': 'images/martabak_manis.png',
      'description': 'Campur tepung, garam, kayu manis, dan gula hingga merata...',
      'likes': '30',
      'chef': 'Chef Dian',
      'difficulty': 'Sedang',
      'time': '60menit',
      'price': '30RB'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(
              title: 'Resep Yang Sedang Tren',
              showBackButton: true,
              showNotificationButton: true,
              showSearchButton: true,
            ),
            FeaturedRecipeCard(
  recipe: _trendingRecipes[0],
),
            _buildRecipesList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipesList(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        itemCount: _trendingRecipes.length - 1,
        itemBuilder: (context, index) {
          return _buildRecipeCard(context, _trendingRecipes[index + 1]);
        },
      ),
    );
  }

  Widget _buildRecipeCard(BuildContext context, Map<String, dynamic> recipe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 140,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(AppTheme.recipeCardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                child: Image.asset(
                  recipe['image'],
                  height: 140,
                  width: 120,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Image.asset(
                  'images/love.png',
                  width: 24, // Ukuran lebih kecil
                  height: 24,
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    recipe['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textBrown,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    recipe['description'],
                    style: AppTheme.foodDescriptionStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (recipe['chef'] != null)
                    Text(
                      "By ${recipe['chef']}",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.accentTeal,
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'images/alarm.png',
                            width: 12,
                            height: 12,
                            color: AppTheme.accentTeal,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            recipe['time'],
                            style: AppTheme.foodInfoStyle,
                          ),
                        ],
                      ),
                      Text(
                        recipe['difficulty'] ?? '-',
                        style: AppTheme.foodInfoStyle,
                      ),
                      Row(
                        children: [
                          Text(
                            recipe['likes'],
                            style: AppTheme.foodPriceStyle,
                          ),
                          const SizedBox(width: 4),
                          Image.asset(
                            'images/star.png',
                            width: 12,
                            height: 12,
                            color: AppTheme.accentTeal,
                          ),
                        ],
                      ),
                      Text(
                        "Rp ${recipe['price']}",
                        style: AppTheme.foodPriceStyle,
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
}
