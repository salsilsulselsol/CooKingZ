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
import 'package:masak2/view/auth/login_page.dart';
import 'package:masak2/view/auth/register_page.dart';
import 'package:masak2/theme/theme.dart'; // <<< Pastikan ini diimport untuk AppTheme

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
  int? _currentLoggedInUserId; // Untuk menyimpan ID pengguna yang login dari SharedPreferences

  // Mengubah getter ini agar lebih akurat setelah kita punya _currentLoggedInUserId
  bool get _isMyProfile {
    // Jika widget.userId adalah null, artinya pengguna mencoba melihat profil mereka sendiri
    // Dan kita perlu membandingkan dengan _currentLoggedInUserId yang sebenarnya login
    return widget.userId == null || widget.userId == _currentLoggedInUserId;
  }

  @override
  void initState() {
    super.initState();
    // Initialize tab controller with a default length; it will be updated after login status check
    _tabController = TabController(length: 2, vsync: this); 
    _checkAndLoadData(); // Call new combined function to check login and load data
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    _currentLoggedInUserId = prefs.getInt('user_id'); // Ambil ID pengguna saat ini

    if (token != null && token.isNotEmpty && _currentLoggedInUserId != null && _currentLoggedInUserId != 0) {
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

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // First, check login status and get auth headers
    final headers = await _getAuthHeaders(); // This will set _isLoggedIn and _currentLoggedInUserId

    // Logika untuk menampilkan guest view (ketika mencoba melihat profil sendiri tapi belum login)
    if (!_isLoggedIn && _isMyProfile) {
      setState(() {
        _isLoading = false;
      });
      return; // Stop loading data, will show guest view
    } 
    // Logika untuk mencoba melihat profil orang lain tanpa login (jika tidak diizinkan backend)
    else if (!_isLoggedIn && !_isMyProfile) {
      // Jika backend Anda mengizinkan profil publik, Anda bisa melanjutkan fetching di sini.
      // Jika tidak, tampilkan pesan error atau arahkan ke login.
      // Untuk saat ini, kita anggap tidak diizinkan dan tampilkan pesan error.
      setState(() {
        _isLoading = false;
        _errorMessage = "Silakan login untuk melihat profil ini."; // Pesan umum
      });
      return;
    }

    // Adjust tab controller length based on whether it's my profile or another user's
    // This needs to be done here after _isLoggedIn is determined
    _tabController = TabController(length: _isMyProfile ? 2 : 1, vsync: this);

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
    final headers = await _getAuthHeaders(); // Memastikan headers diambil dengan token jika ada
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
    final headers = await _getAuthHeaders(); // Memastikan headers diambil dengan token jika ada
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

  Future<void> _toggleFollow() async {
    // Pastikan profil yang dilihat adalah profil orang lain dan tidak null
    if (_isMyProfile || _userProfile == null) return;

    // Tentukan endpoint berdasarkan status follow saat ini
    final String action = _userProfile!.isFollowedByMe ? 'unfollow' : 'follow';
    final url = '${dotenv.env['BASE_URL']}/users/${_userProfile!.id}/$action';
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: await _getAuthHeaders(), // Pastikan headers diambil dengan token yang valid
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_userProfile!.isFollowedByMe ? 'Berhasil mengikuti!' : 'Berhasil berhenti mengikuti.')),
        );
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Menggunakan _isMyProfile yang sudah diperbarui dan _isLoggedIn
    if (!_isLoggedIn && _isMyProfile) { 
      return _buildGuestView();
    }

    // Jika mencoba melihat profil orang lain tanpa login (dan tidak diizinkan backend)
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(_errorMessage!),
        ),
      );
    }

    if (_userProfile == null) {
      return const Center(child: Text("Tidak dapat menemukan data profil."));
    }

    return RefreshIndicator(
        onRefresh: _checkAndLoadData, // Use the new function to refresh data
        child: _buildProfileBody(_userProfile!),
    );
  }

  // Mengubah _buildGuestView agar sesuai dengan tampilan login/daftar
  Widget _buildGuestView() {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        
        elevation: 0, // Hilangkan bayangan jika mau tampilan flat
        title: Text(
          'Profil',
          style: TextStyle(
            color: AppTheme.primaryColor, // Warna teks hijau
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            color: AppTheme.primaryColor, // Warna ikon titik tiga hijau
            onPressed: () {
              Navigator.pushNamed(context, '/pengaturan-utama');
            },
          ),
        ],
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/logo.png', // Menggunakan logo utama aplikasi
              width: 150, // Sesuaikan ukuran
              height: 150,
            ),
            const SizedBox(height: 32),
            const Text(
              'Masuk atau Daftar untuk melihat profil',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row( // Menggunakan Row untuk tombol berdampingan
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                    _checkAndLoadData(); // Coba muat ulang data setelah login
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor, // Menggunakan AppTheme
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Login'),
                ),
                const SizedBox(width: 16), // Spasi antar tombol
                TextButton(
                  onPressed: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
                    _checkAndLoadData(); // Coba muat ulang data setelah daftar
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Daftar'),
                ),
              ],
            ),
          ],
        ),
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
                : [_buildUserRecipesTab()], // Hanya tab resep jika bukan profil sendiri
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile user) {
    ImageProvider profileImage;
    final String? profilePicPath = user.profilePicture;
    final baseUrl = dotenv.env['BASE_URL']; // Pastikan dotenv sudah diinisialisasi

    if (profilePicPath != null && profilePicPath.isNotEmpty && baseUrl != null) {
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
        // Cek _isLoggedIn dan pastikan userId yang valid untuk navigasi
        if (_isLoggedIn && (label == 'Mengikuti' || label == 'Pengikut')) {
          _navigateToFollowerPage(label == 'Mengikuti' ? 0 : 1, userId);
        } else {
          // Tampilkan pesan atau arahkan ke login jika tidak diizinkan
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Silakan login untuk melihat detail ini.')),
          );
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
          if (_isMyProfile) const Tab(text: 'Favorit'), // Hanya tampilkan tab Favorit jika ini profil sendiri
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
    // Pastikan ini tidak akan dipanggil jika _isMyProfile false
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
        // Anda mungkin perlu memanggil _checkAndLoadData() lagi setelah ini
      },
      onCardTap: (index) {
        // TODO: Implementasi navigasi ke detail resep
        // Contoh: Navigator.pushNamed(context, '/detail-resep', arguments: recipes[index].id);
      },
    );
  }
}