// lib/view/profile/profil/edit_profil.dart
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:masak2/models/user_profile_model.dart';
import 'package:masak2/view/component/header_back.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfil extends StatefulWidget {
  const EditProfil({super.key});

  @override
  State<EditProfil> createState() => _EditProfilState();
}

class _EditProfilState extends State<EditProfil> {
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  XFile? _imageFile;
  String? _networkImageUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    return {'Authorization': 'Bearer $token'};
  }

  Future<void> _fetchProfileData() async {
    try {
      final baseUrl = dotenv.env['BASE_URL'];
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/users/me'),
        headers: headers,
      );

      if (mounted && response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        final user = UserProfile.fromJson(data);
        setState(() {
          _fullNameController.text = user.fullName;
          _usernameController.text = user.username;
          _bioController.text = user.bio ?? '';
          _networkImageUrl = user.profilePicture;
        });
      } else {
        throw Exception('Gagal memuat profil');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? selectedImage = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (selectedImage != null) {
      setState(() {
        _imageFile = selectedImage;
      });
    }
  }

  Future<void> _saveProfile() async {
  if (_isSaving) return;
  setState(() => _isSaving = true);

  try {
    final baseUrl = dotenv.env['BASE_URL'];
    var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/users/me'));
    request.headers.addAll(await _getAuthHeaders());
    
    request.fields['fullName'] = _fullNameController.text;
    request.fields['username'] = _usernameController.text;
    request.fields['bio'] = _bioController.text;

    if (_imageFile != null) {
        final fileBytes = await _imageFile!.readAsBytes();
        String? mimeType;

        // ==========================================================
        // **SOLUSI FINAL: Logika berbeda untuk WEB dan MOBILE**
        // kIsWeb adalah konstanta dari Flutter untuk mengecek apakah aplikasi berjalan di web
        // ==========================================================
        if (kIsWeb) {
          // Di web, kita bisa langsung dapatkan mimeType dari XFile
          mimeType = _imageFile!.mimeType;
        } else {
          // Di mobile, kita gunakan package 'mime' untuk deteksi dari path
          mimeType = lookupMimeType(_imageFile!.path);
        }

        final multipartFile = http.MultipartFile.fromBytes(
          'profile_picture',
          fileBytes,
          filename: _imageFile!.name,
          // Sekarang contentType akan terisi dengan benar di kedua platform
          contentType: mimeType != null ? MediaType.parse(mimeType) : null,
        );
        
        request.files.add(multipartFile);
      }
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final decodedBody = json.decode(response.body);
      
      if (mounted) {
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil berhasil diperbarui!'), backgroundColor: Colors.green),
          );

          Navigator.of(context).pop(true);
        } else {
          print('Server Error: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal: ${decodedBody['message'] ?? 'Error tidak diketahui'}'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if(mounted) {
        print('Flutter Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if(mounted){
        setState(() => _isSaving = false);
      }
    }
  }

  ImageProvider _buildProfileImageProvider() {
    if (_imageFile != null) {
      return kIsWeb ? NetworkImage(_imageFile!.path) : FileImage(File(_imageFile!.path));
    }
    if (_networkImageUrl != null && _networkImageUrl!.isNotEmpty) {
      final baseUrl = dotenv.env['BASE_URL']!;
      return NetworkImage('$baseUrl$_networkImageUrl');
    }
    return const AssetImage('images/default_avatar.png');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: SafeArea(
          child: HeaderWidget(
            title: 'Edit Profil',
            onBackPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: _buildProfileImageProvider(),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFF0A6859),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(6),
                              child: const Icon(Icons.edit, color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildTextField(label: 'Nama', controller: _fullNameController),
                  const SizedBox(height: 16),
                  _buildTextField(label: 'Username', controller: _usernameController),
                  const SizedBox(height: 16),
                  _buildTextField(label: 'Bio', controller: _bioController, maxLines: 3),
                  
                  const SizedBox(height: 48),
                  
                  Center(
                    child: SizedBox(
                      width: 200,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006257),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: _isSaving
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Simpan Perubahan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0x4D57B4BA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}