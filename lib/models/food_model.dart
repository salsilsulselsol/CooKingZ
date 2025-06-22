// lib/models/food_model.dart

import 'dart:convert';

// Fungsi konversi dari JSON string ke Food object (tidak langsung digunakan jika sudah ada Map)
Food foodFromJson(String str) => Food.fromJson(json.decode(str));
// Fungsi konversi dari Food object ke JSON string
String foodToJson(Food data) => json.encode(data.toMap());

class Food {
  final int? id;
  final String name;
  final String? description;
  final String image; // Field ini akan menyimpan URL gambar lengkap
  final int? cookingTime;
  final double? rating;
  final int? likes;
  final String? price;
  final String? difficulty;
  final String? detailRoute;

  Food({
    this.id,
    required this.name,
    this.description,
    required this.image,
    this.cookingTime,
    this.rating,
    this.likes,
    this.price,
    this.difficulty,
    this.detailRoute,
  });

  // Factory constructor untuk membuat objek Food dari Map (digunakan untuk parsing data dari API)
  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'] as int?,
      // PERBAIKAN: Mapping dari kunci API backend ke properti model Food
      // Backend mengembalikan 'name' untuk nama resep
      name: json['name']?.toString() ?? 'Resep Tanpa Nama',
      description: json['description']?.toString(),
      // Backend mengembalikan 'image' untuk URL gambar
      image: json['image']?.toString() ?? '',
      cookingTime: (json['cookingTime'] as num?)?.toInt() ?? 0,
      // Backend mengembalikan 'rating' untuk rata-rata ulasan
      rating: double.tryParse(json['rating']?.toString() ?? '') ?? 0.0,
      // Backend mengembalikan 'likes' untuk jumlah favorit
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      price: json['price']?.toString() ?? 'Gratis',
      difficulty: json['difficulty']?.toString(),
      detailRoute: null, // detailRoute tidak datang dari API, bisa diatur null
    );
  }

  // Method untuk mengubah objek Food menjadi Map (untuk kebutuhan toMap)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'cookingTime': cookingTime,
      'rating': rating,
      'likes': likes,
      'price': price,
      'difficulty': difficulty,
    };
  }
}
