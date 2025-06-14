import 'package:flutter/material.dart';
import 'package:masak2/view/component/bottom_navbar.dart';
import 'package:masak2/view/component/header_b_l_s.dart'; // Import header yang Anda gunakan
import '../../theme/theme.dart';
import 'dart:convert'; // Untuk encode/decode JSON
import 'package:http/http.dart' as http; // Untuk permintaan HTTP
import 'package:flutter/foundation.dart' show kIsWeb; // Untuk cek apakah di web
import 'package:video_player/video_player.dart'; // Import video_player

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

  VideoPlayerController? _videoController; // Controller untuk pemutar video

  // Add these for review functionality
  final TextEditingController _commentController = TextEditingController();
  double _currentRating = 0.0; // To store the user's selected rating

  @override
  void initState() {
    super.initState();
    _fetchRecipeDetails(widget.recipeId); // Panggil fungsi untuk mengambil detail resep
  }

  @override
  void dispose() {
    _videoController?.dispose(); // Pastikan controller video di-dispose
    _commentController.dispose(); // Dispose the controller
    super.dispose();
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

          // Inisialisasi video controller jika ada video_url
          if (recipeData['video_url'] != null && (recipeData['video_url'] as String).isNotEmpty) {
            final String videoPath = recipeData['video_url'] as String;
            final fullVideoUrl = kIsWeb ? 'http://localhost:3000$videoPath' : 'http://10.0.2.2:3000$videoPath';

            // Tambahkan print untuk debugging URL video
            print('Trying to load video from: $fullVideoUrl');

            _videoController = VideoPlayerController.networkUrl(Uri.parse(fullVideoUrl))
              ..initialize().then((_) {
                setState(() {}); // Perbarui UI setelah video siap
                _videoController!.setLooping(true); // Opsional: putar ulang video
              }).catchError((e) {
                print('Error initializing video: $e');
                // Handle error video (misal: tampilkan pesan atau sembunyikan player)
                _videoController = null; // Set null agar tidak ditampilkan
                setState(() {}); // Perbarui UI
              });
          } else {
            _videoController = null; // Pastikan null jika tidak ada video_url
          }
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

  // --- NEW: Function to send schedule request ---
  Future<void> _addMealSchedule() async {
    // You'll need the actual user ID. For now, let's use a placeholder.
    // In a real app, this would come from user session/authentication.
    const int userId = 1; // Placeholder User ID

    final String apiUrl = kIsWeb ? 'http://localhost:3000/meal-schedules' : 'http://10.0.2.2:3000/meal-schedules';
    final String formattedDate = selectedDate.toIso8601String().split('T')[0]; // YYYY-MM-DD

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId, // Assuming your backend expects 'user_id'
          'recipe_id': widget.recipeId,
          'scheduled_date': formattedDate, // Assuming your backend expects 'scheduled_date'
        }),
      );

      if (response.statusCode == 201) {
        if (!mounted) return;
        Navigator.of(context).pop(); // Close calendar dialog first
        _showSuccessDialog(context, 'Penjadwalan', 'Menu Berhasil');
      } else {
        if (!mounted) return;
        Navigator.of(context).pop(); // Close calendar dialog
        _showErrorDialog(context, 'Penjadwalan Gagal', 'Gagal menjadwalkan menu: ${json.decode(response.body)['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close calendar dialog
      _showErrorDialog(context, 'Kesalahan Jaringan', 'Terjadi kesalahan jaringan saat menjadwalkan menu: $e');
      print('Error scheduling meal: $e');
    }
  }

  // --- NEW: Function to send review request ---
  Future<void> _submitReview() async {
    final String comment = _commentController.text.trim();

    if (_currentRating == 0.0) {
      _showErrorDialog(context, 'Ulasan Gagal', 'Harap berikan rating bintang.');
      return;
    }
    if (comment.isEmpty) {
      _showErrorDialog(context, 'Ulasan Gagal', 'Harap tuliskan komentar Anda.');
      return;
    }

    // You'll need the actual user ID. For now, let's use a placeholder.
    const int userId = 1; // Placeholder User ID

    final String apiUrl = kIsWeb ? 'http://localhost:3000/reviews' : 'http://10.0.2.2:3000/reviews';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId, // Assuming your backend expects 'user_id'
          'recipe_id': widget.recipeId,
          'rating': _currentRating.toInt(), // Convert double to int for star rating
          'comment': comment,
        }),
      );

      if (response.statusCode == 201) {
        if (!mounted) return;
        _commentController.clear();
        setState(() {
          _currentRating = 0.0; // Reset rating after submission
        });
        _showSuccessDialog(context, 'Ulasan Berhasil', 'Ulasan Anda berhasil ditambahkan!');
        // Optionally, re-fetch recipe details to update average rating and comments count
        _fetchRecipeDetails(widget.recipeId);
      } else {
        if (!mounted) return;
        _showErrorDialog(context, 'Ulasan Gagal', 'Gagal mengirim ulasan: ${json.decode(response.body)['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog(context, 'Kesalahan Jaringan', 'Terjadi kesalahan jaringan saat mengirim ulasan: $e');
      print('Error submitting review: $e');
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
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ),
      );
    }

    // Jika data sudah berhasil diambil, tampilkan UI resep
    // PENTING: Gunakan safe access (?) atau default value (??) di sini
    // Karena _fetchedRecipeData bisa saja masih null jika ada logika yang salah,
    // atau jika response.statusCode == 200 tapi body kosong/tidak sesuai.
    // Meskipun sudah ada cek _isLoading dan _errorMessage,
    // ini adalah best practice untuk menghindari crash.
    final recipe = _fetchedRecipeData;

    // Jika recipe masih null setelah loading selesai (misal, backend mengembalikan 200 OK tapi body kosong)
    if (recipe == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Detail resep tidak dapat dimuat. Data kosong.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ),
      );
    }


    // Konversi cooking_time (menit integer) kembali ke format "X Jam, Y Menit"
    final int cookingTimeMinutes = recipe['cooking_time'] as int? ?? 0;
    final int hours = cookingTimeMinutes ~/ 60;
    final int minutes = cookingTimeMinutes % 60;

    String estimatedTimeDisplay = '';
    if (hours > 0) {
      estimatedTimeDisplay += '$hours Jam';
    }
    if (minutes > 0) {
      if (hours > 0) estimatedTimeDisplay += ', ';
      estimatedTimeDisplay += '$minutes Menit';
    }

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
                title: recipe['title'] as String? ?? 'Resep Tidak Ditemukan',
                likes: recipe['favorites_count'] as int? ?? 0,
                comments: recipe['comments_count'] as int? ?? 0,
                onBackPressed: () => Navigator.pop(context),
                onLikePressed: () {
                  // Handle like button press
                  print('Like button pressed for ${recipe['title']}');
                },
                onSharePressed: () {
                  // Handle share button press
                  print('Share button pressed for ${recipe['title']}');
                },
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gambar resep (menggunakan image_url dari backend)
                      _buildRecipeImage(recipe['image_url'] as String?),
                      // Bagian video (baru ditambahkan)
                      if (_videoController != null && _videoController!.value.isInitialized)
                        _buildRecipeVideo(_videoController!),
                      // Bagian penulis (menggunakan data dari backend)
                      _buildAuthorSection(
                        recipe['user_id'] as int? ?? 0,
                        recipe['username'] as String? ?? 'Pengguna',
                        recipe['full_name'] as String? ?? 'Pengguna Tidak Dikenal',
                        recipe['profile_picture'] as String?,
                      ),
                      _buildDivider(),
                      // Deskripsi resep
                      _buildDescriptionSection(
                        recipe['description'] as String? ?? 'Tidak ada deskripsi tersedia.',
                        'Rp ${recipe['price']?.toString() ?? '0'}',
                        finalEstimatedTimeDisplay,
                        recipe['difficulty'] as String? ?? 'N/A',
                      ),
                      _buildScheduleButton(),
                      // Bagian alat-alat
                      _buildToolsSection(recipe['tools'] as List<dynamic>?),
                      // Bagian bahan-bahan
                      _buildIngredientsSection(recipe['ingredients'] as List<dynamic>?),
                      // Bagian langkah-langkah
                      _buildStepsSection(recipe['instructions'] as List<dynamic>?),
                      _buildDivider(),
                      // Bagian ulasan dan input komentar (menggunakan rata-rata rating)
                      _buildRatingSection(recipe['average_rating'] as double? ?? 0.0),
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
                Text(
                  '${_getMonthName(selectedDate.month)} ${selectedDate.year}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
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
              onPressed: _addMealSchedule, // Call the new function here
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

  // Helper untuk mendapatkan nama bulan
  String _getMonthName(int month) {
    const List<String> monthNames = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return monthNames[month];
  }


  Widget _buildCalendar() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    // Hitung offset untuk hari pertama dalam seminggu (Senin=0, Minggu=6)
    final int weekdayOffset = (firstDayOfMonth.weekday - 1 + 7) % 7;
    final int daysInMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
    final int totalCells = daysInMonth + weekdayOffset; // Jumlah total cell yang dibutuhkan

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: (totalCells / 7).ceil() * 7, // Pastikan kelipatan 7
      itemBuilder: (context, index) {
        if (index < 7) {
          final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
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

        // Hitung hari yang sebenarnya
        final int day = index - 7 - weekdayOffset + 1;

        if (day <= 0 || day > daysInMonth) {
          // Sel kosong untuk hari di bulan sebelumnya/berikutnya
          return const SizedBox.shrink();
        }

        final currentDay = DateTime(selectedDate.year, selectedDate.month, day);
        bool isSelected = currentDay.day == selectedDate.day &&
            currentDay.month == selectedDate.month &&
            currentDay.year == selectedDate.year;

        bool isToday = currentDay.day == now.day &&
            currentDay.month == now.month &&
            currentDay.year == now.year;

        return InkWell(
          onTap: () {
            setState(() {
              selectedDate = currentDay;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.accentTeal : (isToday ? AppTheme.searchBarColor.withOpacity(0.5) : Colors.transparent),
              shape: BoxShape.circle,
              border: isToday && !isSelected ? Border.all(color: AppTheme.primaryColor) : null,
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: TextStyle(
                  color: isSelected ? Colors.white : (isToday ? AppTheme.primaryColor : Colors.black),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }


  // Generic success dialog
  void _showSuccessDialog(BuildContext context, String title1, String title2, [String? message]) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
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
              Text(
                title1,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title2,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppTheme.textBrown),
                ),
              ]
            ],
          ),
        );
      },
    );
  }

  // Generic error dialog
  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Menggunakan URL gambar dari backend
  Widget _buildRecipeImage(String? imageUrl) {
    // Jika tidak ada gambar, tampilkan placeholder atau default
    ImageProvider imageProvider;
    String finalImageUrl = '';

    if (imageUrl != null && imageUrl.isNotEmpty && imageUrl != 'default_recipe_image.png') {
      // Sesuaikan URL backend untuk gambar statis/uploads
      finalImageUrl = kIsWeb ? 'http://localhost:3000$imageUrl' : 'http://10.0.2.2:3000$imageUrl';
      imageProvider = NetworkImage(finalImageUrl);
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
                print('Error loading recipe image from: $finalImageUrl - Error: $error');
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
                  _fetchedRecipeData?['title'] as String? ?? 'Nama Resep', // SAFE ACCESS
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
                      (_fetchedRecipeData?['favorites_count'] as int? ?? 0).toString(), // SAFE ACCESS
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
                      (_fetchedRecipeData?['comments_count'] as int? ?? 0).toString(), // SAFE ACCESS
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

  // Widget baru untuk menampilkan video
  Widget _buildRecipeVideo(VideoPlayerController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            VideoPlayer(controller),
            VideoProgressIndicator(controller, allowScrubbing: true),
            _PlayPauseOverlay(controller: controller),
          ],
        ),
      ),
    );
  }

  // Menggunakan data penulis dari backend (username, full_name, profile_picture)
  Widget _buildAuthorSection(int userId, String username, String fullName, String? profilePictureUrl) {
    ImageProvider profileImageProvider;
    String finalProfileImageUrl = '';

    if (profilePictureUrl != null && profilePictureUrl.isNotEmpty && profilePictureUrl != 'default_profile.png') {
      finalProfileImageUrl = kIsWeb ? 'http://localhost:3000$profilePictureUrl' : 'http://10.0.2.2:3000$profilePictureUrl';
      profileImageProvider = NetworkImage(finalProfileImageUrl);
    } else {
      profileImageProvider = const AssetImage('images/default_profile.png'); // Placeholder
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: profileImageProvider,
                onBackgroundImageError: (exception, stackTrace) {
                  print('Error loading profile image from: $finalProfileImageUrl - Exception: $exception');
                },
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '@$username',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    fullName,
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
                    print('Ikuti/Mengikuti button pressed for user ID: $userId');
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
                onPressed: () {
                  print('More options button pressed for user ID: $userId');
                },
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
                          Icons.attach_money, // Mengganti ikon bintang jadi ikon uang
                          color: Color(0xFF005A4D),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          price,
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
                          estimatedTime,
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
                      difficulty,
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
            description,
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
  Widget _buildToolsSection(List<dynamic>? tools) { // PARAMETER DIUBAH MENJADI NULLABLE
    final List<dynamic> safeTools = tools ?? []; // Jika null, gunakan list kosong

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
          if (safeTools.isNotEmpty) // Tampilkan hanya jika ada alat
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: safeTools
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
                      tool?.toString() ?? 'Alat tidak diketahui', // Pastikan elemen tool juga null-safe
                      style: TextStyle(
                        color: AppTheme.textBrown,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ))
                  .toList(),
            )
          else
            Text(
              'Tidak ada alat yang terdaftar.',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  // Menggunakan daftar bahan dari backend (objects dengan quantity, unit, name)
  Widget _buildIngredientsSection(List<dynamic>? ingredients) { // PARAMETER DIUBAH MENJADI NULLABLE
    final List<dynamic> safeIngredients = ingredients ?? []; // Jika null, gunakan list kosong

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
          if (safeIngredients.isNotEmpty) // Tampilkan hanya jika ada bahan
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: safeIngredients
                  .map<Widget>((ingredient) {
                // Pastikan ingredient adalah Map, dan propertinya juga null-safe
                final Map<String, dynamic> ingredientMap = ingredient is Map ? ingredient as Map<String, dynamic> : {};
                final String quantity = ingredientMap['quantity']?.toString() ?? '';
                final String unit = ingredientMap['unit']?.toString() ?? '';
                final String name = ingredientMap['name']?.toString() ?? 'Bahan tidak diketahui';

                return Padding(
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
                        '$quantity $unit $name'.trim(), // Gabungkan quantity, unit, name
                        style: TextStyle(
                          color: AppTheme.textBrown,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              })
                  .toList(),
            )
          else
            Text(
              'Tidak ada bahan yang terdaftar.',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  // Menggunakan daftar langkah-langkah dari backend
  Widget _buildStepsSection(List<dynamic>? steps) { // PARAMETER DIUBAH MENJADI NULLABLE
    final List<dynamic> safeSteps = steps ?? []; // Jika null, gunakan list kosong

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${safeSteps.length} Langkah Mudah', // Gunakan safeSteps.length
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          if (safeSteps.isNotEmpty) // Tampilkan hanya jika ada langkah
            Column(
              children: List.generate(
                safeSteps.length, // Gunakan safeSteps.length
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
                          safeSteps[index]?.toString() ?? 'Langkah tidak diketahui', // Pastikan elemen juga null-safe
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
            )
          else
            Text(
              'Tidak ada langkah-langkah yang terdaftar.',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  // Menggunakan rata-rata rating dari backend
  Widget _buildRatingSection(double averageRating) {
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
                  (index) => GestureDetector(
                onTap: () {
                  setState(() {
                    _currentRating = (index + 1).toDouble(); // Set rating based on tapped star
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    // Fill star if index is less than current rating
                    index < _currentRating ? Icons.star : Icons.star_border,
                    color: AppTheme.primaryColor,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _currentRating == 0.0
                ? 'Berikan rating Anda'
                : 'Rating Anda: ${_currentRating.toStringAsFixed(1)}',
            style: TextStyle(
              color: AppTheme.textBrown,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Rata-rata Ulasan: ${averageRating.toStringAsFixed(1)} dari 5', // Tampilkan rata-rata rating
            style: TextStyle(
              color: AppTheme.textBrown,
              fontSize: 14,
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
              onPressed: () {
                // You can add functionality here, e.g., attach media
                print('Add comment media button pressed');
              },
            ),
            Expanded(
              child: TextField(
                controller: _commentController, // Assign the controller
                decoration: const InputDecoration(
                  hintText: 'Tuliskan ulasan anda...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                onSubmitted: (value) {
                  // Optional: submit on enter key
                  _submitReview();
                },
              ),
            ),
            IconButton(
              icon: Image.asset(
                'images/send_button.png',
                color: AppTheme.primaryColor,
                width: 24,
                height: 24,
              ),
              onPressed: _submitReview, // Call the new function here
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
        onTap: () {
          print('View all comments button pressed');
        },
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

// Widget untuk kontrol play/pause video
class _PlayPauseOverlay extends StatelessWidget {
  const _PlayPauseOverlay({required this.controller});

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? const SizedBox.shrink()
              : Container(
            color: Colors.black26,
            child: const Center(
              child: Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 100.0,
                semanticLabel: 'Play',
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
      ],
    );
  }
}