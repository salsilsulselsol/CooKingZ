// File: lib/models/scheduled_food_model.dart

import 'dart:convert';
// Import intl jika Anda menggunakannya di sini untuk format angka, tetapi untuk parsing tidak perlu.

ScheduledFood scheduledFoodFromJson(String str) => ScheduledFood.fromJson(json.decode(str));
String scheduledFoodToJson(ScheduledFood data) => json.encode(data.toJson());

class ScheduledFood {
  final int id;
  final int userId;
  final int recipeId;
  final DateTime date;

  // Data dari tabel recipes (disesuaikan dengan alias dari query SQL)
  final String? recipeTitle;
  final String? recipeDescription;
  final int? recipeCookingTime;
  final String? recipeDifficulty;
  final int? recipePrice;
  final String? recipeImageUrl;
  final String? recipeVideoUrl;
  final int? recipeFavoritesCount;
  
  final double? recipeRating; // <<< PERBAIKAN: UBAH DARI int? MENJADI double?

  ScheduledFood({
    required this.id,
    required this.userId,
    required this.recipeId,
    required this.date,
    this.recipeTitle,
    this.recipeDescription,
    this.recipeCookingTime,
    this.recipeDifficulty,
    this.recipePrice,
    this.recipeImageUrl,
    this.recipeVideoUrl,
    this.recipeFavoritesCount,
    this.recipeRating, // Tambahkan properti baru ke constructor
  });

  factory ScheduledFood.fromJson(Map<String, dynamic> json) {
    return ScheduledFood(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      recipeId: json['recipe_id'] as int,
      date: DateTime.parse(json['date']),

      recipeTitle: json['recipe_title'] as String?,
      recipeDescription: json['recipe_description'] as String?,
      recipeCookingTime: json['recipe_cooking_time'] as int?,
      recipeDifficulty: json['recipe_difficulty'] as String?,
      recipePrice: json['recipe_price'] as int?,
      recipeImageUrl: json['recipe_image_url'] as String?,
      recipeVideoUrl: json['recipe_video_url'] as String?,
      recipeFavoritesCount: json['recipe_favorites_count'] as int?,
      
      // <<< PERBAIKAN UNTUK recipeRating >>>
      recipeRating: json['recipe_rating'] != null 
          ? double.tryParse(json['recipe_rating'].toString()) // Coba parse dari String ke double
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "recipe_id": recipeId,
    "date": date.toIso8601String(),

    "recipe_title": recipeTitle,
    "recipe_description": recipeDescription,
    "recipe_cooking_time": recipeCookingTime,
    "recipe_difficulty": recipeDifficulty,
    "recipe_price": recipePrice,
    "recipe_image_url": recipeImageUrl,
    "recipe_video_url": recipeVideoUrl,
    "recipe_favorites_count": recipeFavoritesCount,
    
    "recipe_rating": recipeRating, // Tetap double saat dikonversi kembali ke JSON
  };
}
