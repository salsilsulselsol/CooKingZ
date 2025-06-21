// lib/component/header_back_PSN.dart

import 'package:flutter/material.dart';
import '../../theme/theme.dart';
// Import halaman tujuan agar bisa digunakan di sini
import '../profile/profil/tambah_resep.dart';

class HeaderBackPSN extends StatelessWidget implements PreferredSizeWidget {
  // Tambahkan properti ini untuk menerima fungsi saat tombol tambah ditekan
  final VoidCallback? onAddPressed;

  const HeaderBackPSN({
    super.key,
    this.onAddPressed, // Tambahkan di constructor
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.backgroundColor,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Image.asset(
          'images/arrow.png', // Pastikan path gambar ini benar
          height: AppTheme.iconSizeLarge,
          width: AppTheme.iconSizeLarge,
        ),
      ),
      title: Text(
        'Resep Anda',
        style: AppTheme.headerStyle.copyWith(color: AppTheme.emeraldGreen),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(left: 0.0),
          child: Row(
            children: [
              const SizedBox(width: AppTheme.spacingMedium),
              // BUNGKUS IKON TAMBAH DENGAN GESTUREDETECTOR
              GestureDetector(
                onTap: onAddPressed, // Panggil fungsi yang diberikan saat ditekan
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const CircleAvatar(
                      backgroundColor: AppTheme.emeraldGreen,
                      radius: 14,
                    ),
                    Image.asset(
                      'images/tambah.png', // Pastikan path gambar ini benar
                      height: AppTheme.iconSizeLarge + 4,
                      width: AppTheme.iconSizeLarge + 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.spacingMedium),
              // Tombol Search (bisa diberi GestureDetector juga jika perlu)
              Stack(
                alignment: Alignment.center,
                children: [
                  const CircleAvatar(
                    backgroundColor: AppTheme.emeraldGreen,
                    radius: 14,
                  ),
                  Image.asset(
                    'images/search.png', // Pastikan path gambar ini benar
                    height: AppTheme.iconSizeLarge + 4,
                    width: AppTheme.iconSizeLarge + 4,
                  ),
                ],
              ),
              const SizedBox(width: AppTheme.spacingMedium),
              // Tombol Notif (bisa diberi GestureDetector juga jika perlu)
              Stack(
                alignment: Alignment.center,
                children: [
                  const CircleAvatar(
                    backgroundColor: AppTheme.emeraldGreen,
                    radius: 14,
                  ),
                  Image.asset(
                    'images/notif.png', // Pastikan path gambar ini benar
                    height: AppTheme.iconSizeLarge + 4,
                    width: AppTheme.iconSizeLarge + 4,
                  ),
                ],
              ),
              const SizedBox(width: AppTheme.spacingXLarge),
            ],
          ),
        ),
      ],
    );
  }
}