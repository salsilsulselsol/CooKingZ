

import 'package:flutter/material.dart';
class ProfilUtama extends StatefulWidget {
  const ProfilUtama({super.key});

  @override
 
  State<ProfilUtama> createState() => _ProfilUtamaState();
}

class _ProfilUtamaState extends State<ProfilUtama> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(

          children: [
            // Top section - Profile header
            _buildProfileHeader(),
            
            // Stats section
            _buildStatsSection(),
            
            // Tab Bar
            _buildTabBar(),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildRecipeGrid(),
                  _buildFavoriteGrid(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
 Widget _buildProfileHeader() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile image
        Container(
          width: 74,
          height: 74,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: AssetImage('images/pp_profil.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Name, description, and action buttons
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row untuk nama + tombol aksi
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Nama
                  const Expanded(
                    child: Text(
                      'Siti Rahayu',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Tombol +
                  Container(
                    width: 30,
                    height: 30,
                    margin: const EdgeInsets.only(right: 2),
                    child: IconButton(
                                icon: Image.asset('images/tambah.png', width: 28, height: 28),
                                onPressed: () {},
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                    ),    
                  ),

                  // Tombol titik tiga
                  Container(
                    width: 30,
                    height: 30,
                    child: IconButton(
                                icon: Image.asset('images/garis_tiga.png', width: 28, height: 28),
                                onPressed: () {},
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                    ),  
                  ),
                ],
              ),

              const SizedBox(height: 4),
              // Deskripsi
              const Text(
                'Penulis resep terbaik mencoba dan berbagi resep baru dengan dunia.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}


Widget _buildStatsSection() {
  return Column(
    children: [
      // Tombol aksi profil
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
        Expanded(
              child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "/edit_profil");
              },
              style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A6859),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25), // Sudut tombol lebih kecil
              ),
              padding: const EdgeInsets.symmetric(vertical: 8), // Padding vertikal lebih kecil
              minimumSize: const Size(double.infinity, 20), // Ukuran tombol lebih kecil
              ),
              child: const Text(
              'Edit Profil',
              style: TextStyle(fontSize: 13), // Ukuran font lebih kecil
              ),
              ),
            ),    const SizedBox(width: 12), // Jarak antar tombol lebih kecil
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, "/bagikan_profil");
            },
            style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0A6859),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25), // Sudut tombol lebih kecil
          ),
          padding: const EdgeInsets.symmetric(vertical: 8), // Padding vertikal lebih kecil
          minimumSize: const Size(double.infinity, 20), // Ukuran tombol lebih kecil
            ),
            child: const Text(
          'Bagikan Profil',
          style: TextStyle(fontSize: 13), // Ukuran font lebih kecil
            ),
          ),
        ),
          ],
        ),
      ),
      const SizedBox(height: 10),

      // Stats Counter dengan border membulat
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(
          color: const Color(0xFF0A6859),
          width: 1,
            ),
            borderRadius: BorderRadius.circular(25), // Sudut border membulat
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
          GestureDetector(
            onTap: () {
              _tabController.animateTo(0); // Pindah ke tab Resep
            },
            child: _buildStatCounter('60', 'Resep'),
          ),
          _buildDivider(),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/follow', arguments: 0);
            },
            child: _buildStatCounter('120', 'Mengikuti'),
          ),
          _buildDivider(),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/follow', arguments: 1);
            },
            child: _buildStatCounter('250', 'Pengikut'),
          ),
            ],
          ),
        ),

        const SizedBox(height: 10),
          ],
        );
      }

  Widget _buildStatCounter(String count, String label) {
  return Column(
    children: [
      Text(
        count,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Color.fromARGB(255, 8, 8, 8),
        ),
      ),
    ],
  );
}

