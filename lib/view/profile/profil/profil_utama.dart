// lib/view/profile/profil/profil_utama.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:masak2/view/component/food_card_widget.dart';
import 'package:masak2/view/profile/profil/bagikan_profil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:masak2/view/profile/profil/tambah_resep.dart';
import 'package:masak2/view/profile/profil/edit_profil.dart';
import 'package:masak2/view/profile/profil/mengikuti_pengikut.dart';
import 'package:masak2/models/food_model.dart';
import 'package:masak2/models/user_profile_model.dart';
import 'package:masak2/view/component/grid_2_builder.dart'; // Pastikan FoodCard ada di sini atau impor FoodCard
import 'package:masak2/view/auth/login_page.dart';
import 'package:masak2/view/auth/register_page.dart';
import 'package:masak2/theme/theme.dart'; // Impor AppTheme jika digunakan di FoodCard atau GridView


class ProfilUtama extends StatefulWidget {
  final int? userId; 
  const ProfilUtama({super.key, this.userId});

  @override
  State<ProfilUtama> createState() => _ProfilUtamaState();
}

class _ProfilUtamaState extends State<ProfilUtama> with TickerProviderStateMixin {

  late TabController _tabController;
  
  UserProfile? _userProfile;
  List<Food> _userRecipes = [];
  List<Food> _favoriteRecipes = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isLoggedIn = false; // New state variable to track login status

  bool get _isMyProfile => widget.userId == null;

  @override
  void initState() {
    super.initState();
    // INI ADALAH SATU-SATUNYA TEMPAT _tabController HARUS DIINISIALISASI
    _tabController = TabController(length: _isMyProfile ? 2 : 1, vsync: this); 
    _checkAndLoadData(); // Panggil fungsi untuk memeriksa status login dan memuat data
  }

