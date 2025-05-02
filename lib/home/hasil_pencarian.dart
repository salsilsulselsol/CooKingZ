import 'package:flutter/material.dart';

class HasilPencaharian extends StatefulWidget {
  const HasilPencaharian({super.key});

  @override
  State<HasilPencaharian> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<HasilPencaharian> {
  // Define app colors
  final Color primaryColor = const Color(0xFF005A4D);
  final Color accentTeal = const Color(0xFF57B4BA);
  final Color emeraldGreen = const Color(0xFF015551);

  // Data makanan untuk hasil pencarian (contoh data) - diupdate sesuai dengan gambar
  final List<Map<String, dynamic>> _searchResults = [
    {
      'name': 'Telur Gulung',
      'description': 'Telur dengan Roti Kanada',
      'image': 'images/telur_gulung.png',
      'duration': '15menit',
      'price': '20RB',
      'likes': 5,
    },
    {
      'name': 'Roti Telur',
      'description': 'Irisan roti yang lezat',
      'image': 'images/roti_telur.png',
      'duration': '15menit',
      'price': '20RB',
      'likes': 5,
    },
    {
      'name': 'Pudding Telur',
      'description': 'Campuran sehat untuk sarapan',
      'image': 'images/pudding_telur.png',
      'duration': '15menit',
      'price': '20RB',
      'likes': 12,
    },
    {
      'name': 'Pizza Telur',
      'description': 'Pesona pedesaan yang bertekstur dan alami',
      'image': 'images/pizza_telur.png',
      'duration': '15menit',
      'price': '20RB',
      'likes': 7,
    },
    {
      'name': 'Oatmeal Telur',
      'description': 'menggabungkan oatmeal dengan telur',
      'image': 'images/oatmeal_telur.png',
      'duration': '34menit',
      'price': '20RB',
      'likes': 34,
    },
    {
      'name': 'Telur Roti Panggang',
      'description': 'Roti panggang dengan telur',
      'image': 'images/telur_roti_panggang.png',
      'duration': '34menit',
      'price': '18RB',
      'likes': 32,
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
            _buildSearchBar(),
            Expanded(
              child: _buildFoodGridView(),
            ),
            // Bottom navigation bar removed
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
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.arrow_back, color: primaryColor);
                },
              ),
            ),
          ),

          // Judul halaman
          Text(
            'Hasil Pencarian',
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),

          // Lonceng dihapus, menyisakan space kosong
          const SizedBox(width: 30),
        ],
      ),
    );
  }

  // Search bar dengan text field
  Widget _buildSearchBar() {
    return Row(
      children: [
        // Search Field - dibuat lebih pendek untuk memberi ruang pada filter
        Expanded(
          flex: 5,
          child: Container(
            margin: const EdgeInsets.only(left: 16, right: 10, top: 10, bottom: 10),
            decoration: BoxDecoration(
                color: Color(0xFF9FD5DB),

              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  spreadRadius: 1,
                  blurRadius: 3,
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Telur',
                hintStyle: const TextStyle(color: Colors.white),
                // Icon mic diganti dengan search di suffix
                suffixIcon: Image.asset(
                  'images/search.png',
                  width: 20,
                  height: 20,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.search, color: Colors.white, size: 20);
                  },
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: InputBorder.none,
              ),
              autofocus: false,
              onSubmitted: (value) {
                // Handle search submission
              },
            ),
          ),
        ),
        // Filter Button
        Container(
          margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Image.asset(
              'images/filter.png',
              width: 24,
              height: 24,
              color: Colors.white,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.filter_list, color: Colors.white, size: 24);
              },
            ),
          ),
        ),
      ],
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
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return _buildFoodCard(_searchResults[index]);
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
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 160,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: Icon(Icons.restaurant, color: Colors.grey[600], size: 40),
                        );
                      },
                    ),
                  ),
                  // Favorite button (heart icon dengan transparansi)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: accentTeal.withValues(alpha: 0.7), // Menggunakan withOpacity untuk transparansi
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Image.asset(
                          'images/love.png',
                          width: 16,
                          height: 16,
                          color: Colors.white,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.favorite_border, color: Colors.white, size: 16);
                          },
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
                              // Menggunakan image asset untuk icon star
                              Image.asset(
                                'images/bintang.png',
                                width: 10,
                                height: 10,
                                color: accentTeal,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.star,
                                    color: accentTeal,
                                    size: 8,
                                  );
                                },
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              // Menggunakan image asset untuk icon jam
                              Image.asset(
                                'images/waktu.png',
                                width: 10,
                                height: 10,
                                color: accentTeal,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.access_time,
                                    color: accentTeal,
                                    size: 8,
                                  );
                                },
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
}