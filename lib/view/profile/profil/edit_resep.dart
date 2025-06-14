import 'package:flutter/material.dart';
import '../../component/header_back.dart';
import '../../component/bottom_navbar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http_parser/http_parser.dart';

class AppColors {
  static const Color primaryColor = Color(0xFF005A4D);
  static const Color accentTeal = Color(0xFF57B4BA);
  static const Color emeraldGreen = Color(0xFF015551);
  static const Color lightTeal = Color(0xFF9FD5DB);
  static const Color bgColor = Color(0xFFF9F9F9);
}

class EditResep extends StatefulWidget {
  final int recipeId; // ID resep yang akan diedit

  const EditResep({super.key, required this.recipeId});

  @override
  State<EditResep> createState() => _EditResepState();
}

class _EditResepState extends State<EditResep> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _estimatedTimeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String? _selectedDifficulty;
  String? _selectedCategory;

  XFile? _selectedImage;
  XFile? _selectedVideo;

  String? _initialImageUrl;
  String? _initialVideoUrl;
  bool _imageClearedByUser = false;
  bool _videoClearedByUser = false;

  final ImagePicker _picker = ImagePicker();

  final List<String> _difficultyLevels = ['Mudah', 'Sedang', 'Sulit'];
  final List<Map<String, String>> _categories = [
    {'id': '1', 'name': 'Hidangan Utama'},
    {'id': '2', 'name': 'Sarapan'},
    {'id': '3', 'name': 'Makanan Ringan'},
    {'id': '4', 'name': 'Kue & Dessert'},
    {'id': '5', 'name': 'Minuman'},
    // Tambahkan kategori default jika diperlukan
    {'id': '999', 'name': 'Lainnya'}, // Kategori placeholder untuk kasus tidak ditemukan
  ];

  final List<TextEditingController> _toolControllers = [];
  final List<Map<String, TextEditingController>> _ingredientControllers = [];
  final List<TextEditingController> _instructionControllers = [];

  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchRecipeDetails();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _estimatedTimeController.dispose();
    _priceController.dispose();
    for (var controller in _toolControllers) controller.dispose();
    for (var controllersMap in _ingredientControllers) {
      controllersMap['quantity']?.dispose();
      controllersMap['unit']?.dispose();
      controllersMap['name']?.dispose();
    }
    for (var controller in _instructionControllers) controller.dispose();
    super.dispose();
  }

  Future<void> _fetchRecipeDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    final String apiUrl = kIsWeb ? 'http://localhost:3000/recipes/${widget.recipeId}' : 'http://10.0.2.2:3000/recipes/${widget.recipeId}';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> recipeData = json.decode(response.body);

        _titleController.text = recipeData['title'] ?? '';
        _descriptionController.text = recipeData['description'] ?? '';

        final int cookingTimeMinutes = recipeData['cooking_time'] ?? 0;
        final int hours = cookingTimeMinutes ~/ 60;
        final int minutes = cookingTimeMinutes % 60;
        _estimatedTimeController.text = '${hours > 0 ? '$hours Jam' : ''}${hours > 0 && minutes > 0 ? ', ' : ''}${minutes > 0 ? '$minutes Menit' : ''}'.trim();
        if (_estimatedTimeController.text.isEmpty && cookingTimeMinutes == 0) {
          _estimatedTimeController.text = '0 Menit';
        }

        _priceController.text = (recipeData['price'] ?? 0).toString();
        _selectedDifficulty = recipeData['difficulty'];

        // --- PERBAIKAN UNTUK ERROR 'map_value_type_not_assignable' ---
        // Pastikan orElse mengembalikan Map<String, String> yang valid
        _selectedCategory = _categories.firstWhere(
                (cat) => cat['id'] == (recipeData['category_id'] ?? '').toString(),
            orElse: () => {'id': '999', 'name': 'Lainnya'} // Mengembalikan map yang valid dengan string placeholder
        )['name'];
        // -------------------------------------------------------------

        _initialImageUrl = recipeData['image_url'];
        _initialVideoUrl = recipeData['video_url'];

        _toolControllers.clear();
        final List<dynamic> tools = recipeData['tools'] ?? [];
        for (var toolName in tools) {
          _toolControllers.add(TextEditingController(text: toolName));
        }
        if (_toolControllers.isEmpty) _toolControllers.add(TextEditingController());

        _ingredientControllers.clear();
        final List<dynamic> ingredients = recipeData['ingredients'] ?? [];
        for (var ingredient in ingredients) {
          _ingredientControllers.add({
            'quantity': TextEditingController(text: ingredient['quantity']?.toString() ?? ''),
            'unit': TextEditingController(text: ingredient['unit'] ?? ''),
            'name': TextEditingController(text: ingredient['name'] ?? ''),
          });
        }
        if (_ingredientControllers.isEmpty) {
          _ingredientControllers.add({'quantity': TextEditingController(), 'unit': TextEditingController(), 'name': TextEditingController()});
        }

        _instructionControllers.clear();
        final List<dynamic> instructions = recipeData['instructions'] ?? [];
        for (var instructionText in instructions) {
          _instructionControllers.add(TextEditingController(text: instructionText));
        }
        if (_instructionControllers.isEmpty) _instructionControllers.add(TextEditingController());

      } else {
        _errorMessage = 'Gagal mengambil data resep: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan jaringan saat mengambil resep: $e';
      print('Error fetching recipe: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  void _addToolField() {
    setState(() {
      _toolControllers.add(TextEditingController());
    });
  }

  void _removeToolField(int index) {
    setState(() {
      _toolControllers[index].dispose();
      _toolControllers.removeAt(index);
    });
  }

  void _addIngredientField() {
    setState(() {
      _ingredientControllers.add({
        'quantity': TextEditingController(),
        'unit': TextEditingController(),
        'name': TextEditingController(),
      });
    });
  }

  void _removeIngredientField(int index) {
    setState(() {
      _ingredientControllers[index]['quantity']?.dispose();
      _ingredientControllers[index]['unit']?.dispose();
      _ingredientControllers[index]['name']?.dispose();
      _ingredientControllers.removeAt(index);
    });
  }

  void _addInstructionField() {
    setState(() {
      _instructionControllers.add(TextEditingController());
    });
  }

  void _removeInstructionField(int index) {
    setState(() {
      _instructionControllers[index].dispose();
      _instructionControllers.removeAt(index);
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _selectedImage = image;
      _imageClearedByUser = false; // Jika pilih gambar baru, berarti tidak dihapus
    });
  }

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    setState(() {
      _selectedVideo = video;
      _videoClearedByUser = false; // Jika pilih video baru, berarti tidak dihapus
    });
  }

  void _clearImage() {
    setState(() {
      _selectedImage = null;
      _imageClearedByUser = true; // Tandai bahwa gambar asli dihapus
    });
  }

  void _clearVideo() {
    setState(() {
      _selectedVideo = null;
      _videoClearedByUser = true; // Tandai bahwa video asli dihapus
    });
  }

  Future<void> _submitEditedRecipe() async {
    // URL untuk PUT request (menggunakan ID resep)
    final String apiUrl = kIsWeb ? 'http://localhost:3000/recipes/${widget.recipeId}' : 'http://10.0.2.2:3000/recipes/${widget.recipeId}';

    final String title = _titleController.text.trim();
    final String description = _descriptionController.text.trim();
    final String estimatedTime = _estimatedTimeController.text.trim();
    final String price = _priceController.text.trim();
    final String difficulty = _selectedDifficulty ?? '';
    final String? categoryId = _selectedCategory != null
        ? _categories.firstWhere((cat) => cat['name'] == _selectedCategory)['id']
        : null;

    final List<String> tools = _toolControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    final List<Map<String, String>> ingredients = _ingredientControllers
        .map((map) => {
      'quantity': map['quantity']?.text.trim() ?? '',
      'unit': map['unit']?.text.trim() ?? '',
      'name': map['name']?.text.trim() ?? '',
    })
        .where((map) => map['name']!.isNotEmpty && map['quantity']!.isNotEmpty && map['unit']!.isNotEmpty)
        .toList();

    final List<String> instructions = _instructionControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    // Validasi gambar wajib: Jika tidak ada gambar baru DAN gambar awal adalah default/tidak ada DAN user tidak meng-upload/mengganti
    bool isImageMissing = (_selectedImage == null && _initialImageUrl == 'default_recipe_image.png' && !_imageClearedByUser) ||
        (_selectedImage == null && _initialImageUrl == null && !_imageClearedByUser);
    if (title.isEmpty ||
        description.isEmpty ||
        estimatedTime.isEmpty ||
        price.isEmpty ||
        difficulty.isEmpty ||
        categoryId == null ||
        tools.isEmpty ||
        ingredients.isEmpty ||
        instructions.isEmpty ||
        isImageMissing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field (termasuk Gambar) harus diisi!')),
      );
      return;
    }

    var request = http.MultipartRequest('PUT', Uri.parse(apiUrl)); // Menggunakan PUT untuk update

    // Tambahkan field teks
    request.fields['categoryId'] = categoryId!; // categoryId sudah divalidasi tidak null
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['estimatedTime'] = estimatedTime;
    request.fields['price'] = price;
    request.fields['difficulty'] = difficulty;
    request.fields['tools'] = json.encode(tools);
    request.fields['ingredients'] = json.encode(ingredients);
    request.fields['instructions'] = json.encode(instructions);

    // Tambahkan flag untuk memberitahu backend tentang status gambar/video
    // 'true' jika file lama TIDAK diganti DAN TIDAK dihapus
    // 'false' jika file baru dipilih ATAU file lama dihapus
    request.fields['image_url_unchanged'] = (_selectedImage == null && !_imageClearedByUser).toString();
    request.fields['video_url_unchanged'] = (_selectedVideo == null && !_videoClearedByUser).toString();

    // Tambahkan file gambar (jika ada gambar baru dipilih)
    if (_selectedImage != null) {
      final String? imageMimeType = _selectedImage!.mimeType;
      if (kIsWeb) {
        final bytes = await _selectedImage!.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: _selectedImage!.name,
          contentType: imageMimeType != null ? MediaType.parse(imageMimeType) : null,
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _selectedImage!.path,
          filename: _selectedImage!.name,
          contentType: imageMimeType != null ? MediaType.parse(imageMimeType) : null,
        ));
      }
    }

    // Tambahkan file video (jika ada video baru dipilih)
    if (_selectedVideo != null) {
      final String? videoMimeType = _selectedVideo!.mimeType;
      if (kIsWeb) {
        final bytes = await _selectedVideo!.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'video',
          bytes,
          filename: _selectedVideo!.name,
          contentType: videoMimeType != null ? MediaType.parse(videoMimeType) : null,
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'video',
          _selectedVideo!.path,
          filename: _selectedVideo!.name,
          contentType: videoMimeType != null ? MediaType.parse(videoMimeType) : null,
        ));
      }
    }

    try {
      var response = await request.send();
      var responseData = await response.stream.transform(utf8.decoder).join();
      var jsonResponse = json.decode(responseData);

      if (response.statusCode == 200) { // HTTP 200 OK untuk update berhasil
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resep berhasil diperbarui!')),
        );
        Navigator.pop(context, true); // Kembali ke halaman sebelumnya dengan hasil 'true'
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui resep: ${jsonResponse['message'] ?? 'Terjadi kesalahan tidak dikenal'}')),
        );
      }
    } catch (e) {
      print('Error submitting edited recipe: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan jaringan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.bgColor,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: AppColors.bgColor,
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

    return BottomNavbar(
      Scaffold(
        backgroundColor: AppColors.bgColor,
        body: SafeArea(
          child: Column(
            children: [
              HeaderWidget(
                title: 'Edit Resep', // Ubah judul
                onBackPressed: () {
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Area Unggah Gambar (Wajib)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.lightTeal.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                          image: _selectedImage != null // Jika ada gambar baru dipilih
                              ? DecorationImage(
                            image: kIsWeb ? NetworkImage(_selectedImage!.path) : FileImage(File(_selectedImage!.path)) as ImageProvider,
                            fit: BoxFit.cover,
                          )
                              : _imageClearedByUser // Jika gambar asli dihapus
                              ? null // Tidak ada gambar
                              : (_initialImageUrl != null && _initialImageUrl != 'default_recipe_image.png') // Jika ada gambar awal dari backend dan bukan default
                              ? DecorationImage(
                            image: NetworkImage('http://localhost:3000$_initialImageUrl'), // Sesuaikan URL backend untuk gambar awal
                            fit: BoxFit.cover,
                          )
                              : null, // Default jika tidak ada gambar
                        ),
                        // Tampilkan overlay "Tambahkan Gambar" hanya jika tidak ada gambar sama sekali
                        child: (_selectedImage == null && !_imageClearedByUser && (_initialImageUrl == null || _initialImageUrl == 'default_recipe_image.png'))
                            ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppColors.emeraldGreen.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 36,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Tambahkan Gambar Resep (Wajib)',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        )
                            : null,
                      ),
                      // Tombol Unggah/Ganti/Hapus Gambar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  height: 35,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentTeal.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    (_selectedImage == null && !_imageClearedByUser && (_initialImageUrl == null || _initialImageUrl == 'default_recipe_image.png'))
                                        ? 'Pilih Gambar' // Belum ada gambar sama sekali
                                        : 'Ganti Gambar', // Ada gambar (lama/baru) bisa diganti
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Tampilkan tombol hapus hanya jika ada gambar yang bisa dihapus (bukan null dan bukan default_image.png)
                            if (_selectedImage != null || (_initialImageUrl != null && _initialImageUrl != 'default_recipe_image.png' && !_imageClearedByUser))
                              Expanded(
                                child: GestureDetector(
                                  onTap: _clearImage,
                                  child: Container(
                                    height: 35,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    margin: const EdgeInsets.symmetric(horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentTeal.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'Hapus Gambar',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Area Unggah Video (Opsional)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        height: 100, // Ukuran lebih kecil untuk video opsional
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.lightTeal.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: (_selectedVideo == null && (_initialVideoUrl == null || _videoClearedByUser))
                            ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 40, // Ikon lebih kecil
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.emeraldGreen.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.videocam,
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Tambahkan Video Resep (Opsional)',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        )
                            : Center(
                          child: Text(
                            _selectedVideo != null
                                ? 'Video Terpilih: ${_selectedVideo!.name}'
                                : (_initialVideoUrl != null ? 'Video Terpilih: ${_initialVideoUrl!.split('/').last}' : 'Tidak ada video'), // Tampilkan nama file lama
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      // Tombol Unggah/Hapus Video
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: _pickVideo,
                                child: Container(
                                  height: 35,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentTeal.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    (_selectedVideo == null && (_initialVideoUrl == null || _videoClearedByUser))
                                        ? 'Pilih Video'
                                        : 'Ganti Video',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Tampilkan tombol hapus hanya jika ada video yang bisa dihapus
                            if (_selectedVideo != null || (_initialVideoUrl != null && !_videoClearedByUser))
                              Expanded(
                                child: GestureDetector(
                                  onTap: _clearVideo,
                                  child: Container(
                                    height: 35,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    margin: const EdgeInsets.symmetric(horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentTeal.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'Hapus Video',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),


                      // Recipe Info Fields
                      _buildInfoField('Judul', 'Nama Resep', controller: _titleController),
                      _buildInfoField('Deskripsi', 'Deskripsi Resep', lighter: true, controller: _descriptionController),
                      _buildInfoField('Estimasi Waktu', 'Contoh: 1 Jam, 30 Menit', controller: _estimatedTimeController),
                      _buildInfoField('Harga', 'Contoh: 25000', controller: _priceController, keyboardType: TextInputType.number),

                      // Difficulty Dropdown
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 30.0, top: 16.0, bottom: 8.0),
                            child: Text(
                              'Tingkat Kesulitan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 30),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.accentTeal.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: _selectedDifficulty,
                                hint: const Text(
                                  'Pilih tingkat kesulitan memasak',
                                  style: TextStyle(color: Colors.black54),
                                ),
                                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedDifficulty = newValue;
                                  });
                                },
                                items: _difficultyLevels.map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Category Dropdown
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 30.0, top: 16.0, bottom: 8.0),
                            child: Text(
                              'Kategori Resep',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 30),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.accentTeal.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: _selectedCategory,
                                hint: const Text(
                                  'Pilih kategori resep',
                                  style: TextStyle(color: Colors.black54),
                                ),
                                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedCategory = newValue;
                                  });
                                },
                                items: _categories.map<DropdownMenuItem<String>>((Map<String, String> category) {
                                  return DropdownMenuItem<String>(
                                    value: category['name'],
                                    child: Text(category['name']!),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),


                      // Tools Section (Alat-Alat)
                      const Padding(
                        padding: EdgeInsets.only(left: 30.0, top: 24.0, bottom: 8.0),
                        child: Text(
                          'Alat-Alat',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _toolControllers.length,
                        itemBuilder: (context, index) {
                          return _buildToolItem(index, _toolControllers[index]);
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: GestureDetector(
                            onTap: _addToolField,
                            child: Container(
                              width: 200,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Center(
                                child: Text(
                                  '+ Tambahkan Alat',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Ingredients Section (Bahan-Bahan)
                      const Padding(
                        padding: EdgeInsets.only(left: 30.0, top: 16.0, bottom: 8.0),
                        child: Text(
                          'Bahan-Bahan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _ingredientControllers.length,
                        itemBuilder: (context, index) {
                          return _buildIngredientItem(
                            index,
                            _ingredientControllers[index]['quantity']!,
                            _ingredientControllers[index]['unit']!,
                            _ingredientControllers[index]['name']!,
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: GestureDetector(
                            onTap: _addIngredientField,
                            child: Container(
                              width: 200,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Center(
                                child: Text(
                                  '+ Tambahkan Bahan',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Instructions Section (Instruksi)
                      const Padding(
                        padding: EdgeInsets.only(left: 30.0, top: 16.0, bottom: 8.0),
                        child: Text(
                          'Instruksi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _instructionControllers.length,
                        itemBuilder: (context, index) {
                          return _buildInstructionItem(index, _instructionControllers[index]);
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: GestureDetector(
                            onTap: _addInstructionField,
                            child: Container(
                              width: 200,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Center(
                                child: Text(
                                  '+ Tambahkan Instruksi',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Tombol Simpan Perubahan
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submitEditedRecipe, // Panggil fungsi submitEditedRecipe
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Simpan Perubahan', // Ubah teks tombol
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 80),
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

  // Metode pembangun untuk field info (judul, deskripsi, dll.)
  Widget _buildInfoField(String label, String placeholder, {bool lighter = false, required TextEditingController controller, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 30.0, top: 16.0, bottom: 8.0),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 30),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          decoration: BoxDecoration(
            color: AppColors.accentTeal.withOpacity(0.5),
            borderRadius: BorderRadius.circular(24),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: const TextStyle(
                color: Colors.black54,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            maxLines: lighter ? null : 1,
          ),
        ),
      ],
    );
  }

  // Metode pembangun untuk item alat
  Widget _buildToolItem(int index, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              decoration: BoxDecoration(
                color: AppColors.accentTeal.withOpacity(0.5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Nama Alat ${index + 1}',
                  hintStyle: const TextStyle(color: Colors.black54),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.black),
            onPressed: () => _removeToolField(index),
          ),
        ],
      ),
    );
  }

  // Metode pembangun untuk item bahan
  Widget _buildIngredientItem(int index, TextEditingController quantityController, TextEditingController unitController, TextEditingController nameController) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
          const SizedBox(width: 2),
          SizedBox(
            width: 60, // Lebar untuk jumlah
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              decoration: BoxDecoration(
                color: AppColors.accentTeal.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Qty',
                  hintStyle: const TextStyle(color: Colors.black54, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80, // Lebar untuk unit
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              decoration: BoxDecoration(
                color: AppColors.accentTeal.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: unitController,
                decoration: InputDecoration(
                  hintText: 'Unit',
                  hintStyle: const TextStyle(color: Colors.black54, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              decoration: BoxDecoration(
                color: AppColors.accentTeal.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Nama Bahan ${index + 1}',
                  hintStyle: const TextStyle(color: Colors.black54),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete, color: Color.fromARGB(255, 4, 0, 0)),
            onPressed: () => _removeIngredientField(index),
          ),
        ],
      ),
    );
  }

  // Metode pembangun untuk item instruksi
  Widget _buildInstructionItem(int index, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              decoration: BoxDecoration(
                color: AppColors.accentTeal.withOpacity(0.5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Instruksi ${index + 1}',
                  hintStyle: const TextStyle(color: Colors.black54),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
                maxLines: null, // Instruksi bisa multi-baris
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.black),
            onPressed: () => _removeInstructionField(index),
          ),
        ],
      ),
    );
  }
}