Widget _buildDivider() {
  return Container(
    height: 30,
    width: 1,
    color:  const Color(0xFF0A6859),
  );
}


  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF0A6859),
        labelColor: const Color(0xFF0A6859),
        unselectedLabelColor: Colors.grey,
        tabs: const [
          Tab(text: 'Resep'),
          Tab(text: 'Favorit'),
        ],
      ),
    );
  }

  Widget _buildRecipeGrid() {
  // List of recipes
  List<Map<String, dynamic>> recipes = [
    {
      'name': 'Udang Krispi',
      'description': 'Digoreng dengan tepung',
      'image': 'images/udang_krispi.jpg',
      'duration': '15menit',
      'price': '20RB',
      'likes': 34, // Changed from rating to likes
    },
    {
      'name': 'Sayap Ayam Kecap',
      'description': 'Dimasak dengan kecap',
      'image': 'images/sayap_ayam_kecap.jpg',
      'duration': '15menit',
      'price': '20RB',
      'likes': 5, // Changed from rating to likes
    },
    {
      'name': 'Macarons',
      'description': 'Manis, fluffy, dan Pink',
      'image': 'images/macarons.jpg',
      'duration': '15menit',
      'price': '20RB',
      'likes': 96, // Changed from rating to likes
    },
    {
      'name': 'Pina Colada',
      'description': 'Minuman segar khas tropis',
      'image': 'images/pina_colada.jpg',
      'duration': '5menit',
      'price': '20RB',
      'likes': 5, // Changed from rating to likes
    },
    {
      'name': 'Spring Rolls',
      'description': 'Delicate and full of flavor',
      'image': 'images/spring_rolls.jpg',
      'duration': '30menit',
      'price': '30RB',
      'likes': 4, // Changed from rating to likes
    },
    {
      'name': 'French Toast',
      'description': 'Delicious slice of bread',
      'image': 'images/french_toast.jpg',
      'duration': '25menit',
      'price': '20RB',
      'likes': 4, // Changed from rating to likes
    },
  ];

  return GridView.builder(
  padding : const EdgeInsets.symmetric(horizontal: 2, vertical: 20),
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,         // 2 items per baris
    crossAxisSpacing: 0.50,      // jarak horizontal antar box
    mainAxisSpacing: 5,       // jarak vertikal antar box
    childAspectRatio: 3 / 3.5,   // lebar : tinggi (misalnya 3:4 = 0.75)
  ),
  itemCount: recipes.length,
  itemBuilder: (context, index) {
    return _buildFoodCard(recipes[index]);
  },
);

}

Widget _buildFoodCard(Map<String, dynamic> food) {
  return IntrinsicHeight(
    child: Container(
      margin: const EdgeInsets.only(right: 10, left: 20, bottom: 10),
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
                      color: const Color(0xFF57B4BA),
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
                  color: const Color(0xFF015551),
                  width: 1,
                ),
                right: BorderSide(
                  color: const Color(0xFF015551),
                  width: 1,
                ),
                bottom: BorderSide(
                  color: const Color(0xFF015551),
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
                    const SizedBox(height: 4),
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
                        style: const TextStyle(
                        color: Color(0xFF57B4BA),
                        fontSize: 10, // Reduced font size
                        ),
                      ),
                      const SizedBox(width: 4),
                      Image.network(
                        "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/4BVj0nFRxh/n14ym11w_expires_30_days.png",
                        width: 8, // Reduced icon size
                        height: 8, // Reduced icon size
                        fit: BoxFit.fill,
                      ),
                      ],
                    ),
                    Row(
                      children: [
                      Image.asset(
                                  'images/star_hijau.png',
                                  width: 7, // Reduced icon size
                                  height: 8, // Reduced icon size
                                  fit: BoxFit.fill,
                                  ),    const SizedBox(width: 4),
                      Text(
                        food['duration'],
                        style: const TextStyle(
                        color: Color(0xFF57B4BA),
                        fontSize: 10, // Reduced font size
                        ),
                      ),
                      ],
                    ),
                    Row(
                      children: [
                      const Text(
                        "RP",
                        style: TextStyle(
                        color: Color(0xFF57B4BA),
                        fontSize: 10, // Reduced font size
                        fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        food['price'],
                        style: const TextStyle(
                        color: Color(0xFF57B4BA),
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

  Widget _buildFavoriteGrid() {
    // For the favorites section, we're showing food categories instead of individual recipes
    return SingleChildScrollView(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/makanan_favorit', arguments: 'Manis');
            },
            child: _buildCategoryCard(
              'Manis', 
              'images/manis.png', 
              'Kumpulan resep makanan dan minuman manis',
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/makanan_favorit', arguments: 'Asin');
            },
            child: _buildCategoryCard(
              'Asin', 
              'images/asin.png', 
              'Kumpulan resep makanan dan minuman asin',
            ),
          ),    Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Buat Koleksi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A6859),
                foregroundColor: Colors.white,
                minimumSize: const Size(100, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoryCard(String title, String imageUrl, String description) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
        
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          imageUrl,
          height: 103, // Adjusted height to make the image smaller
          width: 356,
          fit: BoxFit.cover,
        ),
          ),
          Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
          ),
        ],
      ),
        );
      }

  
}