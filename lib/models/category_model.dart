// lib/models/category.dart

class Category {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl; // Menggunakan imageUrl agar konsisten

  Category({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
  });

  // Factory constructor untuk membuat instance Category dari JSON
  // Pastikan key-nya cocok dengan JSON dari backend Anda
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['image_url'], // cocokkan dengan 'image_url' dari backend
    );
  }
}