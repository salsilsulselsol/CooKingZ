import 'package:flutter/material.dart';
import '../../component/grid_2_builder.dart';
import '../../../models/food_model.dart';

class ProfilUtama extends StatefulWidget {
  const ProfilUtama({super.key});
  @override
  State createState() => _ProfilUtamaState();
}

class _ProfilUtamaState extends State with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Dummy data for recipes.  Using the Food model.
  final List<Food> _recipes = [
    Food(
      id: 1,
      name: 'Udang Krispi',
      description: 'Digoreng dengan tepung',
      image: 'images/udang_krispi.jpg',
      cookingTime: 15,
      price: '20RB',
      likes: 34,
    ),
    Food(
      id: 2,
      name: 'Sayap Ayam Kecap',
      description: 'Dimasak dengan kecap',
      image: 'images/sayap_ayam_kecap.jpg',
      cookingTime: 15,
      price: '20RB',
      likes: 5,
    ),
    Food(
      id: 3,
      name: 'Macarons',
      description: 'Manis, fluffy, dan Pink',
      image: 'images/macarons.jpg',
      cookingTime: 15,
      price: '20RB',
      likes: 96,
    ),
    Food(
      id: 4,
      name: 'Pina Colada',
      description: 'Minuman segar khas tropis',
      image: 'images/pina_colada.jpg',
      cookingTime: 5,
      price: '20RB',
      likes: 5,
    ),
    Food(
      id: 5,
      name: 'Spring Rolls',
      description: 'Delicate and full of flavor',
      image: 'images/spring_rolls.jpg',
      cookingTime: 30,
      price: '30RB',
      likes: 4,
    ),
    Food(
      id: 6,
      name: 'French Toast',
      description: 'Delicious slice of bread',
      image: 'images/french_toast.jpg',
      cookingTime: 25,
      price: '20RB',
      likes: 4,
    ),
  ];

    // For the Favorite Tab
  final List<Map<String, String>> _favoriteCategories = [
    {
      'name': 'Manis',
      'image': 'images/manis.png',
      'description': 'Kumpulan resep makanan dan minuman manis',
    },
    {
      'name': 'Asin',
      'image': 'images/asin.png',
      'description': 'Kumpulan resep makanan dan minuman asin',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
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
                  // Use the FoodGridWidget here
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

  // Profile header
  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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

  // Stats Profil
  Widget _buildStatsSection() {
    return Column(
      children: [
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
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    minimumSize: const Size(double.infinity, 20),
                  ),
                  child: const Text(
                    'Edit Profil',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/bagikan_profil");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A6859),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    minimumSize: const Size(double.infinity, 20),
                  ),
                  child: const Text(
                    'Bagikan Profil',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFF0A6859),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  _tabController.animateTo(0);
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
        const SizedBox(height: 8),
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
        const SizedBox(height: 2),
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

  // Pembatas di stats profil
  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: const Color(0xFF0A6859),
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

  // Use FoodGridWidget
    Widget _buildRecipeGrid() {
    return FoodGridWidget(
      foods: _recipes,
      onFavoritePressed: (index) {
        // Handler doang buat nanti
        print('Favorite pressed for recipe at index: $index');
      },
      onCardTap: (index) {
        // Handler doang buat nanti
        print('Card tapped for recipe at index: $index');
      },
    );
  }

  Widget _buildFavoriteGrid() {
    return SingleChildScrollView(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/makanan-favorit', arguments: 'Manis');
            },
            child: _buildCategoryCard(
              _favoriteCategories[0]['name']!,
              _favoriteCategories[0]['image']!,
              _favoriteCategories[0]['description']!,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/makanan-favorit', arguments: 'Asin');
            },
            child: _buildCategoryCard(
              _favoriteCategories[1]['name']!,
              _favoriteCategories[1]['image']!,
              _favoriteCategories[1]['description']!,
            ),
          ),
          Padding(
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
            height: 103,
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