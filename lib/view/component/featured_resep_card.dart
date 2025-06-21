import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class FeaturedRecipeCard extends StatefulWidget {
  final Map<String, dynamic> recipe;

  const FeaturedRecipeCard({
    Key? key,
    required this.recipe,
  }) : super(key: key);

  @override
  State<FeaturedRecipeCard> createState() => _FeaturedRecipeCardState();
}

class _FeaturedRecipeCardState extends State<FeaturedRecipeCard> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final String imagePath = recipe['image'] ?? 'images/placeholder.png';
    final String name = recipe['name'] ?? 'Resep Tanpa Nama';
    final String description = recipe['description'] ?? 'Tidak ada deskripsi';
    final String likes = recipe['likes'] ?? '0';
    final String time = recipe['time'] ?? 'N/A';
    final String price = recipe['price'] ?? '0';

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
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          final id = recipe['id']?.toString() ?? '';
          Navigator.pushNamed(context, '/detail-resep/$id');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Gambar dengan loader dan tombol favorite
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              child: Stack(
                children: [
                  Container(
                    height: AppTheme.foodCardImageHeight,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: Image.asset(
                      imagePath,
                      height: AppTheme.foodCardImageHeight,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                        if (wasSynchronouslyLoaded || frame != null) {
                          Future.microtask(() {
                            if (mounted) setState(() => _isLoading = false);
                          });
                        }
                        return child;
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(Icons.broken_image, size: 60, color: Colors.grey[600]),
                        );
                      },
                    ),
                  ),
                  // Loader pojok kanan atas
                  if (_isLoading)
                    Positioned(
                      top: AppTheme.spacingMedium,
                      right: AppTheme.spacingMedium + 40,
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  // Tombol Favorite
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
                        onPressed: () {
                          print('Favorite button pressed');
                        },
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
            ),

            // Informasi resep
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
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                likes,
                                style: AppTheme.foodInfoStyle.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accentTeal,
                                ),
                              ),
                              const SizedBox(width: AppTheme.spacingXSmall),
                                Icon(
                                Icons.favorite,
                                color: AppTheme.accentTeal,
                                size: 10
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
                                time,
                                style: AppTheme.foodInfoStyle.copyWith(
                                  color: AppTheme.accentTeal,
                                ),
                                
                              ),
                              const SizedBox(width: AppTheme.spacingLarge),
                              Text(
                          "RP $price",
                          style: AppTheme.foodPriceStyle,
                        ),
                            ],
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
      ),
    );
  }
}
