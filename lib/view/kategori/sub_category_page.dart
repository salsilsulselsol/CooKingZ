import 'package:flutter/material.dart';

class SubCategoryPage extends StatefulWidget {
  const SubCategoryPage({super.key});

  @override
  State<SubCategoryPage> createState() => _SubCategoryPageState();
}

class _SubCategoryPageState extends State<SubCategoryPage> {
  // Define app colors
  final Color primaryColor = const Color(0xFF005A4D);
  final Color accentTeal = const Color(0xFF57B4BA);
  final Color emeraldGreen = const Color(0xFF015551);

  // Lista navigasi tab (di bawah 'Sarapan')
  final List<String> _categories = [
    'Sarapan',
    'Makan Siang',
    'Makan Malam',
    'Vegan',
    'Halal',
  ];

  // Index tab yang aktif
  int _selectedCategoryIndex = 0;

  // Data makanan untuk kategori sarapan
  final List<Map<String, dynamic>> _breakfastFoods = [
    {
      'name': 'Eggs Benedict',
      'description': 'Muffin dengan Bacon Kanada',
      'image': 'images/eggs_benedict.png',
      'duration': '45 menit',
      'price': '30RB',
      'likes': 12,
    },
    {
      'name': 'French Toast',
      'description': 'Irisan roti yang lezat',
      'image': 'images/french_toast.png',
      'duration': '15 menit',
      'price': '25RB',
      'likes': 24,
    },
    {
      'name': 'Oatmeal & Kacang',
      'description': 'Campuran sehat untuk sarapan',
      'image': 'images/oatmeal_kacang.png',
      'duration': '20 menit',
      'price': '25RB',
      'likes': 14,
    },
    {
      'name': 'Telur Dadar',
      'description': 'bertekstur dan alami',
      'image': 'images/telur_dadar.png',
      'duration': '30 menit',
      'price': '15RB',
      'likes': 85,
    },
    {
      'name': 'Oatmeal Stroberi',
      'description': 'Siap santap dengan stroberi dan blueberry',
      'image': 'images/oatmeal_stroberi.png',
      'duration': '15 menit',
      'price': '25RB',
      'likes': 23,
    },
    {
      'name': 'Bruschetta',
      'description': 'Roti panggang dengan topping segar',
      'image': 'images/bruschetta.png',
      'duration': '30 menit',
      'price': '35RB',
      'likes': 42,
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
            _buildTabBar(),
            Expanded(
              child: _buildFoodGridView(),
            ),
            _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  // Header dengan judul dan tombol navigasi
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            'Sarapan',
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
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(100),
                ),
                padding: const EdgeInsets.all(1),
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
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(100),
                ),
                padding: const EdgeInsets.all(1),
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

  // Tab bar untuk kategori makanan
  Widget _buildTabBar() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: _selectedCategoryIndex == index
                    ? primaryColor
                    : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: primaryColor,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  _categories[index],
                  style: TextStyle(
                    color: _selectedCategoryIndex == index
                        ? Colors.white
                        : primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Grid view untuk item makanan
  Widget _buildFoodGridView() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 0.50,
        mainAxisSpacing: 5,
        childAspectRatio: 3 / 3.5,
      ),
      itemCount: _breakfastFoods.length,
      itemBuilder: (context, index) {
        return _buildFoodCard(_breakfastFoods[index]);
      },
    );
  }

  // Card untuk setiap item makanan
  Widget _buildFoodCard(Map<String, dynamic> food) {
    return IntrinsicHeight(
      child: Container(
        margin: const EdgeInsets.only(right: 10, left: 10, bottom: 0),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Food image with position settings
            Container(
              height: 160,
              width: double.infinity,
              alignment: Alignment.topRight,
              child: Stack(
                children: [
                  // Food image with rounded corners
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      food['image'],
                      height: 1000,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Favorite button (heart icon)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: accentTeal,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.favorite_border, size: 16),
                        color: const Color.fromARGB(255, 253, 252, 252),
                        onPressed: () {
                          // Add logic for favorite button here
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IntrinsicHeight(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide.none, // Menghilangkan border atas
                    left: BorderSide(
                      color: emeraldGreen,
                      width: 1,
                    ),
                    right: BorderSide(
                      color: emeraldGreen,
                      width: 1,
                    ),
                    bottom: BorderSide(
                      color: emeraldGreen,
                      width: 1,
                    ),
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 0),
                margin: const EdgeInsets.symmetric(horizontal: 7),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Food Name and Description
                    Container(
                      margin: const EdgeInsets.only(bottom: 8, left: 10, right: 10),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            food['name'],
                            style: const TextStyle(
                              color: Color(0xFF3E2823),
                              fontSize: 12, // Reduced font size
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            food['description'],
                            style: const TextStyle(
                              color: Color(0xFF3E2823),
                              fontSize: 10, // Reduced font size
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Likes, Duration, Price
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            children: [
                              Text(
                                food['likes'].toString(),
                                style: TextStyle(
                                  color: accentTeal,
                                  fontSize: 10, // Reduced font size
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.favorite,
                                color: accentTeal,
                                size: 8, // Reduced icon size
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: accentTeal,
                                size: 8, // Reduced icon size
                              ),
                              const SizedBox(width: 4),
                              Text(
                                food['duration'],
                                style: TextStyle(
                                  color: accentTeal,
                                  fontSize: 10, // Reduced font size
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "RP",
                                style: TextStyle(
                                  color: accentTeal,
                                  fontSize: 10, // Reduced font size
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                food['price'],
                                style: TextStyle(
                                  color: accentTeal,
                                  fontSize: 10, // Reduced font size
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bottom navigation bar
  Widget _buildBottomNavigationBar() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
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