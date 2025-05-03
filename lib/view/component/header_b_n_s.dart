import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final bool showBackButton;
  final bool showNotificationButton;
  final bool showSearchButton;
  final Color? titleColor;
  final String? backRoute;
  final String? searchRoute;
  final String? notificationRoute;

  const CustomHeader({
    Key? key,
    required this.title,
    this.showBackButton = true,
    this.showNotificationButton = true,
    this.showSearchButton = true,
    this.titleColor,
    this.backRoute,
    this.searchRoute = '/hasil-pencarian',
    this.notificationRoute = '/notif',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color defaultColor = const Color(0xFF005A4D);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tombol kembali dengan image asset
          if (showBackButton)
            GestureDetector(
              onTap: () {
                if (backRoute != null) {
                  Navigator.pushNamed(context, backRoute!);
                } else {
                  Navigator.pop(context);
                }
              },
              child: Container(
                width: 30,
                height: 30,
                padding: const EdgeInsets.all(3),
                child: Image.asset(
                  'images/arrow.png',
                  width: 24,
                  height: 24,
                ),
              ),
            )
          else
            const SizedBox(width: 30), // Placeholder untuk menjaga layout

          // Judul halaman
          Text(
            title,
            style: TextStyle(
              color: titleColor ?? defaultColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),

          // Tombol-tombol di kanan
          Row(
            children: [
              // Tombol notifikasi
              if (showNotificationButton)
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, notificationRoute ?? '/notif');
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    margin: const EdgeInsets.only(right: 10),
                    child: Image.asset(
                      'images/notif.png',
                      width: 28,
                      height: 28,
                    ),
                  ),
                ),

              // Tombol pencarian
              if (showSearchButton)
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, searchRoute ?? '/hasil-pencarian');
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    child: Image.asset(
                      'images/search.png',
                      width: 28,
                      height: 28,
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