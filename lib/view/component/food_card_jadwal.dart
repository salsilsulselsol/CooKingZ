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
    // Pastikan dotenv diinisialisasi di main.dart atau tempat lain yang sesuai.
    // Jika tidak, dotenv.env['BASE_URL'] akan null.
    final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:3000'; // Defaultkan jika env tidak ada
    // Path gambar perlu dihandle dengan benar jika backend hanya mengirim path relatif seperti 'images/pecel.png'
    final String fullImageUrl = (scheduledMeal.recipeImageUrl?.isNotEmpty ?? false)
        ? '$baseUrl/${scheduledMeal.recipeImageUrl!}'
        : '';

    // Pastikan nilai-nilai ini tidak null sebelum digunakan
    final String priceFormatted = scheduledMeal.recipePrice != null 
        ? 'RB ${NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(scheduledMeal.recipePrice)}' 
        : 'Gratis';
    final String cookingTimeText = scheduledMeal.recipeCookingTime != null 
        ? '${scheduledMeal.recipeCookingTime} menit' 
        : 'N/A';
    final String ratingText = scheduledMeal.recipeRating != null 
        ? scheduledMeal.recipeRating!.toStringAsFixed(1) // Format ke 1 desimal
        : 'N/A';
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
       width: double.infinity, // Menggunakan double.infinity agar card memenuhi lebar yang tersedia
      // Contoh: Untuk mengatur tinggi (jika Anda ingin tinggi tetap)
      height: 350, // Mengatur tinggi card (hati-hati dengan kontennya)
      decoration: BoxDecoration(
        
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // semua sudut radius 20
       
        border: Border.all(color: AppTheme.primaryColor, width: 10), // <<< UBAH LEBAR BORDER DI SINI
        boxShadow: [ // Tambahkan boxShadow untuk efek kartu
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // Pergeseran bayangan
          ),
        ],
      ),
      child: Column( // Menghilangkan Column luar yang tidak perlu
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Gambar
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16), // Sesuaikan radius agar pas dengan border Container
              topRight: Radius.circular(16),
            ),
            child: AspectRatio(
              aspectRatio: 3 / 2,
              child: fullImageUrl.isNotEmpty
                  ? Image.network(
                      fullImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container( // Menggunakan Container sebagai placeholder error
                            color: Colors.grey[300], // Warna abu-abu saat gambar error
                            child: Center(child: const Icon(Icons.broken_image, size: 48, color: Colors.grey)),
                          ),
                    )
                  : Container(
                      color: Colors.grey[300], // Placeholder jika tidak ada gambar
                      child: Center(child: const Icon(Icons.image, size: 48, color: Colors.grey)),
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
                Expanded( // Ini sudah benar
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
                      Row( // Baris untuk rating, waktu masak, harga
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            ratingText,
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.access_time, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(cookingTimeText, style: const TextStyle(fontSize: 13)),
                          const SizedBox(width: 12),
                          // Menggunakan Flexible untuk harga agar tidak overflow jika teks terlalu panjang
                          Flexible( // <<< SOLUSI OVERFLOW UNTUK HARGA
                            child: Text(
                              priceFormatted,
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                              overflow: TextOverflow.ellipsis, // Tambahkan ellipsis jika teks terlalu panjang
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Tombol hapus
                if (onDelete != null)
                  Padding( // Memberikan sedikit padding agar tombol tidak terlalu mepet
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Container(
                      width: 40, // Berikan lebar dan tinggi eksplisit agar ukuran tombol konsisten
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.red[400], // Ubah warna agar lebih jelas sebagai tombol hapus
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