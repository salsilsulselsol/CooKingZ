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
          "Aplikasi Resep Masak",
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
                            '''Faisal Nur Qolbi            2311399\nMuhammad Farhan             2309323\nMuhammad Helmi Rahmadi      2311574\nSifa Imania Nurul Hidayah   2312084\nYazid Madarizel             2305328''',
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

              const Text(
                'Menu Utama',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF206153),
                ),
              ),

              const SizedBox(height: 20),

              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildMenuSection(context, 'Onboarding & Auth', [
                    _buildMenuItem(context, Icons.info_outline, 'Boarding', '/boardinga'),
                    _buildMenuItem(context, Icons.login, 'Login', '/login'),
                    _buildMenuItem(context, Icons.app_registration, 'Daftar', '/register'),
                    _buildMenuItem(context, Icons.abc, 'Kuesioner', '/cooking'),
                    _buildMenuItem(context, Icons.health_and_safety_outlined, 'Alergi', '/allergy'),
                    _buildMenuItem(context, Icons.password, 'Lupa Password', '/forgot-password'),
                  ]),
                  _buildMenuSection(context, 'Home & Fitur', [
                    _buildMenuItem(context, Icons.home, 'Beranda', '/beranda'),
                    _buildMenuItem(context, Icons.notifications, 'Notifikasi', '/notif'),
                    _buildMenuItem(context, Icons.calendar_month, 'Penjadwalan', '/penjadwalan'),
                    _buildMenuItem(context, Icons.search, 'Pencarian', '/search'),
                    _buildMenuItem(context, Icons.filter_list, 'Filter', '/filter'),
                    _buildMenuItem(context, Icons.star, 'Pengguna Terbaik', '/pengguna-terbaik'),
                    _buildMenuItem(context, Icons.trending_up, 'Trending Resep', '/trending-resep'),
                    _buildMenuItem(context, Icons.find_in_page, 'Hasil Pencarian', '/hasil-pencarian'),
                  ]),
                  _buildMenuSection(context, 'Kategori & Komunitas', [
                    _buildMenuItem(context, Icons.category, 'Kategori', '/kategori'),
                    _buildMenuItem(context, Icons.category_outlined, 'Sub Kategori', '/sub-category'),
                    _buildMenuItem(context, Icons.group, 'Komunitas', '/komunitas'),
                    _buildMenuItem(context, Icons.reviews, 'Review', '/review'),
                  ]),
                  _buildMenuSection(context, 'Profil', [
                    _buildMenuItem(context, Icons.person, 'Profil', '/profil-utama'),
                    _buildMenuItem(context, Icons.share, 'Bagikan Profil', '/bagikan-profil'),
                    _buildMenuItem(context, Icons.edit, 'Edit Profil', '/edit-profil'),
                    _buildMenuItem(context, Icons.people, 'Pengikut', '/pengikut-mengikuti'),
                    _buildMenuItem(context, Icons.favorite, 'Makanan Favorit', '/makanan-favorit'),
                  ]),
                  _buildMenuSection(context, 'Pengaturan', [
                    _buildMenuItem(context, Icons.settings, 'Pengaturan', '/pengaturan-utama'),
                    _buildMenuItem(context, Icons.notifications_none, 'Pengaturan Notifikasi', '/pengaturan-notifikasi'),
                    _buildMenuItem(context, Icons.help_outline, 'Pusat Bantuan', '/pusat-bantuan'),
                  ]),
                  _buildMenuSection(context, 'Resep', [
                    _buildMenuItem(context, Icons.add, 'Tambah Resep', '/tambah-resep'),
                    _buildMenuItem(context, Icons.edit, 'Edit Resep', '/edit-resep'),
                    _buildMenuItem(context, Icons.receipt_long, 'Detail Resep', '/detail-resep'),
                    _buildMenuItem(context, Icons.book, 'Resep Anda', '/resep-anda'),
                    _buildMenuItem(context, Icons.schedule, 'Jadwal Resep', '/resep-schedule'),
                  ]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, String title, List<Widget> items) {
    return Container(
      width: MediaQuery.of(context).size.width / 2 - 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF206153),
              ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, String route) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
        child: Row(
          children: [
            Icon(icon, size: 24, color: const Color(0xFF206153)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF206153),
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
