import 'package:flutter/material.dart';
import '../../component/header_back.dart';
import '../../component/bottom_navbar.dart';
import 'dart:convert'; // Untuk encode/decode JSON
import 'package:http/http.dart' as http; // Untuk permintaan HTTP
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'dart:io'; // Untuk File (khusus platform non-web)
import 'package:flutter/foundation.dart' show kIsWeb; // Untuk cek apakah di web
import 'package:http_parser/http_parser.dart'; // Tambahkan ini untuk MediaType.parse

class AppColors {
  static const Color primaryColor = Color(0xFF005A4D);
  static const Color accentTeal = Color(0xFF57B4BA);
  static const Color emeraldGreen = Color(0xFF015551);
  static const Color lightTeal = Color(0xFF9FD5DB);
  static const Color bgColor = Color(0xFFF9F9F9);
}

class BuatResep extends StatefulWidget {
  const BuatResep({super.key});

  @override
  State<BuatResep> createState() => _BuatResepState();
}

class _BuatResepState extends State<BuatResep> {
  // Controllers untuk input teks
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _estimatedTimeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String? _selectedDifficulty;
  String? _selectedCategory;

  // Variabel untuk menyimpan file gambar dan video yang dipilih
  XFile? _selectedImage;
  XFile? _selectedVideo;

  // ImagePicker instance
  final ImagePicker _picker = ImagePicker();

  // Daftar tingkat kesulitan dan kategori (bisa diambil dari API nanti jika kategori dinamis)
  final List<String> _difficultyLevels = ['Mudah', 'Sedang', 'Sulit'];
  final List<Map<String, String>> _categories = [
    {'id': '1', 'name': 'Hidangan Utama'},
    {'id': '2', 'name': 'Sarapan'},
    {'id': '3', 'name': 'Makanan Ringan'},
    {'id': '4', 'name': 'Kue & Dessert'},
    {'id': '5', 'name': 'Minuman'},
  ];


