import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:masak2/view/component/bottom_navbar.dart';
import 'package:masak2/view/component/header_b_n_s.dart';
import 'package:masak2/view/component/grid_pengguna.dart'; // Import the new ChefCard widget
import '../../theme/theme.dart';

class PenggunaTerbaik extends StatelessWidget {
  const PenggunaTerbaik({super.key});

  // Using app theme colors

  @override
  Widget build(BuildContext context) {
    return BottomNavbar(
      _buildMainContent(context),
    );
  }

  // Widget yang berisi konten utama
  Widget _buildMainContent(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Menggunakan CustomHeader yang diimport
            CustomHeader(
              title: 'Pengguna Terbaik',
              titleColor: AppTheme.primaryColor,
            ),
            Expanded(
              child: _buildUserContentView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserContentView() {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 320,
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Pengguna Populer"),
                  _buildUsersGrid('Pengguna Populer', [
                    {
                      'name': 'Ayu Lestari',
                      'username': '@ayu_lestari',
                      'likes': '925',
                      'followw': true,
                      'image': 'images/ayulestari.png',
                    },
                    {
                      'name': 'Bagas Pratama',
                      'username': '@bagaspratama',
                      'likes': '880',
                      'followw': true,
                      'image': 'images/bagas_pt.png',
                    },
                  ]),
                ],
              ),
            ),

            Container(
              height: 320,
              margin: EdgeInsets.only(top: AppTheme.spacingXXLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Pengguna Disukai Terbaru"),
                  _buildUmum('Pengguna Disukai Terbaru', [
                    {
                      'name': 'Doni Candra',
                      'username': '@donicandra',
                      'likes': '800',
                      'followw': true,
                      'image': 'images/doni.png',
                    },
                    {
                      'name': 'Ayu Dewi' ,
                      'username': '@ayudewi',
                      'likes': '750',
                      'followw': true,
                      'image': 'images/ayu_23.png',
                    },
                  ]),
                ],
              ),
            ),

            Container(
              height: 320,
              margin: const EdgeInsets.only(top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Pengguna Terbaru"),
                  _buildUmum('Pengguna Terbaru', [
                    {
                      'name': 'Lulu Rahma',
                      'username': '@lulu_rahma',
                      'likes': '700',
                      'followw': true,
                      'image': 'images/lulu.png',
                    },
                    {
                      'name': 'Edward Jones',
                      'username': '@edwardjones',
                      'likes': '650',
                      'followw': true,
                      'image': 'images/edwar.png',
                    },
                  ]),
                ],
              ),
            ),

            // Tambahkan padding 90 di bagian bawah untuk mencegah konten tertutup navbar
            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(
          left: AppTheme.spacingXXLarge + 10,
          top: AppTheme.spacingLarge,
          bottom: AppTheme.spacingMedium
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: title == "Pengguna Populer" ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildUsersGrid(String title, List<Map<String, dynamic>> users) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingXXLarge + 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: users.map((user) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: AppTheme.borderRadiusMedium),
                  child: ChefCard(
                    name: user['name'],
                    username: user['username'],
                    likes: user['likes'],
                    isFollowing: user['followw'] ?? false,
                    image: user['image'],
                    useGreenBackground: true, // Green background for Popular Users
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUmum(String title, List<Map<String, dynamic>> users) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: AppTheme.spacingXXLarge + 10,
          vertical: AppTheme.spacingLarge
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: users.map((user) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: ChefCard(
                    name: user['name'],
                    username: user['username'],
                    likes: user['likes'],
                    isFollowing: user['followw'] ?? false,
                    image: user['image'],
                    useGreenBackground: false, // White background for other sections
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}