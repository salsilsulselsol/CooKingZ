import 'package:flutter/material.dart';
import 'package:masak2/view/component/bottom_navbar.dart';
import 'package:masak2/view/component/header_b_l_s.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // <--- ADD THIS IMPORT for DateFormat
import '../../theme/theme.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:video_player/video_player.dart';
import '../profile/profil/edit_resep.dart';
import 'bagikan_resep.dart';

class RecipeDetailPage extends StatefulWidget {
  final int recipeId;
  final VoidCallback? onScheduleAdded; // <--- ADD THIS

  const RecipeDetailPage({super.key, required this.recipeId, this.onScheduleAdded}); // <--- UPDATE CONSTRUCTOR

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  final String _baseUrl = kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic>? _fetchedRecipeData;

  bool isFollowing = false;
  DateTime selectedDate = DateTime.now();

  VideoPlayerController? _videoController;

  final TextEditingController _commentController = TextEditingController();
  double _currentRating = 0.0;

  bool _isFavorited = false;
  bool _isOwner = false;
  int? _currentLoggedInUserId; // State untuk menyimpan user_id yang login

  @override
  void dispose() {
    _videoController?.dispose();
    _commentController.dispose();
    super.dispose();
  }

  // Fungsi untuk mendapatkan user ID dari SharedPreferences
  Future<int?> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final int? userIdInt = prefs.getInt('user_id'); // Kunci harus SAMA dengan saat menyimpan
    return userIdInt;
  }

  // Fungsi BARU untuk mendapatkan Access Token dari SharedPreferences
  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    // Gunakan kunci yang SAMA PERSIS dengan yang Anda gunakan saat menyimpan token setelah login
    final String? token = prefs.getString('auth_token'); // <--- PASTIKAN KUNCI INI SAMA
    print('DEBUG in RecipeDetailPage: Token from SharedPreferences: $token');
    return token;
  }

  @override
  void initState() {
    super.initState();
    _initializePageData(); // Panggil fungsi inisialisasi baru
  }

  // Fungsi inisialisasi data halaman secara berurutan
  Future<void> _initializePageData() async {
    _currentLoggedInUserId = await _getCurrentUserId(); // Ambil user ID saat init
    await _fetchRecipeDetails(widget.recipeId); // Ambil detail resep

    // Cek status favorit hanya jika user_id tersedia
    if (_currentLoggedInUserId != null) {
      await _checkFavoriteStatus(widget.recipeId, _currentLoggedInUserId!);
    }
    _checkOwnership(); // Cek kepemilikan

    setState(() {
      _isLoading = false; // Set loading to false setelah semua data awal dimuat
    });
  }

  // Fungsi untuk mengecek kepemilikan resep
  Future<void> _checkOwnership() async {
    if (_currentLoggedInUserId != null && _fetchedRecipeData != null) {
      setState(() {
        _isOwner = (_currentLoggedInUserId! == (_fetchedRecipeData!['user_id'] as int));
      });
    }
  }

  // Fungsi untuk mengambil detail resep dari backend
  Future<void> _fetchRecipeDetails(int id) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _fetchedRecipeData = null;
    });

    final String apiUrl = '$_baseUrl/recipes/$id';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> recipeData = json.decode(response.body);
        setState(() {
          _fetchedRecipeData = recipeData;

          if (recipeData['video_url'] != null && (recipeData['video_url'] as String).isNotEmpty) {
            final String videoPath = recipeData['video_url'] as String;
            final fullVideoUrl = '$_baseUrl$videoPath';

            print('Trying to load video from: $fullVideoUrl');

            _videoController = VideoPlayerController.networkUrl(Uri.parse(fullVideoUrl))
              ..initialize().then((_) {
                if (mounted) setState(() {});
                _videoController!.setLooping(true);
              }).catchError((e) {
                print('Error initializing video: $e');
                _videoController = null;
                if (mounted) setState(() {});
              });
          } else {
            _videoController = null;
          }
        });
        _checkOwnership();
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

  void _editRecipe() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditResep(recipeId: widget.recipeId),
      ),
    );

    if (result == true) {
      print('Kembali dari halaman edit, me-refresh data...');
      _initializePageData(); // Panggil ulang untuk merefresh semua data
    }
  }

  void _deleteRecipe() {
    _showDeleteConfirmationDialog(context);
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus resep ini? Aksi ini tidak dapat dibatalkan.'),
          actions: <Widget>[
            TextButton(
              child: Text('Batal', style: TextStyle(color: AppTheme.textBrown)),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(ctx).pop();
                _performDelete();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _performDelete() async {
    setState(() {
      _isLoading = true;
    });
    final String apiUrl = '$_baseUrl/recipes/${widget.recipeId}';

    final String? accessToken = await _getAccessToken(); // Ambil token
    if (accessToken == null) {
      _showErrorDialog(context, 'Autentikasi Gagal', 'Anda tidak memiliki sesi login yang aktif. Silakan login kembali.');
      setState(() { _isLoading = false; });
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $accessToken', // Sertakan token
        },
      );
      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 204) {
        Navigator.of(context).pop();
      } else if (response.statusCode == 401) {
        _showErrorDialog(context, 'Autentikasi Diperlukan', 'Sesi Anda telah berakhir atau tidak valid. Silakan login kembali.');
      }
      else {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog(context, 'Hapus Gagal', 'Gagal menghapus resep: ${json.decode(response.body)['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog(context, 'Kesalahan Jaringan', 'Terjadi kesalahan jaringan saat menghapus resep: $e');
    }
  }

  // Fungsi untuk mengecek status favorit resep
  Future<void> _checkFavoriteStatus(int recipeId, int userId) async {
    final String apiUrl = kIsWeb
        ? 'http://localhost:3000/recipes/$recipeId/favorite-status?user_id=$userId'
        : 'http://10.0.2.2:3000/recipes/$recipeId/favorite-status?user_id=$userId';

    final String? accessToken = await _getAccessToken(); // Ambil token
    // Perhatikan: Anda bisa memilih apakah cek status favorit butuh token atau tidak.
    // Saat ini, backend Anda mungkin tidak memerlukannya karena rute '/recipes' belum ada `authenticateToken`
    // Tapi jika di masa depan `favoriteRoutes` juga di bawah `authenticateToken`, ini akan diperlukan.

    Map<String, String> headers = {'Content-Type': 'application/json'};
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: headers, // Gunakan header yang mungkin berisi token
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _isFavorited = data['isFavorited'] ?? false;
          });
        }
      } else {
        print('Gagal mengecek status favorit: ${response.statusCode} - ${json.decode(response.body)['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('Error mengecek status favorit: $e');
    }
  }

  // Fungsi untuk menambah/menghapus resep dari favorit
  Future<void> _toggleFavorite() async {
    if (_currentLoggedInUserId == null) {
      _showErrorDialog(context, 'Favorit Gagal', 'Anda harus login untuk menambahkan ke favorit.');
      return;
    }

    final String? accessToken = await _getAccessToken(); // Ambil token
    if (accessToken == null) {
      _showErrorDialog(context, 'Autentikasi Gagal', 'Anda tidak memiliki sesi login yang aktif. Silakan login kembali.');
      return;
    }

    final String apiUrl = kIsWeb ? 'http://localhost:3000/recipes/${widget.recipeId}/favorite' : 'http://10.0.2.2:3000/recipes/${widget.recipeId}/favorite';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken', // Sertakan token
        },
        body: json.encode({'user_id': _currentLoggedInUserId!}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _isFavorited = data['isFavorited'] ?? !_isFavorited;
            if (_fetchedRecipeData != null) {
              if (_isFavorited) {
                _fetchedRecipeData!['favorites_count'] = (_fetchedRecipeData!['favorites_count'] as int? ?? 0) + 1;
              } else {
                _fetchedRecipeData!['favorites_count'] = (_fetchedRecipeData!['favorites_count'] as int? ?? 0) - 1;
              }
            }
          });
          _showSuccessDialog(context, 'Favorit', data['message']);
        }
      } else if (response.statusCode == 401) {
        _showErrorDialog(context, 'Autentikasi Diperlukan', 'Sesi Anda telah berakhir atau tidak valid. Silakan login kembali.');
      } else {
        _showErrorDialog(context, 'Favorit Gagal', 'Gagal mengubah status favorit: ${json.decode(response.body)['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      _showErrorDialog(context, 'Kesalahan Jaringan', 'Terjadi kesalahan jaringan saat mengubah status favorit: $e');
      print('Error toggling favorite: $e');
    }
  }

  // Fungsi untuk mengirim permintaan jadwal
  Future<void> _addMealSchedule() async {
    if (_currentLoggedInUserId == null) {
      _showErrorDialog(context, 'Penjadwalan Gagal', 'Anda harus login untuk menjadwalkan menu.');
      return;
    }

    // 1. Ambil token dari SharedPreferences menggunakan fungsi _getAccessToken()
    final String? token = await _getAccessToken();

    if (token == null || token.isEmpty) {
      _showErrorDialog(context, 'Token Tidak Valid', 'Silakan login kembali.');
      return;
    }

    final String apiUrl = kIsWeb
        ? 'http://localhost:3000/api/utilities/meal-schedules'
        : 'http://10.0.2.2:3000/api/utilities/meal-schedules';

    final String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'user_id': _currentLoggedInUserId, // Kirim user_id yang sedang login
          'recipe_id': widget.recipeId,
          'date': formattedDate,
          'meal_type': 'Dinner', // Bisa diubah menjadi parameter yang bisa dipilih user
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        Navigator.of(context).pop(); // Tutup dialog kalender
        _showSuccessDialog(context, 'Penjadwalan Berhasil', 'Menu berhasil ditambahkan ke jadwal');

        // Panggil callback jika ada, untuk merefresh tampilan halaman sebelumnya (misal: halaman jadwal)
        if (widget.onScheduleAdded != null) {
          widget.onScheduleAdded!();
        }
      } else if (response.statusCode == 401) {
        Navigator.of(context).pop(); // Tutup dialog sebelum menampilkan error auth
        _showErrorDialog(context, 'Autentikasi Diperlukan', 'Sesi Anda telah berakhir atau tidak valid. Silakan login kembali.');
      } else {
        Navigator.of(context).pop();
        final errorResponse = json.decode(response.body);
        _showErrorDialog(
            context,
            'Penjadwalan Gagal',
            errorResponse['message'] ?? 'Terjadi kesalahan (${response.statusCode})'
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      _showErrorDialog(
          context,
          'Kesalahan Jaringan',
          'Gagal terhubung ke server: ${e.toString()}'
      );
      print('Error scheduling meal: $e');
    }
  }

  // Fungsi untuk mengirim permintaan ulasan
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
    if (_currentLoggedInUserId == null) {
      _showErrorDialog(context, 'Ulasan Gagal', 'Anda harus login untuk memberikan ulasan.');
      return;
    }

    final String? accessToken = await _getAccessToken(); // Ambil token
    if (accessToken == null) {
      _showErrorDialog(context, 'Autentikasi Gagal', 'Anda tidak memiliki sesi login yang aktif. Silakan login kembali.');
      return;
    }

    final String apiUrl = kIsWeb ? 'http://localhost:3000/reviews' : 'http://10.0.2.2:3000/reviews';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken', // Sertakan token
        },
        body: json.encode({
          'user_id': _currentLoggedInUserId!,
          'recipe_id': widget.recipeId,
          'rating': _currentRating.toInt(),
          'comment': comment,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        _commentController.clear();
        if (mounted) {
          setState(() {
            _currentRating = 0.0;
          });
        }
        _showSuccessDialog(context, 'Ulasan Berhasil', 'Ulasan Anda berhasil ditambahkan!');
        _fetchRecipeDetails(widget.recipeId);
      } else if (response.statusCode == 401) {
        _showErrorDialog(context, 'Autentikasi Diperlukan', 'Sesi Anda telah berakhir atau tidak valid. Silakan login kembali.');
      } else {
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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
      );
    }

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

    final recipe = _fetchedRecipeData;

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

    final String finalEstimatedTimeDisplay = estimatedTimeDisplay.isEmpty && cookingTimeMinutes == 0
        ? '0 Menit'
        : estimatedTimeDisplay;


    return BottomNavbar(
      Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              RecipeDetailHeader(
                title: recipe['title'] as String? ?? 'Resep Tidak Ditemukan',
                likes: recipe['favorites_count'] as int? ?? 0,
                comments: recipe['comments_count'] as int? ?? 0,
                onBackPressed: () => Navigator.pop(context),
                onLikePressed: _toggleFavorite,
                onSharePressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BagikanResep(
                        recipeId: widget.recipeId,
                        recipeTitle: recipe['title'] as String? ?? 'Resep Lezat',
                      ),
                    ),
                  );
                },
                isOwner: _isOwner,
                onEditPressed: _editRecipe,
                onDeletePressed: _deleteRecipe,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRecipeImage(recipe['image_url'] as String?),
                      if (_videoController != null && _videoController!.value.isInitialized)
                        _buildRecipeVideo(_videoController!),
                      _buildAuthorSection(
                        recipe['user_id'] as int? ?? 0,
                        recipe['username'] as String? ?? 'Pengguna',
                        recipe['full_name'] as String? ?? 'Pengguna Tidak Dikenal',
                        recipe['profile_picture'] as String?,
                      ),
                      _buildDivider(),
                      _buildDescriptionSection(
                        recipe['description'] as String? ?? 'Tidak ada deskripsi tersedia.',
                        'Rp ${recipe['price']?.toString() ?? '0'}',
                        finalEstimatedTimeDisplay,
                        recipe['difficulty'] as String? ?? 'N/A',
                      ),
                      _buildScheduleButton(),
                      _buildToolsSection(recipe['tools'] as List<dynamic>?),
                      _buildIngredientsSection(recipe['ingredients'] as List<dynamic>?),
                      _buildStepsSection(recipe['instructions'] as List<dynamic>?),
                      _buildDivider(),
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

  // Widget untuk menampilkan bagian penulis resep
  Widget _buildAuthorSection(int userId, String username, String fullName, String? profilePictureUrl) {
    String finalProfileImageUrl = '';
    Widget profileImageWidget;

    if (profilePictureUrl != null && profilePictureUrl.isNotEmpty) {
      finalProfileImageUrl = kIsWeb ? 'http://localhost:3000$profilePictureUrl' : 'http://10.0.2.2:3000$profilePictureUrl';
      profileImageWidget = CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(finalProfileImageUrl),
        onBackgroundImageError: (exception, stackTrace) {
          print('Error loading profile image from: $finalProfileImageUrl - Exception: $exception');
        },
      );
    } else {
      profileImageWidget = CircleAvatar(
        radius: 24,
        backgroundColor: Colors.grey[300],
        child: Icon(
          Icons.person,
          color: Colors.grey[600],
          size: 30,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              profileImageWidget,
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
              if (_isOwner)
                IconButton(
                  icon: Icon(Icons.more_vert, color: AppTheme.primaryColor),
                  onPressed: () {
                    _showOwnerOptionsDialog(context);
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

  // Fungsi untuk menampilkan dialog opsi owner
  void _showOwnerOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Opsi Resep',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit, color: AppTheme.primaryColor),
                title: Text('Edit Resep'),
                onTap: () {
                  Navigator.of(context).pop();
                  _editRecipe();
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Hapus Resep', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.of(context).pop();
                  _deleteRecipe();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal', style: TextStyle(color: AppTheme.primaryColor)),
            ),
          ],
        );
      },
    );
  }

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
      builder: (BuildContext dialogContext) { // Gunakan dialogContext agar tidak bingung dengan context utama
        return AlertDialog(
          title: Text(
            'Jadwalkan Menu',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          content: StatefulBuilder( // StatefulBuilder untuk memperbarui UI di dalam dialog
            builder: (BuildContext context, StateSetter setDialogState) {
              final now = DateTime.now();
              final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
              final int weekdayOffset = (firstDayOfMonth.weekday - 1 + 7) % 7;
              final int daysInMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
              final int totalCells = daysInMonth + weekdayOffset;

              return SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_left, color: AppTheme.primaryColor),
                          onPressed: () {
                            setDialogState(() {
                              selectedDate = DateTime(selectedDate.year, selectedDate.month - 1, selectedDate.day);
                            });
                          },
                        ),
                        Text(
                          '${_getMonthName(selectedDate.month)} ${selectedDate.year}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_right, color: AppTheme.primaryColor),
                          onPressed: () {
                            setDialogState(() {
                              selectedDate = DateTime(selectedDate.year, selectedDate.month + 1, selectedDate.day);
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(), // Mencegah scrolling di dalam dialog
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: (totalCells / 7).ceil() * 7,
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

                        final int day = index - 7 - weekdayOffset + 1;

                        if (day <= 0 || day > daysInMonth) {
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
                            setDialogState(() { // Perbarui state dialog saja
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
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text('Batal', style: TextStyle(color: AppTheme.primaryColor)),
            ),
            ElevatedButton(
              onPressed: _addMealSchedule,
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

  String _getMonthName(int month) {
    const List<String> monthNames = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return monthNames[month];
  }

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

  Widget _buildRecipeImage(String? imageUrl) {
    String finalImageUrl = '';
    Widget imageWidget;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      final String finalImageUrl = '$_baseUrl$imageUrl';
      imageWidget = Image.network(
        finalImageUrl,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading recipe image from: $finalImageUrl - Error: $error');
          return Container(
            height: 200,
            color: Colors.grey[200],
            child: const Center(
              child: Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
            ),
          );
        },
      );
    } else {
      imageWidget = Container(
        height: 200,
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.image, color: Colors.grey, size: 50),
        ),
      );
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
            child: imageWidget,
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
                  _fetchedRecipeData?['title'] as String? ?? 'Nama Resep',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      _isFavorited ? Icons.favorite : Icons.favorite_border,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      (_fetchedRecipeData?['favorites_count'] as int? ?? 0).toString(),
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
                      (_fetchedRecipeData?['comments_count'] as int? ?? 0).toString(),
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

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Divider(
        thickness: 2,
        color: AppTheme.primaryColor,
      ),
    );
  }

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

  Widget _buildToolsSection(List<dynamic>? tools) {
    final List<dynamic> safeTools = tools ?? [];

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
          if (safeTools.isNotEmpty)
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
                      tool?.toString() ?? 'Alat tidak diketahui',
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

  Widget _buildIngredientsSection(List<dynamic>? ingredients) {
    final List<dynamic> safeIngredients = ingredients ?? [];

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
          if (safeIngredients.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: safeIngredients
                  .map<Widget>((ingredient) {
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
                        '$quantity $unit $name'.trim(),
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

  Widget _buildStepsSection(List<dynamic>? steps) {
    final List<dynamic> safeSteps = steps ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${safeSteps.length} Langkah Mudah',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          if (safeSteps.isNotEmpty)
            Column(
              children: List.generate(
                safeSteps.length,
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
                          safeSteps[index]?.toString() ?? 'Langkah tidak diketahui',
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
                    _currentRating = (index + 1).toDouble();
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
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
            'Rata-rata Ulasan: ${averageRating.toStringAsFixed(1)} dari 5',
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
                print('Add comment media button pressed');
              },
            ),
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  hintText: 'Tuliskan ulasan anda...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                onSubmitted: (value) {
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
              onPressed: _submitReview,
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

class _PlayPauseOverlay extends StatefulWidget {
  const _PlayPauseOverlay({required this.controller});

  final VideoPlayerController controller;

  @override
  State<_PlayPauseOverlay> createState() => _PlayPauseOverlayState();
}

class _PlayPauseOverlayState extends State<_PlayPauseOverlay> {
  void _listener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_listener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: widget.controller.value.isPlaying
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
            if (widget.controller.value.isPlaying) {
              widget.controller.pause();
            } else {
              widget.controller.play();
            }
          },
        ),
      ],
    );
  }
}