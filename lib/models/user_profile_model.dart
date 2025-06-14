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
        id: json["id"],
        username: json["username"],
        fullName: json["full_name"],
        email: json["email"],
        cookingLevel: json["cooking_level"],
        bio: json["bio"],
        profilePicture: json["profile_picture"],
        recipeCount: json["recipe_count"],
        followersCount: json["followers_count"],
        followingCount: json["following_count"],
    );

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