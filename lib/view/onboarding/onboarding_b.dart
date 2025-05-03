import 'package:flutter/material.dart';
import 'onboarding_c.dart';

class OnboardingB extends StatelessWidget {
  const OnboardingB({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fullscreen image
          Positioned.fill(
            child: Image.asset(
              'images/onboarding_b.png',
              fit: BoxFit.cover,
            ),
          ),

          // Gradient overlay (efek kabut hanya sampai teks)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300, // Sesuaikan tinggi dengan panjang teks kamu
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Color.fromARGB(0, 255, 255, 255),
                  ],
                ),
              ),
            ),
          ),

          // Overlay content
          SafeArea(
            child: Column(
              children: [
                // Back Button (Ganti dengan gambar arrow.png)
                Padding(
                  padding: const EdgeInsets.only(top: 32.0, left: 24.0), // Geser ke bawah dan ke kanan
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Image.asset(
                        'images/arrow.png', // Path ke gambar arrow.png
                        width: 28, // Sesuaikan ukuran gambar
                        height: 28,
                      ),
                    ),
                  ),
                ),

                // Texts
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, left: 24.0, right: 24.0), // Geser teks ke bawah
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Tingkatkan Keterampilanmu',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Kuasi teknik dasar memasak secara fleksibel, sesuai kecepatanmu!',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Button
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.2,
                    vertical: MediaQuery.of(context).size.height * 0.04,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const OnboardingC()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB4E1E1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Selanjutnya',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}