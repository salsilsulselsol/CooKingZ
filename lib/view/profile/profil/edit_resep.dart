// edit_resep.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

// Impor komponen dan model yang diperlukan
import '../../component/header_back.dart';
import '../../component/bottom_navbar.dart';
import '/../models/category_model.dart'; // Pastikan path ini benar

// Kelas statis untuk mendefinisikan palet warna yang konsisten.
class AppColors {
  static const Color primaryColor = Color(0xFF005A4D);
  static const Color accentTeal = Color(0xFF57B4BA);
  static const Color emeraldGreen = Color(0xFF015551);
  static const Color lightTeal = Color(0xFF9FD5DB);
  static const Color bgColor = Color(0xFFF9F9F9);
}

// `EditResep` adalah StatefulWidget untuk mengedit resep yang ada.
class EditResep extends StatefulWidget {
  final int recipeId; // ID resep yang akan diedit.

  const EditResep({super.key, required this.recipeId});

  @override
  State<EditResep> createState() => _EditResepState();
}

class _EditResepState extends State<EditResep> {
  // --- CONTROLLERS DAN STATE VARIABLES ---

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _estimatedTimeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String? _selectedDifficulty;
  String? _selectedCategory; // Menyimpan NAMA kategori yang dipilih.

  XFile? _selectedImage;
  XFile? _selectedVideo;

  // URL gambar & video awal dari backend untuk ditampilkan.
  String? _initialImageUrl;
  String? _initialVideoUrl;
  // Flag untuk melacak apakah pengguna secara eksplisit menghapus gambar/video.
  bool _imageClearedByUser = false;
  bool _videoClearedByUser = false;

  final ImagePicker _picker = ImagePicker();

  final List<String> _difficultyLevels = ['Mudah', 'Sedang', 'Sulit'];

  // Variabel untuk kategori dinamis dari API.
  List<Category> _fetchedCategories = [];

  // Lists untuk field input dinamis.
  final List<TextEditingController> _toolControllers = [];
  final List<Map<String, TextEditingController>> _ingredientControllers = [];
  final List<TextEditingController> _instructionControllers = [];

  // State untuk loading dan error.
  bool _isLoading = true;
  String _errorMessage = '';

  // --- LIFECYCLE METHODS ---

  @override
  void initState() {
    super.initState();
    // Memanggil fungsi untuk mengambil semua data awal (detail resep dan kategori).
    _fetchInitialData();
  }

  @override
  void dispose() {
    // Pastikan semua controller dilepaskan untuk mencegah memory leak.
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

  // --- FUNGSI PENGAMBILAN DATA ---

  // Fungsi untuk mengambil detail resep yang ada dari server.
  Future<Map<String, dynamic>> _fetchRecipeDetails() async {
    // Sesuaikan URL berdasarkan platform jika diperlukan
    final String apiUrl = 'http://localhost:3000/recipes/${widget.recipeId}';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal memuat detail resep: ${response.statusCode}');
    }
  }

