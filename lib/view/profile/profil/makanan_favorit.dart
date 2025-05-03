import 'package:flutter/material.dart';

class MakananFavorit extends StatelessWidget {
  const MakananFavorit({super.key});

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
          'Manis',
          style: TextStyle(
            color: Color(0xFF006A4E),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: _buildRecipeGrid(),
    );
  }

  Widget _buildRecipeGrid() {
    // List of recipes
    List<Map<String, dynamic>> recipes = [
      {
        'name': 'French Toast',
        'description': 'Rican ini yang klasik',
        'image': 'images/french_toast.jpg',
        'duration': '25 menit',
        'price': '35RB',
        'likes': 30,
      },
      {
        'name': 'Crepes Buah',
        'description': 'Crepes cream isi buah',
        'image': 'images/manis.png',
        'duration': '15 menit',
        'price': '30RB',
        'likes': 27,
      },
      {
        'name': 'Macarons',
        'description': 'Klasik, berwarna-warni, dan lembut manis',
        'image': 'images/macarons.jpg',
        'duration': '60 menit',
        'price': '40RB',
        'likes': 38,
      },
      {
        'name': 'Spring Cupcake',
        'description': 'Cupcake di spring, bertopping kurma mudah siap',
        'image': 'images/springcake.png',
        'duration': '45 menit',
        'price': '28RB',
        'likes': 25,
      },
      {
        'name': 'Cheesecake',
        'description': 'Cheesecake dingin yang lemon dan lembut',
        'image': 'images/chesscake.png', 
        'duration': '50 menit',
        'price': '45RB',
        'likes': 32,
      },
      {
        'name': 'Es Kopi',
        'description': 'Kopi susu dingin dan segar',
        'image': '/images/eskopi.ong',
        'duration': '10 menit',
        'price': '25RB',
        'likes': 29,
      },
    ];

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        return _buildFoodCard(recipes[index]);
      },
    );
  }

  Widget _buildFoodCard(Map<String, dynamic> food) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image container with heart icon
          Stack(
            children: [
              // Food image
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.asset(
                  food['image'],
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              // Heart icon button
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Color(0xFF57B4BA),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite_border,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          // Card content
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Color(0xFFE0E0E0),
                width: 1,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Food name
                Text(
                  food['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF006A4E),
                  ),
                ),
                SizedBox(height: 4),
                // Description
                Text(
                  food['description'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                // Bottom row with icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Likes
                    Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          color: Color(0xFF57B4BA),
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          food['likes'].toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF57B4BA),
                          ),
                        ),
                      ],
                    ),
                    // Duration
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Color(0xFF57B4BA),
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          food['duration'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF57B4BA),
                          ),
                        ),
                      ],
                    ),
                    // Price
                    Text(
                      "Rp${food['price']}",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF57B4BA),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}