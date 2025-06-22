import 'package:flutter/material.dart';
import 'package:flutter/services.dart';       // Untuk Clipboard
import 'package:qr_flutter/qr_flutter.dart';  // Untuk QR Code
import 'package:share_plus/share_plus.dart';  // Untuk tombol bagikan
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../models/user_profile_model.dart';

class BagikanProfil extends StatefulWidget {
  const BagikanProfil({super.key});

  @override
  State<BagikanProfil> createState() => _BagikanProfilState();
}

class _BagikanProfilState extends State<BagikanProfil> {
  UserProfile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyProfile();
  }

  // <<< TAMBAHKAN FUNGSI INI >>>
  // Helper untuk mendapatkan headers dengan token
  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // <<< UBAH FUNGSI INI >>>
  // Fungsi untuk mengambil data profil sendiri
  Future<void> _fetchMyProfile() async {
    final baseUrl = dotenv.env['BASE_URL'];
    if (baseUrl == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final headers = await _getAuthHeaders(); // Dapatkan header
      final response = await http.get(
        Uri.parse('$baseUrl/users/me'),
        headers: headers, // Gunakan header
      );

      if (mounted && response.statusCode == 200) {
        setState(() {
          // Sesuaikan dengan struktur JSON dari server Anda
          final responseData = json.decode(response.body);
          _userProfile = UserProfile.fromJson(responseData['data']);
          _isLoading = false;
        });
      } else {
        throw Exception('Gagal memuat profil (Status: ${response.statusCode})');
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  // Fungsi yang akan dijalankan saat tombol "Bagikan" ditekan
  void _onShare(BuildContext context) {
    if (_userProfile != null) {
      // Ganti dengan domain asli Anda jika sudah punya
      final String profileUrl = 'https://cookingz.app/users/${_userProfile!.id}'; 
      final String shareText =
          'Lihat profil resep milik ${_userProfile!.fullName} (@${_userProfile!.username}) di aplikasi CookingZ! Kunjungi profilnya di: $profileUrl';
      
      Share.share(shareText);
    }
  }

  // Fungsi yang akan dijalankan saat tombol "Salin Tautan" ditekan
  void _onCopyLink(BuildContext context) {
    if (_userProfile != null) {
      // Ganti dengan domain asli Anda jika sudah punya
      final String profileUrl = 'https://cookingz.app/users/${_userProfile!.id}'; 
      Clipboard.setData(ClipboardData(text: profileUrl)).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tautan profil disalin ke clipboard!')),
        );
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: AppBar(
        // ... (biarkan sama)
        backgroundColor: const Color(0xFF006257),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Bagikan Profil',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userProfile == null
              ? const Center(child: Text("Gagal memuat data profil."))
              : _buildShareContent(),
    );
  }

  Widget _buildShareContent() {
    // ... (widget ini sudah benar, tidak perlu diubah)
    final String profileUrl = 'https://cookingz.app/users/${_userProfile!.id}';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFF0A6859), width: 3),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(77),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: QrImageView(
              data: profileUrl,
              version: QrVersions.auto,
              size: 220.0,
              gapless: false,
              // Ganti dengan path logo Anda jika ada
              // embeddedImage: const AssetImage('assets/images/logo.png'), 
              embeddedImageStyle: const QrEmbeddedImageStyle(
                size: Size(40, 40),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _userProfile!.fullName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            '@${_userProfile!.username}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 36),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.share),
                    label: const Text('Bagikan'),
                    onPressed: () => _onShare(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF006257),
                      side: const BorderSide(color: Color(0xFF006257), width: 2),
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
                    onPressed: () => _onCopyLink(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006257),
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
    );
  }
}