// File: lib/view/profile/Pengaturan/pengaturan_utama.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:http/http.dart' as http; // Import http
import '../../component/pengaturan_widgets.dart'; 
import '../../component/custom_appbar.dart'; 
import 'dart:convert'; 

class PengaturanUtama extends StatefulWidget { 
  const PengaturanUtama({super.key});

  @override
  State<PengaturanUtama> createState() => _PengaturanUtamaState(); 
}

class _PengaturanUtamaState extends State<PengaturanUtama> { 
  bool _isLoggedIn = false; 

  final String _baseUrl = 'http://localhost:3000'; // Sesuaikan dengan IP backend Anda

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); 
  }

  Future<void> _checkLoginStatus() async {
    print('DEBUG PENGATURAN: Memeriksa status login...');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token'); 
    final userId = prefs.getInt('user_id'); 

    setState(() {
      _isLoggedIn = (token != null && token.isNotEmpty && userId != null); 
      print('DEBUG PENGATURAN: is_logged_in: $_isLoggedIn');
    });
  }

  // Fungsi untuk logout (clear token dan navigasi ke login)
  Future<void> _handleLogout(BuildContext context) async {
    print('DEBUG PENGATURAN: Proses logout dimulai.');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token'); 
    await prefs.remove('username'); 
    await prefs.remove('user_id'); 

    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false); 
    print('DEBUG PENGATURAN: Logout berhasil, navigasi ke /login.');
  }

  // Fungsi untuk hapus akun (implementasi API delete user)
  Future<void> _handleDeleteAccount(BuildContext context) async {
    print('DEBUG PENGATURAN: Proses hapus akun dimulai.');
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userId = prefs.getInt('user_id');

      if (token == null || userId == null) {
        print('ERROR PENGATURAN: Tidak ada token atau user ID, tidak bisa menghapus akun.');
        // Tampilkan pesan ke pengguna: "Anda tidak login."
        return;
      }

      final uri = Uri.parse('$_baseUrl/users/$userId'); // Endpoint DELETE /users/:id
      print('DEBUG PENGATURAN: Menghapus akun URL: $uri');

      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Kirim token untuk autentikasi
        },
      );

      if (response.statusCode == 200) {
        print('DEBUG PENGATURAN: Akun berhasil dihapus di backend.');
        await prefs.clear(); // Hapus semua data login lokal
        // Navigasi ke halaman register atau welcome setelah akun dihapus
        Navigator.pushNamedAndRemoveUntil(context, '/register', (route) => false); 
        print('DEBUG PENGATURAN: Akun berhasil dihapus, navigasi ke /register.');
      } else {
        final errorBody = json.decode(response.body);
        print('[ERROR] PENGATURAN: Gagal menghapus akun: ${response.statusCode} - ${errorBody['message']}');
        // Tampilkan pesan error ke pengguna
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus akun: ${errorBody['message']}')),
        );
      }
    } catch (e) {
      print('[EXCEPTION] PENGATURAN: Error menghapus akun: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat menghapus akun: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    print('DEBUG PENGATURAN: build method dipanggil. isLoggedIn: $_isLoggedIn');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Pengaturan',
        onBackPressed: () => Navigator.pop(context), 
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MenuItem(
              icon: Icons.notifications_none,
              label: 'Notifikasi',
              routeName: '/pengaturan-notifikasi',
            ),
            MenuItem(
              icon: Icons.help_outline,
              label: 'Pusat Bantuan',
              routeName: '/pusat-bantuan',
            ),
            // Tampilkan opsi "Keluar" dan "Hapus Akun" hanya jika sudah login
            if (_isLoggedIn) ...[ 
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
                        onConfirm: () => _handleLogout(context), 
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
                        message: 'Apakah Anda yakin ingin menghapus akun? Tindakan ini tidak dapat dibatalkan.',
                        cancelButtonText: 'Batalkan',
                        confirmButtonText: 'Ya, Hapus Akun',
                        onConfirm: () => _handleDeleteAccount(context), 
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
          ],
        ),
      ),
    );
  }
}