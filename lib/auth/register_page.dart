import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;

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
                decoration: _inputDecoration(hint: '  Dedi'),
              ),
              const SizedBox(height: 16),
              const Text('Email'),
              const SizedBox(height: 8),
              TextField(
                decoration: _inputDecoration(hint: '  example@example.com'),
              ),
              const SizedBox(height: 16),
              const Text('Nomor HP'),
              const SizedBox(height: 8),
              TextField(
                decoration: _inputDecoration(hint: '  + 123 456 789'),
              ),
              const SizedBox(height: 16),
              const Text('Tanggal Lahir'),
              const SizedBox(height: 8),
              TextField(
                decoration: _inputDecoration(hint: '  DD / MM / YYYY'),
              ),
              const SizedBox(height: 16),
              const Text('Password'),
              const SizedBox(height: 8),
              TextField(
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
                  onPressed: () {
                    _showSuccessDialog(context);
                  },
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
          backgroundColor: Colors.black.withOpacity(0.7), // Latar belakang hitam transparan
          contentPadding: const EdgeInsets.all(40),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white, // Latar belakang lingkaran putih
                ),
                child: const Icon(
                  Icons.person_outline, // Ikon tetap "person_outline"
                  size: 60,
                  color: Color.fromARGB(255, 1, 85, 51), // Warna hijau tua
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
                  Navigator.of(context).pop(); // Tutup dialog
                  Navigator.pushNamed(context, '/login'); // Navigasi ke halaman login
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF57B4BA), // Warna tombol hijau
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: const Text(
                  "Kembali Ke Beranda",
                  style: TextStyle(color: Colors.white, fontSize: 18),
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