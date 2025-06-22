// File: lib/view/home/home_page.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:masak2/view/profile/profil/profil_utama.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Import komponen kustom Anda
import 'package:masak2/view/home/popup_search.dart';
import 'package:masak2/view/component/trending_recipe_card.dart';
import 'package:masak2/view/component/bottom_navbar.dart';
import 'package:masak2/view/component/category_tab.dart';
import 'package:masak2/theme/theme.dart';

// Import models Anda
import 'package:masak2/models/food_model.dart';
import 'package:masak2/models/user_profile_model.dart';
import 'package:masak2/models/category_model.dart';

// Impor FoodCard sebagai komponen eksternal
import 'package:masak2/view/component/food_card_widget.dart';

// Import halaman SubCategoryPage
import 'package:masak2/view/kategori/sub_category_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  String _loggedInUsername = 'people';
  int? _currentUserId; // Akan menyimpan ID pengguna dari SharedPreferences
  List<Food> _trendingRecipes = [];
  List<UserProfile> _bestUsers = [];
  List<Food> _latestRecipes = [];
  List<Food> _userRecipes = [];
  List<Category> _categories = [];

  int _selectedCategoryIndex = -1;

  // Pastikan ini adalah IP backend Anda yang benar dan dapat diakses dari emulator/perangkat.
  // Contoh: 'http://10.0.2.2:3000' untuk Android emulator, atau IP lokal Anda.
  final String _baseUrl = 'http://localhost:3000'; 

  @override
  void initState() {
    super.initState();
    _fetchHomeData();
  }

  Future<void> _fetchHomeData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final usernameFromPrefs = prefs.getString('username');
      
      // Mengambil ID pengguna dari SharedPreferences.
      // Pastikan kunci 'user_id' ini benar saat Anda menyimpan ID setelah login.
      _currentUserId = prefs.getInt('user_id'); 
      
      // Atur username: jika ada, gunakan username; jika tidak, gunakan 'people'
      if (usernameFromPrefs != null && usernameFromPrefs.isNotEmpty) {
        _loggedInUsername = usernameFromPrefs;
      } else {
        _loggedInUsername = 'people';
      }
      print('DEBUG: Mulai fetch home data. Username dari prefs: $_loggedInUsername, User ID: $_currentUserId');

      // Modifikasi URL API: tambahkan ID pengguna dari SharedPreferences.
      // Jika _currentUserId null (misal: belum login), kirim '0' sebagai placeholder.
      final String apiUrl;
      if (_currentUserId != null) {
        apiUrl = '$_baseUrl/home/$_currentUserId'; 
      } else {
        apiUrl = '$_baseUrl/home/0'; // Mengirim ID 0 untuk pengguna yang tidak login
      }
      
      print('DEBUG: Memanggil API: $apiUrl');

      final response = await http.get(
        Uri.parse(apiUrl), // Gunakan URL yang sudah dimodifikasi
        headers: {
          'Content-Type': 'application/json',
          // Header Authorization hanya dikirim jika ada token
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print('DEBUG: Status Code API: ${response.statusCode}');
      // Hanya tampilkan sebagian body response jika terlalu panjang agar tidak memenuhi konsol
      print('DEBUG: Response Body API: ${response.body.length > 500 ? response.body.substring(0, 500) + '...' : response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final Map<String, dynamic> data = responseData['data'];

        print('DEBUG: JSON data parsed successfully.');

        setState(() {
          _trendingRecipes = (data['trendingRecipes'] as List)
              .map((jsonItem) => Food.fromJson(jsonItem))
              .toList();
          print('DEBUG: Trending recipes parsed. Count: ${_trendingRecipes.length}');

          _bestUsers = (data['bestUsers'] as List)
              .map((jsonItem) => UserProfile.fromJson(jsonItem))
              .toList();
          print('DEBUG: Best users parsed. Count: ${_bestUsers.length}');

          _latestRecipes = (data['latestRecipes'] as List)
              .map((jsonItem) => Food.fromJson(jsonItem))
              .toList();
          print('DEBUG: Latest recipes parsed. Count: ${_latestRecipes.length}');

          // Logika untuk userRecipes: pastikan tidak null dan tidak kosong
          if (data['userRecipes'] != null && (data['userRecipes'] as List).isNotEmpty) {
            _userRecipes = (data['userRecipes'] as List)
                .map((jsonItem) => Food.fromJson(jsonItem))
                .toList();
          } else {
            _userRecipes = [];
          }
          print('DEBUG: User recipes parsed. Count: ${_userRecipes.length}');

          _categories = (data['categories'] as List)
              .map((jsonItem) => Category.fromJson(jsonItem))
              .toList();
          print('DEBUG: Categories parsed. Count: ${_categories.length}');

          _isLoading = false;
          print('DEBUG: SetState complete. Loading finished.');
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = 'Gagal memuat data beranda: ${response.statusCode} ${response.reasonPhrase}';
          _isLoading = false;
        });
        print('[ERROR] Failed to load home data: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
      print('[EXCEPTION] Error fetching home data in catch block: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavbar(
      Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _hasError
                ? Center(
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  )
                : SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopSection(context),
                        Expanded( // Expanded tetap di sini untuk SingleChildScrollView
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // CategoryTabBar sekarang di dalam SingleChildScrollView
                                CategoryTabBar(
                                  categories: _categories.map((cat) => cat.name).toList(),
                                  selectedIndex: _selectedCategoryIndex,
                                  primaryColor: AppTheme.primaryColor,
                                  onCategorySelected: (index) {
                                    setState(() {
                                      _selectedCategoryIndex = index;
                                    });
                                    final selectedCategory = _categories[index];

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Anda menekan kategori: **${selectedCategory.name}**. Mengarahkan ke halaman kategori...'),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SubCategoryPage(
                                          categoryName: selectedCategory.name,
                                          categoryId: selectedCategory.id!, 
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                // Semua section resep di bawah ini juga di dalam SingleChildScrollView
                                _buildTrendingRecipeSection(context),
                                if (_userRecipes.isNotEmpty) 
                                  _buildYourRecipesSection(context),
                                _buildTopUsersSection(context),
                                _buildRecentlyAddedRecipeSection(context),
                                const SizedBox(height: 70), // Memberi ruang di bagian bawah agar tidak tertutup BottomNavbar
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildTopSection(BuildContext context) {
    final bool isLoggedIn = _loggedInUsername != 'people';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacingXLarge,
        AppTheme.spacingXLarge,
        AppTheme.spacingXXLarge,
        AppTheme.spacingLarge,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                'images/logo.png',
                width: 32,
                height: 32,
              ),
              const SizedBox(width: AppTheme.spacingSmall),
              isLoggedIn
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi! $_loggedInUsername',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Masak apa hari ini?',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/login'),
                          style: TextButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(60, 32),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                          child: const Text('Login'),
                        ),
                        const SizedBox(width: AppTheme.spacingSmall),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/register'),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black87,
                            minimumSize: const Size(60, 32),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                          child: const Text('Daftar'),
                        ),
                      ],
                  ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/notif'),
                child: Container(
                  width: AppTheme.favoriteButtonSize,
                  height: AppTheme.favoriteButtonSize,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('images/notif.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingMedium),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/penjadwalan'),
                child: Container(
                  width: AppTheme.favoriteButtonSize,
                  height: AppTheme.favoriteButtonSize,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('images/calendar.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingMedium),
              GestureDetector(
                onTap: () => showRecipeRecommendationsTopSheet(context),
                child: Container(
                  width: AppTheme.favoriteButtonSize,
                  height: AppTheme.favoriteButtonSize,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('images/search.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingRecipeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: AppTheme.spacingXLarge, right: AppTheme.spacingXXLarge, top: AppTheme.spacingMedium, bottom: AppTheme.spacingMedium),
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/trending-resep');
            },
            child: Text(
              'Resep Trending >',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXLarge),
            itemCount: _trendingRecipes.length,
            physics: const ClampingScrollPhysics(), // Memungkinkan scroll horizontal
            itemBuilder: (context, index) {
              final recipe = _trendingRecipes[index];
              return Row( // Menggunakan Row untuk menempatkan kartu dan separator
                children: [
                  SizedBox( 
                    width: 250, 
                    child: TrendingRecipeCard(
                      imagePath: recipe.image,
                      title: recipe.name,
                      description: recipe.description ?? 'Tidak ada deskripsi',
                      favorites: recipe.likes?.toString() ?? '0',
                      duration: recipe.cookingTime != null ? '${recipe.cookingTime} menit' : 'N/A',
                      price: recipe.price ?? 'Gratis',
                      detailRoute: '/detail-resep/${recipe.id}',
                    ),
                  ),
                  // Menambahkan SizedBox sebagai pemisah antar kotak
                  if (index < _trendingRecipes.length - 1) // Jangan tambahkan setelah kotak terakhir
                    const SizedBox(width: AppTheme.spacingMedium), // Sesuaikan lebar pemisah
                ],
              );
            },
          ),
        ),
        const SizedBox(height: AppTheme.spacingLarge),
      ],
    );
  }

  Widget _buildYourRecipesSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 3, 159, 135),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
       
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: AppTheme.spacingXLarge, right: AppTheme.spacingXXLarge, top: AppTheme.spacingXLarge, bottom: AppTheme.spacingXLarge),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/resep-anda');
              },
              child: Text(
                'Resep Anda >',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Sudah putih
                ),
              ),
            ),
          ),
          SizedBox(
            height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: AppTheme.spacingXLarge, right: AppTheme.spacingXLarge),
              itemCount: _userRecipes.length,
              physics: const ClampingScrollPhysics(), 
              itemBuilder: (context, index) {
                final recipe = _userRecipes[index];
                return Row( // Menggunakan Row untuk menempatkan kartu dan separator
                  children: [
                    SizedBox( 
                      width: 180, 
                      child: FoodCard(
                        food: recipe,
                        onCardTap: () {
                          Navigator.pushNamed(context, '/detail-resep', arguments: recipe.id);
                        },
                        onFavoritePressed: () {
                          print('Favorite pressed for ${recipe.name}');
                        },
                      ),
                    ),
                    if (index < _userRecipes.length - 1)
                      const SizedBox(width: AppTheme.spacingMedium), // Sesuaikan lebar pemisah
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: AppTheme.spacingXXLarge),
        ],
      ),
    );
  }

  Widget _buildTopUsersSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: AppTheme.spacingXLarge, right: AppTheme.spacingXXLarge, top: AppTheme.spacingXLarge, bottom: AppTheme.spacingXLarge),
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/pengguna-terbaik');
            },
            child: Text(
              'Pengguna Terbaik >',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: AppTheme.spacingXLarge, right: AppTheme.spacingXLarge),
            itemCount: _bestUsers.length,
            physics: const ClampingScrollPhysics(), 
            itemBuilder: (context, index) {
              final user = _bestUsers[index];

              return Row( // Menggunakan Row untuk menempatkan item dan separator
                children: [
                  SizedBox( 
                    width: 80, 
                    child: GestureDetector(
                      onTap: () {
                        if (user.id == _currentUserId) {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => const ProfilUtama(),
                          ));
                        } else {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => ProfilUtama(userId: user.id),
                          ));
                        }
                      },
                      child: Column( // Menghapus Padding di sini dan biarkan SizedBox(width: 80) mengatur lebar
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: user.profilePicture != null && user.profilePicture!.isNotEmpty
                                  ? NetworkImage('$_baseUrl${user.profilePicture}')
                                  : const AssetImage('images/user_placeholder.png') as ImageProvider,
                          ),
                          const SizedBox(height: AppTheme.spacingSmall),
                          Text(
                            user.username,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (index < _bestUsers.length - 1)
                    const SizedBox(width: AppTheme.spacingMedium), // Sesuaikan lebar pemisah
                ],
              );
            },
          ),
        ),
        const SizedBox(height: AppTheme.spacingLarge),
      ],
    );
  }

  Widget _buildRecentlyAddedRecipeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: AppTheme.spacingXLarge, right: AppTheme.spacingXXLarge, top: AppTheme.spacingXLarge, bottom: AppTheme.spacingXLarge),
          child: Text(
            'Baru Saja Ditambahkan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXLarge),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(), 
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppTheme.spacingMedium,
              mainAxisSpacing: AppTheme.spacingMedium,
              childAspectRatio: 0.75,
            ),
            itemCount: _latestRecipes.length,
            itemBuilder: (context, index) {
              final recipe = _latestRecipes[index];
              return FoodCard(
                food: recipe,
                onCardTap: () {
                  Navigator.pushNamed(context, '/detail-resep', arguments: recipe.id);
                },
                onFavoritePressed: () {
                  print('Favorite pressed for ${recipe.name}');
                },
              );
            },
          ),
        ),
        const SizedBox(height: AppTheme.spacingXXLarge),
      ],
    );
  }
}