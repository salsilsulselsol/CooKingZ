import 'package:flutter/material.dart';
import '../../theme/theme.dart'; // Impor theme jika diperlukan untuk styling

class TrendingRecipeCard extends StatelessWidget {
  // 1. Ganti nama 'imagePath' menjadi 'imageUrl' agar lebih jelas maksudnya
  final String imageUrl;
  final String title;
  final String description;
  final String favorites;
  final String duration;
  final String price;
  final String detailRoute;

  const TrendingRecipeCard({
    Key? key,
    // 2. Sesuaikan constructor untuk menerima 'imageUrl'
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.favorites,
    required this.duration,
    required this.price,
    required this.detailRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, detailRoute);
      },
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 8,
                  bottom: 8,
                ),
                child: Column(
                  children: [
                    // --- PERBAIKAN UTAMA ADA DI SINI ---
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      // 3. Gunakan Image.network untuk menampilkan gambar dari URL
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              height: 180,
                              width: 358,
                              fit: BoxFit.cover,
                              // Optional: Tampilkan loading indicator saat gambar diunduh
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: 180,
                                  width: 358,
                                  color: Colors.grey[200],
                                  child: const Center(child: CircularProgressIndicator()),
                                );
                              },
                              // Optional: Tampilkan placeholder jika gambar gagal dimuat
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'images/placeholder.png', // Pastikan ada gambar ini di folder assets/images
                                  height: 180,
                                  width: 358,
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                          // Jika imageUrl kosong, tampilkan placeholder
                          : Image.asset(
                              'images/placeholder.png', // Pastikan ada gambar ini di folder assets/images
                              height: 180,
                              width: 358,
                              fit: BoxFit.cover,
                            ),
                    ),
                    // --- Akhir dari bagian yang diubah ---
                    
                    // Info Container (tidak perlu diubah)
                    Container(
                      height: 76,
                      width: 340,
                      // ... sisa kode Anda tetap sama
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: const Border(
                          left: BorderSide(color: Color(0xFF035E53), width: 2),
                          right: BorderSide(color: Color(0xFF035E53), width: 2),
                          bottom: BorderSide(color: Color(0xFF035E53), width: 2),
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        description,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Image.asset(
                                        'images/star_hijau.png',
                                        width: 16,
                                        height: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        favorites,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      const SizedBox(width: 12),
                                      Image.asset(
                                        'images/time.png',
                                        width: 16,
                                        height: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        duration,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    child: Text(
                                      'RP $price',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF57B4BA),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}