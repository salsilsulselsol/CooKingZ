import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class ChefCard extends StatelessWidget {
  final String name;
  final String username;
  final String likes;
  final bool isFollowing;
  final String image;
  final bool useGreenBackground;

  const ChefCard({
    Key? key,
    required this.name,
    required this.username,
    required this.likes,
    required this.isFollowing,
    required this.image,
    this.useGreenBackground = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // Kartu utama pembungkus user card
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 254, 253, 253).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // ========================
          // BAGIAN FOTO PROFIL USER
          // ========================
          Container(
            height: 175,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusXLarge),
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // ================================
          // BAGIAN INFORMASI USER (NAMA DLL)
          // ================================
          Padding(
            padding: const EdgeInsets.fromLTRB(
              12,
              0,
              12,
              0,
            ), // Jarak atas dikurangi
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: useGreenBackground
                    ? AppTheme.primaryColor
                    : AppTheme.backgroundColor,
                border: Border(
                  left: BorderSide(
                    color: useGreenBackground
                        ? Colors.white
                        : AppTheme.primaryColor,
                    width: 2,
                  ),
                  right: BorderSide(
                    color: useGreenBackground
                        ? const Color.fromARGB(255, 255, 255, 255)
                        : const Color(0xFF005A4D),
                    width: 2,
                  ),
                  bottom: BorderSide(
                    color: useGreenBackground
                        ? const Color.fromARGB(255, 255, 255, 255)
                        : const Color(0xFF005A4D),
                    width: 2,
                  ),
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppTheme.borderRadiusXLarge),
                  bottomRight: Radius.circular(AppTheme.borderRadiusXLarge),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama & Username
                  Padding(
                    padding: EdgeInsets.only(left: AppTheme.spacingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: useGreenBackground ? Colors.white : Colors.black,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          username,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),

                  // Baris Like dan Tombol Follow
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Ikon dan jumlah like
                      Row(
                        children: <Widget>[
                          SizedBox(width: AppTheme.spacingMedium),
                          Icon(
                            Icons.favorite,
                            color: AppTheme.accentTeal,
                            size: AppTheme.iconSizeSmall,
                          ),
                          SizedBox(width: useGreenBackground ? 0.5 : 4),
                          Text(
                            likes,
                            style: AppTheme.foodInfoStyle,
                          ),
                          SizedBox(width: useGreenBackground ? 30 : 25),
                          // Tombol "Mengikuti" atau "Pengikut"
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF57B4BA),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isFollowing ? 'Mengikuti' : 'Pengikut',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Tombol Share
                          Container(
                            height: 20,
                            width: 20,
                            decoration: const BoxDecoration(
                              color: Color(0xFF57B4BA),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.share,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}