  @override
  void dispose() {
    _tabController.dispose(); // Pastikan TabController dispose
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkAndLoadData();
      }
    });
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null && token.isNotEmpty) {
      _isLoggedIn = true;
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    } else {
      _isLoggedIn = false;
      return {
        'Content-Type': 'application/json',
      };
    }
  }

  Future<void> _checkAndLoadData() async {
    if (!mounted) return;

    await _getAuthHeaders(); // Ini akan mengatur _isLoggedIn

    if (!_isLoggedIn && _isMyProfile) { // Guest mencoba melihat profil sendiri
      setState(() {
        _isLoading = false;
      });
      return; // Hentikan pemuatan data untuk tampilan guest
    } else if (!_isLoggedIn && !_isMyProfile) { // Guest mencoba melihat profil orang lain tanpa login
        setState(() {
          _isLoading = false;
          _errorMessage = "Silakan login untuk melihat profil ini.";
        });
        return;
    }

    // PENTING: PASTIKAN BARIS INI TIDAK ADA DI SINI.
    // _tabController = TabController(length: _isMyProfile ? 2 : 1, vsync: this); 
    // Baris ini hanya boleh ada di initState().

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
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Terjadi kesalahan: ${e.toString()}";
          _isLoading = false;
        });
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
      final responseData = json.decode(response.body);
      return UserProfile.fromJson(responseData['data']);
    } else if (response.statusCode == 401) { // Unauthorized, possibly expired token or no token for 'me' endpoint
      throw Exception('Sesi Anda telah berakhir atau tidak terautentikasi. Silakan login kembali.');
    } else if (response.statusCode == 404 && !_isMyProfile) {
        throw Exception('Profil pengguna tidak ditemukan.');
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
    } else if (response.statusCode == 401) {
        throw Exception('Tidak memiliki akses untuk melihat resep pengguna ini.');
    }
    else {
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
    } else if (response.statusCode == 401) {
        throw Exception('Tidak memiliki akses untuk melihat resep favorit.');
    }
    else {
      throw Exception('Gagal memuat resep favorit.');
    }
  }

  void _navigateToEditProfile() async {
    final result = await Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => const EditProfil())
    );
    if (result == true && mounted) {
      _checkAndLoadData(); // Reload all data after edit
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
        _checkAndLoadData(); // Reload all data after follow/unfollow
      }
  }

  // --- FUNGSI BARU UNTUK LOGIKA FOLLOW/UNFOLLOW ---
  Future<void> _toggleFollow() async {
    // Pastikan profil yang dilihat adalah profil orang lain
    if (_isMyProfile || _userProfile == null) return;

    // Tentukan endpoint berdasarkan status follow saat ini
    final String action = _userProfile!.isFollowedByMe ? 'unfollow' : 'follow';
    final url = '${dotenv.env['BASE_URL']}/users/${_userProfile!.id}/$action';
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        // Jika berhasil, langsung perbarui UI untuk respons instan
        setState(() {
          // Balik status follow
          _userProfile!.isFollowedByMe = !_userProfile!.isFollowedByMe;
          // Tambah atau kurangi jumlah followers
          if (_userProfile!.isFollowedByMe) {
            _userProfile!.followersCount++;
          } else {
            _userProfile!.followersCount--;
          }
        });
      } else {
        final body = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${body['message'] ?? 'Gagal melakukan aksi'}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }
  // ---------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Jika belum login dan sedang melihat profil sendiri, tampilkan tampilan guest
    if (!_isLoggedIn && _isMyProfile) { 
      return _buildGuestView(); // _buildGuestView sudah mengembalikan Scaffold
    }

    // Jika ada pesan error, tampilkan pesan error
    if (_errorMessage != null) {
      // Pastikan ada Material ancestor jika ingin menampilkan SnackBar di sini juga
      return Scaffold( // Tambahkan Scaffold untuk menampilkan error message di Material context
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(_errorMessage!),
          ),
        ),
      );
    }

    // Jika profil null setelah loading (misal: ID pengguna tidak valid), tampilkan pesan
    if (_userProfile == null) {
      return const Scaffold( // Tambahkan Scaffold
        body: Center(child: Text("Tidak dapat menemukan data profil.")),
      );
    }

    // Ini adalah tampilan profil utama (baik profil sendiri maupun profil pengguna lain)
    // PERBAIKAN: Bungkus RefreshIndicator dengan Scaffold agar memiliki Material ancestor
    return Scaffold( 
      body: RefreshIndicator(
        onRefresh: _checkAndLoadData, // Gunakan fungsi _checkAndLoadData untuk refresh data
        child: _buildProfileBody(_userProfile!), // _buildProfileBody mengembalikan Column, bukan Scaffold
      ),
    );
  }

  Widget _buildGuestView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/default_avatar.png', // Placeholder image for guest
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 20),
              const Text(
                'Masuk untuk melihat profil Anda',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                    _checkAndLoadData(); // Reload data after login attempt
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A6859),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Login'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
                    _checkAndLoadData(); // Reload data after register attempt (though usually registration leads to login)
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0A6859),
                    side: const BorderSide(color: Color(0xFF0A6859)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Daftar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileBody(UserProfile user) {
    return SafeArea( // SafeArea itu sendiri tidak menyediakan Material
      child: Column(
        children: [
          _buildProfileHeader(user),
          _buildStatsAndActions(user),
          _buildTabBar(), // TabBar menggunakan _tabController yang diinisialisasi sekali
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
      final fullUrl = '$baseUrl$profilePicPath?v=${DateTime.now().millisecondsSinceEpoch}';
      profileImage = NetworkImage(fullUrl);
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
                          onPressed: () => Navigator.pushNamed(context, "/pengaturan-utama"),
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
    bool isFollowing = _userProfile?.isFollowedByMe ?? false;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _toggleFollow,
            style: ElevatedButton.styleFrom(
              backgroundColor: isFollowing ? Colors.grey[300] : const Color(0xFF0A6859),
              foregroundColor: isFollowing ? Colors.black : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            child: Text(isFollowing ? 'Diikuti' : 'Ikuti', style: const TextStyle(fontSize: 13)),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCounter(String count, String label, int userId) {
    return GestureDetector(
      onTap: () {
        if (_isLoggedIn) { // Only allow navigation if logged in
            if (label == 'Mengikuti' || label == 'Pengikut') {
              _navigateToFollowerPage(label == 'Mengikuti' ? 0 : 1, userId);
            }
        } else {
          // Tidak menampilkan SnackBar di sini untuk menghindari "No Material widget found"
          // karena SnackBar membutuhkan Scaffold di ancestor.
          // Jika Anda ingin menampilkan pesan, pastikan Scaffold ada di atas konteks ini.
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
    // Asumsi FoodGridWidget atau GridView.builder ada di file yang diimpor
    // Saya akan menggunakan GridView.builder sebagai contoh yang paling umum
    return GridView.builder(
      padding: const EdgeInsets.all(16.0), // Tambahkan padding
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 0.75, // Sesuaikan aspek rasio jika kartu resep Anda tidak persegi
      ),
      itemCount: recipes.length,
      shrinkWrap: true, // Penting agar GridView tidak mengambil semua ruang jika di dalam SingleChildScrollView
      physics: const NeverScrollableScrollPhysics(), // Non-scrollable karena sudah ada SingleChildScrollView di atasnya
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        // Pastikan FoodCard sudah diimpor dan tersedia.
        // Jika FoodCard tidak ada, Anda bisa mengganti ini dengan Container sederhana untuk tes.
        return FoodCard( // Menggunakan FoodCard, pastikan sudah diimpor jika ini custom widget
          food: recipe,
          onCardTap: () {
            // Implementasi navigasi ke detail resep
            // Misalnya: Navigator.pushNamed(context, '/detail-resep', arguments: recipe.id);
          },
          onFavoritePressed: () {
            // Implementasi logika favorit
            print('Favorite pressed for ${recipe.name}');
          },
        );
      },
    );
  }
}