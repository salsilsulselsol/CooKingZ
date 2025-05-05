import 'package:flutter/material.dart';
import '../../view/component/header_back.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFCF9),
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            HeaderWidget(
              title: 'Lupa Password',
              onBackPressed: () => Navigator.pop(context),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Halo!',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Masukkan alamat email Anda. Kami akan mengirim kode verifikasi di langkah berikutnya.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 30),
                    const Text("Email"),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'example@example.com',
                        filled: true,
                        fillColor: const Color(0xFFD0EAEA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF005D56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const OTPScreen()),
                          );
                        },
                        child: const Text(
                          'Selanjutnya',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OTPScreen extends StatelessWidget {
  const OTPScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFCF9),
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            HeaderWidget(
              title: 'Lupa Password',
              onBackPressed: () => Navigator.pop(context),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Emailmu Sudah Sampai!',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Kami akan mengirim kode verifikasi ke alamat email Anda. Silakan periksa email Anda dan masukkan kode di bawah ini.',
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        OtpBox(number: '2'),
                        OtpBox(number: '7'),
                        OtpBox(number: '3'),
                        OtpBox(number: '9'),
                        OtpBox(number: '1'),
                        OtpBox(number: '6'),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Center(
                      child: Text("Tidak menerima email? Anda bisa\nkirim ulang dalam 49 detik",
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Spacer(),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF005D56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const NewPasswordScreen()),
                          );
                        },
                        child: const Text(
                          'Selanjutnya',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NewPasswordScreen extends StatelessWidget {
  const NewPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFCF9),
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            HeaderWidget(
              title: 'Buat Password Baru',
              onBackPressed: () => Navigator.pop(context),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Buat Password Baru',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Masukkan password baru Anda. Jika lupa password, silakan ikuti langkah-langkah pemulihan password',
                    ),
                    const SizedBox(height: 30),
                    const Text("Password Baru"),
                    const SizedBox(height: 8),
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFD0EAEA),
                        suffixIcon: const Icon(Icons.visibility_off),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text("Konfirmasi Password"),
                    const SizedBox(height: 8),
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFD0EAEA),
                        suffixIcon: const Icon(Icons.visibility_off),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: const [
                        Checkbox(value: false, onChanged: null),
                        Text('Ingatkan Saya')
                      ],
                    ),
                    const Spacer(),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF005D56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => const SuccessDialog(),
                          );
                        },
                        child: const Text(
                          'Selanjutnya',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OtpBox extends StatelessWidget {
  final String number;
  const OtpBox({super.key, required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF005D56)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        number,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}

class SuccessDialog extends StatelessWidget {
  const SuccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black.withOpacity(0.7),
      contentPadding: const EdgeInsets.all(40),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_box_outlined, color: Colors.white, size: 48),
          const SizedBox(height: 20),
          const Text(
            "Ubah Password\nBerhasil",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF57B4BA),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            child: const Text(
              "Kembali Ke Beranda",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}