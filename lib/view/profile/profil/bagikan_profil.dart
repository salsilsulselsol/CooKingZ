
import 'package:flutter/material.dart';
class BagikanProfil extends StatelessWidget {
  const BagikanProfil({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF006257), // Dark teal background
      appBar: AppBar(
        backgroundColor: const Color(0xFF006257),
        elevation: 0,
        centerTitle: true,
       leading: GestureDetector(
          onTap: () => Navigator.pushNamed(context, "/home"),
          child: Transform.translate(
            offset: const Offset(15, 0), // Geser tombol 15px ke kanan
            child: SizedBox(
              width: 30, // Area klik lebih besar dari gambar
              height: 30,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: Image.asset(
                    color: Colors.white,
                    'icons/Tombol_kembali.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ),
        title: Text(
          'Bagikan Profil',
          style: TextStyle(
            color: Color.fromARGB(255, 251, 251, 251),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Username Display
            const Text(
              '@siti_r',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // QR Code
            Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                color: const Color(0xFF006257), // Green background
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                'images/qr.png',
                fit: BoxFit.contain,
              ),
            ),
            
            const SizedBox(height: 36),
            
            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Share Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Share profile logic
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006257),
                        side: const BorderSide(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Bagikan',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Copy Link Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Copy link logic
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tautan profil disalin')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Salin Tautan',
                        style: TextStyle(
                          color: Color(0xFF006257),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Download Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Download QR Code logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('QR Code berhasil diunduh')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006257),
                    side: const BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Unduh',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
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
}