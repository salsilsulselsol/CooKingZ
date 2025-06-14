import 'package:flutter/material.dart';
import 'package:masak2/view/component/bottom_navbar.dart';
import 'package:masak2/view/component/header_b_l_s.dart'; // Import header yang Anda gunakan
import '../../theme/theme.dart';
import 'dart:convert'; // Untuk encode/decode JSON
import 'package:http/http.dart' as http; // Untuk permintaan HTTP
import 'package:flutter/foundation.dart' show kIsWeb; // Untuk cek apakah di web

class RecipeDetailPage extends StatefulWidget {
  final int recipeId; // Tambahkan parameter recipeId

  const RecipeDetailPage({super.key, required this.recipeId});

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  bool _isLoading = true; // State untuk indikator loading
  String _errorMessage = ''; // State untuk pesan error
  Map<String, dynamic>? _fetchedRecipeData; // Data resep yang diambil dari backend

  bool isFollowing = false; // Contoh state untuk tombol Ikuti
  DateTime selectedDate = DateTime.now(); // Contoh state untuk penjadwalan

  @override
  void initState() {
    super.initState();
    _fetchRecipeDetails(widget.recipeId); // Panggil fungsi untuk mengambil detail resep
  }

  // Fungsi untuk mengambil detail resep dari backend
  Future<void> _fetchRecipeDetails(int id) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _fetchedRecipeData = null;
    });

    // Sesuaikan URL backend Anda
    final String apiUrl = kIsWeb ? 'http://localhost:3000/recipes/$id' : 'http://10.0.2.2:3000/recipes/$id';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> recipeData = json.decode(response.body);
        setState(() {
          _fetchedRecipeData = recipeData;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Gagal mengambil data resep: ${response.statusCode} - ${json.decode(response.body)['message'] ?? 'Unknown error'}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan jaringan: $e';
        _isLoading = false;
      });
      print('Error fetching recipe: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan indikator loading jika data masih diambil
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
      );
    }

    // Tampilkan pesan error jika terjadi kesalahan
    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ),
      );
    }

    // Jika data sudah berhasil diambil, tampilkan UI resep
    final recipe = _fetchedRecipeData!; // Gunakan data yang sudah diambil

    // Konversi cooking_time (menit integer) kembali ke format "X Jam, Y Menit"
    final int cookingTimeMinutes = recipe['cooking_time'] ?? 0;
    final int hours = cookingTimeMinutes ~/ 60;
    final int minutes = cookingTimeMinutes % 60;
    final String estimatedTimeDisplay = '${hours > 0 ? '$hours Jam' : ''}${hours > 0 && minutes > 0 ? ', ' : ''}${minutes > 0 ? '$minutes Menit' : ''}'.trim();

    // Perbaiki tampilan estimatedTime jika hanya 0 menit
    final String finalEstimatedTimeDisplay = estimatedTimeDisplay.isEmpty && cookingTimeMinutes == 0
        ? '0 Menit'
        : estimatedTimeDisplay;


    return BottomNavbar(
      Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Header resep detail
              RecipeDetailHeader(
                title: recipe['title'] ?? 'Resep Tidak Ditemukan', // Gunakan title dari backend
                onBackPressed: () => Navigator.pop(context),
                likes: recipe['favorites_count'] ?? 0, // Asumsi favorites_count dari DB
                comments: 0, // Komentar akan diambil terpisah jika ada tabel reviews_count
                onLikePressed: () {
                  // Handle like button press
                },
                onSharePressed: () {
                  // Handle share button press
                },
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gambar resep (menggunakan image_url dari backend)
                      _buildRecipeImage(recipe['image_url']),
                      // Bagian penulis (data dummy, bisa jadi perlu ambil dari tabel users)
                      _buildAuthorSection(recipe['user_id']),
                      _buildDivider(),
                      // Deskripsi resep
                      _buildDescriptionSection(
                        recipe['description'],
                        recipe['price']?.toString() ?? 'Rp 0', // Ambil harga dari backend
                        finalEstimatedTimeDisplay,
                        recipe['difficulty'] ?? 'N/A', // Ambil kesulitan
                      ),
                      _buildScheduleButton(),
                      // Bagian alat-alat
                      _buildToolsSection(recipe['tools']),
                      // Bagian bahan-bahan
                      _buildIngredientsSection(recipe['ingredients']),
                      // Bagian langkah-langkah
                      _buildStepsSection(recipe['instructions']),
                      _buildDivider(),
                      // Bagian ulasan dan input komentar (data dummy)
                      _buildRatingSection(),
                      _buildCommentInput(),
                      _buildDivider(),
                      _buildViewAllCommentsButton(),
                      const SizedBox(height: 60),
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

  // --- Widget Builder yang sudah dimodifikasi untuk data dinamis ---

  Widget _buildScheduleButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: InkWell(
        onTap: () {
          _showCalendarDialog(context);
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'Jadwalkan Menu',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCalendarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Jadwalkan Menu',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('April 2025'), // Ini masih statis, bisa diubah dinamis
                const SizedBox(height: 16),
                _buildCalendar(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal', style: TextStyle(color: AppTheme.primaryColor)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showSuccessDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: const Text(
                'Tambahkan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCalendar() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: 35,
      itemBuilder: (context, index) {
        if (index < 7) {
          final days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
          return Center(
            child: Text(
              days[index],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          );
        }

        int day = index - 7 + 1;

        if (day <= 0) {
          day = 30 + day; // Mengisi hari dari bulan sebelumnya jika perlu
          return Center(
            child: Text(
              day.toString(),
              style: TextStyle(color: Colors.grey[400]),
            ),
          );
        }

        if (day > 30) {
          day = day - 30; // Mengisi hari dari bulan berikutnya jika perlu
          return Center(
            child: Text(
              day.toString(),
              style: TextStyle(color: Colors.grey[400]),
            ),
          );
        }

        bool isSelected = day == selectedDate.day; // Mengecek apakah hari ini yang dipilih

        return InkWell(
          onTap: () {
            setState(() {
              selectedDate = DateTime(2025, 4, day); // Tangani perubahan tanggal
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.accentTeal : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context).pop();
        });

        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[300]!),
                ),
                padding: const EdgeInsets.all(16),
                child: Icon(
                  Icons.check,
                  size: 50,
                  color: Colors.green[600],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Penjadwalan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Menu Berhasil',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Menggunakan URL gambar dari backend
  Widget _buildRecipeImage(String? imageUrl) {
    // Jika tidak ada gambar, tampilkan placeholder atau default
    ImageProvider imageProvider;
    if (imageUrl != null && imageUrl.isNotEmpty && imageUrl != 'default_recipe_image.png') {
      // Sesuaikan URL backend untuk gambar statis/uploads
      final fullImageUrl = kIsWeb ? 'http://localhost:3000$imageUrl' : 'http://10.0.2.2:3000$imageUrl';
      imageProvider = NetworkImage(fullImageUrl);
    } else {
      imageProvider = const AssetImage('images/default_recipe.png'); // Placeholder
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Image(
              image: imageProvider,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'images/default_recipe.png', // Fallback jika gambar gagal dimuat
                  height: 200,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _fetchedRecipeData!['title'] ?? 'Nama Resep', // Gunakan title dari backend
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      (_fetchedRecipeData!['favorites_count'] ?? 0).toString(), // Gunakan favorites_count dari backend
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      // Jika ada hitungan komentar di DB
                      (_fetchedRecipeData!['comments_count'] ?? 0).toString(), // Asumsi ada comments_count
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Menggunakan data penulis dari backend (asumsi user_id ada)
  Widget _buildAuthorSection(int userId) {
    // Anda mungkin perlu membuat API endpoint terpisah untuk detail pengguna
    // untuk mendapatkan 'author' dan 'authorName' dari user_id ini.
    // Untuk demo ini, saya akan menggunakan placeholder.
    String authorUsername = '@user${userId}';
    String authorFullName = 'Pengguna ${userId}';

    // Jika Anda punya data users di _fetchedRecipeData (misal, di-JOIN di backend)
    // authorUsername = recipe['username'] ?? '';
    // authorFullName = recipe['full_name'] ?? '';


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage('images/default_profile.png'), // Placeholder
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authorUsername,
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    authorFullName,
                    style: TextStyle(
                      color: AppTheme.textBrown,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: isFollowing ? 120 : 100,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isFollowing = !isFollowing;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFollowing ? AppTheme.searchBarColor : AppTheme.primaryColor,
                    foregroundColor: isFollowing ? AppTheme.primaryColor : Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    isFollowing ? 'Mengikuti' : 'Ikuti',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.more_vert, color: AppTheme.primaryColor),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Divider(
        thickness: 2,
        color: AppTheme.primaryColor,
      ),
    );
  }

  // Menggunakan data deskripsi, harga, waktu, kesulitan dari backend
  Widget _buildDescriptionSection(String description, String price, String estimatedTime, String difficulty) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Deskripsi',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.white, // Warna bintang bisa disesuaikan
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          price, // Menggunakan harga dari backend
                          style: const TextStyle(
                            color: Color(0xFF005A4D),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          'images/alarm_hitam.png',
                          color: AppTheme.primaryColor,
                          width: 14,
                          height: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          estimatedTime, // Menggunakan estimasi waktu dari backend
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentTeal,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      difficulty, // Menggunakan kesulitan dari backend
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description, // Menggunakan deskripsi dari backend
            style: TextStyle(
              color: AppTheme.textBrown,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // Menggunakan daftar alat dari backend
  Widget _buildToolsSection(List<dynamic> tools) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alat-Alat',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: tools
                .map<Widget>((tool) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    tool.toString(), // Alat dikirim sebagai list of strings dari backend
                    style: TextStyle(
                      color: AppTheme.textBrown,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ))
                .toList(),
          ),
        ],
      ),
    );
  }

  // Menggunakan daftar bahan dari backend (objects dengan quantity, unit, name)
  Widget _buildIngredientsSection(List<dynamic> ingredients) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bahan-Bahan',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: ingredients
                .map<Widget>((ingredient) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${ingredient['quantity']} ${ingredient['unit']} ${ingredient['name']}', // Gabungkan quantity, unit, name
                    style: TextStyle(
                      color: AppTheme.textBrown,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ))
                .toList(),
          ),
        ],
      ),
    );
  }

  // Menggunakan daftar langkah-langkah dari backend
  Widget _buildStepsSection(List<dynamic> steps) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${steps.length} Langkah Mudah',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: List.generate(
              steps.length,
                  (index) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: index % 2 == 0 ? AppTheme.primaryColor : AppTheme.searchBarColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index % 2 == 0 ? AppTheme.searchBarColor : AppTheme.primaryColor,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: index % 2 == 0 ? AppTheme.primaryColor : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        steps[index].toString(), // Langkah dikirim sebagai list of strings
                        style: TextStyle(
                          color: index % 2 == 0 ? Colors.white : AppTheme.primaryColor,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ulasan',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(
              5,
                  (index) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Image.asset(
                  'images/star.png', // Gambar bintang statis
                  color: AppTheme.primaryColor,
                  width: 32,
                  height: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.searchBarColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.add_circle,
                color: AppTheme.primaryColor,
              ),
              onPressed: () {},
            ),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tuliskan ulasan anda...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: Image.asset(
                'images/send_button.png',
                color: AppTheme.primaryColor,
                width: 24,
                height: 24,
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewAllCommentsButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Lihat Semua Ulasan & Diskusi Resep',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.primaryColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}