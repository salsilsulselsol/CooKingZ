import 'package:flutter/material.dart';
import '../../theme/theme.dart';

// Widget untuk menampilkan card resep.
class RecipeCard extends StatelessWidget {
  final String title;
  final String rating;
  final String time;
  final String price;
  final String imagePath;
  final String? description; // Deskripsi resep (opsional).
  final bool showGlow;

  const RecipeCard({
    super.key,
    required this.title,
    required this.rating,
    required this.time,
    required this.price,
    required this.imagePath,
    this.description,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.recipeCardBorderRadius), // Menggunakan dari theme.dart
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: Colors.grey.shade300, // কাছাকাছি dengan yang Anda gunakan
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.recipeCardBorderRadius),
                  topRight: Radius.circular(AppTheme.recipeCardBorderRadius),
                ),
                child: Image.asset(
                  imagePath,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  child: Image.asset(
                    'images/love.png', // Pastikan path ini benar
                    height: 28,
                    width: 28,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(
                AppTheme.spacingMedium), // Menggunakan dari theme.dart
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.foodTitleStyle
                      .copyWith(fontWeight: FontWeight.bold), // Menggunakan dari theme.dart
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (description != null)
                  Text(
                    description!,
                    style: AppTheme.foodDescriptionStyle, // Menggunakan dari theme.dart
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: AppTheme.spacingSmall), // Menggunakan dari theme.dart
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      rating,
                      style: AppTheme.foodInfoStyle, // Menggunakan dari theme.dart
                    ),
                    Text(
                      time,
                      style: AppTheme.foodInfoStyle, // Menggunakan dari theme.dart
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'RP ',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.accentTeal, // Menggunakan dari theme.dart
                                fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: price.replaceFirst('RP ', ''),
                            style: TextStyle(
                                fontSize: 12, color: AppTheme.accentTeal), // Menggunakan dari theme.dart
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}