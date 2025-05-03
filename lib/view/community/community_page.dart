import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KomunitasPage extends StatelessWidget {
  const KomunitasPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Set status bar menjadi visible dengan transparansi
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      // Memungkinkan body mengisi area di belakang status bar
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: _buildRecipeList(),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // Sisa kode sama seperti sebelumnya
  // Header with title and action buttons
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: Image.asset(
            'images/arrow.png',
            height: 24,
            width: 24,
          ),
            onPressed: () {},
          ),
          const Expanded(
            child: Text(
              'Komunitas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF035E53),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF035E53),
              borderRadius: BorderRadius.circular(50),
            ),
            margin: const EdgeInsets.only(right: 8),
            child: Image.asset(
              'images/notif.png',
              height: 28,
              width: 28,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF035E53),
              borderRadius: BorderRadius.circular(50),
            ),
            margin: const EdgeInsets.only(right: 8),
            child: Image.asset(
              'images/search.png',
              height: 28,
              width: 28,
            ),
          ),
        ],
      ),
    );
  }

  // Tab bar for Trending, Newest, Oldest
  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Center(  // Wrap the Row with Center widget
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,  // Center the tabs horizontally
          mainAxisSize: MainAxisSize.min,  // Make the Row take only needed space
          children: [
            _buildTab('Trending', isSelected: true),
            const SizedBox(width: 16),
            _buildTab('Terbaru', isSelected: false),
            const SizedBox(width: 16),
            _buildTab('Terlama', isSelected: false),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String text, {required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF035E53) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF035E53),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
      ),
    );
  }

  // Recipe list
  Widget _buildRecipeList() {
    // Recipe data
    final List<Map<String, dynamic>> recipes = [
      {
        'username': '@xyfebrian',
        'profileImage': 'images/xyfebrian.png',
        'timeAgo': '2 menit lalu',
        'recipeImage': 'images/croffle.png',
        'title': 'Croffle Ice Cream',
        'description': 'Resep ini simpel dan cepat disiapkan, pas untuk hari sibuk.',
        'likes': '48',
        'comments': '41',
      },
      {
        'username': '@bagas_pratama',
        'profileImage': 'images/bagas.png',
        'timeAgo': '1 jam lalu',
        'recipeImage': 'images/lumpia.png',
        'title': 'Lumppia',
        'description': 'Lumpia adalah camilan atau hidangan pembuka yang populer dan lezat dari berbagai masakan Asia.',
        'likes': '580',
        'comments': '357',
      },
      {
        'username': '@chef_maya',
        'profileImage': 'images/maya.png',
        'timeAgo': '1 jam 25 menit lalu',
        'recipeImage': 'images/es_teh_hijau.png',
        'title': 'Es Teh Hijau',
        'description': 'Es teh hijau adalah minuman segar dan sehat, cocok dinikmati saat cuaca panas. Berikut resep sederhananya...',
        'likes': '180',
        'comments': '79',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(0),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return _buildRecipeCard(
          username: recipe['username'],
          profileImage: recipe['profileImage'],
          timeAgo: recipe['timeAgo'],
          recipeImage: recipe['recipeImage'],
          title: recipe['title'],
          description: recipe['description'],
          likes: recipe['likes'],
          comments: recipe['comments'],
        );
      },
    );
  }

  // Individual recipe card
  Widget _buildRecipeCard({
    required String username,
    required String profileImage,
    required String timeAgo,
    required String recipeImage,
    required String title,
    required String description,
    required String likes,
    required String comments,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: AssetImage(profileImage),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Recipe image
          Stack(
            children: [
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(recipeImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Favorite button
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_border,
                    color: Color(0xFF035E53),
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          // Recipe info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF035E53),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Likes and comments side by side
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.favorite,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              likes,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.comment,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              comments,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
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
    );
  }

  // Bottom Navigation Bar
  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF035E53),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        currentIndex: 1, // Community tab selected
        onTap: (index) {},
      ),
    );
  }
}