import 'package:flutter/material.dart';

class OnboardingC extends StatelessWidget {
  const OnboardingC({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Back Button
            Padding(
              padding: const EdgeInsets.only(top: 16.0, left: 24.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Image.asset('images/arrow.png', width: 28, height: 28),
                ),
              ),
            ),
            // Grid of Images
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildImage('images/1.png'),
                    _buildImage('images/2.png'),
                    _buildImage('images/3.png'),
                    _buildImage('images/4.png'),
                    _buildImage('images/5.png'),
                    _buildImage('images/6.png'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Title Text
            const Text(
              'Selamat Datang',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Description Text - Modified with specific line break
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'Jelajahi resep dengan tutorial lengkap untuk\nmengasah keahlian masak Anda',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 24),
            // Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB4E1E1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/beranda');
                    },
                    child: const Text(
                      'Selanjutnya',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String assetPath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(assetPath, fit: BoxFit.cover),
    );
  }
}
