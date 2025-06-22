import 'dart:convert';

ScheduledFood scheduledFoodFromJson(String str) => ScheduledFood.fromJson(json.decode(str));
String scheduledFoodToJson(ScheduledFood data) => json.encode(data.toJson());

class ScheduledFood {
  final int id;
  final int userId;
  final int recipeId;
  final String mealType; // Contoh: Sarapan, Makan Siang
  final DateTime date;

  // Informasi tambahan dari JOIN backend
  final String? recipeTitle;
  final String? recipeImageUrl;
  final int? recipeCookingTime;
  final int? recipePrice;
  final int? recipeRating;
  final String? recipeDescription;

  ScheduledFood({
    required this.id,
    required this.userId,
    required this.recipeId,
    required this.mealType,
    required this.date,
    this.recipeTitle,
    this.recipeImageUrl,
    this.recipeCookingTime,
    this.recipePrice,
    this.recipeRating,
    this.recipeDescription,
  });

  factory ScheduledFood.fromJson(Map<String, dynamic> json) {
    return ScheduledFood(
      id: json['id'],
      userId: json['user_id'],
      recipeId: json['recipe_id'],
      mealType: json['meal_type'],
      date: DateTime.parse(json['date']),
      recipeTitle: json['recipe_title'],
      recipeImageUrl: json['recipe_image_url'],
      recipeCookingTime: json['recipe_cooking_time'],
      recipePrice: json['recipe_price'],
      recipeRating: json['recipe_rating'], // Harus diberi alias di backend kalau AVG
      recipeDescription: json['recipe_description'],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "recipe_id": recipeId,
        "meal_type": mealType,
        "date": date.toIso8601String().split('T')[0],
        "recipe_title": recipeTitle,
        "recipe_image_url": recipeImageUrl,
        "recipe_cooking_time": recipeCookingTime,
        "recipe_price": recipePrice,
        "recipe_rating": recipeRating,
        "recipe_description": recipeDescription,
      };
}
