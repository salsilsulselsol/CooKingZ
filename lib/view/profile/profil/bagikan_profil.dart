import 'package:flutter/material.dart';
import '../../component/bagikan_profil_content.dart';

class BagikanProfil extends StatelessWidget {
  final String username;
  final String qrImagePath;
  
  const BagikanProfil({
    super.key, 
    this.username = '@siti_r',
    this.qrImagePath = 'images/qr.png',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF006257),
      appBar: AppBar(
        backgroundColor: const Color(0xFF006257),
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 30.0, top: 20.0),
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, "/beranda"),
            child: Transform.translate(
              offset: const Offset(15, 0),
              child: SizedBox(
                width: 30,
                height: 30,
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: Image.asset(
                      'images/arrow.png',
                      color: Colors.white,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        title: const Padding(
          padding: EdgeInsets.only(top: 20.0),
          child: Text(
            'Bagikan Profil',
            style: TextStyle(
              color: Color.fromARGB(255, 251, 251, 251),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
      body: BagikanProfilContent(
        username: username,
        qrImagePath: qrImagePath,
      ),
    );
  }
}
