// lib/view/component/header_b_l_s.dart

import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class RecipeDetailHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBackPressed;
  final int likes;
  final int comments;
  final VoidCallback? onLikePressed;
  final VoidCallback? onSharePressed;

  // MODIFIED: Parameter baru ditambahkan di sini
  final bool isOwner;
  final VoidCallback? onEditPressed;
  final VoidCallback? onDeletePressed;

  const RecipeDetailHeader({
    Key? key,
    required this.title,
    required this.onBackPressed,
    required this.likes,
    required this.comments,
    this.onLikePressed,
    this.onSharePressed,
    // MODIFIED: Tambahkan parameter baru ke constructor
    this.isOwner = false,
    this.onEditPressed,
    this.onDeletePressed,
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
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),

          // Action buttons (like, share, and more options)
          Row(
            mainAxisSize: MainAxisSize.min,
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

              // NEW: Tampilkan menu opsi jika pengguna adalah pemilik resep
              if (isOwner)
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: AppTheme.primaryColor),
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEditPressed?.call();
                    } else if (value == 'delete') {
                      onDeletePressed?.call();
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit Resep'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Hapus Resep'),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}