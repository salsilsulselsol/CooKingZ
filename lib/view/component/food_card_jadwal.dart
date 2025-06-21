// File: lib/view/component/food_card_jadwal.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Untuk mengakses BASE_URL
import 'package:intl/intl.dart'; // Untuk format harga jika Anda menggunakan NumberFormat
import '../../theme/theme.dart';
import '../../models/scheduled_food_model.dart'; // Import model ScheduledFood yang sudah diperbarui


class FoodCardJadwal extends StatelessWidget {
  final ScheduledFood scheduledMeal; // Menerima objek ScheduledFood
  final VoidCallback? onDelete; // Callback untuk menghapus jadwal

  const FoodCardJadwal({
    Key? key,
    required this.scheduledMeal,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Bangun URL gambar resep lengkap
    final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:3000/uploads';
    final String fullImageUrl = scheduledMeal.recipeImageUrl != null && scheduledMeal.recipeImageUrl!.isNotEmpty
        ? '$baseUrl/${scheduledMeal.recipeImageUrl!}' // Pastikan tidak null jika digunakan
        : ''; // Kosong jika null/empty

    // Untuk format harga (jika diperlukan)
    final currencyFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'RP ', // RP diikuti spasi
      decimalDigits: 0,
    );
    // Asumsi harga ada di scheduledMeal (jika query backend mengambilnya)
    final String formattedPrice = scheduledMeal.recipeTitle != null && scheduledMeal.recipeTitle!.contains('price') // Ini hanya placeholder, sesuaikan jika Anda ingin menampilkan harga
      ? currencyFormat.format(double.tryParse(scheduledMeal.recipeTitle!.split('price')[1].trim()) ?? 0) // Ini contoh parsing jika price ada di title, SANGAT TIDAK DIREKOMENDASIKAN
      : (scheduledMeal.recipeTitle ?? '').contains('RB') ? scheduledMeal.recipeTitle! : 'RP --'; // Contoh fallback.
    // Jika harga ada di Food model, Anda perlu melewatkan Food object ke ScheduledMeal atau ambil harga dari scheduledMeal jika query backend mengembalikan harga.
    // Untuk saat ini, saya akan menggunakan harga dari Food model yang asli jika Anda punya, atau tampilkan placeholder.
    // Karena ScheduledFood model saat ini tidak memiliki 'price' langsung, saya akan pakai placeholder.
    
    // Asumsi: query backend jadwal makan TIDAK mengembalikan detail 'price' dan 'cooking_time' resep.
    // Jika Anda ingin menampilkannya, query backend di utilityController.js perlu diperluas
    // untuk mengambil juga r.price dan r.cooking_time, dan menambahkannya ke ScheduledFood model.
    final String displayCookingTime = 'N/A'; // Default placeholder
    final String displayPrice = 'N/A'; // Default placeholder


    return GestureDetector(
      onTap: () {
        if (scheduledMeal.recipeId != null) {
          print('DEBUG FOOD_CARD_JADWAL: Tapped scheduled recipe ID: ${scheduledMeal.recipeId}');
          Navigator.pushNamed(context, '/detail-resep/${scheduledMeal.recipeId}');
        } else {
          print('ERROR: Recipe ID is null for scheduled meal.');
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: AppTheme.spacingMedium),
        padding: EdgeInsets.all(AppTheme.spacingMedium),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Gambar Resep
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              child: Container(
                width: 80,
                height: 80,
                color: Colors.grey[200],
                child: fullImageUrl.isNotEmpty
                    ? Image.network(
                        fullImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print('ERROR LOADING JADWAL IMAGE: $error for URL: $fullImageUrl');
                          return Icon(Icons.broken_image, size: 40, color: Colors.grey[600]);
                        },
                      )
                    : Center(child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey[600])),
              ),
            ),
            SizedBox(width: AppTheme.spacingMedium),
            
            // Detail Resep
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scheduledMeal.recipeTitle ?? 'Resep Tidak Dikenal', // Nama resep dari model
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.textBrown,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppTheme.spacingXSmall),
                  Text(
                    '${scheduledMeal.mealType} - ${DateFormat('dd MMM').format(scheduledMeal.date)}', // Jenis makan + tanggal singkat
                    style: TextStyle(fontSize: 14, color: AppTheme.primaryColor),
                  ),
                  SizedBox(height: AppTheme.spacingXSmall),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(displayCookingTime, style: TextStyle(fontSize: 12, color: Colors.grey)), // Waktu Masak
                      SizedBox(width: 8),
                      Icon(Icons.money, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(displayPrice, style: TextStyle(fontSize: 12, color: Colors.grey)), // Harga
                    ],
                  ),
                ],
              ),
            ),
            
            // Tombol Hapus (opsional)
            if (onDelete != null)
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}