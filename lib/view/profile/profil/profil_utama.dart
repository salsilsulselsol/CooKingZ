import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

// **FIX**: Impor ini sekarang akan memanggil kelas 'FoodGridWidget' yang benar dari file ini
import '../../component/grid_2_builder.dart'; 
import '../../../models/food_model.dart';
import '../../../models/user_profile_model.dart';
import '../../../theme/theme.dart';
import 'tambah_resep.dart'; // File ini berisi kelas 'BuatResep'
import 'edit_profil.dart';

class ProfilUtama extends StatefulWidget {
  const ProfilUtama({super.key});
  @override
  State createState() => _ProfilUtamaState();
}

class _ProfilUtamaState extends State with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // State untuk data API
  late Future<UserProfile> futureUserProfile;
  late Future<List<Food>> futureUserRecipes;

  // Data dummy hanya untuk tab favorit (sesuai kode asli Anda)
  final List<Map<String, String>> _favoriteCategories = [
    {'name': 'Manis', 'image': 'images/manis.png', 'description': 'Kumpulan resep makanan dan minuman manis'},
    {'name': 'Asin', 'image': 'images/asin.png', 'description': 'Kumpulan resep makanan dan minuman asin'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _loadAllData();
  }

  void _loadAllData() {
    futureUserProfile = fetchUserProfile();
    futureUserProfile.then((user) {
      if (mounted) {
        setState(() {
          futureUserRecipes = fetchUserRecipes(user.id);
        });
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          futureUserRecipes = Future.error('Profil gagal dimuat, resep tidak bisa diambil.');
        });
      }
    });
  }
  
  Future<UserProfile> fetchUserProfile() async {
    final baseUrl = dotenv.env['BASE_URL'];
    if (baseUrl == null) throw Exception("BASE_URL tidak ada di .env");
    final response = await http.get(Uri.parse('$baseUrl/api/users/me'));
    if (response.statusCode == 200) {
      return UserProfile.fromJson(json.decode(response.body));
    } else {
      throw Exception('Gagal memuat profil (Status: ${response.statusCode})');
    }
  }

  Future<List<Food>> fetchUserRecipes(int userId) async {
    final baseUrl = dotenv.env['BASE_URL'];
    if (baseUrl == null) throw Exception("BASE_URL tidak ada di .env");
    final response = await http.get(Uri.parse('$baseUrl/api/users/$userId/recipes'));
    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Food.fromMap(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Gagal memuat resep');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<UserProfile>(
        future: futureUserProfile,
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (userSnapshot.hasError) {
            return Center(child: Text("Error: ${userSnapshot.error}"));
          }
          if (userSnapshot.hasData) {
            return _buildProfileBody(userSnapshot.data!);
          }
          return const Center(child: Text("Tidak ada data profil."));
        },
      ),
    );
  }
  
  Widget _buildProfileBody(UserProfile user) {
    return SafeArea(
      child: Column(
        children: [
          _buildProfileHeader(user),
          _buildStatsSection(user),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                FutureBuilder<List<Food>>(
                  future: futureUserRecipes,
                  builder: (context, recipeSnapshot) {
                    if (recipeSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (recipeSnapshot.hasError) {
                      return Center(child: Text('${recipeSnapshot.error}'));
                    }
                    if (recipeSnapshot.hasData && recipeSnapshot.data!.isNotEmpty) {
                      return _buildRecipeGrid(recipeSnapshot.data!);
                    }
                    return const Center(child: Text("Anda belum punya resep."));
                  }
                ),
                _buildFavoriteGrid(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Semua widget di bawah ini sekarang menggunakan data dinamis
  // dan struktur asli dari kode yang Anda berikan.
  
  Widget _buildProfileHeader(UserProfile user) {
    // **LOGIKA BARU UNTUK GAMBAR PROFIL**
    ImageProvider profileImage;
    final String? profilePicPath = user.profilePicture;

    // Jika path mengandung /uploads/, gunakan NetworkImage
    if (profilePicPath != null && profilePicPath.contains('/uploads/')) {
      final baseUrl = dotenv.env['BASE_URL']!;
      profileImage = NetworkImage('$baseUrl$profilePicPath');
    } 
    // Jika tidak, gunakan aset lokal sebagai default
    else {
      // Ganti 'default_avatar.png' jika nama file Anda berbeda
      profileImage = const AssetImage('images/default_avatar.png'); 
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar( // Menggunakan CircleAvatar agar lebih rapi
            radius: 37,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: profileImage, // Gunakan ImageProvider yang sudah ditentukan
            onBackgroundImageError: (e, s) { // Fallback jika NetworkImage gagal
              print('Gagal memuat gambar profil: $e');
            },
            child: (profileImage == null) ? const Icon(Icons.person, size: 37) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(user.fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                    SizedBox(
                      width: 30, height: 30,
                      child: IconButton(
                        icon: Image.asset('images/tambah.png', width: 28, height: 28),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BuatResep())),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(width: 2),
                    SizedBox(
                      width: 30, height: 30,
                      child: IconButton(
                        icon: Image.asset('images/garis_tiga.png', width: 28, height: 28),
                        onPressed: () => Navigator.pushNamed(context, "/pengaturan"),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(user.bio ?? 'Bio belum diatur.', style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(UserProfile user) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfil())),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A6859), foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Edit Profil', style: TextStyle(fontSize: 13)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, "/bagikan_profil"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A6859), foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Bagikan Profil', style: TextStyle(fontSize: 13)),
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
            border: Border.all(color: const Color(0xFF0A6859), width: 1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () => _tabController.animateTo(0),
                child: _buildStatCounter(user.recipeCount.toString(), 'Resep')),
              _buildDivider(),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/follow', arguments: 0),
                child: _buildStatCounter(user.followingCount.toString(), 'Mengikuti')),
              _buildDivider(),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/follow', arguments: 1),
                child: _buildStatCounter(user.followersCount.toString(), 'Pengikut')),
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
        Text(count, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: Color.fromARGB(255, 8, 8, 8))),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 30, width: 1, color: const Color(0xFF0A6859));
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1))),
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF0A6859),
        labelColor: const Color(0xFF0A6859),
        unselectedLabelColor: Colors.grey,
        tabs: const [Tab(text: 'Resep'), Tab(text: 'Favorit')],
      ),
    );
  }

  // **FIX**: Memanggil FoodGridWidget (dari file grid_2_builder.dart) dengan benar
  Widget _buildRecipeGrid(List<Food> recipes) {
    return FoodGridWidget(
      foods: recipes,
      onFavoritePressed: (index) { print('Favorite pressed for recipe at index: $index'); },
      onCardTap: (index) { print('Card tapped for recipe at index: $index'); },
    );
  }

  Widget _buildFavoriteGrid() {
    return SingleChildScrollView(
      child: Column(
        children: [
          ..._favoriteCategories.map((category) => GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/makanan-favorit', arguments: category['name']),
            child: _buildCategoryCard(category['name']!, category['image']!, category['description']!),
          )),
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
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(imageUrl, height: 103, width: 356, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}