// File: lib/models/user_profile_model.dart

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

    factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json["id"] as int, 
        // Menggunakan toString() untuk memastikan String, dan fallback jika null
        username: json["username"]?.toString() ?? 'unknown_username', 
        // Menggunakan toString() untuk memastikan String, dan fallback jika null
        fullName: json["full_name"]?.toString() ?? json["username"]?.toString() ?? 'unknown_full_name', 
        // Menggunakan toString() untuk memastikan String, dan fallback jika null
        email: json["email"]?.toString() ?? 'unknown@example.com', 
        cookingLevel: json["cooking_level"] as String?, 
        bio: json["bio"] as String?, 
        profilePicture: json["profile_picture_url"] as String?, 
        // Konversi ke int dan default ke 0 jika null
        recipeCount: (json["total_recipes"] as num?)?.toInt() ?? 0, 
        // Default ke 0 jika null atau tidak ada
        followersCount: (json["followers_count"] as num?)?.toInt() ?? 0, 
        followingCount: (json["following_count"] as num?)?.toInt() ?? 0, 
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "full_name": fullName,
        "email": email,
        "cooking_level": cookingLevel,
        "bio": bio,
        "profile_picture_url": profilePicture, 
        "total_recipes": recipeCount, 
        "followers_count": followersCount,
        "following_count": followingCount,
    };
}