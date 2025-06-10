import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../view/component/header_back.dart'; // Import the HeaderWidget
import '../../view/component/bottom_navbar.dart'; // Import BottomNavbar

class ReviewPage extends StatelessWidget {
  const ReviewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wrap with BottomNavbar
    return BottomNavbar(
      Scaffold(
        backgroundColor: const Color(0xFFF5F7F7),
        body: SafeArea(
          child: Column(
            children: [
              // Using the HeaderWidget component instead of custom header
              HeaderWidget(
                title: 'Ulasan & Diskusi',
                onBackPressed: () {
                  Navigator.pop(context);
                },
                // No need for rightWidget as it's optional
              ),
              Expanded(
                child: _buildReviewsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reviews list
  Widget _buildReviewsList() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 90), // Add bottom padding to prevent content from being hidden by navbar
      children: [
        // Recipe Card
        _buildRecipeCard(),

        // Reviews
        _buildReviewCard(
          username: '@yudapratama',
          name: 'Yuda Pratama',
          profileImage: 'images/yuda.png',
          reviewImage: 'images/croffle-1.png',
          rating: 4,
          review: 'Croffle-nya enak tapi menurut saya terlalu manis tapi overall resep ini bagus',
          commentCount: 10,
        ),

        _buildReviewCard(
          username: '@entin_cio',
          name: 'Entin Cio',
          profileImage: 'images/entin_cio.png',
          reviewImage: 'images/croffle-2.png',
          rating: 3,
          review: 'Not my best croffle ice cream tapi cukup enak',
          commentCount: 5,
        ),
      ],
    );
  }

  // Recipe info card with image on left, text on right
  Widget _buildRecipeCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF035E53),
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
      child: Row(
        children: [
          // Left side - Image with rounded edges and right padding
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12), // padding from left and right
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12), // rounded edges
              child: Image.asset(
                'images/croffle.png',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Right side - Text content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Croffle Ice Cream',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      for (int i = 0; i < 4; i++)
                        Image.asset(
                          'images/star.png',
                          width: 16,
                          height: 16,
                        ),
                      Image.asset(
                        'images/empty_star.png',
                        width: 16,
                        height: 16,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '(213 Reviews)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundImage: const AssetImage('images/xyfebrian.png'),
                      ),
                      const SizedBox(width: 6),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '@xyfebrian',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'William Smith',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white70,
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

  // Individual review card
  Widget _buildReviewCard({
    required String username,
    required String name,
    required String profileImage,
    required String reviewImage,
    required int rating,
    required String review,
    required int commentCount,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFB0DCDC),
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
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
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
                        color: Color(0xFF035E53),
                      ),
                    ),
                    Text(
                      name,
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
          // Review Image positioned below the text and left aligned
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: Container(
              height: 140,
              width: 140,  // Ensures it spans the available width
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage(reviewImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    for (int i = 0; i < rating; i++)
                      Padding(
                        padding: const EdgeInsets.only(right: 2),
                        child: Image.asset(
                          'images/star.png',
                          width: 16,
                          height: 16,
                        ),
                      ),
                    for (int i = 0; i < 5 - rating; i++)
                      Padding(
                        padding: const EdgeInsets.only(right: 2),
                        child: Image.asset(
                          'images/empty_star.png',
                          width: 16,
                          height: 16,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  review,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Transform.translate(
              offset: const Offset(0, 12),
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF035E53),
                  borderRadius: BorderRadius.circular(8), // Less rounded, more rectangular
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline,
                      size: 20,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$commentCount Komentar',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}