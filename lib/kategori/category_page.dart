import 'package:flutter/material.dart';
import 'package:masak2/kategori/sub_category_page.dart'; // Import the existing SubCategoryPage

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  // Define app colors
  final Color primaryColor = const Color(0xFF005A4D);
  final Color accentTeal = const Color(0xFF57B4BA);

  // Data kategori makanan
  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Makanan Laut',
      'image': 'images/category_makanan_laut.png',
    },
    {
      'name': 'Makan Siang',
      'image': 'images/category_makan_siang.png',
    },
    {
      'name': 'Sarapan',
      'image': 'images/category_sarapan.png',
    },
    {
      'name': 'Makan Malam',
      'image': 'images/category_makan_malam.png',
    },
    {
      'name': 'Vegan',
      'image': 'images/category_vegan.png',
    },
    {
      'name': 'Hidangan Penutup',
      'image': 'images/category_hidangan_penutup.png',
    },
    {
      'name': 'Minuman',
      'image': 'images/category_minuman.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildCategoryGrid(),
            ),
            // _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  // Header dengan judul dan tombol navigasi
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tombol kembali dengan image asset
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 30,
              height: 30,
              padding: const EdgeInsets.all(3),
              child: Image.asset(
                'images/arrow.png',
                width: 24,
                height: 24,
              ),
            ),
          ),

          // Judul halaman
          Text(
            'Kategori',
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),

          // Tombol-tombol di kanan
          Row(
            children: [
              // Tombol notifikasi
              Container(
                width: 30,
                height: 30,
                margin: const EdgeInsets.only(right: 10),
                child: Image.asset(
                  'images/notif.png',
                  width: 28,
                  height: 28,
                ),
              ),

              // Tombol pencarian
              Container(
                width: 30,
                height: 30,
                child: Image.asset(
                  'images/search.png',
                  width: 28,
                  height: 28,

                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Grid view untuk kategori makanan
  Widget _buildCategoryGrid() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          // Row 1: Makanan Laut (full width)
          _buildLargeCategory(_categories[0]),
          const SizedBox(height: 16),

          // Row 2: Makan Siang dan Sarapan (two columns)
          Row(
            children: [
              Expanded(child: _buildSmallCategory(_categories[1])),
              const SizedBox(width: 16),
              Expanded(child: _buildSmallCategory(_categories[2])),
            ],
          ),
          const SizedBox(height: 16),

          // Row 3: Makan Malam dan Vegan (two columns)
          Row(
            children: [
              Expanded(child: _buildSmallCategory(_categories[3])),
              const SizedBox(width: 16),
              Expanded(child: _buildSmallCategory(_categories[4])),
            ],
          ),
          const SizedBox(height: 16),

          // Row 4: Hidangan Penutup dan Minuman (two columns)
          Row(
            children: [
              Expanded(child: _buildSmallCategory(_categories[5])),
              const SizedBox(width: 16),
              Expanded(child: _buildSmallCategory(_categories[6])),
            ],
          ),
        ],
      ),
    );
  }

  // Card untuk kategori besar (full width) - Makanan Laut
  Widget _buildLargeCategory(Map<String, dynamic> category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SubCategoryPage(),
          ),
        );
      },
      child: Column(
        children: [
          // Category name positioned above the image
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Center(
              child: Text(
                category['name'],
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Image container
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: AssetImage(category['image']),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Card untuk kategori kecil (half width)
  Widget _buildSmallCategory(Map<String, dynamic> category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SubCategoryPage(),
          ),
        );
      },
      child: Column(
        children: [
          // Image container
          Container(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: AssetImage(category['image']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Category name positioned below the image
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Center(
              child: Text(
                category['name'],
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Bottom navigation bar
  Widget _buildBottomNavigationBar() {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),  // Colors.black with 10% opacity
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavBarItem(Icons.home, true),
          _buildNavBarItem(Icons.chat_bubble_outline, false),
          _buildNavBarItem(Icons.layers, false),
          _buildNavBarItem(Icons.person_outline, false),
        ],
      ),
    );
  }

  // Item untuk bottom navigation bar
  Widget _buildNavBarItem(IconData icon, bool isActive) {
    return Icon(
      icon,
      color: isActive ? primaryColor : Colors.grey,
      size: 28,
    );
  }
}