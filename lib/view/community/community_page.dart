import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../view/component/header_b_n_s.dart'; // Import CustomHeader
import '../../view/component/bottom_navbar.dart'; // Import BottomNavbar
import '../../theme/theme.dart';

class KomunitasPage extends StatefulWidget {
  const KomunitasPage({Key? key}) : super(key: key);
  @override
  State<KomunitasPage> createState() => _KomunitasPageState();
}

class _KomunitasPageState extends State<KomunitasPage> {
  // Define tab options
  final List<String> _tabs = ['Trending', 'Terbaru', 'Terlama'];

  // Track the currently selected tab
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Using BottomNavbar widget the same way as CategoryPage does
    return BottomNavbar(
      _buildMainContent(),
    );
  }

  // Widget that contains the main content of KomunitasPage
  Widget _buildMainContent() {
    return Scaffold(
      extendBody: true, // Let body extend behind the navigation bar
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false, // Content can extend below safe area
        child: Column(
          children: [
            // Using CustomHeader component
            CustomHeader(
              title: 'Komunitas',
              titleColor: Color(0xFF035E53),
              // No need to provide callback as handler is already in CustomHeader
            ),
            _buildTabBar(),
            Expanded(
              child: _buildRecipeList(),
            ),
          ],
        ),
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
          children: List.generate(_tabs.length, (index) {
            return Row(
              children: [
                _buildTab(_tabs[index],
                    isSelected: _selectedTabIndex == index,
                    onTap: () => _onTabSelected(index)
                ),
                // Add spacing between tabs, except after the last tab
                if (index < _tabs.length - 1) const SizedBox(width: 16),
              ],
            );
          }),
        ),
      ),
    );
  }

  // Build individual tab with tap functionality
  Widget _buildTab(String text, {required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }

  // Handler for tab selection
  void _onTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
    // Here you can also add logic to load different content based on the selected tab
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
      padding: const EdgeInsets.only(bottom: 90), // Mengubah padding untuk memberikan ruang di bawah agar tidak tertutup oleh navbar
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

                  child: Image.asset(
                      'images/love.png',
                      width: 30,
                      height: 30
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
}
