import 'package:flutter/material.dart';
// Mengimpor dua komponen kustom dari direktori lain dalam proyek.
import '../../component/header_back.dart';
import '../../component/bottom_navbar.dart';
import 'dart:convert'; // Diperlukan untuk mengubah objek Dart (seperti List dan Map) menjadi string JSON (encode) dan sebaliknya (decode).
import 'package:http/http.dart' as http; // Paket untuk membuat permintaan HTTP (GET, POST, dll.) ke server/backend.
import 'package:image_picker/image_picker.dart'; // Paket untuk memilih gambar atau video dari galeri atau kamera perangkat.
import 'dart:io'; // Diperlukan untuk menggunakan objek 'File', yang merepresentasikan file dalam sistem file perangkat (khusus untuk platform mobile/desktop, bukan web).
import 'package:flutter/foundation.dart' show kIsWeb; // Sebuah konstanta boolean (`kIsWeb`) untuk memeriksa apakah aplikasi sedang berjalan di platform web.
import 'package:http_parser/http_parser.dart'; // Diperlukan untuk membuat objek `MediaType` yang mendefinisikan tipe MIME dari file yang diunggah (misalnya, 'image/jpeg').
import '/../models/category_model.dart';

// Kelas statis untuk mendefinisikan palet warna yang konsisten di seluruh aplikasi.
class AppColors {
  static const Color primaryColor = Color(0xFF005A4D);
  static const Color accentTeal = Color(0xFF57B4BA);
  static const Color emeraldGreen = Color(0xFF015551);
  static const Color lightTeal = Color(0xFF9FD5DB);
  static const Color bgColor = Color(0xFFF9F9F9);
}

// `BuatResep` adalah StatefulWidget, yang berarti UI-nya dapat berubah berdasarkan interaksi pengguna atau data yang masuk.
class BuatResep extends StatefulWidget {
  const BuatResep({super.key});

  @override
  // Membuat dan mengembalikan state untuk widget ini.
  State<BuatResep> createState() => _BuatResepState();
}

// `_BuatResepState` adalah kelas State yang berisi semua logika dan state (data) untuk widget `BuatResep`.
class _BuatResepState extends State<BuatResep> {
  // --- CONTROLLERS DAN STATE VARIABLES ---

