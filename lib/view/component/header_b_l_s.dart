import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class RecipeDetailHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBackPressed;
  final int likes;
  final int comments;
  final VoidCallback? onLikePressed;
  final VoidCallback? onSharePressed;

  const RecipeDetailHeader({
    Key? key,
    required this.title,
    required this.onBackPressed,
    required this.likes,
    required this.comments,
    this.onLikePressed,
    this.onSharePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          GestureDetector(
            onTap: onBackPressed,
            child: Container(
              width: 30,
              height: 30,
              padding: const EdgeInsets.all(3),
              child: Image.asset(
                'images/arrow.png',
                color: AppTheme.primaryColor,
                width: 24,
                height: 24,
              ),
            ),
          ),

          // Title
          Text(
            title,
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),

          // Action buttons (like and share)
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                margin: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: Image.asset(
                    'images/love_hijau_tua.png',
                    width: 28,
                    height: 28,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: onLikePressed,
                ),
              ),
              Container(
                width: 30,
                height: 30,
                child: IconButton(
                  icon: Image.asset(
                    'images/share_button.png',
                    width: 28,
                    height: 28,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: onSharePressed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}