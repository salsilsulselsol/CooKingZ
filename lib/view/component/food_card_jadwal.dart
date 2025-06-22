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
    final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:3000/uploads';
    final String fullImageUrl = (scheduledMeal.recipeImageUrl?.isNotEmpty ?? false)
        ? '$baseUrl/${scheduledMeal.recipeImageUrl!}'
        : '';

    final int price = scheduledMeal.recipePrice ?? 0;
    final int cookingTime = scheduledMeal.recipeCookingTime ?? 0;
    final int rating = scheduledMeal.recipeRating ?? 0;
   

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       

        // Kartu dengan radius 20 di semua sudut
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20), // semua sudut radius 20
            border: Border.all(color: AppTheme.primaryColor, width: 20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Gambar
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: AspectRatio(
                  aspectRatio: 3 / 2,
                  child: fullImageUrl.isNotEmpty
                      ? Image.network(
                          fullImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image, size: 48),
                        )
                      : Container(
                          color: const Color.fromARGB(255, 33, 66, 50),
                          child: const Icon(Icons.image, size: 48),
                        ),
                ),
              ),

              // Isi penjelasan
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kolom teks
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
                              Text(
                                '$rating',
                                style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                              ),
                              const Icon(Icons.star, size: 16, color: Colors.amber),
                              const SizedBox(width: 12),
                              const Icon(Icons.access_time, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text('$cookingTime menit', style: const TextStyle(fontSize: 13)),
                              const SizedBox(width: 12),
                              Text(
                                'RB $price',
                                style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Tombol hapus
                    if (onDelete != null)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.teal[200],
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white),
                          onPressed: onDelete,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),
      ],
    );
  }
}
