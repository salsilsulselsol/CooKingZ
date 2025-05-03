import 'package:flutter/material.dart';
import 'package:masak2/view/home/popup_search.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(

        
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              _buildTopSection(context),
              _buildFilterTabs(),
              _buildTrendingRecipe(context),
              _buildYourRecipes(
                context,
                'Resep Anda   >',
                Colors.white,
                Color(0xFF035E53),
              ), // Menggunakan latar belakang hijau
              _buildTopUsers(context),
              _buildRecentlyAddedRecipe(
                context,
                'Baru Saja Ditambahkan',
                Color(0xFF035E53),
                Colors.white,
              ),
              const SizedBox(height: 70), // Space for bottom navbar
            ],
          ),
        ),
      ),
    );
  }

  // Top greeting and icons section
  Widget _buildTopSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 16, 20, 10),  // Changed left padding to 30
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Hi! Siti',
                style: TextStyle(
                  color: Color(0xFF035E53),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Masak apa hari ini?',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/notif');
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('images/notif.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/penjadwalan');
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('images/calendar.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    // Call the function to show the bottom sheet
                    showRecipeRecommendationsTopSheet(context);
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('images/search.png'),
                        fit: BoxFit.cover,
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

  // Filter tabs for meal types
  Widget _buildFilterTabs() {
    final List<String> mealTypes = [
      'Sarapan',
      'Makan Siang',
      'Makan Malam',
      'Vegan',
      'Dessert',
    ];

    return Container(
      height: 25,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 30, right: 16),  // Changed left padding to 30
        itemCount: mealTypes.length,
        itemBuilder: (context, index) {
          final bool isSelected = index == 0;
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isSelected
                        ? const Color(0xFF035E53)
                        : const Color(0xFFFFF4FC),
                foregroundColor:
                    isSelected
                        ? const Color(0xFFFFF4FC)
                        : const Color(0xFF035E53),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Text(mealTypes[index]),
            ),
          );
        },
      ),
    );
  }

  // Trending Recipe section
  Widget _buildTrendingRecipe(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 30, right: 20, top: 8, bottom: 8),  // Changed left padding to 30
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/trending-resep');
            },
            child: const Text(
              'Resep Trending   >',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF035E53),

              ),
            ),
          ),
        ),
        // Image Container
        // Combined Container with Stack
        Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // The main container that holds both image and info
                Container(
                  margin: const EdgeInsets.only(
                    left: 30,  // Changed left margin to 30
                    right: 20,
                    top: 8,
                    bottom: 8,
                  ),
                  child: Column(
                    children: [
                      // Image Container
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        child: Container(
                          height: 180,
                          width: 358,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('images/croffle.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      // Info Container - directly attached to the image
                      Container(
                        height: 76,
                        width: 340, // Same width as image container
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            left: BorderSide(
                              color: const Color(0xFF035E53),
                              width: 2,
                            ),
                            right: BorderSide(
                              color: const Color(0xFF035E53),
                              width: 2,
                            ),
                            bottom: BorderSide(
                              color: const Color(0xFF035E53),
                              width: 2,
                            ),
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 50,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          'Croffle Ice Cream',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Berikut ringkasan bahan-bahannya...',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // Favorites and Time in one row
                                    Row(
                                      children: [
                                        Image.asset(
                                          'images/star_hijau.png',
                                          width: 16,
                                          height: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        const Text(
                                          '213',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        const SizedBox(width: 12),
                                        Image.asset(
                                          'images/time.png',
                                          width: 16,
                                          height: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        const Text(
                                          '15menit',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    // Price below
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      child: const Text(
                                        'RP 20RB',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF57B4BA),
                                          fontWeight: FontWeight.bold,
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
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // Your Recipes section
  Widget _buildYourRecipes(
    context,
    String recipesText,
    Color textColor,
    Color backgroundColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20), // Added border radius
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Padding(
            padding: const EdgeInsets.only(left: 30, right: 20, top: 16, bottom: 16),  // Changed left padding to 30
            child: GestureDetector(
              onTap: () {
              Navigator.pushNamed(context, '/resep-anda');
              },
              child: Text(
              recipesText,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              ),
            ),
            
          ),
          Container(
            height: 250, // Increased height to accommodate the food card
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 30, right: 16),  // Changed left padding to 30
              children: [
                Center(
                  child: SizedBox(
                    width: 180, // Control the width of the food card
                    child: _buildFoodCard( context,
                      {
                        'name': 'Gulai',
                        'image': 'images/gulai.jpg',
                        'likes': 15,
                        'duration': '50menit',
                        'price': '50RB',
                        'description': 'Gulai ayam dengan santan kental dan rempah'
                      },
                      borderColor: Colors.white, // Warna border putih untuk kontras dengan background hijau
                      nameColor: Colors.white, // Warna nama putih
                      descriptionColor: Colors.white.withOpacity(0.8), // Warna deskripsi putih dengan opacity
                    ),
                  ),
                ),
                Center(
                  child: SizedBox(
                    width: 180, // Control the width of the food card
                    child: _buildFoodCard(context,
                      
                      {
                        'name': 'Martabak Manis',
                        'image': 'images/martabak_manis.png',
                        'likes': 9,
                        'duration': '20menit',
                        'price': '30RB',
                        'description': 'Martabak dengan coklat dan keju'
                      },
                      borderColor: Colors.white, // Warna border putih untuk kontras dengan background hijau
                      nameColor: Colors.white, // Warna nama putih
                      descriptionColor: Colors.white.withOpacity(0.8), // Warna deskripsi putih dengan opacity
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20), // Padding bawah sebesar 20
        ],
      ),
    );
  }

  Widget _buildRecentlyAddedRecipe(
    context,
    String recipesText,
    Color textColor,
    Color backgroundColor,
  ) {
    return Container(
      color: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 20, top: 16, bottom: 16),  // Changed left padding to 30
            child: Text(
              recipesText,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          Container(
            height: 250, // Increased height to accommodate the food card
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 30, right: 16),  // Changed left padding to 30
              children: [
                Center(
                  child: SizedBox(
                    width: 180, // Control the width of the food card
                    child: _buildFoodCard(
                      context,
                      {
                        'name': 'Pasta',
                        'image': 'images/pasta.png',
                        'likes': 12,
                        'duration': '30menit',
                        'price': '40RB',
                        'description': 'Pasta dengan saus carbonara dan bacon'
                      },
                      borderColor: const Color(0xFF035E53), // Warna border hijau untuk kontras dengan background putih
                      nameColor: const Color(0xFF035E53), // Warna nama hijau
                      descriptionColor: const Color(0xFF035E53).withOpacity(0.7), // Warna deskripsi hijau dengan opacity
                    ),
                  ),
                ),
                Center(
                  child: SizedBox(
                    width: 180, // Control the width of the food card
                    child: _buildFoodCard(
                      context,
                      {
                        'name': 'Lemonade',
                        'image': 'images/lemon.png',
                        'likes': 7,
                        'duration': '10menit',
                        'price': '25RB',
                        'description': 'Minuman segar dengan lemon dan mint'
                      },
                      borderColor: const Color(0xFF035E53), // Warna border hijau untuk kontras dengan background putih
                      nameColor: const Color(0xFF035E53), // Warna nama hijau
                      descriptionColor: const Color(0xFF035E53).withOpacity(0.7), // Warna deskripsi hijau dengan opacity
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20), // Padding bawah sebesar 20
        ],
      ),
    );
  }

  Widget _buildFoodCard( context,
    Map<String, dynamic> food, {
    Color borderColor = const Color(0xFF015551),
    Color nameColor = const Color(0xFF3E2823),
    Color descriptionColor = const Color(0xFF3E2823),
  }) {
    return IntrinsicHeight(
      child: Container(
        margin: const EdgeInsets.only(right: 10, left: 10),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Food image with position settings
            Container(
              height: 160,
              width: double.infinity,
              alignment: Alignment.topRight,
              child: Stack(
                children: [
                  // Food image with rounded corners
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      food['image'],
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Favorite button (heart icon)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage('images/love.png'),
                        fit: BoxFit.cover,
                      ),
                      shape: BoxShape.circle,
                      ),
                    ),
                    ),
                ],
              ),
            ),
            IntrinsicHeight(
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide.none, // Menghilangkan border atas
                    left: BorderSide(
                      color: borderColor,
                      width: 2,
                    ),
                    right: BorderSide(
                      color: borderColor,
                      width: 2,
                    ),
                    bottom: BorderSide(
                      color: borderColor,
                      width: 2,
                    ),
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 0),
                margin: const EdgeInsets.symmetric(horizontal: 7),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Food Name and Description
                    Container(
                      margin: const EdgeInsets.only(bottom: 4, left: 10, right: 10, top: 4),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            food['name'],
                            style: TextStyle(
                              color: nameColor,
                              fontSize: 12, // Reduced font size
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            food['description'],
                            style: TextStyle(
                              color: descriptionColor,
                              fontSize: 10, // Reduced font size
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Likes, Duration, Price
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            children: [
                              Text(
                                food['likes'].toString(),
                                style: const TextStyle(
                                  color: Color(0xFF57B4BA),
                                  fontSize: 10, // Reduced font size
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.star,
                                color: Color(0xFF57B4BA),
                                size: 12,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: Color(0xFF57B4BA),
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                food['duration'],
                                style: const TextStyle(
                                  color: Color(0xFF57B4BA),
                                  fontSize: 10, // Reduced font size
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Text(
                                "RP",
                                style: TextStyle(
                                  color: Color(0xFF57B4BA),
                                  fontSize: 10, // Reduced font size
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                food['price'],
                                style: const TextStyle(
                                  color: Color(0xFF57B4BA),
                                  fontSize: 10, // Reduced font size
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Top Users section
  Widget _buildTopUsers(context) {
    final List<Map<String, String>> users = [
      {'name': 'Cecep', 'avatar': 'images/cecep.png'},
      {'name': 'Andre', 'avatar': 'images/andre.png'},
      {'name': 'Maya', 'avatar': 'images/miya.png'},
      {'name': 'Mila', 'avatar': 'images/mila.png'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 30, right: 20, top: 16, bottom: 16),  // Changed left padding to 30
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/pengguna-terbaik');
            },
            child: Text(
              'Pengguna Terbaik   >',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF035E53),
              ),
            ),
          ),
        ),
        Container(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 30, right: 16),  // Changed left padding to 30
            itemCount: users.length,
            itemBuilder: (context, index) {
              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        12,
                      ), // This ensures the image is clipped with rounded corners
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFE6F2F2),
                            width: 2,
                          ),
                          image: DecorationImage(
                            image: AssetImage(users[index]['avatar']!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      users[index]['name']!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}










