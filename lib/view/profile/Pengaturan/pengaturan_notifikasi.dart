import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  // Switch state variables
  bool generalNotifications = true;
  bool soundNotifications = true;
  bool vibrationNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
                    'images/Tombol_kembali.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ),
        title: Text(
          'Notifikasi',
          style: TextStyle(
            color: Color(0xFF006A4E),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            _buildSwitchRow(
              title: 'Notifikasi Umum',
              value: generalNotifications,
              onChanged: (value) {
                setState(() {
                  generalNotifications = value;
                });
              },
            ),
            _buildDivider(),
            _buildSwitchRow(
              title: 'Suara',
              value: soundNotifications,
              onChanged: (value) {
                setState(() {
                  soundNotifications = value;
                });
              },
            ),
            _buildDivider(),
            _buildSwitchRow(
              title: 'Getar',
              value: vibrationNotifications,
              onChanged: (value) {
                setState(() {
                  vibrationNotifications = value;
                });
              },
            ),
            _buildDivider(),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: Color(0xFF006A4E),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: Colors.grey.shade200,
    );
  }
}