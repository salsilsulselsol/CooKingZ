// File: lib/models/scheduled_food_model.dart
import 'dart:convert';
// Import Food model jika diperlukan di tempat lain, tapi ScheduledMeal akan mencakup detail resep sendiri.

ScheduledFood scheduledFoodFromJson(String str) => ScheduledFood.fromJson(json.decode(str));
String scheduledFoodToJson(ScheduledFood data) => json.encode(data.toJson());

class ScheduledFood { // Menggunakan nama kelas yang Anda inginkan
  final int id;
  final int userId;
  final int recipeId;
  final String mealType; // misal: 'Sarapan', 'Makan Siang', dll.
  final DateTime date;
  
  // Detail resep dari join di backend
  final String? recipeTitle;
  final String? recipeImageUrl; // Menggunakan String? untuk penanganan null

  ScheduledFood({
    required this.id,
    required this.userId,
    required this.recipeId,
    required this.mealType,
    required this.date,
    this.recipeTitle,
    this.recipeImageUrl,
  });

  factory ScheduledFood.fromJson(Map<String, dynamic> json) {
    return ScheduledFood(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      recipeId: json['recipe_id'] as int,
      mealType: json['meal_type'] as String,
      date: DateTime.parse(json['date']), // Tanggal dari backend harus string YYYY-MM-DD
      recipeTitle: json['recipe_title'] as String?, // Ambil dari 'recipe_title'
      recipeImageUrl: json['recipe_image_url'] as String?, // Ambil dari 'recipe_image_url'
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "recipe_id": recipeId,
        "meal_type": mealType,
        "date": date.toIso8601String().split('T')[0], // Hanya tanggal (YYYY-MM-DD)
        "recipe_title": recipeTitle,
        "recipe_image_url": recipeImageUrl,
      };
}