import 'package:flutter/material.dart';
import 'dart:ui'; 

class PengaturanUtama extends StatelessWidget {
  const PengaturanUtama({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pushNamed(context, "/home"),
          child: Transform.translate(
            offset: const Offset(15, 0), // Geser tombol 15px ke kanan
            child: SizedBox(
              width: 30, // Area klik lebih besar dari gambar
              height: 30,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: Image.asset(
                    'images/Tombol_kembali.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Pengaturan',
          style: TextStyle(
            color: Color(0xFF015551),
            fontWeight: FontWeight.bold,
          ),
        ),
        // Geser AppBar ke bawah menggunakan Transform
        toolbarHeight: 80, // Atur tinggi AppBar
        flexibleSpace: Transform.translate(
          offset: const Offset(0, 15), // Geser AppBar 15px ke bawah
          child: Container(), // Kontainer kosong untuk transformasi
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
  
  // Tidak perlu fungsi handler terpisah karena kita langsung menggunakan anonymous function di dalam onConfirm
}

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? routeName;
  final VoidCallback? onTap;
  final bool showArrow;

  const MenuItem({
    super.key,
    required this.icon,
    required this.label,
    this.routeName,
    this.onTap,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ??
          () {
            if (routeName != null) {
              Navigator.pushNamed(context, routeName!);
            }
          },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF015551),
              radius: 20,
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            if (showArrow)
              SizedBox(
                width: 15,
                height: 15,
                child: Image.asset(
                  'images/Tombol_lanjut.png',
                  fit: BoxFit.contain,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Komponen dialog konfirmasi yang fleksibel untuk berbagai keperluan
class ConfirmationDialogWithBlur extends StatelessWidget {
  final String title;
  final String message;
  final String cancelButtonText;
  final String confirmButtonText;
  final Function() onConfirm;
  
  const ConfirmationDialogWithBlur({
    super.key,
    required this.title,
    required this.message,
    required this.cancelButtonText,
    required this.confirmButtonText,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Blur latar belakang
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Container(
            color: Colors.black.withOpacity(0.2),
          ),
        ),

        // Dialog utama dengan animasi muncul dari bawah
        Positioned(
          bottom: 0, // Posisi dialog di bawah layar
          left: 0,
          right: 0,
          child: AnimatedBuilder(
            animation: ModalRoute.of(context)?.animation ?? const AlwaysStoppedAnimation(0),
            builder: (context, child) {
              final animation = ModalRoute.of(context)?.animation;
              final offset = Tween<Offset>(
                begin: const Offset(0, 1), // Mulai dari bawah layar
                end: Offset.zero, // Berhenti di posisi normal
              ).animate(animation!);

              return SlideTransition(
                position: offset,
                child: SizedBox(
                  width: double.infinity, // Dialog memenuhi lebar layar
                  
                  child: Card(
                    margin: EdgeInsets.zero,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    color: Colors.white,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Color(0xFF015551),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            message,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFBCE2E0),
                                    foregroundColor: Colors.black87,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    cancelButtonText,
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF015551),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context); // Tutup dialog
                                    onConfirm(); // Panggil fungsi callback yang diberikan
                                  },
                                  child: Text(
                                    confirmButtonText,
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}