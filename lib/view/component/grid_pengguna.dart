// File: lib/view/component/grid_pengguna.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; 
import '../../theme/theme.dart';
import '../../models/user_profile_model.dart'; 

class ChefCard extends StatelessWidget {
  final UserProfile user; 
  final bool isFollowing; 
  final VoidCallback? onFollowToggle; 
  final bool useGreenBackground; 

  const ChefCard({
    Key? key,
    required this.user,
    this.isFollowing = false, 
    this.onFollowToggle,
    this.useGreenBackground = false, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Bangun URL gambar profil lengkap
    final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:3000/uploads';
    final String fullProfileImageUrl = user.profilePicture != null && user.profilePicture!.isNotEmpty
        ? '$baseUrl/${user.profilePicture!}'
        : ''; 

    return Container(
      width: 150, 
      margin: const EdgeInsets.only(right: 12.0, bottom: 12.0),
      decoration: BoxDecoration(
        color: useGreenBackground ? AppTheme.primaryColor : AppTheme.backgroundColor, 
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            ClipOval( 
              child: Container(
                width: 70, 
                height: 70,
                color: Colors.grey[200],
                child: fullProfileImageUrl.isNotEmpty
                    ? Image.network( // <<< Menggunakan Image.network untuk gambar dari URL API
                        fullProfileImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print('ERROR LOADING PROFILE IMAGE: $error for URL: $fullProfileImageUrl');
                          return Icon(Icons.person, size: 50, color: Colors.grey[600]);
                        },
                      )
                    : Icon(Icons.person, size: 50, color: Colors.grey[600]), 
              ),
            ),
            SizedBox(height: AppTheme.spacingMedium),
            Text(
              user.fullName.isNotEmpty ? user.fullName : user.username, 
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: useGreenBackground ? Colors.white : AppTheme.textBrown, 
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: AppTheme.spacingXSmall),
            Text(
              '@${user.username}',
              style: TextStyle(fontSize: 12, color: useGreenBackground ? Colors.white70 : Colors.grey), 
            ),
            SizedBox(height: AppTheme.spacingXSmall),
            Text(
              '${user.recipeCount} Resep', 
              style: TextStyle(fontSize: 12, color: useGreenBackground ? Colors.white : AppTheme.primaryColor), 
            ),
            SizedBox(height: AppTheme.spacingMedium),
            ElevatedButton(
              onPressed: onFollowToggle, 
              style: ElevatedButton.styleFrom(
                backgroundColor: isFollowing 
                    ? useGreenBackground ? Colors.white.withOpacity(0.8) : Colors.grey 
                    : useGreenBackground ? Colors.white : AppTheme.primaryColor, 
                foregroundColor: isFollowing 
                    ? useGreenBackground ? AppTheme.primaryColor : Colors.white 
                    : useGreenBackground ? AppTheme.primaryColor : Colors.white, 
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                textStyle: TextStyle(fontSize: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(isFollowing ? 'Mengikuti' : 'Ikuti'),
            ),
          ],
        ),
      ),
    );
  }
}