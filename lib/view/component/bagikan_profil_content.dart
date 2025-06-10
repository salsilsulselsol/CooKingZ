import 'package:flutter/material.dart';

class BagikanProfilContent extends StatefulWidget {
  final String username;
  final String qrImagePath;

  const BagikanProfilContent({
    super.key,
    required this.username,
    required this.qrImagePath,
  });

  @override
  State<BagikanProfilContent> createState() => _BagikanProfilContentState();
}

class _BagikanProfilContentState extends State<BagikanProfilContent> {
  bool isBagikanPressed = false;
  bool isSalinPressed = false;
  bool isUnduhPressed = false;

  Color getColor(bool isPressed, Color primary, Color secondary) {
    return isPressed ? secondary : primary;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.username,
            style: const TextStyle(
              color: Color(0xFF006257),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              color: const Color(0xFF006257),
              border: Border.all(color: const Color.fromARGB(255, 249, 250, 250), width: 2),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: widget.qrImagePath.isEmpty
                ? Placeholder(
                    color: const Color(0xFF006257).withOpacity(0.5),
                  )
                : Image.asset(widget.qrImagePath, fit: BoxFit.contain),
          ),
          const SizedBox(height: 36),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Bagikan Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isBagikanPressed = !isBagikanPressed;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fitur berbagi profil'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: getColor(isBagikanPressed, const Color(0xFF006257), Colors.white),
                      foregroundColor: getColor(isBagikanPressed, Colors.white, const Color(0xFF006257)),
                      side: const BorderSide(color: Color(0xFF006257), width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Bagikan',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Salin Tautan Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isSalinPressed = !isSalinPressed;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tautan profil disalin'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: getColor(isSalinPressed, Colors.white, const Color(0xFF006257)),
                      foregroundColor: getColor(isSalinPressed, const Color(0xFF006257), Colors.white),
                      side: const BorderSide(color: Color(0xFF006257)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Salin Tautan',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Unduh Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    isUnduhPressed = !isUnduhPressed;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('QR Code berhasil diunduh')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: getColor(isUnduhPressed, const Color(0xFF006257), Colors.white),
                  foregroundColor: getColor(isUnduhPressed, Colors.white, const Color(0xFF006257)),
                  side: const BorderSide(color: Color(0xFF006257)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Unduh',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