  // Lists untuk input dinamis
  final List<TextEditingController> _toolControllers = [TextEditingController()];
  final List<Map<String, TextEditingController>> _ingredientControllers = [
    {'quantity': TextEditingController(), 'unit': TextEditingController(), 'name': TextEditingController()}
  ];
  final List<TextEditingController> _instructionControllers = [TextEditingController()];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _estimatedTimeController.dispose();
    _priceController.dispose();
    // Dispose semua controller dalam list
    for (var controller in _toolControllers) controller.dispose();
    for (var controllersMap in _ingredientControllers) {
      controllersMap['quantity']?.dispose();
      controllersMap['unit']?.dispose();
      controllersMap['name']?.dispose();
    }
    for (var controller in _instructionControllers) controller.dispose();
    super.dispose();
  }

  // --- Fungsi untuk menambah/menghapus field dinamis ---
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

  // --- Fungsi untuk memilih gambar dan video ---
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _selectedImage = image;
    });
  }

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    setState(() {
      _selectedVideo = video;
    });
  }

  void _clearVideo() {
    setState(() {
      _selectedVideo = null;
    });
  }

  // --- Fungsi untuk mengirim data resep ke backend ---
  Future<void> _submitRecipe() async {
    // Alamat IP backend Anda. PENTING: Sesuaikan ini!
    // Jika menjalankan di emulator Android, gunakan 'http://10.0.2.2:3000/recipes'.
    // Jika di iOS simulator/perangkat fisik, gunakan IP lokal Anda (misal: http://192.168.1.100:3000/recipes).
    // Jika di browser web (di komputer yang sama dengan backend), gunakan 'http://localhost:3000/recipes'.
    const String apiUrl = 'http://localhost:3000/recipes'; // Ubah sesuai kebutuhan Anda!

    const int dummyUserId = 1; // ID pengguna sementara, ganti dengan ID pengguna yang sebenarnya dari sesi login

    // Kumpulkan data teks dari controllers
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
        .where((map) => map['name']!.isNotEmpty && map['quantity']!.isNotEmpty && map['unit']!.isNotEmpty) // Pastikan semua bagian bahan terisi
        .toList();

    final List<String> instructions = _instructionControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    // Validasi input di frontend
    if (title.isEmpty ||
        description.isEmpty ||
        estimatedTime.isEmpty ||
        price.isEmpty ||
        difficulty.isEmpty ||
        categoryId == null ||
        tools.isEmpty ||
        ingredients.isEmpty ||
        instructions.isEmpty ||
        _selectedImage == null) { // Gambar wajib
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field (termasuk Gambar) harus diisi!')),
      );
      return;
    }

    // Buat MultipartRequest untuk mengirim file dan data teks
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

    // Tambahkan field teks. Perhatikan bahwa list/map akan di-encode ke JSON string
    request.fields['userId'] = dummyUserId.toString();
    request.fields['categoryId'] = categoryId;
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['estimatedTime'] = estimatedTime;
    request.fields['price'] = price;
    request.fields['difficulty'] = difficulty;
    request.fields['tools'] = json.encode(tools); // Encode list ke JSON string
    request.fields['ingredients'] = json.encode(ingredients); // Encode list map ke JSON string
    request.fields['instructions'] = json.encode(instructions); // Encode list ke JSON string

    // Tambahkan file gambar (wajib)
    if (_selectedImage != null) {
      // Dapatkan MIME type dari XFile.mimeType atau nama file
      final String? imageMimeType = _selectedImage!.mimeType;

      if (kIsWeb) {
        // Untuk web, baca file sebagai bytes
        final bytes = await _selectedImage!.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'image', // Nama field di backend (sesuai `upload.fields({name: 'image'})`)
          bytes,
          filename: _selectedImage!.name,
          contentType: imageMimeType != null ? MediaType.parse(imageMimeType) : null,
        ));
      } else {
        // Untuk platform non-web (mobile/desktop), gunakan fromPath
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _selectedImage!.path,
          filename: _selectedImage!.name,
          contentType: imageMimeType != null ? MediaType.parse(imageMimeType) : null,
        ));
      }
    }

    // Tambahkan file video (opsional)
    if (_selectedVideo != null) {
      final String? videoMimeType = _selectedVideo!.mimeType; // Dapatkan MIME type dari XFile

      if (kIsWeb) {
        // Untuk web, baca file sebagai bytes
        final bytes = await _selectedVideo!.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'video', // Nama field di backend (sesuai `upload.fields({name: 'video'})`)
          bytes,
          filename: _selectedVideo!.name,
          contentType: videoMimeType != null ? MediaType.parse(videoMimeType) : null,
        ));
      } else {
        // Untuk platform non-web, gunakan fromPath
        request.files.add(await http.MultipartFile.fromPath(
          'video',
          _selectedVideo!.path,
          filename: _selectedVideo!.name,
          contentType: videoMimeType != null ? MediaType.parse(videoMimeType) : null,
        ));
      }
    }

    try {
      var response = await request.send(); // Mengirim request
      var responseData = await response.stream.transform(utf8.decoder).join(); // Mengambil respons
      var jsonResponse = json.decode(responseData); // Mengurai respons JSON

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Resep berhasil ditambahkan! ID: ${jsonResponse['recipeId']}')),
        );
        // Reset form setelah berhasil
        _titleController.clear();
        _descriptionController.clear();
        _estimatedTimeController.clear();
        _priceController.clear();
        setState(() {
          _selectedDifficulty = null;
          _selectedCategory = null;
          _selectedImage = null; // Hapus gambar terpilih
          _selectedVideo = null; // Hapus video terpilih
          // Reset controller list
          _toolControllers.clear();
          _toolControllers.add(TextEditingController()); // Tambahkan satu field kosong
          _ingredientControllers.clear();
          _ingredientControllers.add({
            'quantity': TextEditingController(),
            'unit': TextEditingController(),
            'name': TextEditingController()
          });
          _instructionControllers.clear();
          _instructionControllers.add(TextEditingController());
        });
      } else {
        // Tangani error dari backend
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan resep: ${jsonResponse['message'] ?? 'Terjadi kesalahan tidak dikenal'}')),
        );
      }
    } catch (e) {
      // Tangani error jaringan atau parsing JSON
      print('Error submitting recipe: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan jaringan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavbar(
      Scaffold(
        backgroundColor: AppColors.bgColor,
        body: SafeArea(
          child: Column(
            children: [
              HeaderWidget(
                title: 'Buat Resep',
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
                          image: _selectedImage != null
                              ? kIsWeb // Cek jika di web
                              ? DecorationImage(
                            image: NetworkImage(_selectedImage!.path), // Untuk web, gunakan NetworkImage
                            fit: BoxFit.cover,
                          )
                              : DecorationImage(
                            image: FileImage(File(_selectedImage!.path)), // Untuk non-web, gunakan FileImage
                            fit: BoxFit.cover,
                          )
                              : null,
                        ),
                        child: _selectedImage == null
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
                                    _selectedImage == null ? 'Pilih Gambar' : 'Ganti Gambar',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (_selectedImage != null)
                              Expanded(
                                child: GestureDetector(
                                  onTap: () { setState(() { _selectedImage = null; }); },
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
                        child: _selectedVideo == null
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
                            'Video Terpilih: ${_selectedVideo!.name}',
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
                                    _selectedVideo == null ? 'Pilih Video' : 'Ganti Video',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (_selectedVideo != null)
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

                      // Tombol Simpan Resep
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submitRecipe,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Simpan Resep',
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