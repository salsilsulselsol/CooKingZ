import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import '../../theme/theme.dart';
import '../../models/scheduled_food_model.dart';

class FoodCardJadwal extends StatelessWidget {
  final ScheduledFood scheduledMeal;
  final VoidCallback? onDelete;

  const FoodCardJadwal({
    Key? key,
    required this.scheduledMeal,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:3000';

    // === PERUBAHAN KRITIS DI SINI ===
    // Hapus slash tambahan jika recipeImageUrl sudah dimulai dengan slash.
    // Gunakan Uri.parse().resolve() untuk penanganan path yang lebih aman dan benar.
    final String? relativeImagePath = scheduledMeal.recipeImageUrl;
    final bool hasRecipeImage = relativeImagePath?.isNotEmpty ?? false;

    // Cara paling aman untuk menggabungkan URL:
    final String? imageUrl = hasRecipeImage
        ? Uri.parse(baseUrl).resolve(relativeImagePath!).toString()
        : null;

    final String priceFormatted = scheduledMeal.recipePrice != null
        ? 'RB ${NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(scheduledMeal.recipePrice)}'
        : 'Gratis';
    final String cookingTimeText = scheduledMeal.recipeCookingTime != null
        ? '${scheduledMeal.recipeCookingTime} menit'
        : 'N/A';
    final String ratingText = scheduledMeal.recipeRating != null
        ? scheduledMeal.recipeRating!.toStringAsFixed(1)
        : 'N/A';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: AspectRatio(
              aspectRatio: 3 / 2,
              child: Container(
                color: Colors.grey[200],
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
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
                          print('ERROR LOADING IMAGE: $error - URL: $imageUrl');
                          return const Center(child: Icon(Icons.broken_image, size: 48, color: Colors.grey));
                        },
                      )
                    : const Center(child: Icon(Icons.image, size: 48, color: Colors.grey)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scheduledMeal.recipeTitle ?? 'Judul Tidak Dikenal',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.textBrown,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        scheduledMeal.recipeDescription ?? 'Deskripsi tidak tersedia.',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            ratingText,
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.access_time, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(cookingTimeText, style: const TextStyle(fontSize: 13)),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              priceFormatted,
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (onDelete != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.red[400],
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                        onPressed: onDelete,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
