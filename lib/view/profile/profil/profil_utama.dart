import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:masak2/view/profile/profil/bagikan_profil.dart';
import 'dart:convert';

import '../../component/grid_2_builder.dart';
import '../../../models/food_model.dart';
import '../../../models/user_profile_model.dart';
import 'tambah_resep.dart';
import 'edit_profil.dart';
import 'mengikuti_pengikut.dart'; // <-- Pastikan import ini ada

class ProfilUtama extends StatefulWidget {
  const ProfilUtama({super.key});
  @override
  State createState() => _ProfilUtamaState();
}

class _ProfilUtamaState extends State<ProfilUtama> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  late Future<UserProfile> futureUserProfile;
  late Future<List<Food>> futureUserRecipes;
  late Future<List<Food>> futureFavoriteRecipes;

  // Variabel ini kita biarkan untuk logika menampilkan/menyembunyikan UI
  // berdasarkan profil sendiri atau orang lain, jika nanti dikembangkan.
  // Untuk sekarang, karena kita fokus ke profil sendiri, nilainya akan selalu true.
  bool _isMyProfile = true; 

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAllData();
  }

  // Fungsi ini akan kita panggil untuk me-refresh data
  void _loadAllData() {
    if (!mounted) return;
    setState(() {
      futureUserProfile = fetchUserProfile();
      futureFavoriteRecipes = fetchFavoriteRecipes();
      
      futureUserProfile.then((user) {
        if (mounted) {
          setState(() {
            futureUserRecipes = fetchUserRecipes(user.id);
          });
        }
      }).catchError((error) {
        if (mounted) {
          setState(() {
            futureUserRecipes = Future.error('Gagal memuat resep pengguna ini.');
          });
        }
      });
    });
  }
  
  Future<UserProfile> fetchUserProfile() async {
    final baseUrl = dotenv.env['BASE_URL'];
    if (baseUrl == null) throw Exception("BASE_URL tidak ada di .env");
    
    // Selalu fetch 'me' karena ini adalah halaman profil utama kita
    final endpoint = '/users/me'; 
    final response = await http.get(Uri.parse('$baseUrl$endpoint'));

    if (response.statusCode == 200) {
      return UserProfile.fromJson(json.decode(response.body));
    } else {
      throw Exception('Gagal memuat profil (Status: ${response.statusCode})');
    }
  }

  Future<List<Food>> fetchUserRecipes(int userId) async {
    final baseUrl = dotenv.env['BASE_URL'];
    if (baseUrl == null) throw Exception("BASE_URL tidak ada di .env");
    final response = await http.get(Uri.parse('$baseUrl/users/$userId/recipes'));
    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Food.fromMap(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Gagal memuat resep buatan pengguna');
    }
  }

  Future<List<Food>> fetchFavoriteRecipes() async {
    final baseUrl = dotenv.env['BASE_URL'];
    if (baseUrl == null) throw Exception("BASE_URL tidak ada di .env");
    final response = await http.get(Uri.parse('$baseUrl/users/me/favorites'));
    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Food.fromMap(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Gagal memuat resep favorit');
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
            return Center(
                child: Text("Error: Gagal memuat profil.\n${userSnapshot.error}"));
          }
          if (userSnapshot.hasData) {
            return _buildProfileBody(userSnapshot.data!);
          }
          return const Center(child: Text("Tidak dapat menemukan data profil."));
        },
      ),
    );
  }
  
  Widget _buildProfileBody(UserProfile user) {
    return SafeArea(
      child: Column(
        children: [
          _buildProfileHeader(user),
          _buildStatsAndActions(user),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUserRecipesTab(),
                _buildFavoritesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserRecipesTab() {
    return FutureBuilder<List<Food>>(
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
      },
    );
  }
  
  Widget _buildFavoritesTab() {
    return FutureBuilder<List<Food>>(
      future: futureFavoriteRecipes,
      builder: (context, favoriteSnapshot) {
        if (favoriteSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (favoriteSnapshot.hasError) {
          return Center(child: Text('${favoriteSnapshot.error}'));
        }
        if (favoriteSnapshot.hasData && favoriteSnapshot.data!.isNotEmpty) {
          return _buildRecipeGrid(favoriteSnapshot.data!);
        }
        return const Center(child: Text("Anda belum memiliki resep favorit."));
      },
    );
  }
  
  Widget _buildRecipeGrid(List<Food> recipes) {
    return FoodGridWidget(
      foods: recipes,
      onFavoritePressed: (index) {
        print('Favorite pressed for recipe at index: $index');
      },
      onCardTap: (index) {
        print('Card tapped for recipe at index: $index');
      },
    );
  }
  
  Widget _buildProfileHeader(UserProfile user) {
    ImageProvider profileImage;
    final String? profilePicPath = user.profilePicture;

    if (profilePicPath != null && profilePicPath.isNotEmpty) {
      final baseUrl = dotenv.env['BASE_URL']!;
      final imagePath = profilePicPath.startsWith('/') ? profilePicPath : '/$profilePicPath';
      profileImage = NetworkImage('$baseUrl$imagePath');
    } else {
      profileImage = const AssetImage('images/default_avatar.png'); 
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 37,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: profileImage,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(user.fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                    if (_isMyProfile) ...[
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
                    ]
                  ],
                ),
                const SizedBox(height: 2), 
                Text(
                  '@${user.username}',
                  style: const TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Text(user.bio ?? 'Bio belum diatur.', style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsAndActions(UserProfile user) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildMyProfileActions(user),
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
              _buildStatCounter(user.recipeCount.toString(), 'Resep'),
              _buildDivider(),
              _buildStatCounter(user.followingCount.toString(), 'Mengikuti'),
              _buildDivider(),
              _buildStatCounter(user.followersCount.toString(), 'Pengikut'),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildMyProfileActions(UserProfile user) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              // Menunggu hasil dari halaman EditProfil
              final result = await Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const EditProfil())
              );
              // Jika halaman edit mengembalikan 'true', muat ulang data
              if (result == true && mounted) {
                _loadAllData();
              }
            },
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BagikanProfil()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A6859), foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            child: const Text('Bagikan Profil', style: TextStyle(fontSize: 13)),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCounter(String count, String label) {
    return GestureDetector(
      onTap: () async {
        // Hanya bisa diklik jika ini profil kita sendiri
        if (_isMyProfile) {
          if (label == 'Mengikuti' || label == 'Pengikut') {
            final int initialIndex = (label == 'Mengikuti') ? 0 : 1;
            
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MengikutiPengikut(),
                settings: RouteSettings(arguments: initialIndex),
              ),
            );

            // Jika halaman sebelumnya mengirim sinyal 'true', muat ulang data
            if (result == true && mounted) {
              _loadAllData();
            }
          }
        }
      },
      child: Column(
        children: [
          Text(count, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: Color.fromARGB(255, 8, 8, 8))),
        ],
      ),
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
        tabs: const [
          Tab(text: 'Resep'),
          Tab(text: 'Favorit'),
        ],
      ),
    );
  }
}