import 'package:flutter/material.dart';

class BottomNavbar extends StatefulWidget {
  final Widget child;
  const BottomNavbar(this.child, {Key? key}) : super(key: key);

  @override
  BottomNavbarState createState() => BottomNavbarState();
}

class BottomNavbarState extends State<BottomNavbar> {
  // Map each navigation item to its corresponding route
  final Map<int, String> _navRoutes = {
    0: '/beranda',           // Home
    1: '/komunitas',         // Community/Chat
    2: '/kategori',          // Categories/Layers
    3: '/profil-utama',      // Profile
  };

  int getSelectedIndex() {
    String? currentRoute = ModalRoute.of(context)?.settings.name;

    // Check which navigation section the current route belongs to
    if (currentRoute != null) {
      // Home section routes
      if (currentRoute == '/beranda' ||
          currentRoute == '/notif' ||
          currentRoute == '/pengguna-terbaik' ||
          currentRoute == '/trending-resep' ||
          currentRoute == '/hasil-pencarian') {
        return 0;
      }

      // Community section routes
      else if (currentRoute == '/komunitas' ||
          currentRoute == '/review') {
        return 1;
      }

      // Categories section routes
      else if (currentRoute == '/kategori' ||
          currentRoute == '/sub-category' ||
          currentRoute == '/detail-resep' ||
          currentRoute == '/penjadwalan' ||
          currentRoute == '/recipe') {
        return 2;
      }

      // Profile section routes
      else if (currentRoute == '/profil-utama' ||
          currentRoute == '/edit-profil' ||
          currentRoute == '/bagikan-profil' ||
          currentRoute == '/mengikuti-pengikut' ||
          currentRoute == '/makanan-favorit' ||
          currentRoute == '/tambah-resep' ||
          currentRoute == '/edit-resep' ||
          currentRoute == '/pengaturan-utama' ||
          currentRoute == '/pengaturan-notifikasi' ||
          currentRoute == '/pusat-bantuan') {
        return 3;
      }
    }

    return 0; // Default to home if route not found
  }

  void _onItemTapped(int index) {
    String targetRoute = _navRoutes[index] ?? '/beranda';

    // Only navigate if we're not already on a page in this section
    if (getSelectedIndex() != index) {
      Navigator.pushReplacementNamed(context, targetRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    int selectedIndex = getSelectedIndex();

    return Stack(
      children: [
        widget.child,
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 90,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Color(0xFF7ECBCD),    // Solid color at bottom
                  Color(0x807ECBCD),    // Semi-transparent in middle
                  Color(0x007ECBCD),    // Fully transparent at top
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
              child: Container(
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  color: const Color(0xFF006257),  // Dark teal color
                  borderRadius: BorderRadius.circular(35),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(0, Icons.home_outlined, selectedIndex),
                    _buildNavItem(1, Icons.chat_bubble_outline, selectedIndex),
                    _buildNavItem(2, Icons.layers_outlined, selectedIndex),
                    _buildNavItem(3, Icons.person_outline, selectedIndex),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(int index, IconData icon, int selectedIndex) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 40,
            alignment: Alignment.center,
            child: Icon(
                icon,
                size: 28,
                color: Colors.white
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: 3,
            width: isSelected ? 24 : 0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }
}