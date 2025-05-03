import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'onboarding_b.dart';


class OnboardingA extends StatelessWidget {
  const OnboardingA({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    // Ensure status bar is visible and set color
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      // Ensure status bar is shown
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: Stack(
        children: [
          // Background gambar full
          Positioned.fill(
            child: Image.asset(
              'images/onboarding_a.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),

          // Gradient putih dari atas sampai tulisan
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300, // Ubah tinggi sesuai kebutuhan agar pas di belakang teks
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

          // Konten
          Column(
            children: [
              // Area status bar
              SizedBox(height: MediaQuery.of(context).viewPadding.top),
              
              // Teks
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.08,
                  vertical: size.height * 0.09,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Temukan Inspirasi',
                      style: TextStyle(
                        fontSize: size.width * 0.07,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    SizedBox(height: size.height * 0.0),
                    Text(
                      'Temukan inspirasi masakan dari rekomendasi resep kami setiap hari.',
                      style: TextStyle(
                        fontSize: size.width * 0.04,
                        color: const Color.fromARGB(210, 0, 0, 0),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Tombol
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.2, 
                  vertical: size.height * 0.065,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OnboardingB()),
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
        ],
      ),
    );
  }
}