import 'package:flutter/material.dart';
import 'package:masak2/view/kategori/sub_category_page.dart';
import 'package:masak2/view/component/bottom_navbar.dart';
import 'package:masak2/view/component/header_b_n_s.dart'; // Import custom header component

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
    // Menggunakan BottomNavbar di dalam build method untuk memastikan
    // CategoryPage selalu muncul dengan bottom navbar
    return BottomNavbar(
      _buildMainContent(),
    );
  }

  // Widget yang berisi konten utama dari CategoryPage
  Widget _buildMainContent() {
    return Scaffold(
      extendBody: true, // Tambahkan ini untuk membuat body meluas ke bawah navbar
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false, // Tambahkan ini agar content bisa mengisi area di bawah
        child: Column(
          children: [
            // Menggunakan CustomHeader component dengan handler langsung di dalamnya
            CustomHeader(
              title: 'Kategori',
              titleColor: primaryColor,
              // Tidak perlu lagi menyediakan callback karena handler sudah ada di CustomHeader
            ),
            Expanded(
              child: _buildCategoryGrid(),
            ),
          ],
        ),
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
          // Tambahkan padding tambahan di bagian bawah untuk memberikan ruang bagi navbar
          const SizedBox(height: 90),
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
            // Juga memanggil bottom navbar di SubCategoryPage untuk konsistensi
            builder: (context) => BottomNavbar(const SubCategoryPage()),
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
            // Juga memanggil bottom navbar di SubCategoryPage untuk konsistensi
            builder: (context) => BottomNavbar(const SubCategoryPage()),
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
}