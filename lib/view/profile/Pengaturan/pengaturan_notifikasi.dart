import 'package:flutter/material.dart';
import 'package:masak2/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import '../../component/header_back.dart';
import '../../component/custom_switch.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  // Switch state variables (tetap ada jika nanti user bisa login dan mengakses ini)
  bool generalNotifications = true;
  bool soundNotifications = true;
  bool vibrationNotifications = true;

  bool _isLoggedIn = false; // State untuk melacak status login

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Panggil fungsi untuk memeriksa status login saat inisialisasi
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id'); // Atau 'id', sesuai kunci yang Anda gunakan
    
    setState(() {
      _isLoggedIn = userId != null && userId != 0; // Asumsi ID 0 berarti tidak login
    });
    print('DEBUG Notif: User ID from SharedPreferences: $userId, Is Logged In: $_isLoggedIn');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header Widget
          Padding(
            padding: EdgeInsets.only(top: 24.0),
            child: HeaderWidget(
              title: 'Notifikasi',
              onBackPressed: () => Navigator.pop(context),
            ),
          ),
          
          // Body Content - Kondisional berdasarkan status login
          Expanded(
            child: _isLoggedIn
                ? _buildLoggedInContent() // Tampilkan pengaturan notifikasi jika login
                : _buildLoggedOutContent(context), // Tampilkan logo dan tombol jika belum login
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedInContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        children: [
          SwitchSettingRow(
            title: 'Notifikasi Umum',
            value: generalNotifications,
            onChanged: (value) {
              setState(() {
                generalNotifications = value;
              });
            },
          ),
          CustomDivider(),
          SwitchSettingRow(
            title: 'Suara',
            value: soundNotifications,
            onChanged: (value) {
              setState(() {
                soundNotifications = value;
              });
            },
          ),
          CustomDivider(),
          SwitchSettingRow(
            title: 'Getar',
            value: vibrationNotifications,
            onChanged: (value) {
              setState(() {
                vibrationNotifications = value;
              });
            },
          ),
          CustomDivider(),
        ],
      ),
    );
  }

  Widget _buildLoggedOutContent(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'images/logo.png', // Pastikan path ini benar
            width: 150, // Sesuaikan ukuran logo
            height: 150,
          ),
          const SizedBox(height: 32), // Spasi antara logo dan tombol
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.primaryColor, // Menggunakan tema warna Anda
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            child: const Text('Login'),
          ),
          const SizedBox(height: 16), // Spasi antar tombol
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/register');
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey[300], // Warna abu-abu untuk tombol daftar
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            child: const Text('Daftar'),
          ),
        ],
      ),
    );
  }
}

class CustomDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: Colors.grey.shade200,
    );
  }
}