  @override
  void initState() {
    super.initState();
    // Panggil fungsi untuk mengambil data kategori saat widget pertama kali dibuat.
    _fetchCategories();
  }

// --- FUNGSI BARU UNTUK MENGAMBIL KATEGORI DARI API ---
  Future<void> _fetchCategories() async {
    const String apiUrl = 'http://localhost:3000/categories';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Jika request berhasil (200 OK)
        final List<dynamic> data = json.decode(response.body);
        // Ubah setiap item JSON menjadi objek Category menggunakan factory constructor
        final List<Category> categories = data.map((json) => Category.fromJson(json)).toList();

        // Perbarui state dengan data yang sudah didapat
        setState(() {
          _fetchedCategories = categories;
          _isLoadingCategories = false; // Loading selesai
        });
      } else {
        // Jika server mengembalikan error
        setState(() {
          _isLoadingCategories = false; // Loading selesai (dengan error)
        });
        // Tampilkan pesan error di konsol atau dengan SnackBar
        print('Gagal memuat kategori: ${response.statusCode}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal memuat kategori dari server.')),
          );
        }
      }
    } catch (e) {
      // Jika terjadi error jaringan atau lainnya
      setState(() {
        _isLoadingCategories = false; // Loading selesai (dengan error)
      });
      print('Terjadi kesalahan saat mengambil kategori: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan jaringan: $e')),
        );
      }
    }
  }

  // Controllers untuk field input teks. `TextEditingController` digunakan untuk mengelola teks dalam `TextField`.
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _estimatedTimeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  // Variabel untuk menyimpan nilai yang dipilih dari dropdown.
  String? _selectedDifficulty; // Menyimpan tingkat kesulitan yang dipilih, null jika belum dipilih.
  String? _selectedCategory;   // Menyimpan nama kategori yang dipilih, null jika belum dipilih.

  // Variabel untuk menyimpan file media yang dipilih oleh pengguna. `XFile` adalah objek dari `image_picker`.
  XFile? _selectedImage;
  XFile? _selectedVideo;

  // Instance dari `ImagePicker` untuk mengakses fungsionalitas pemilihan gambar/video.
  final ImagePicker _picker = ImagePicker();

  // Daftar statis untuk dropdown. Dalam aplikasi nyata, ini bisa diambil dari API.
  final List<String> _difficultyLevels = ['Mudah', 'Sedang', 'Sulit'];

  List<Category> _fetchedCategories = [];
  // Variabel untuk menandai status loading
  bool _isLoadingCategories = true;


  // Lists untuk field input dinamis. Setiap field akan memiliki controllernya sendiri.
  // Ini memungkinkan pengguna untuk menambah atau mengurangi jumlah field sesuai kebutuhan.
  final List<TextEditingController> _toolControllers = [TextEditingController()]; // Dimulai dengan satu field alat.
  final List<Map<String, TextEditingController>> _ingredientControllers = [ // Dimulai dengan satu field bahan.
    {'quantity': TextEditingController(), 'unit': TextEditingController(), 'name': TextEditingController()}
  ];
  final List<TextEditingController> _instructionControllers = [TextEditingController()]; // Dimulai dengan satu field instruksi.

  // --- LIFECYCLE METHOD ---

  @override
  void dispose() {
    // Metode ini dipanggil ketika widget dihapus dari pohon widget (misalnya, saat halaman ditutup).
    // Sangat penting untuk melepaskan (dispose) semua controller untuk mencegah kebocoran memori (memory leaks).
    _titleController.dispose();
    _descriptionController.dispose();
    _estimatedTimeController.dispose();
    _priceController.dispose();

    // Melepaskan semua controller dalam list dinamis.
    for (var controller in _toolControllers) controller.dispose();
    for (var controllersMap in _ingredientControllers) {
      controllersMap['quantity']?.dispose();
      controllersMap['unit']?.dispose();
      controllersMap['name']?.dispose();
    }
    for (var controller in _instructionControllers) controller.dispose();

    super.dispose(); // Memanggil metode dispose dari kelas induk.
  }

  // --- FUNGSI UNTUK MENGELOLA FIELD DINAMIS ---
  // Fungsi-fungsi ini memanipulasi list controller dan memanggil `setState`
  // untuk memberi tahu Flutter agar membangun ulang UI dengan perubahan tersebut.

  // Menambahkan satu field input alat baru.
  void _addToolField() {
    setState(() {
      _toolControllers.add(TextEditingController());
    });
  }

  // Menghapus field input alat pada indeks tertentu.
  void _removeToolField(int index) {
    setState(() {
      _toolControllers[index].dispose(); // Lepaskan controller sebelum menghapusnya dari list.
      _toolControllers.removeAt(index);
    });
  }

  // Menambahkan satu set field input bahan baru.
  void _addIngredientField() {
    setState(() {
      _ingredientControllers.add({
        'quantity': TextEditingController(),
        'unit': TextEditingController(),
        'name': TextEditingController(),
      });
    });
  }

  // Menghapus satu set field input bahan pada indeks tertentu.
  void _removeIngredientField(int index) {
    setState(() {
      // Lepaskan semua controller dalam map sebelum menghapus dari list.
      _ingredientControllers[index]['quantity']?.dispose();
      _ingredientControllers[index]['unit']?.dispose();
      _ingredientControllers[index]['name']?.dispose();
      _ingredientControllers.removeAt(index);
    });
  }

  // Menambahkan satu field input instruksi baru.
  void _addInstructionField() {
    setState(() {
      _instructionControllers.add(TextEditingController());
    });
  }

  // Menghapus field input instruksi pada indeks tertentu.
  void _removeInstructionField(int index) {
    setState(() {
      _instructionControllers[index].dispose(); // Lepaskan controller.
      _instructionControllers.removeAt(index);
    });
  }

  // --- FUNGSI UNTUK MEMILIH GAMBAR DAN VIDEO ---

  // Membuka galeri untuk memilih gambar.
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    // Jika pengguna memilih gambar (image != null), perbarui state.
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  // Membuka galeri untuk memilih video.
  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    // Jika pengguna memilih video (video != null), perbarui state.
    if (video != null) {
      setState(() {
        _selectedVideo = video;
      });
    }
  }

  // Menghapus video yang telah dipilih.
  void _clearVideo() {
    setState(() {
      _selectedVideo = null;
    });
  }

  // --- FUNGSI UTAMA: MENGIRIM DATA RESEP KE BACKEND ---
  Future<void> _submitRecipe() async {
    // URL endpoint API di backend untuk membuat resep baru.
    // PENTING: URL ini harus disesuaikan dengan lingkungan pengembangan Anda.
    const String apiUrl = 'http://localhost:3000/recipes'; // Contoh untuk web di mesin yang sama.

    // ID pengguna sementara. Dalam aplikasi nyata, ini harus didapat dari state login/autentikasi.
    const int dummyUserId = 1;

    // 1. MENGUMPULKAN DAN MEMBERSIHKAN DATA TEKS
    // Mengambil teks dari controller dan `.trim()` untuk menghapus spasi di awal/akhir.
    final String title = _titleController.text.trim();
    final String description = _descriptionController.text.trim();
    final String estimatedTime = _estimatedTimeController.text.trim();
    final String price = _priceController.text.trim();
    final String difficulty = _selectedDifficulty ?? ''; // Gunakan string kosong jika null.

    // Mencari ID kategori berdasarkan nama kategori yang dipilih.
    // Mencari ID kategori berdasarkan nama kategori yang dipilih dari list dinamis.
    final int? categoryIdAsInt = _selectedCategory != null
        ? _fetchedCategories.firstWhere((cat) => cat.name == _selectedCategory, orElse: () => Category(id: -1, name: '')).id
        : null;

    // Ubah ID menjadi String. Pastikan tidak mengirim ID -1 jika tidak ditemukan.
    final String? categoryId = (categoryIdAsInt != null && categoryIdAsInt != -1) ? categoryIdAsInt.toString() : null;

    // 2. MENGUMPULKAN DAN MENGUBAH DATA DARI LIST DINAMIS
    // Mengubah list `TextEditingController` menjadi list `String` untuk alat.
    final List<String> tools = _toolControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty) // Hanya ambil yang tidak kosong.
        .toList();

    // Mengubah list map controller bahan menjadi list map string.
    final List<Map<String, String>> ingredients = _ingredientControllers
        .map((map) => {
      'quantity': map['quantity']?.text.trim() ?? '',
      'unit': map['unit']?.text.trim() ?? '',
      'name': map['name']?.text.trim() ?? '',
    })
        .where((map) => map['name']!.isNotEmpty && map['quantity']!.isNotEmpty && map['unit']!.isNotEmpty) // Pastikan semua field bahan terisi.
        .toList();

    // Mengubah list controller instruksi menjadi list string.
    final List<String> instructions = _instructionControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty) // Hanya ambil yang tidak kosong.
        .toList();

    // 3. VALIDASI INPUT DI FRONTEND
    // Memeriksa apakah semua field yang wajib diisi sudah terisi sebelum mengirim ke server.
    if (title.isEmpty ||
        description.isEmpty ||
        estimatedTime.isEmpty ||
        price.isEmpty ||
        difficulty.isEmpty ||
        categoryId == null ||
        tools.isEmpty ||
        ingredients.isEmpty ||
        instructions.isEmpty ||
        _selectedImage == null) { // Gambar wajib ada.
      // Jika ada yang kosong, tampilkan pesan error menggunakan SnackBar.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field (termasuk Gambar) harus diisi!')),
      );
      print('VALIDATION FAILED: Some required fields are empty.');
      print('Title: $title');
      print('Description: $description');
      print('Estimated Time: $estimatedTime');
      print('Price: $price');
      print('Difficulty: $difficulty');
      print('Category ID: $categoryId');
      print('Tools: $tools (isEmpty: ${tools.isEmpty})');
      print('Ingredients: $ingredients (isEmpty: ${ingredients.isEmpty})');
      print('Instructions: $instructions (isEmpty: ${instructions.isEmpty})');
      print('Selected Image: ${_selectedImage != null}');
      return; // Hentikan eksekusi fungsi.
    }

    // 4. MEMBUAT PERMINTAAN MULTIPART
    // `MultipartRequest` digunakan karena kita akan mengirim data formulir (teks) dan file (gambar/video) secara bersamaan.
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

    // 5. MENAMBAHKAN FIELD TEKS KE REQUEST
    // Data List dan Map harus diubah menjadi string JSON menggunakan `json.encode` agar bisa dikirim.
    request.fields['userId'] = dummyUserId.toString();
    request.fields['categoryId'] = categoryId;
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['estimatedTime'] = estimatedTime;
    request.fields['price'] = price;
    request.fields['difficulty'] = difficulty;
    request.fields['tools'] = json.encode(tools);
    request.fields['ingredients'] = json.encode(ingredients);
    request.fields['instructions'] = json.encode(instructions);

    // --- DEBUGGING: PRINT THE FIELDS BEING SENT ---
    print('--- Sending Request Fields ---');
    request.fields.forEach((key, value) {
      print('$key: $value');
    });
    print('----------------------------');

    // 6. MENAMBAHKAN FILE GAMBAR (WAJIB)
    // `kIsWeb` digunakan untuk membedakan logika penanganan file untuk web dan mobile.
    if (_selectedImage != null) {
      final String? imageMimeType = _selectedImage!.mimeType;
      print('Image MIME Type: $imageMimeType');
      print('Selected Image Name: ${_selectedImage!.name}');

      if (kIsWeb) {
        // Untuk web: file dibaca sebagai byte array (`Uint8List`).
        final bytes = await _selectedImage!.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'image', // Nama field ini harus sesuai dengan yang diharapkan oleh backend (misal: di multer, `upload.single('image')`).
          bytes,
          filename: _selectedImage!.name,
          contentType: imageMimeType != null ? MediaType.parse(imageMimeType) : null,
        ));
        print('Image added for web (bytes). Size: ${bytes.length} bytes');
      } else {
        // Untuk mobile/desktop: file ditambahkan menggunakan path-nya.
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _selectedImage!.path,
          filename: _selectedImage!.name,
          contentType: imageMimeType != null ? MediaType.parse(imageMimeType) : null,
        ));
        print('Image added for mobile (path): ${_selectedImage!.path}');
      }
    } else {
      print('No image selected, this should have been caught by validation.');
    }


    // 7. MENAMBAHKAN FILE VIDEO (OPSIONAL)
    if (_selectedVideo != null) {
      final String? videoMimeType = _selectedVideo!.mimeType;
      print('Video MIME Type: $videoMimeType');
      print('Selected Video Name: ${_selectedVideo!.name}');
      if (kIsWeb) {
        final bytes = await _selectedVideo!.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'video', // Nama field untuk video.
          bytes,
          filename: _selectedVideo!.name,
          contentType: videoMimeType != null ? MediaType.parse(videoMimeType) : null,
        ));
        print('Video added for web (bytes). Size: ${bytes.length} bytes');
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'video',
          _selectedVideo!.path,
          filename: _selectedVideo!.name,
          contentType: videoMimeType != null ? MediaType.parse(videoMimeType) : null,
        ));
        print('Video added for mobile (path): ${_selectedVideo!.path}');
      }
    } else {
      print('No video selected (optional).');
    }

    // 8. MENGIRIM REQUEST DAN MENANGANI RESPON
    try {
      print('Sending request to: ${request.url}');
      var response = await request.send(); // Mengirim request ke server.
      var responseData = await response.stream.transform(utf8.decoder).join(); // Membaca data respons.

      print('--- Server Response ---');
      print('Status Code: ${response.statusCode}');
      print('Response Data: $responseData');
      print('-----------------------');

      // Memeriksa status code dari respons. 201 (Created) menandakan sukses.
      if (response.statusCode == 201) {
        var jsonResponse = json.decode(responseData); // Mengurai respons JSON dari server.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Resep berhasil ditambahkan! ID: ${jsonResponse['recipeId']}')),
        );
        // Jika berhasil, reset semua field di form.
        _titleController.clear();
        _descriptionController.clear();
        _estimatedTimeController.clear();
        _priceController.clear();
        setState(() {
          _selectedDifficulty = null;
          _selectedCategory = null;
          _selectedImage = null;
          _selectedVideo = null;
          // Reset list controller dinamis dan tambahkan satu field kosong kembali.
          _toolControllers.clear();
          _toolControllers.add(TextEditingController());
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
        // Jika gagal, tampilkan pesan error dari server.
        var jsonResponse = json.decode(responseData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan resep: ${jsonResponse['message'] ?? 'Terjadi kesalahan tidak dikenal'}')),
        );
      }
    } catch (e) {
      // Menangani error jika terjadi masalah jaringan atau saat parsing JSON.
      print('Error submitting recipe: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan jaringan: $e')),
      );
    }
  }

  // --- UI BUILDING METHOD ---

  @override
  Widget build(BuildContext context) {
    // `BottomNavbar` adalah wrapper kustom, kemungkinan untuk menampilkan navigasi bawah.
    return BottomNavbar(
      Scaffold(
        backgroundColor: AppColors.bgColor,
        body: SafeArea( // Memastikan konten tidak tumpang tindih dengan status bar atau notch.
          child: Column(
            children: [
              // Widget header kustom dengan judul dan tombol kembali.
              HeaderWidget(
                title: 'Buat Resep',
                onBackPressed: () {
                  Navigator.pop(context); // Kembali ke halaman sebelumnya.
                },
              ),
              // `Expanded` membuat `SingleChildScrollView` mengisi sisa ruang yang tersedia.
              Expanded(
                child: SingleChildScrollView( // Memungkinkan konten di-scroll jika melebihi ukuran layar.
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Rata kiri untuk semua anak.
                    children: [
                      // --- AREA UNGGAH GAMBAR (WAJIB) ---
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.lightTeal.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                          // Menampilkan gambar jika `_selectedImage` tidak null.
                          image: _selectedImage != null
                              ? kIsWeb // Cek platform
                          // Untuk web, `FileImage` tidak berfungsi. `_selectedImage.path` akan berisi URL blob, jadi `NetworkImage` digunakan.
                              ? DecorationImage(
                            image: NetworkImage(_selectedImage!.path),
                            fit: BoxFit.cover,
                          )
                          // Untuk mobile, `FileImage` digunakan untuk menampilkan gambar dari path file lokal.
                              : DecorationImage(
                            image: FileImage(File(_selectedImage!.path)),
                            fit: BoxFit.cover,
                          )
                              : null, // Jika null, tidak ada gambar.
                        ),
                        // Menampilkan UI placeholder jika tidak ada gambar yang dipilih.
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
                            : null, // Jika gambar sudah ada, jangan tampilkan placeholder.
                      ),
                      // --- Tombol untuk memilih atau menghapus gambar ---
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: _pickImage, // Panggil fungsi pemilih gambar saat diketuk.
                                child: Container(
                                  // UI tombol.
                                  height: 35,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentTeal.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    // Teks tombol berubah tergantung apakah gambar sudah dipilih.
                                    _selectedImage == null ? 'Pilih Gambar' : 'Ganti Gambar',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14),
                                  ),
                                ),
                              ),
                            ),
                            // Tombol hapus hanya muncul jika ada gambar yang dipilih.
                            if (_selectedImage != null)
                              Expanded(
                                child: GestureDetector(
                                  onTap: () { setState(() { _selectedImage = null; }); }, // Set `_selectedImage` menjadi null untuk menghapusnya.
                                  child: Container(
                                    // UI tombol hapus.
                                    height: 35,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    margin: const EdgeInsets.symmetric(horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentTeal.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text('Hapus Gambar', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14)),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // --- AREA UNGGAH VIDEO (OPSIONAL) --- (Logikanya mirip dengan gambar)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.lightTeal.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        // Menampilkan placeholder atau nama file video yang dipilih.
                        child: _selectedVideo == null
                            ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.emeraldGreen.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.videocam, size: 24, color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            const Text('Tambahkan Video Resep (Opsional)', style: TextStyle(color: Colors.black54, fontSize: 14)),
                          ],
                        )
                            : Center(
                          child: Text(
                            'Video Terpilih: ${_selectedVideo!.name}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      // --- Tombol untuk memilih atau menghapus video ---
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: _pickVideo, // Panggil fungsi pemilih video.
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
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14),
                                  ),
                                ),
                              ),
                            ),
                            // Tombol hapus video hanya muncul jika ada video yang dipilih.
                            if (_selectedVideo != null)
                              Expanded(
                                child: GestureDetector(
                                  onTap: _clearVideo, // Panggil fungsi untuk menghapus video.
                                  child: Container(
                                    height: 35,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    margin: const EdgeInsets.symmetric(horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentTeal.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text('Hapus Video', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14)),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // --- FIELD INFORMASI RESEP ---
                      // Menggunakan metode pembantu `_buildInfoField` untuk membuat UI field input yang konsisten.
                      _buildInfoField('Judul', 'Nama Resep', controller: _titleController),
                      _buildInfoField('Deskripsi', 'Deskripsi Resep', lighter: true, controller: _descriptionController),
                      _buildInfoField('Estimasi Waktu (menit)', '45', controller: _estimatedTimeController, keyboardType: TextInputType.number),
                      _buildInfoField('Harga', '25000', controller: _priceController, keyboardType: TextInputType.number),

                      // --- DROPDOWN TINGKAT KESULITAN ---
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 30.0, top: 16.0, bottom: 8.0),
                            child: Text('Tingkat Kesulitan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                                value: _selectedDifficulty, // Nilai saat ini yang terpilih.
                                hint: const Text('Pilih tingkat kesulitan memasak', style: TextStyle(color: Colors.black54)),
                                onChanged: (String? newValue) {
                                  // Perbarui state saat pengguna memilih item baru.
                                  setState(() {
                                    _selectedDifficulty = newValue;
                                  });
                                },
                                // Membuat daftar item dropdown dari list `_difficultyLevels`.
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

                      // --- DROPDOWN KATEGORI RESEP --- (Logikanya mirip dengan tingkat kesulitan)
// --- DROPDOWN KATEGORI RESEP --- (DINAMIS)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 30.0, top: 16.0, bottom: 8.0),
                            child: Text('Kategori Resep', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 30),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.accentTeal.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            // Tampilkan loading indicator jika sedang fetching, atau dropdown jika sudah selesai
                            child: _isLoadingCategories
                                ? const Center(
                              heightFactor: 2.0, // Memberi sedikit tinggi agar indicator terlihat baik
                              child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.primaryColor)
                              ),
                            )
                                : DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: _selectedCategory,
                                hint: const Text('Pilih kategori resep', style: TextStyle(color: Colors.black54)),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedCategory = newValue;
                                  });
                                },
                                // Membuat daftar item dari list _fetchedCategories yang sudah kita ambil dari API.
                                items: _fetchedCategories.map<DropdownMenuItem<String>>((Category category) {
                                  return DropdownMenuItem<String>(
                                    // Nilai yang disimpan saat dipilih adalah nama kategori (String).
                                    value: category.name,
                                    // Teks yang ditampilkan di dropdown adalah nama kategori.
                                    child: Text(category.name),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // --- BAGIAN ALAT-ALAT (DINAMIS) ---
                      const Padding(
                        padding: EdgeInsets.only(left: 30.0, top: 24.0, bottom: 8.0),
                        child: Text('Alat-Alat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      // `ListView.builder` secara efisien membangun daftar widget dari list controller.
                      ListView.builder(
                        shrinkWrap: true, // Membuat ListView hanya memakan ruang yang dibutuhkan.
                        physics: const NeverScrollableScrollPhysics(), // Menonaktifkan scroll internal karena sudah ada di `SingleChildScrollView`.
                        itemCount: _toolControllers.length,
                        itemBuilder: (context, index) {
                          // Membangun setiap item menggunakan metode pembantu `_buildToolItem`.
                          return _buildToolItem(index, _toolControllers[index]);
                        },
                      ),
                      // Tombol untuk menambah field alat baru.
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: GestureDetector(
                            onTap: _addToolField, // Panggil fungsi penambah field.
                            child: Container(
                              width: 200,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Center(
                                child: Text('+ Tambahkan Alat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // --- BAGIAN BAHAN-BAHAN (DINAMIS) --- (Logikanya mirip dengan alat)
                      const Padding(
                        padding: EdgeInsets.only(left: 30.0, top: 16.0, bottom: 8.0),
                        child: Text('Bahan-Bahan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _ingredientControllers.length,
                        itemBuilder: (context, index) {
                          // Membangun setiap item menggunakan metode pembantu `_buildIngredientItem`.
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
                            onTap: _addIngredientField, // Panggil fungsi penambah field.
                            child: Container(
                              width: 200,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Center(
                                child: Text('+ Tambahkan Bahan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // --- BAGIAN INSTRUKSI (DINAMIS) --- (Logikanya mirip dengan alat)
                      const Padding(
                        padding: EdgeInsets.only(left: 30.0, top: 16.0, bottom: 8.0),
                        child: Text('Instruksi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _instructionControllers.length,
                        itemBuilder: (context, index) {
                          // Membangun setiap item menggunakan metode pembantu `_buildInstructionItem`.
                          return _buildInstructionItem(index, _instructionControllers[index]);
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: GestureDetector(
                            onTap: _addInstructionField, // Panggil fungsi penambah field.
                            child: Container(
                              width: 200,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Center(
                                child: Text('+ Tambahkan Instruksi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // --- TOMBOL SIMPAN RESEP ---
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submitRecipe, // Memicu fungsi pengiriman data saat ditekan.
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Simpan Resep',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                      ),

                      // Memberi sedikit ruang di bagian bawah agar konten tidak terlalu mepet dengan BottomNavBar.
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

  // --- METODE PEMBANTU UNTUK MEMBANGUN WIDGET ---
  // Metode-metode ini dibuat untuk mengurangi duplikasi kode dan membuat metode `build` utama lebih bersih.

  // Metode untuk membangun field info umum (judul, deskripsi, dll.).
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
            controller: controller, // Menggunakan controller yang diberikan.
            keyboardType: keyboardType, // Mengatur tipe keyboard (teks, angka, dll.).
            decoration: InputDecoration(
              hintText: placeholder, // Teks placeholder.
              hintStyle: const TextStyle(color: Colors.black54),
              border: InputBorder.none, // Menghilangkan garis bawah default.
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            maxLines: lighter ? null : 1, // `null` memungkinkan input multi-baris (untuk deskripsi).
          ),
        ),
      ],
    );
  }

  // Metode untuk membangun satu baris item alat.
  Widget _buildToolItem(int index, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          // Ikon 'drag handle' (saat ini tidak memiliki fungsi).
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
          const SizedBox(width: 2),
          // Field input untuk nama alat.
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
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Tombol untuk menghapus item alat ini.
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.black),
            onPressed: () => _removeToolField(index), // Memanggil fungsi penghapus dengan indeks yang benar.
          ),
        ],
      ),
    );
  }

  // Metode untuk membangun satu baris item bahan.
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
          // Field untuk jumlah (Qty).
          SizedBox(
            width: 60,
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
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Field untuk satuan (Unit).
          SizedBox(
            width: 80,
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
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Field untuk nama bahan.
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
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Tombol untuk menghapus item bahan ini.
          IconButton(
            icon: const Icon(Icons.delete, color: Color.fromARGB(255, 4, 0, 0)),
            onPressed: () => _removeIngredientField(index),
          ),
        ],
      ),
    );
  }

  // Metode untuk membangun satu baris item instruksi.
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
                style: const TextStyle(color: Colors.black, fontSize: 16),
                maxLines: null, // Memungkinkan input instruksi yang panjang dan multi-baris.
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