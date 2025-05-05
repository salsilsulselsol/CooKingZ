import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class FeaturedRecipeCard extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const FeaturedRecipeCard({
    Key? key,
    required this.recipe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 5, bottom: 15),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                child: Image.asset(
                  recipe['image'],
                  height: AppTheme.foodCardImageHeight,
                  width: double.infinity,
                  fit: BoxFit.cover,
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
                        width: 30, // Diperbesar
                        height: 30,
                      ),
                    ),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 30,
                      minHeight: 30,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Transform.translate(
            offset: const Offset(0, -15),
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                  boxShadow: [
                    AppTheme.boxShadowSmall,
                  ],
                ),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Column(
                  children: [
                    Text(
                      recipe['name'],
                      style: AppTheme.foodTitleStyle.copyWith(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.spacingXSmall),
                    Text(
                      recipe['description'],
                      style: AppTheme.foodDescriptionStyle.copyWith(fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.spacingSmall),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              recipe['likes'],
                              style: AppTheme.foodInfoStyle.copyWith(
                                fontSize: AppTheme.foodInfoStyle.fontSize,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accentTeal,
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingXSmall),
                            Opacity(
                              opacity: 0.8,
                              child: Image.asset(
                                'images/love.png',
                                width: 18, // Diperbesar
                                height: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: AppTheme.spacingLarge),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Opacity(
                              opacity: 0.7,
                              child: Image.asset(
                                'images/alarm.png',
                                width: AppTheme.iconSizeSmall,
                                height: AppTheme.iconSizeSmall,
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingXSmall),
                            Text(
                              recipe['time'],
                              style: AppTheme.foodInfoStyle.copyWith(
                                fontSize: AppTheme.foodInfoStyle.fontSize,
                                color: AppTheme.accentTeal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: AppTheme.spacingLarge),
                        Text(
                          "RP ${recipe['price']}",
                          style: AppTheme.foodPriceStyle,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}