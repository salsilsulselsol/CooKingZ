// File: lib/view/component/featured_resep_card.dart

import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class FeaturedRecipeCard extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const FeaturedRecipeCard({
    Key? key,
    required this.recipe,
  }) : super(key: key);

  // Helper widget untuk membuat item info (Ikon + Teks) agar kode tidak berulang
  Widget _buildInfoItem(BuildContext context, {required IconData icon, required Color iconColor, required String text}) {
    return Padding(
      // Beri sedikit jarak horizontal untuk setiap item
      padding: const EdgeInsets.symmetric(horizontal: 4.0), 
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 4),
          Text(text, style: AppTheme.foodInfoStyle),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ekstrak semua data dari map
    final String name = recipe['name'] ?? 'Resep Unggulan';
    final String imageUrl = recipe['imageUrl'] ?? '';
    final String description = recipe['description'] ?? 'Tidak ada deskripsi';
    final String likes = recipe['likes']?.toString() ?? '0';
    final String time = recipe['time'] ?? 'N/A';
    final String difficulty = recipe['difficulty'] ?? 'Mudah';
    final String price = recipe['price']?.toString() ?? '0';
    
    final num ratingValue = recipe['avg_rating'] ?? 0.0;
    final String rating = (ratingValue > 0) ? ratingValue.toStringAsFixed(1) : 'N/A';
    
    final recipeId = recipe['id'];

    return Container(
      margin: const EdgeInsets.only(top: 5, bottom: 15),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          if (recipeId != null) {
            Navigator.pushNamed(context, '/detail-resep/$recipeId');
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Bagian Gambar (tidak berubah) ---
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              child: Stack(
                children: [
                  Container(
                    height: AppTheme.foodCardImageHeight,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            height: AppTheme.foodCardImageHeight,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(child: CircularProgressIndicator());
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(Icons.broken_image, size: 60, color: Colors.grey[600]),
                              );
                            },
                          )
                        : Center(
                            child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey[600]),
                          ),
                  ),
                  Positioned(
                    top: AppTheme.spacingMedium,
                    right: AppTheme.spacingMedium,
                    child: SizedBox(
                      width: AppTheme.favoriteButtonSize + 6,
                      height: AppTheme.favoriteButtonSize + 6,
                      child: IconButton(
                        icon: Opacity(
                          opacity: 0.8,
                          child: Image.asset(
                            'images/love.png',
                            width: 30,
                            height: 30,
                          ),
                        ),
                        onPressed: () => print('Favorite button pressed'),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- Bagian Informasi Resep ---
            Transform.translate(
              offset: const Offset(0, -5),
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                    boxShadow: [AppTheme.boxShadowSmall],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  child: Column(
                    children: [
                      Text(
                        name,
                        style: AppTheme.foodTitleStyle.copyWith(fontSize: 14),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppTheme.spacingXSmall),
                      Text(
                        description,
                        style: AppTheme.foodDescriptionStyle.copyWith(fontSize: 10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTheme.spacingSmall),

                      // <<< PERUBAHAN UTAMA: MENGGUNAKAN WRAP UNTUK SEMUA INFO >>>
                      Wrap(
                        alignment: WrapAlignment.center, // Pusatkan semua item
                        spacing: 12.0, // Jarak horizontal antar item
                        runSpacing: 4.0, // Jarak vertikal jika item turun ke baris baru
                        children: [
                          _buildInfoItem(context, icon: Icons.star, iconColor: Colors.amber, text: rating),
                          _buildInfoItem(context, icon: Icons.favorite, iconColor: Colors.redAccent, text: likes),
                          _buildInfoItem(context, icon: Icons.timer_outlined, iconColor: AppTheme.accentTeal, text: time),
                          _buildInfoItem(context, icon: Icons.whatshot_outlined, iconColor: Colors.deepOrange, text: difficulty),
                          _buildInfoItem(context, icon: Icons.paid_outlined, iconColor: Colors.green, text: "Rp $price"),
                        ],
                      )
                      // <<< AKHIR PERUBAHAN >>>
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}