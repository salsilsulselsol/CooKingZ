// lib/view/component/food_card_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // <-- Pastikan import ini ada
import '../../theme/theme.dart';
import '../../models/food_model.dart';

class FoodCard extends StatelessWidget {
  final Food food;
  final Function()? onFavoritePressed;
  final Function()? onCardTap;

  const FoodCard({
    Key? key,
    required this.food,
    this.onFavoritePressed,
    this.onCardTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCardTap,
      child: IntrinsicHeight(
        child: Container(
          margin: AppTheme.marginFoodCard,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildFoodImage(), // Perubahan ada di dalam widget ini
              _buildFoodInfo(),  // dan widget ini
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFoodImage() {
    Widget imageWidget;
    final String imagePath = food.image;

    // Logika untuk memilih sumber gambar (TIDAK DIUBAH)
    if (imagePath.contains('/uploads/')) {
      final baseUrl = dotenv.env['BASE_URL'];
      if (baseUrl == null) {
        imageWidget = const Center(child: Text('.env error'));
      } else {
        final imageUrl = '$baseUrl$imagePath';
        imageWidget = Image.network(
          imageUrl,
          height: 1000,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: AppTheme.foodCardImageHeight,
              color: Colors.grey[200],
              child: Icon(Icons.broken_image, color: Colors.grey[600], size: 40),
            );
          },
        );
      }
    } else {
      imageWidget = Image.asset(
        'images/$imagePath',
        height: 1000,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: AppTheme.foodCardImageHeight,
            color: Colors.grey[200],
            child: Icon(Icons.image_not_supported, color: Colors.grey[600], size: 40),
          );
        },
      );
    }
    
    // Logika untuk teks rating
    // Jika rating null atau 0, tampilkan '-', selain itu tampilkan angkanya.
    final String ratingText = (food.rating == null || food.rating == 0) ? '-' : food.rating!.toStringAsFixed(1);

    // Layout asli Anda dipertahankan, hanya menambahkan Positioned baru untuk rating
    return Container(
      height: AppTheme.foodCardImageHeight,
      width: double.infinity,
      alignment: Alignment.topRight,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            child: imageWidget, // <-- Menggunakan widget gambar yang sudah dipilih
          ),
          
          // Tombol favorit pojok kanan atas (KODE ASLI ANDA, TIDAK DIUBAH)
          Positioned(
            top: AppTheme.spacingMedium,
            right: AppTheme.spacingMedium,
            child: GestureDetector(
              onTap: onFavoritePressed,
              child: Container(
                width: AppTheme.favoriteButtonSize,
                height: AppTheme.favoriteButtonSize,
                child: Center(
                  child: Image.asset(
                    'images/love.png',
                    width: AppTheme.favoriteIconSize,
                    height: AppTheme.favoriteIconSize,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.favorite_border, color: Colors.white, size: 16);
                    },
                  ),
                ),
              ),
            ),
          ),
          
          // ==========================================================
          // **PERUBAHAN 1: MENAMBAHKAN RATING DI POJOK KIRI ATAS**
          // ==========================================================
          Positioned(
            top: AppTheme.spacingMedium,
            left: AppTheme.spacingMedium,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.yellow, size: 14),
                  const SizedBox(width: 4),
                  Text(ratingText, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodInfo() {
    return IntrinsicHeight(
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide.none,
            left: BorderSide(color: AppTheme.emeraldGreen, width: AppTheme.borderWidth),
            right: BorderSide(color: AppTheme.emeraldGreen, width: AppTheme.borderWidth),
            bottom: BorderSide(color: AppTheme.emeraldGreen, width: AppTheme.borderWidth),
          ),
          borderRadius: const BorderRadius.only(
            bottomRight: Radius.circular(AppTheme.borderRadiusMedium),
            bottomLeft: Radius.circular(AppTheme.borderRadiusMedium),
          ),
        ),
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.symmetric(horizontal: 7),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: AppTheme.paddingFoodCardContent,
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: AppTheme.foodTitleStyle,
                  ),
                  const SizedBox(height: AppTheme.spacingXSmall),
                  Text(
                    food.description ?? '',
                    style: AppTheme.foodDescriptionStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              margin: AppTheme.paddingFoodCardInfo,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // ====================================================================
                  // **PERUBAHAN 2: MENGUBAH BINTANG HIJAU MENJADI IKON LOVE DI KIRI**
                  // ====================================================================
                  _buildInfoItem(
                    text: (food.likes ?? 0).toString(),
                    iconAsset: '', // Dikosongkan agar memakai iconFallback
                    iconFallback: Icons.favorite, // Menggunakan ikon love dari Flutter
                    isTextFirst: false, // Posisi ikon di sebelah kiri teks
                  ),
                  _buildInfoItem(
                    text: food.cookingTime != null ? '${food.cookingTime} menit' : '-',
                    iconAsset: 'images/time.png',
                    iconFallback: Icons.access_time,
                    isTextFirst: false,
                  ),
                  _buildPriceItem(food.price ?? '-'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildInfoItem tidak diubah sama sekali
  Widget _buildInfoItem({ required String text, required String iconAsset, required IconData iconFallback, bool isTextFirst = true }) {
    final textWidget = Text(text, style: AppTheme.foodInfoStyle);
    final iconWidget = Image.asset(
      iconAsset,
      width: AppTheme.iconSizeSmall,
      height: AppTheme.iconSizeSmall,
      color: AppTheme.accentTeal,
      errorBuilder: (context, error, stackTrace) {
        return Icon(iconFallback, color: AppTheme.accentTeal, size: AppTheme.iconSizeSmall);
      },
    );
    return Row(
      children: isTextFirst
          ? [textWidget, const SizedBox(width: AppTheme.spacingSmall), iconWidget]
          : [iconWidget, const SizedBox(width: AppTheme.spacingSmall), textWidget],
    );
  }

  // Widget _buildPriceItem tidak diubah sama sekali
  Widget _buildPriceItem(String price) {
    return Row(
      children: [
        Text("RP", style: AppTheme.foodPriceStyle),
        const SizedBox(width: AppTheme.spacingSmall),
        Text(price, style: AppTheme.foodInfoStyle),
      ],
    );
  }
}