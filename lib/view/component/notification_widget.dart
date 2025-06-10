import 'package:flutter/material.dart';

// Widget untuk membangun item notifikasi individual
class NotificationItem extends StatelessWidget {
  final Map<String, String> notification;
  final Color emeraldGreen =
      const Color(0xFF015551); // Mendefinisikan warna hijau emerald

  const NotificationItem({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: emeraldGreen, // Menggunakan warna hijau emerald untuk kotak
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 5,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none, // Memungkinkan elemen keluar dari batas Stack
        children: [
          // Konten utama (ikon, judul, deskripsi)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ikon notifikasi
              Image.asset(
                notification['icon']!,
                height: 40,
                width: 40,
              ),
              const SizedBox(width: 12),
              // Konten notifikasi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul
                    Text(
                      notification['title']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Deskripsi
                    Text(
                      notification['description']!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Waktu di kanan atas, lebih tinggi dari konten utama
          Positioned(
            top: -8, // Menggeser waktu lebih ke atas
            right: 0,
            child: Text(
              notification['time']!,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white70, // Warna teks waktu lebih redup
              ),
            ),
          ),
        ],
      ),
    );
  }
}