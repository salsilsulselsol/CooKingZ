import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controllers untuk semua input field
  final TextEditingController _usernameController = TextEditingController();    // Baru: Controller untuk username
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  // Untuk Dropdown cooking_level
  String? _selectedCookingLevel; // Nullable pada awalnya
  final List<String> _cookingLevels = [
    'Pemula',
    'Menengah',
    'Lanjutan',
    'Professional',
  ];

  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;

  // Fungsi untuk melakukan registrasi
  Future<void> _register() async {
    // Validasi input di sisi client - SEMUA field sekarang wajib diisi
    if (_usernameController.text.isEmpty ||    // Validasi baru untuk username
        _fullNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _bioController.text.isEmpty ||
        _selectedCookingLevel == null) {
      _showErrorDialog(context, 'Semua field harus diisi.');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorDialog(context, 'Password dan konfirmasi password tidak cocok.');
      return;
    }

    final String apiUrl = 'http://localhost:3000/register';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        // Body JSON menyertakan SEMUA field yang akan disimpan
        body: jsonEncode(<String, String>{
          'username': _usernameController.text,     // Dikirim: username
          'fullName': _fullNameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'confirmPassword': _confirmPasswordController.text,
          'bio': _bioController.text,
          'cookingLevel': _selectedCookingLevel!,
        }),
      );

      if (response.statusCode == 201) {
        // Registrasi berhasil
        _showSuccessDialog(context);
      } else {
        // Registrasi gagal, tampilkan pesan error dari server
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        _showErrorDialog(context, responseData['message'] ?? 'Registrasi gagal. Silakan coba lagi.');
      }
    } catch (e) {
      // Tangani error jaringan atau error lainnya
      print('Error during registration: $e');
      _showErrorDialog(context, 'Terjadi kesalahan jaringan atau server tidak merespons.');
    }
  }

  @override
  void dispose() {
    // Pastikan untuk membuang controllers saat widget di dispose
    _usernameController.dispose(); // Dispose baru untuk username
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Center(
                child: Text(
                  'Daftar',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF015551)),
                ),
              ),
              const SizedBox(height: 40),
              const Text('Nama Lengkap'),
              const SizedBox(height: 8),
              TextField(
                controller: _fullNameController,
                decoration: _inputDecoration(hint: '  Dedi'),
              ),
              const SizedBox(height: 16),
              const Text('Username'), // Input baru untuk username
              const SizedBox(height: 8),
              TextField(
                controller: _usernameController,
                decoration: _inputDecoration(hint: '  dedi_aja'),
              ),
              const SizedBox(height: 16),
              const Text('Email'),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration(hint: '  example@example.com'),
              ),
              const SizedBox(height: 16),
              const Text('Bio'),
              const SizedBox(height: 8),
              TextField(
                controller: _bioController,
                decoration: _inputDecoration(hint: '  Ceritakan tentang diri Anda...'),
                maxLines: 3, // Multi-line input
              ),
              const SizedBox(height: 16),
              const Text('Level Memasak'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFB4E1E1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedCookingLevel,
                    hint: const Text('Pilih Level Anda', style: TextStyle(color: Colors.black54)),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCookingLevel = newValue;
                      });
                    },
                    items: _cookingLevels.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    dropdownColor: const Color(0xFFB4E1E1),
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Password'),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _isPasswordHidden,
                decoration: _inputDecoration(
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordHidden ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _isPasswordHidden = !_isPasswordHidden;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Konfirmasi Password'),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _isConfirmPasswordHidden,
                decoration: _inputDecoration(
                  suffixIcon: IconButton(
                    icon: Icon(_isConfirmPasswordHidden ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordHidden = !_isConfirmPasswordHidden;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB4E1E1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: const Size(200, 50),
                  ),
                  child: const Text('Daftar', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: RichText(
                    text: const TextSpan(
                      text: 'Sudah punya akun? ',
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: 'Masuk',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // =================== POPUP: Success ===================
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black.withOpacity(0.7),
          contentPadding: const EdgeInsets.all(40),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Icon(
                  Icons.person_outline,
                  size: 60,
                  color: Color.fromARGB(255, 1, 85, 51),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Daftar Akun\nBerhasil",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF57B4BA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: const Text(
                  "Kembali Ke Login",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =================== POPUP: Error ===================
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.red.withOpacity(0.7),
          contentPadding: const EdgeInsets.all(40),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: const Text(
                  "Tutup",
                  style: TextStyle(color: Colors.red, fontSize: 18),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration({String hint = '', Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFB4E1E1),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
    );
  }
}