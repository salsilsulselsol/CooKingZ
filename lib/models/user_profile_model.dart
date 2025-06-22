// lib/models/user_profile_model.dart

import 'dart:convert';

UserProfile userProfileFromJson(String str) => UserProfile.fromJson(json.decode(str));

String userProfileToJson(UserProfile data) => json.encode(data.toJson());

class UserProfile {
    final int id;
    final String username;
    final String fullName; 
    final String email;    
    final String? cookingLevel;
    final String? bio;
    final String? profilePicture; 

    final int recipeCount;
    final int followersCount;
    final int followingCount;

    UserProfile({
        required this.id,
        required this.username,
        required this.fullName,
        required this.email,
        this.cookingLevel,
        this.bio,
        this.profilePicture,
        required this.recipeCount,
        required this.followersCount,
        required this.followingCount,
    });

    // ==== PERBAIKAN UTAMA ADA DI FUNGSI INI ====
    factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json["id"] as int, 
        username: json["username"]?.toString() ?? 'unknown_username', 
        fullName: json["full_name"]?.toString() ?? json["username"]?.toString() ?? 'unknown_full_name', 
        email: json["email"]?.toString() ?? 'unknown@example.com', 
        cookingLevel: json["cooking_level"] as String?, 
        bio: json["bio"] as String?, 
        // Menggunakan key "profile_picture" yang benar
        profilePicture: json["profile_picture"] as String?, 
        // Menggunakan key "recipe_count" yang benar
        recipeCount: (json["recipe_count"] as num?)?.toInt() ?? 0, 
        followersCount: (json["followers_count"] as num?)?.toInt() ?? 0, 
        followingCount: (json["following_count"] as num?)?.toInt() ?? 0, 
    );

    // Kita juga sesuaikan di toJson untuk konsistensi
    Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "full_name": fullName,
        "email": email,
        "cooking_level": cookingLevel,
        "bio": bio,
        "profile_picture": profilePicture, 
        "recipe_count": recipeCount, 
        "followers_count": followersCount,
        "following_count": followingCount,
    };
}