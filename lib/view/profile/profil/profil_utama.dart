// lib/view/profile/profil/profil_utama.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:masak2/view/profile/profil/bagikan_profil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:masak2/view/profile/profil/tambah_resep.dart';
import 'package:masak2/view/profile/profil/edit_profil.dart';
import 'package:masak2/view/profile/profil/mengikuti_pengikut.dart';
import 'package:masak2/models/food_model.dart';
import 'package:masak2/models/user_profile_model.dart';
import 'package:masak2/view/component/grid_2_builder.dart';


class ProfilUtama extends StatefulWidget {
  final int? userId; 
  const ProfilUtama({super.key, this.userId});

  @override
  State<ProfilUtama> createState() => _ProfilUtamaState();
}

class _ProfilUtamaState extends State<ProfilUtama> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Variabel untuk menyimpan data dan status UI
  UserProfile? _userProfile;
  List<Food> _userRecipes = [];
  List<Food> _favoriteRecipes = [];
  bool _isLoading = true;
  String? _errorMessage;

  bool get _isMyProfile => widget.userId == null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _isMyProfile ? 2 : 1, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ==== KUNCI REFRESH #1 ====
  // Fungsi terpusat untuk mengambil semua data dari server dan memperbarui UI.
  Future<void> _loadAllData() async {
    if (!mounted) return;

    // ---> TAMBAHKAN LOG DI SINI <---
    print('[DEBUG ProfilUtama] ==> Memulai eksekusi _loadAllData...');

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _fetchUserProfile();
      final recipes = await _fetchUserRecipes(user.id);
      final favorites = _isMyProfile ? await _fetchFavoriteRecipes() : <Food>[];
      
      if (mounted) {
        setState(() {
          _userProfile = user;
          _userRecipes = recipes;
          _favoriteRecipes = favorites;
          _isLoading = false;
        });
        // ---> TAMBAHKAN LOG DI SINI <---
        print('[DEBUG ProfilUtama] ==> Selesai memuat data. Nama baru: "${user.fullName}". UI seharusnya diperbarui.');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Terjadi kesalahan: ${e.toString()}";
          _isLoading = false;
        });
        print('[DEBUG ProfilUtama] ==> GAGAL memuat data. Error: $e');
      }
    }
  }
  
  Future<UserProfile> _fetchUserProfile() async {
    final baseUrl = dotenv.env['BASE_URL'];
    final endpoint = _isMyProfile ? '/users/me' : '/users/${widget.userId}';
    final headers = await _getAuthHeaders();
    
    final uri = Uri.parse('$baseUrl$endpoint?cache_buster=${DateTime.now().millisecondsSinceEpoch}');
    
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      // ==========================================================
      // **DEBUGGING DATA MENTAH DARI SERVER**
      // ==========================================================
      final responseData = json.decode(response.body);
      print('==================== DEBUG DATA ====================');
      print('[DEBUG ProfilUtama] RAW JSON RESPONSE: $responseData');
      
      final user = UserProfile.fromJson(responseData['data']);
      print('[DEBUG ProfilUtama] HASIL PARSING - Nama: ${user.fullName}');
      print('[DEBUG ProfilUtama] HASIL PARSING - Path Gambar: ${user.profilePicture}');
      print('====================================================');
      // ==========================================================
      
      return user;
    } else {
      throw Exception('Gagal memuat profil (Status: ${response.statusCode}) - Body: ${response.body}');
    }
  }

  Future<List<Food>> _fetchUserRecipes(int userId) async {
    final baseUrl = dotenv.env['BASE_URL'];
    final headers = await _getAuthHeaders();
    final response = await http.get(Uri.parse('$baseUrl/users/$userId/recipes'), headers: headers);

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body)['data'];
      return body.map((dynamic item) => Food.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Gagal memuat resep pengguna.');
    }
  }

  Future<List<Food>> _fetchFavoriteRecipes() async {
    final baseUrl = dotenv.env['BASE_URL'];
    final headers = await _getAuthHeaders();
    final response = await http.get(Uri.parse('$baseUrl/users/me/favorites'), headers: headers);
      
    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body)['data'];
      return body.map((dynamic item) => Food.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Gagal memuat resep favorit.');
    }
  }

  // ==== KUNCI REFRESH #2 ====
  // Fungsi ini menangani perpindahan ke halaman edit dan MENUNGGU hasilnya.
  void _navigateToEditProfile() async {
    print('[DEBUG ProfilUtama] Tombol "Edit Profil" ditekan. Membuka halaman edit...');
    
    // Pergi ke halaman edit dan TUNGGU sampai halaman itu ditutup
    final result = await Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => const EditProfil())
    );
    
    // Ini akan dieksekusi setelah halaman edit ditutup
    print('[DEBUG ProfilUtama] Kembali dari halaman edit. Menerima sinyal: $result');

    if (result == true && mounted) {
      print('[DEBUG ProfilUtama] Sinyal adalah "true", MEMANGGIL FUNGSI _loadAllData UNTUK REFRESH...');
      _loadAllData();
    } else {
      print('[DEBUG ProfilUtama] Sinyal BUKAN "true" (atau halaman sudah tidak ada). TIDAK MELAKUKAN REFRESH.');
    }
  }
  
  void _navigateToFollowerPage(int initialIndex, int userId) async {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MengikutiPengikut(userId: userId),
          settings: RouteSettings(arguments: initialIndex),
        ),
      );

      if (result == true && mounted) {
        _loadAllData();
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(_errorMessage!),
              ),
            )
          : _userProfile == null
            ? const Center(child: Text("Tidak dapat menemukan data profil."))
            : RefreshIndicator(
                onRefresh: _loadAllData,
                child: _buildProfileBody(_userProfile!),
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
              children: _isMyProfile 
                ? [_buildUserRecipesTab(), _buildFavoritesTab()]
                : [_buildUserRecipesTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile user) {
    ImageProvider profileImage;
    final String? profilePicPath = user.profilePicture;

    if (profilePicPath != null && profilePicPath.isNotEmpty) {
      final baseUrl = dotenv.env['BASE_URL']!;
      profileImage = NetworkImage('$baseUrl$profilePicPath');
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
          child: _isMyProfile ? _buildMyProfileActions() : _buildOtherProfileActions(),
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
              _buildStatCounter(user.recipeCount.toString(), 'Resep', user.id),
              _buildDivider(),
              _buildStatCounter(user.followingCount.toString(), 'Mengikuti', user.id),
              _buildDivider(),
              _buildStatCounter(user.followersCount.toString(), 'Pengikut', user.id),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
  
  // ==== KUNCI REFRESH #3 ====
  // Tombol "Edit Profil" sekarang memanggil fungsi _navigateToEditProfile.
  Widget _buildMyProfileActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _navigateToEditProfile,
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

  Widget _buildOtherProfileActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () { /* TODO: Logika Follow/Unfollow */ },
            child: const Text('Ikuti'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () { /* TODO: Logika Kirim Pesan */ },
            child: const Text('Kirim Pesan'),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCounter(String count, String label, int userId) {
    return GestureDetector(
      onTap: () {
        if (label == 'Mengikuti') {
          _navigateToFollowerPage(0, userId);
        } else if (label == 'Pengikut') {
          _navigateToFollowerPage(1, userId);
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
        tabs: [
          const Tab(text: 'Resep'),
          if (_isMyProfile) const Tab(text: 'Favorit'),
        ],
      ),
    );
  }

  Widget _buildUserRecipesTab() {
    return _userRecipes.isEmpty
      ? const Center(child: Text("Pengguna ini belum memiliki resep."))
      : _buildRecipeGrid(_userRecipes);
  }
  
  Widget _buildFavoritesTab() {
    if (!_isMyProfile) return Container();
    
    return _favoriteRecipes.isEmpty
      ? const Center(child: Text("Anda belum memiliki resep favorit."))
      : _buildRecipeGrid(_favoriteRecipes);
  }
  
  Widget _buildRecipeGrid(List<Food> recipes) {
    return FoodGridWidget(
      foods: recipes,
      onFavoritePressed: (index) {
        // TODO: Implementasi logika favorit
      },
      onCardTap: (index) {
        // TODO: Implementasi navigasi ke detail resep
      },
    );
  }
}