import 'package:flutter/material.dart';
import '../../component/pengaturan_widgets.dart';
import '../../component/custom_appbar.dart';

class PengaturanUtama extends StatelessWidget {
  const PengaturanUtama({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Pengaturan',
        onBackPressed: () => Navigator.pushNamed(context, "/"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MenuItem(
              icon: Icons.notifications_none,
              label: 'Notifikasi',
              routeName: '/pengaturan_notifikasi',
            ),
            MenuItem(
              icon: Icons.help_outline,
              label: 'Pusat Bantuan',
              routeName: '/pusat_bantuan',
            ),
            MenuItem(
              icon: Icons.logout,
              label: 'Keluar',
              onTap: () {
                showGeneralDialog(
                  context: context,
                  barrierDismissible: true,
                  barrierLabel: "Keluar",
                  transitionDuration: const Duration(milliseconds: 200),
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return ConfirmationDialogWithBlur(
                      title: 'Akhiri Sesi',
                      message: 'Apakah Anda yakin ingin keluar?',
                      cancelButtonText: 'Batalkan',
                      confirmButtonText: 'Ya, Akhiri Sesi',
                      onConfirm: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                    );
                  },
                );
              },
              showArrow: false,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                showGeneralDialog(
                  context: context,
                  barrierDismissible: true,
                  barrierLabel: "Hapus Akun",
                  transitionDuration: const Duration(milliseconds: 200),
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return ConfirmationDialogWithBlur(
                      title: 'Hapus Akun',
                      message: 'Apakah Anda yakin ingin menghapus akun?',
                      cancelButtonText: 'Batalkan',
                      confirmButtonText: 'Ya, Hapus Akun',
                      onConfirm: () {
                        // Implementasi hapus akun
                        Navigator.pushReplacementNamed(context, '/welcome');
                      },
                    );
                  },
                );
              },
              child: const Text(
                'Hapus Akun',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}