  // Fungsi untuk mengambil daftar kategori dari server.
  Future<List<Category>> _fetchCategories() async {
    const String apiUrl = 'http://localhost:3000/categories';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat kategori: ${response.statusCode}');
    }
  }

  // Fungsi utama untuk mengambil semua data awal secara bersamaan.
  Future<void> _fetchInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      // Menjalankan kedua proses fetch secara paralel untuk efisiensi.
      final results = await Future.wait([
        _fetchRecipeDetails(),
        _fetchCategories(),
      ]);

      final Map<String, dynamic> recipeData = results[0] as Map<String, dynamic>;
      final List<Category> categories = results[1] as List<Category>;

      // --- POPULATE STATE DENGAN DATA YANG DIDAPAT (DENGAN KEY YANG SUDAH DIPERBAIKI) ---
      _fetchedCategories = categories;

      _titleController.text = recipeData['title'] ?? '';
      _descriptionController.text = recipeData['description'] ?? '';

      // PERBAIKAN 1: Gunakan key 'cooking_time' dari backend
      _estimatedTimeController.text = (recipeData['cooking_time'] ?? '0').toString();

      _priceController.text = (recipeData['price'] ?? 0).toString();
      _selectedDifficulty = recipeData['difficulty'];

      // PERBAIKAN 2: Gunakan key 'category_id' dari backend
      final int categoryIdFromServer = recipeData['category_id'] ?? -1;
      _selectedCategory = categories
          .firstWhere((cat) => cat.id == categoryIdFromServer, orElse: () => Category(id: -1, name: ''))
          .name;
      if(_selectedCategory!.isEmpty) _selectedCategory = null;


      // PERBAIKAN 3: Gunakan key 'image_url' dari backend
      _initialImageUrl = recipeData['image_url'];

      // PERBAIKAN 4: Gunakan key 'video_url' dari backend
      _initialVideoUrl = recipeData['video_url'];

      // Mengisi controllers untuk tools, ingredients, dan instructions.
      // (Bagian ini sudah benar karena backend mengirim 'tools', 'ingredients', 'instructions')
      final List<dynamic> tools = recipeData['tools'] ?? [];
      _toolControllers.clear();
      for (var toolName in tools) {
        _toolControllers.add(TextEditingController(text: toolName.toString()));
      }
      if (_toolControllers.isEmpty) _toolControllers.add(TextEditingController());

      final List<dynamic> ingredients = recipeData['ingredients'] ?? [];
      _ingredientControllers.clear();
      for (var ingredient in ingredients) {
        _ingredientControllers.add({
          'quantity': TextEditingController(text: ingredient['quantity']?.toString() ?? ''),
          'unit': TextEditingController(text: ingredient['unit']?.toString() ?? ''),
          'name': TextEditingController(text: ingredient['name']?.toString() ?? ''),
        });
      }
      if (_ingredientControllers.isEmpty) {
        _ingredientControllers.add({'quantity': TextEditingController(), 'unit': TextEditingController(), 'name': TextEditingController()});
      }

      final List<dynamic> instructions = recipeData['instructions'] ?? [];
      _instructionControllers.clear();
      for (var instructionText in instructions) {
        _instructionControllers.add(TextEditingController(text: instructionText.toString()));
      }
      if (_instructionControllers.isEmpty) _instructionControllers.add(TextEditingController());

    } catch (e) {
      // Tangani error jika salah satu proses fetch gagal.
      _errorMessage = 'Terjadi kesalahan saat memuat data: $e';
    } finally {
      // Pastikan loading dihentikan setelah semua proses selesai.
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  // --- FUNGSI UNTUK MENGELOLA FIELD DINAMIS (ADD/REMOVE) ---
  void _addToolField() => setState(() => _toolControllers.add(TextEditingController()));
  void _removeToolField(int index) {
    setState(() {
      _toolControllers[index].dispose();
      _toolControllers.removeAt(index);
    });
  }

  void _addIngredientField() => setState(() => _ingredientControllers.add({
    'quantity': TextEditingController(),
    'unit': TextEditingController(),
    'name': TextEditingController(),
  }));
  void _removeIngredientField(int index) {
    setState(() {
      _ingredientControllers[index]['quantity']?.dispose();
      _ingredientControllers[index]['unit']?.dispose();
      _ingredientControllers[index]['name']?.dispose();
      _ingredientControllers.removeAt(index);
    });
  }

  void _addInstructionField() => setState(() => _instructionControllers.add(TextEditingController()));
  void _removeInstructionField(int index) {
    setState(() {
      _instructionControllers[index].dispose();
      _instructionControllers.removeAt(index);
    });
  }

  // --- FUNGSI UNTUK MEMILIH GAMBAR DAN VIDEO ---
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _imageClearedByUser = false;
      });
    }
  }

  void _clearImage() {
    setState(() {
      _selectedImage = null;
      _imageClearedByUser = true;
    });
  }

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _selectedVideo = video;
        _videoClearedByUser = false;
      });
    }
  }

  void _clearVideo() {
    setState(() {
      _selectedVideo = null;
      _videoClearedByUser = true;
    });
  }

  // --- FUNGSI UTAMA: MENGIRIM PERUBAHAN KE BACKEND ---
  Future<void> _submitEditedRecipe() async {
    final String apiUrl = 'http://localhost:3000/recipes/${widget.recipeId}';

    final String title = _titleController.text.trim();
    final String description = _descriptionController.text.trim();
    final String estimatedTime = _estimatedTimeController.text.trim();
    final String price = _priceController.text.trim();
    final String difficulty = _selectedDifficulty ?? '';

    final int? categoryIdAsInt = _selectedCategory != null
        ? _fetchedCategories.firstWhere((cat) => cat.name == _selectedCategory, orElse: () => Category(id: -1, name: '')).id
        : null;
    final String? categoryId = (categoryIdAsInt != null && categoryIdAsInt != -1) ? categoryIdAsInt.toString() : null;

    final List<String> tools = _toolControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
    final List<Map<String, String>> ingredients = _ingredientControllers
        .map((map) => {
      'quantity': map['quantity']?.text.trim() ?? '',
      'unit': map['unit']?.text.trim() ?? '',
      'name': map['name']?.text.trim() ?? '',
    })
        .where((map) => map['name']!.isNotEmpty && map['quantity']!.isNotEmpty && map['unit']!.isNotEmpty)
        .toList();
    final List<String> instructions = _instructionControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();

    bool isImageMissing = _selectedImage == null && (_initialImageUrl == null || _initialImageUrl!.isEmpty) && _imageClearedByUser;
    if (title.isEmpty || description.isEmpty || estimatedTime.isEmpty || price.isEmpty || difficulty.isEmpty || categoryId == null || tools.isEmpty || ingredients.isEmpty || instructions.isEmpty || isImageMissing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field (termasuk Gambar) harus diisi!')),
      );
      return;
    }

    var request = http.MultipartRequest('PUT', Uri.parse(apiUrl));

    request.fields['categoryId'] = categoryId;
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['estimatedTime'] = estimatedTime;
    request.fields['price'] = price;
    request.fields['difficulty'] = difficulty;
    request.fields['tools'] = json.encode(tools);
    request.fields['ingredients'] = json.encode(ingredients);
    request.fields['instructions'] = json.encode(instructions);

    request.fields['image_cleared'] = _imageClearedByUser.toString();
    request.fields['video_cleared'] = _videoClearedByUser.toString();


    if (_selectedImage != null) {
      final String? imageMimeType = _selectedImage!.mimeType;
      if (kIsWeb) {
        final bytes = await _selectedImage!.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'image', bytes, filename: _selectedImage!.name,
          contentType: imageMimeType != null ? MediaType.parse(imageMimeType) : null,
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'image', _selectedImage!.path, filename: _selectedImage!.name,
          contentType: imageMimeType != null ? MediaType.parse(imageMimeType) : null,
        ));
      }
    }

    if (_selectedVideo != null) {
      final String? videoMimeType = _selectedVideo!.mimeType;
      if (kIsWeb) {
        final bytes = await _selectedVideo!.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'video', bytes, filename: _selectedVideo!.name,
          contentType: videoMimeType != null ? MediaType.parse(videoMimeType) : null,
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'video', _selectedVideo!.path, filename: _selectedVideo!.name,
          contentType: videoMimeType != null ? MediaType.parse(videoMimeType) : null,
        ));
      }
    }

    try {
      var response = await request.send();
      var responseData = await response.stream.transform(utf8.decoder).join();
      var jsonResponse = json.decode(responseData);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resep berhasil diperbarui!')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui resep: ${jsonResponse['message'] ?? 'Kesalahan tidak dikenal'}')),
        );
      }
    } catch (e) {
      print('Error submitting edited recipe: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan jaringan: $e')),
      );
    }
  }


  // --- UI BUILDING METHOD ---

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.bgColor,
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
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
                title: 'Edit Resep',
                onBackPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.lightTeal.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                          image: _buildImageProvider(),
                        ),
                        child: _buildImagePlaceholder(),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  height: 35,
                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(color: AppColors.accentTeal.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
                                  alignment: Alignment.center,
                                  child: Text(
                                    (_selectedImage == null && (_initialImageUrl == null || _imageClearedByUser)) ? 'Pilih Gambar' : 'Ganti Gambar',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14),
                                  ),
                                ),
                              ),
                            ),
                            if (_selectedImage != null || (_initialImageUrl != null && !_imageClearedByUser))
                              Expanded(
                                child: GestureDetector(
                                  onTap: _clearImage,
                                  child: Container(
                                    height: 35,
                                    margin: const EdgeInsets.symmetric(horizontal: 8),
                                    decoration: BoxDecoration(color: AppColors.accentTeal.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
                                    alignment: Alignment.center,
                                    child: const Text('Hapus Gambar', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14)),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.lightTeal.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: _buildVideoPlaceholder(),
                      ),

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
                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(color: AppColors.accentTeal.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
                                  alignment: Alignment.center,
                                  child: Text(
                                    (_selectedVideo == null && (_initialVideoUrl == null || _videoClearedByUser)) ? 'Pilih Video' : 'Ganti Video',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14),
                                  ),
                                ),
                              ),
                            ),
                            if (_selectedVideo != null || (_initialVideoUrl != null && !_videoClearedByUser))
                              Expanded(
                                child: GestureDetector(
                                  onTap: _clearVideo,
                                  child: Container(
                                    height: 35,
                                    margin: const EdgeInsets.symmetric(horizontal: 8),
                                    decoration: BoxDecoration(color: AppColors.accentTeal.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
                                    alignment: Alignment.center,
                                    child: const Text('Hapus Video', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14)),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      _buildInfoField('Judul', 'Nama Resep', controller: _titleController),
                      _buildInfoField('Deskripsi', 'Deskripsi Resep', lighter: true, controller: _descriptionController),
                      _buildInfoField('Estimasi Waktu (menit)', '45', controller: _estimatedTimeController, keyboardType: TextInputType.number),
                      _buildInfoField('Harga', '25000', controller: _priceController, keyboardType: TextInputType.number),

                      _buildDifficultyDropdown(),

                      _buildCategoryDropdown(),

                      _buildDynamicSection('Alat-Alat', _toolControllers, _buildToolItem, _addToolField),

                      _buildDynamicSection('Bahan-Bahan', _ingredientControllers, _buildIngredientItem, _addIngredientField),

                      _buildDynamicSection('Instruksi', _instructionControllers, _buildInstructionItem, _addInstructionField),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submitEditedRecipe,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text(
                              'Simpan Perubahan',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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

  // --- METODE PEMBANTU UNTUK MEMBANGUN UI ---

  DecorationImage? _buildImageProvider() {
    if (_selectedImage != null) {
      return DecorationImage(
        image: kIsWeb ? NetworkImage(_selectedImage!.path) : FileImage(File(_selectedImage!.path)) as ImageProvider,
        fit: BoxFit.cover,
      );
    }
    if (_initialImageUrl != null && _initialImageUrl!.isNotEmpty && !_imageClearedByUser) {
      final imageUrl = _initialImageUrl!.startsWith('http') ? _initialImageUrl! : 'http://localhost:3000$_initialImageUrl';
      return DecorationImage(
        image: NetworkImage(imageUrl),
        fit: BoxFit.cover,
      );
    }
    return null;
  }

  Widget? _buildImagePlaceholder() {
    if (_selectedImage == null && (_initialImageUrl == null || _initialImageUrl!.isEmpty || _imageClearedByUser)) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(color: AppColors.emeraldGreen.withOpacity(0.5), shape: BoxShape.circle),
            child: const Icon(Icons.camera_alt, size: 36, color: Colors.white),
          ),
          const SizedBox(height: 12),
          const Text('Tambahkan Gambar Resep (Wajib)', style: TextStyle(color: Colors.black54, fontSize: 16)),
        ],
      );
    }
    return null;
  }

  Widget _buildVideoPlaceholder() {
    if (_selectedVideo == null && (_initialVideoUrl == null || _initialVideoUrl!.isEmpty || _videoClearedByUser)) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: AppColors.emeraldGreen.withOpacity(0.5), shape: BoxShape.circle),
            child: const Icon(Icons.videocam, size: 24, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text('Tambahkan Video Resep (Opsional)', style: TextStyle(color: Colors.black54, fontSize: 14)),
        ],
      );
    }
    return Center(
      child: Text(
        _selectedVideo != null
            ? 'Video Terpilih: ${_selectedVideo!.name}'
            : 'Video Terpilih: ${_initialVideoUrl!.split('/').last}',
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoField(String label, String placeholder, {bool lighter = false, required TextEditingController controller, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 30.0, top: 16.0, bottom: 8.0),
          child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
              hintStyle: const TextStyle(color: Colors.black54),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            maxLines: lighter ? null : 1,
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 30.0, top: 16.0, bottom: 8.0),
          child: Text('Tingkat Kesulitan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: AppColors.accentTeal.withOpacity(0.5), borderRadius: BorderRadius.circular(24)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedDifficulty,
              hint: const Text('Pilih tingkat kesulitan', style: TextStyle(color: Colors.black54)),
              onChanged: (String? newValue) => setState(() => _selectedDifficulty = newValue),
              items: _difficultyLevels.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 30.0, top: 16.0, bottom: 8.0),
          child: Text('Kategori Resep', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: AppColors.accentTeal.withOpacity(0.5), borderRadius: BorderRadius.circular(24)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedCategory,
              hint: const Text('Pilih kategori resep', style: TextStyle(color: Colors.black54)),
              onChanged: (String? newValue) => setState(() => _selectedCategory = newValue),
              items: _fetchedCategories.map<DropdownMenuItem<String>>((Category category) {
                return DropdownMenuItem<String>(
                  value: category.name,
                  child: Text(category.name),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicSection(String title, List<dynamic> controllers, Function itemBuilder, VoidCallback onAdd) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 30.0, top: 24.0, bottom: 8.0),
          child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controllers.length,
          itemBuilder: (context, index) {
            if (title == 'Bahan-Bahan') {
              final item = controllers[index] as Map<String, TextEditingController>;
              return _buildIngredientItem(index, item['quantity']!, item['unit']!, item['name']!);
            } else {
              return itemBuilder(index, controllers[index]);
            }
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: GestureDetector(
              onTap: onAdd,
              child: Container(
                width: 200,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(24)),
                child: Center(
                  child: Text('+ Tambahkan ${title.split('-').first}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToolItem(int index, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.more_vert, color: Colors.black), onPressed: () {}),
          const SizedBox(width: 2),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              decoration: BoxDecoration(color: AppColors.accentTeal.withOpacity(0.5), borderRadius: BorderRadius.circular(24)),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Nama Alat ${index + 1}',
                  hintStyle: const TextStyle(color: Colors.black54),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.delete, color: Colors.black), onPressed: () => _removeToolField(index)),
        ],
      ),
    );
  }

  Widget _buildIngredientItem(int index, TextEditingController quantityController, TextEditingController unitController, TextEditingController nameController) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.more_vert, color: Colors.black), onPressed: () {}),
          SizedBox(
            width: 60,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              decoration: BoxDecoration(color: AppColors.accentTeal.withOpacity(0.5), borderRadius: BorderRadius.circular(16)),
              child: TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Qty', border: InputBorder.none, hintStyle: TextStyle(color: Colors.black54, fontSize: 14)),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              decoration: BoxDecoration(color: AppColors.accentTeal.withOpacity(0.5), borderRadius: BorderRadius.circular(16)),
              child: TextField(
                controller: unitController,
                decoration: const InputDecoration(hintText: 'Unit', border: InputBorder.none, hintStyle: TextStyle(color: Colors.black54, fontSize: 14)),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              decoration: BoxDecoration(color: AppColors.accentTeal.withOpacity(0.5), borderRadius: BorderRadius.circular(16)),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(hintText: 'Nama Bahan ${index + 1}', border: InputBorder.none, hintStyle: const TextStyle(color: Colors.black54)),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.delete, color: Colors.black), onPressed: () => _removeIngredientField(index)),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(int index, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.more_vert, color: Colors.black), onPressed: () {}),
          const SizedBox(width: 2),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              decoration: BoxDecoration(color: AppColors.accentTeal.withOpacity(0.5), borderRadius: BorderRadius.circular(24)),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Instruksi ${index + 1}',
                  hintStyle: const TextStyle(color: Colors.black54),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.black, fontSize: 16),
                maxLines: null,
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.delete, color: Colors.black), onPressed: () => _removeInstructionField(index)),
        ],
      ),
    );
  }
}