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

  // Fungsi untuk hapus akun (implementasi API delete user)
  Future<void> _handleDeleteAccount() async {
    // Menutup dialog terlebih dahulu sebelum proses
    Navigator.of(context).pop(); 

    // Menampilkan loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userId = prefs.getInt('user_id');

      if (token == null || userId == null) {
        throw Exception('Sesi tidak valid, silakan login ulang.');
      }

      final uri = Uri.parse('$_baseUrl/users/$userId'); 
      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Tutup loading indicator
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        if (response.statusCode == 200) {
          await prefs.clear();
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Akun berhasil dihapus.'), backgroundColor: Colors.green),
          );
        } else {
          final errorBody = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus akun: ${errorBody['message']}')),
          );
        }
      }
    } catch (e) {
      // Tutup loading indicator jika terjadi error
      if (mounted) Navigator.of(context).pop();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    }
  }

  // Fungsi untuk menampilkan dialog konfirmasi sebelum menghapus akun
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Akun Permanen'),
          content: const Text('Tindakan ini tidak dapat dibatalkan. Semua resep dan data Anda akan hilang selamanya. Apakah Anda benar-benar yakin?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batalkan'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Ya, Hapus Akun Saya',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              onPressed: _handleDeleteAccount, // Panggil fungsi hapus akun
            ),
          ],
        );
      },
    );
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
                onTap: _showLogoutDialog, // Panggil fungsi dialog yang baru kita buat
                showArrow: false, 
              ),
              const SizedBox(height: 20),
              GestureDetector(
                // Panggil fungsi dialog yang sudah kita buat
                onTap: _showDeleteAccountDialog,
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Akhiri Sesi'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batalkan'),
              onPressed: () {
                // Tutup hanya dialognya saja
                Navigator.of(dialogContext).pop(); 
              },
            ),
            TextButton(
              child: const Text(
                'Ya, Keluar',
                style: TextStyle(color: Colors.red), // Beri warna merah untuk aksi destruktif
              ),
              onPressed: () async {
                // 1. Dapatkan instance SharedPreferences
                final prefs = await SharedPreferences.getInstance();
                
                // 2. Hapus data token dan user
                await prefs.remove('auth_token');
                await prefs.remove('user_id');

                // 3. Pastikan widget masih ada sebelum navigasi
                if (!mounted) return;

                // 4. Arahkan ke halaman login dan hapus semua rute sebelumnya
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
            ),
          ],
        );
      },
    );
  }
}