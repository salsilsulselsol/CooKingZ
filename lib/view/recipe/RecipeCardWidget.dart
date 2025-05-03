import 'package:flutter/material.dart';

// Widget untuk menampilkan card resep.
class RecipeCard extends StatelessWidget {
  final String title;
  final String rating;
  final String time;
  final String price;
  final String imagePath;
  final String? description; // Deskripsi resep (opsional).
  final bool showGlow;

  const RecipeCard({
    super.key,
    required this.title,
    required this.rating,
    required this.time,
    required this.price,
    required this.imagePath,
    this.description, // Menerima deskripsi.
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (showGlow)
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  imagePath,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(6), // Padding dikurangi menjadi 6
                  child: Image.asset(
                    'images/love.png',
                    height: 28, // Ukuran gambar dikurangi menjadi 20
                    width: 28,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                if (description != null)
                  Text(
                    description!,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(rating,
                        style:
                            const TextStyle(fontSize: 12, color: Color(0xFF57B4BA))),
                    Text(time,
                        style:
                            const TextStyle(fontSize: 12, color: Color(0xFF57B4BA))),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                              text: 'RP ',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF57B4BA),
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: price.replaceFirst('RP ', ''),
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF57B4BA))),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}