import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
      child: Container(
        margin: AppTheme.marginFoodCard,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFoodImage(),
            _buildFoodInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodImage() {
    // ==========================================================
    // **PERUBAHAN UTAMA ADA DI SINI**
    // Kita hanya cek apakah path gambar tidak kosong.
    // ==========================================================
    final bool hasImage = food.image.isNotEmpty;
    final String? imageUrl = hasImage ? '${dotenv.env['BASE_URL']}${food.image}' : null;

    final String ratingText = (food.rating == null || food.rating == 0) ? '-' : food.rating!.toStringAsFixed(1);

    return Container(
      height: AppTheme.foodCardImageHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            child: Container(
              color: Colors.grey[200],
              child: hasImage && imageUrl != null
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.broken_image, color: Colors.grey[600], size: 40);
                      },
                    )
                  : Icon(Icons.image_not_supported, color: Colors.grey[600], size: 40),
            ),
          ),
          
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
          
          Positioned(
            top: AppTheme.spacingMedium,
            left: AppTheme.spacingMedium,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha((0.5 * 255).toInt()),
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                  _buildInfoItem(
                    text: (food.likes ?? 0).toString(),
                    iconAsset: '',
                    iconFallback: Icons.favorite,
                    isTextFirst: false,
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

  Widget _buildInfoItem({ required String text, required String iconAsset, required IconData iconFallback, bool isTextFirst = true }) {
    final textWidget = Text(text, style: AppTheme.foodInfoStyle);
    
    Widget iconWidget;
    if (iconAsset.isNotEmpty) {
      iconWidget = Image.asset(
        iconAsset,
        width: AppTheme.iconSizeSmall,
        height: AppTheme.iconSizeSmall,
        color: AppTheme.accentTeal,
        errorBuilder: (context, error, stackTrace) {
          return Icon(iconFallback, color: AppTheme.accentTeal, size: AppTheme.iconSizeSmall);
        },
      );
    } else {
      iconWidget = Icon(iconFallback, color: AppTheme.accentTeal, size: AppTheme.iconSizeSmall);
    }

    return Row(
      children: isTextFirst
          ? [textWidget, const SizedBox(width: AppTheme.spacingSmall), iconWidget]
          : [iconWidget, const SizedBox(width: AppTheme.spacingSmall), textWidget],
    );
  }

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