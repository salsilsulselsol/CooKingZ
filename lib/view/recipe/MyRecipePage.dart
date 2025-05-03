import 'package:flutter/material.dart';
import 'RecipeCardWidget.dart';

class ResepAndaPage extends StatelessWidget {
  final TextStyle headerStyle = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  final TextStyle subTextStyle = const TextStyle(
    fontSize: 12,
    color: Color(0xFF57B4BA),
  );
  final Color primaryColor = const Color(0xFF005A4D);
  final Color accentTeal = const Color(0xFF57B4BA);
  final Color emeraldGreen = const Color(0xFF015551);

  const ResepAndaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Image.asset(
            'images/arrow.png',
            height: 24,
            width: 24,
          ),
        ),
        title: Text(
          'Resep Anda',
          style: TextStyle(color: emeraldGreen, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 0.0),
            child: Row(
              children: [
                const SizedBox(width: 8), // Reduced spacing
                Stack(
                  alignment: Alignment.center,
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xFF015551),
                      radius: 14,
                    ),
                    Image.asset(
                      'images/tambah.png',
                      height: 28,
                      width: 28,

                    ),
                  ],
                ),
                const SizedBox(width: 8), // Reduced spacing
                Stack(
                  alignment: Alignment.center,
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xFF015551),
                      radius: 14,
                    ),
                    Image.asset(
                      'images/search.png',
                      height: 28,
                      width: 28,
                    ),
                  ],
                ),
                const SizedBox(width: 8), // Reduced spacing
                Stack(
                  alignment: Alignment.center,
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xFF015551),
                      radius: 14,
                    ),
                    Image.asset(
                      'images/notif.png',
                      height: 28,
                      width: 28,
                    ),
                  ],
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Most Viewed Today',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    spacing: 12,
                    children: [
                      Expanded(
                        child: RecipeCard(
                            title: 'Gulai',
                            rating: '15★',
                            time: '50menit',
                            price: 'RP 50RB',
                            imagePath: 'images/gulai.jpg',
                            showGlow: false),
                      ),
                      Expanded(
                        child: RecipeCard(
                            title: 'Pina Colada',
                            rating: '5★',
                            time: '5menit',
                            price: 'RP 20RB',
                            imagePath: 'images/pina_colada.jpg',
                            showGlow: false),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
              children: [
                RecipeCard(
                  title: 'Pasta Bechamel',
                  description: 'Krim yang lembut dan memanjakan.',
                  rating: '5★',
                  time: '30menit',
                  price: 'RP 20RB',
                  imagePath: 'images/pasta.jpg',
                ),
                RecipeCard(
                  title: 'Grilled Skewers',
                  description: 'Potongan-potongan lezat.',
                  rating: '5★',
                  time: '30menit',
                  price: 'RP 20RB',
                  imagePath: 'images/skewers.png',
                ),
                RecipeCard(
                  title: 'kue brownies kacang',
                  description:
                      'Adalah hidangan penutup yang lezat dan nikmat…',
                  rating: '23★',
                  time: '87menit',
                  price: 'RP 47RB',
                  imagePath: 'images/brownies.png',
                ),
                RecipeCard(
                  title: 'Oatmeal pancakes',
                  description:
                      'Kelezatan yang bergizi ini menawarkan kepuasan…',
                  rating: '76★',
                  time: '58menit',
                  price: 'RP 88RB',
                  imagePath: 'images/pancakes.jpg',
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}