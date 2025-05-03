import 'package:flutter/material.dart';

class TrandingResep extends StatefulWidget {
  const TrandingResep({super.key});

  @override
  State<TrandingResep> createState() => _TrendingReceipesPageState();
}

class _TrendingReceipesPageState extends State<TrandingResep> {
  // Define app colors
  final Color primaryColor = const Color(0xFFFFD54F); // Yellow color
  final Color accentTeal = const Color(0xFF57B4BA);
  final Color originalGreen = const Color(0xFF005A4D); // Original green color for texts and buttons

  // Data resep trending
  final List<Map<String, dynamic>> _trendingRecipes = [
    {
      'name': 'Croffle Ice Cream',
      'image': 'images/croffle.png',
      'description': 'Berikut adalah ikhtisar singkat bahan-bahannya...',
      'likes': '213',
      'time': '15menit',
      'price': 'RP.20RB'
    },
    {
      'name': 'Kari Ayam',
      'image': 'images/kari_ayam_komunitas.png',
      'description': 'Nikmat: Kari Ayam yang aromatik—campuran rempah-rempah yang kaya...',
      'likes': '45',
      'chef': 'Chef Josh Ryan',
      'difficulty': 'Mudah',
      'time': '45menit',
      'price': 'RP.50RB'
    },
    {
      'name': 'Gulai',
      'image': 'images/gulai.jpg',
      'description': 'Nikmat: Gulai yang lezat: ayam berbumbu...',
      'likes': '15',
      'chef': 'Chef Andre',
      'difficulty': 'Mudah',
      'time': '50menit',
      'price': 'RP.50RB'
    },
    {
      'name': 'Martabak Manis',
      'image': 'images/martabak_manis.png',
      'description': 'Campur tepung, garam, kayu manis, dan gula hingga merata...',
      'likes': '30',
      'chef': 'Chef Dian',
      'difficulty': 'Sedang',
      'time': '60menit',
      'price': 'RP.30RB'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildFeaturedRecipe(context, _trendingRecipes[0]),
            _buildLihatSemuanya(),
            _buildRecipesList(context),
          ],
        ),
      ),
    );
  }

  // Header dengan judul dan tombol navigasi
  Widget _buildHeader(BuildContext context) {
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
            'Resep Yang Sedang Tren',
            style: TextStyle(
              color: originalGreen,
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
                  color: originalGreen,
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

  // "Lihat Semuanya" text
  Widget _buildLihatSemuanya() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          'Lihat Semuanya',
          style: TextStyle(
            color: accentTeal,
            fontWeight: FontWeight.w500,
            fontSize: 14,
            height: 2,
            decoration: TextDecoration.underline,
            decorationColor: accentTeal,
            decorationThickness: 1.2, // Bisa disesuaikan
          ),
        ),
      ),
    );
  }

  // Featured recipe (large card)
  Widget _buildFeaturedRecipe(BuildContext context, Map<String, dynamic> recipe) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 25),
      // Tambahan container luar dengan background primaryColor
      decoration: BoxDecoration(
        color: originalGreen,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(8), // Padding untuk efek border dari primaryColor
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food image with position settings
          Container(
            height: 160,
            width: double.infinity,
            alignment: Alignment.center,
            child: Stack(
              children: [
                // Food image with rounded corners
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    recipe['image'],
                    height: 170,
                    width: 350,
                    fit: BoxFit.cover,
                  ),
                ),
                // Favorite button (star icon)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 30,
                    height: 30,
                    child: IconButton(
                      icon: Image.asset(
                        'images/love.png', // Pastikan path ini sesuai dengan lokasi file gambar kamu
                        width: 28,
                        height: 28,
                      ),
                      color: Colors.white, // Ini tidak berpengaruh pada Image.asset
                      onPressed: () {},
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
          // Bottom card with recipe info
          IntrinsicHeight(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              margin: const EdgeInsets.symmetric(horizontal: 33),
              width: double.infinity,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LEFT SIDE: Recipe Name and Description
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe['name'],
                          style: const TextStyle(
                            color: Color(0xFF3E2823),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          recipe['description'],
                          style: const TextStyle(
                            color: Color(0xFF3E2823),
                            fontSize: 10,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // RIGHT SIDE: Likes, Duration, Price
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Likes and Time in single row
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Likes
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  recipe['likes'].toString(),
                                  style: TextStyle(
                                    color: accentTeal,
                                    fontSize: 10,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Image.asset(
                                  'images/love.png',
                                  width: 8,
                                  height: 8,
                                  color: accentTeal,
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            // Time
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'images/alarm.png', // Make sure this image exists in your assets
                                  width: 8,
                                  height: 8,
                                  color: accentTeal,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  recipe['time'],
                                  style: TextStyle(
                                    color: accentTeal,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Price in separate row
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "RP",
                              style: TextStyle(
                                color: Color(0xFF57B4BA),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              recipe['price'],
                              style: TextStyle(
                                color: accentTeal,
                                fontSize: 10,
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
    );
  }

  // Recipe list (scrollable)
  Widget _buildRecipesList(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _trendingRecipes.length - 1, // Skip the first recipe as it's featured
        itemBuilder: (context, index) {
          return _buildRecipeCard(context, _trendingRecipes[index + 1]);
        },
      ),
    );
  }

  // Recipe card for list items
  Widget _buildRecipeCard(BuildContext context, Map<String, dynamic> recipe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Recipe image
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
            child: Image.asset(
              recipe['image'],
              height: 160,
              width: 140,
              fit: BoxFit.cover,
            ),
          ),

          // Recipe details
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              height: 160, // Match parent height
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Center vertically
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recipe name and description
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        recipe['description'],
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Chef name and details
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "By ${recipe['chef']}",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Time with alarm icon
                            Row(
                              children: [
                                Image.asset(
                                  'images/alarm.png',
                                  width: 12,
                                  height: 12,
                                  color: Colors.teal,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  recipe['time'],
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.teal,
                                  ),
                                ),
                              ],
                            ),

                            // Difficulty
                            Text(
                              recipe['difficulty'],
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.teal,
                              ),
                            ),

                            // Likes with star icon
                            Row(
                              children: [
                                Text(
                                  recipe['likes'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.teal,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Image.asset(
                                  'images/star.png',
                                  width: 12,
                                  height: 12,
                                  color: Colors.teal,
                                ),
                              ],
                            ),

                            // Price with RP prefix
                            Text(
                              "RP ${recipe['price']}",
                              style: TextStyle(
                                fontSize: 12,
                                color: accentTeal,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}