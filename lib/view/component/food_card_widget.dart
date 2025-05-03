import 'package:flutter/material.dart';
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
              // Food image with position settings
              _buildFoodImage(),
              _buildFoodInfo(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget for food image and favorite button
  Widget _buildFoodImage() {
    return Container(
      height: AppTheme.foodCardImageHeight,
      width: double.infinity,
      alignment: Alignment.topRight,
      child: Stack(
        children: [
          // Food image with rounded corners
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            child: Image.asset(
              food.image,
              height: 1000,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: AppTheme.foodCardImageHeight,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: Icon(Icons.restaurant, color: Colors.grey[600], size: 40),
                );
              },
            ),
          ),
          // Favorite button (heart icon)
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
        ],
      ),
    );
  }

  // Widget for food information (name, description, details)
  Widget _buildFoodInfo() {
    return IntrinsicHeight(
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide.none,
            left: BorderSide(
              color: AppTheme.emeraldGreen,
              width: AppTheme.borderWidth,
            ),
            right: BorderSide(
              color: AppTheme.emeraldGreen,
              width: AppTheme.borderWidth,
            ),
            bottom: BorderSide(
              color: AppTheme.emeraldGreen,
              width: AppTheme.borderWidth,
            ),
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
            // Food Name and Description
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
                    food.description ?? '', // Handle nullable description
                    style: AppTheme.foodDescriptionStyle,
                  ),
                ],
              ),
            ),
            // Likes, Duration, Price
            Container(
              margin: AppTheme.paddingFoodCardInfo,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildInfoItem(
                    text: food.likes.toString(),
                    iconAsset: 'images/bintang.png',
                    iconFallback: Icons.star,
                  ),
                  _buildInfoItem(
                    text: food.cookingTime != null ? '${food.cookingTime} menit' : '-', // Handle nullable cookingTime
                    iconAsset: 'images/waktu.png',
                    iconFallback: Icons.access_time,
                    isTextFirst: false,
                  ),
                  _buildPriceItem(food.price ?? '-'), // Handle nullable price
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for info items (likes, duration)
  Widget _buildInfoItem({
    required String text,
    required String iconAsset,
    required IconData iconFallback,
    bool isTextFirst = true,
  }) {
    final textWidget = Text(
      text,
      style: AppTheme.foodInfoStyle,
    );

    final iconWidget = Image.asset(
      iconAsset,
      width: AppTheme.iconSizeSmall,
      height: AppTheme.iconSizeSmall,
      color: AppTheme.accentTeal,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          iconFallback,
          color: AppTheme.accentTeal,
          size: AppTheme.iconSizeSmall,
        );
      },
    );

    return Row(
      children: isTextFirst
          ? [
              textWidget,
              const SizedBox(width: AppTheme.spacingSmall),
              iconWidget,
            ]
          : [
              iconWidget,
              const SizedBox(width: AppTheme.spacingSmall),
              textWidget,
            ],
    );
  }

  // Helper widget for price item
  Widget _buildPriceItem(String price) {
    return Row(
      children: [
        Text(
          "RP",
          style: AppTheme.foodPriceStyle,
        ),
        const SizedBox(width: AppTheme.spacingSmall),
        Text(
          price,
          style: AppTheme.foodInfoStyle,
        ),
      ],
    );
  }
}