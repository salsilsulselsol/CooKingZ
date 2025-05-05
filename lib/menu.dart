import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Set status bar style for this screen
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF206153),
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Aplikasi Utama",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF206153),
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF206153),
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Profile Kelompok Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Color(0xFF206153),
                      child: Icon(Icons.person, size: 35, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Kelompok 25',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF206153),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '''Faisal Nur Qolbi            2311399
Muhammad Farhan             2309323
Muhammad Helmi Rahmadi      2311574
Sifa Imania Nurul Hidayah   2312084
Yazid Madarizel             2305328''',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Title Menu Utama
              const Text(
                'Menu Utama',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF206153),
                ),
              ),

              const SizedBox(height: 20),

              // Menu Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildMenuItem(context, Icons.info_outline, 'Boarding', '/boardinga'),
                  _buildMenuItem(context, Icons.category, 'Kategori', '/kategori'),
                  _buildMenuItem(context, Icons.group, 'Komunitas', '/komunitas'),
                  _buildMenuItem(context, Icons.login, 'Login', '/login'),
                  _buildMenuItem(context, Icons.app_registration, 'Daftar', '/register'),
                  _buildMenuItem(context, Icons.password, 'Lupa Password', '/forgot-password'),

                  _buildMenuItem(context, Icons.notifications, 'Notifikasi', '/notif'),
                  
                  _buildMenuItem(context, Icons.home, 'Beranda', '/beranda'),
                  _buildMenuItem(context, Icons.star, 'Pengguna Terbaik', '/pengguna-terbaik'),
                  _buildMenuItem(context, Icons.trending_up, 'Trending Resep', '/trending-resep'),
                  _buildMenuItem(context, Icons.find_in_page, 'Hasil Pencarian', '/hasil-pencarian'),
                  _buildMenuItem(context, Icons.edit, 'Edit Profil', '/edit-profil'),

                  _buildMenuItem(context, Icons.abc, 'Kuesioner', '/cooking'),
                  _buildMenuItem(context, Icons.person, 'Profil', '/profil-utama'),
                  _buildMenuItem(context, Icons.people, 'Pengikut', '/pengikut-mengikuti'),
                  _buildMenuItem(context, Icons.restaurant_menu, 'Resep', '/recipe'),
                  _buildMenuItem(context, Icons.add, 'Tambah Resep', '/tambah-resep'),
                  _buildMenuItem(context, Icons.edit, 'Edit Resep', '/edit-resep'),
                  _buildMenuItem(context, Icons.receipt_long, 'Detail Resep', '/detail-resep'),
                  _buildMenuItem(context, Icons.reviews, 'Review', '/review'),
                  _buildMenuItem(context, Icons.schedule, 'Jadwal', '/resep-schedule'),

                  _buildMenuItem(context, Icons.settings, 'HOMEEEE', '/home-screen'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Menu Item Builder
  Widget _buildMenuItem(BuildContext context, IconData icon, String title, String route) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color(0xFF206153)),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF206153),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
