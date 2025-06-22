import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:masak2/view/auth/login_page.dart';
import 'dart:convert';
import 'dart:async'; // Import untuk Timer
import '../../view/component/header_back.dart'; // Pastikan path ini benar

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final String _backendUrl = "http://localhost:3000"; // Ganti dengan URL backend Anda

  Future<void> _sendOtp() async {
    final email = _emailController.text;
    if (email.isEmpty) {
      _showAlertDialog('Error', 'Email wajib diisi.');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/forgot-password/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        _showAlertDialog('Sukses', responseData['message']);
        // Navigasi ke OTPScreen dan berikan email yang digunakan
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OTPScreen(email: email)),
        );
      } else {
        _showAlertDialog('Error', responseData['message'] ?? 'Gagal mengirim OTP.');
      }
    } catch (e) {
      _showAlertDialog('Error', 'Terjadi kesalahan koneksi: $e');
    }
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFCF9),
      body: SafeArea(
        child: Column(
          children: [
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
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
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
                        onPressed: _sendOtp,
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

class OTPScreen extends StatefulWidget {
  final String email;
  const OTPScreen({super.key, required this.email});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (index) => TextEditingController());
  final String _backendUrl = "http://localhost:3000"; // Ganti dengan URL backend Anda
  Timer? _timer;
  int _countdownSeconds = 300; // 5 menit = 300 detik

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    _countdownSeconds = 300; // Reset timer saat dimulai atau dikirim ulang ke 5 menit penuh
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 0) {
        setState(() {
          _countdownSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  // Fungsi untuk memformat waktu mundur menjadi menit dan detik
  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  Future<void> _resendOtp() async {
    // Implementasi kirim ulang OTP ke backend
    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/forgot-password/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': widget.email}),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        _showAlertDialog('Sukses', responseData['message']);
        _startCountdown(); // Mulai hitung mundur lagi
        for (var controller in _otpControllers) {
          controller.clear(); // Bersihkan field OTP
        }
      } else {
        _showAlertDialog('Error', responseData['message'] ?? 'Gagal mengirim ulang OTP.');
      }
    } catch (e) {
      _showAlertDialog('Error', 'Terjadi kesalahan koneksi: $e');
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpControllers.map((controller) => controller.text).join();
    if (otp.length != 6) {
      _showAlertDialog('Error', 'Silakan masukkan 6 digit OTP.');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/forgot-password/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': widget.email, 'otp': otp}),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        _showAlertDialog('Sukses', responseData['message']);
        _timer?.cancel(); // Hentikan timer setelah verifikasi berhasil
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NewPasswordScreen(email: widget.email)),
        );
      } else {
        _showAlertDialog('Error', responseData['message'] ?? 'Gagal verifikasi OTP.');
      }
    } catch (e) {
      _showAlertDialog('Error', 'Terjadi kesalahan koneksi: $e');
    }
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFCF9),
      body: SafeArea(
        child: Column(
          children: [
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
                    Text(
                      'Kami akan mengirim kode verifikasi ke alamat email Anda (${widget.email}). Silakan periksa email Anda dan masukkan kode di bawah ini.',
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) {
                        return OtpBox(controller: _otpControllers[index]);
                      }),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: _countdownSeconds > 0
                          ? Text(
                              "Tidak menerima email? Anda bisa\nkirim ulang dalam ${_formatDuration(_countdownSeconds)}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14),
                            )
                          : TextButton(
                              onPressed: _resendOtp,
                              child: const Text(
                                "Kirim Ulang Kode",
                                style: TextStyle(color: Color(0xFF005D56), fontSize: 14, fontWeight: FontWeight.bold),
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
                        onPressed: _verifyOtp,
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

class NewPasswordScreen extends StatefulWidget {
  final String email;
  const NewPasswordScreen({super.key, required this.email});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final String _backendUrl = "http://localhost:3000"; // Ganti dengan URL backend Anda
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _resetPassword() async {
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showAlertDialog('Error', 'Semua field wajib diisi.');
      return;
    }
    if (newPassword != confirmPassword) {
      _showAlertDialog('Error', 'Password baru dan konfirmasi password tidak cocok.');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/forgot-password/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': widget.email,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (_) => const SuccessDialog(),
        );
      } else {
        _showAlertDialog('Error', responseData['message'] ?? 'Gagal mereset password.');
      }
    } catch (e) {
      _showAlertDialog('Error', 'Terjadi kesalahan koneksi: $e');
    }
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFCF9),
      body: SafeArea(
        child: Column(
          children: [
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
                      controller: _newPasswordController,
                      obscureText: _obscureNewPassword,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFD0EAEA),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureNewPassword = !_obscureNewPassword;
                            });
                          },
                        ),
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
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFD0EAEA),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
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
                        onPressed: _resetPassword,
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
  final TextEditingController controller;
  const OtpBox({super.key, required this.controller});

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
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
        ),
        style: const TextStyle(fontSize: 20),
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          } else if (value.isEmpty) {
            FocusScope.of(context).previousFocus();
          }
        },
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
            onPressed: () {
              // Navigasi kembali ke halaman login dan hapus semua rute sebelumnya
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text(
              "Kembali Ke Login",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
