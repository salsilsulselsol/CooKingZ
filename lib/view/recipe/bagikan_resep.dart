import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk Clipboard
import 'package:qr_flutter/qr_flutter.dart'; // Untuk QR Code
import 'package:share_plus/share_plus.dart'; // Untuk tombol bagikan

class BagikanResep extends StatelessWidget {
  final int recipeId;
  final String recipeTitle;

  const BagikanResep({
    super.key,
    required this.recipeId,
    required this.recipeTitle,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Buat URL dan teks untuk dibagikan.
    // Ganti 'cookingz.app' dengan domain aplikasi Anda nantinya.
    final String recipeUrl = 'https://cookingz.app/recipes/$recipeId';
    final String shareText =
        'Coba resep "$recipeTitle" ini! Enak banget loh. Lihat selengkapnya di: $recipeUrl';

    // 2. Fungsi untuk aksi tombol
    void onShare() {
      Share.share(shareText);
    }

    void onCopyLink() {
      Clipboard.setData(ClipboardData(text: recipeUrl)).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tautan resep disalin ke clipboard!')),
        );
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF005A4D), // Warna dari tema Anda
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Bagikan Resep',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tampilan QR Code
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFF005A4D), width: 3),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: QrImageView(
                data: recipeUrl,
                version: QrVersions.auto,
                size: 220.0,
                gapless: false,
                // Ganti dengan logo aplikasi Anda jika ada
                // embeddedImage: const AssetImage('images/logo.png'),
                // embeddedImageStyle: const QrEmbeddedImageStyle(
                //   size: Size(40, 40),
                // ),
              ),
            ),
            const SizedBox(height: 20),

            // Judul Resep
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                recipeTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 36),

            // Tombol Aksi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.share),
                      label: const Text('Bagikan'),
                      onPressed: onShare, // Panggil fungsi onShare
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF005A4D),
                        side: const BorderSide(color: Color(0xFF005A4D), width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.copy),
                      label: const Text('Salin'),
                      onPressed: onCopyLink, // Panggil fungsi onCopyLink
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF005A4D),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}