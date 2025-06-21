// File: lib/models/category_model.dart
class Category {
  final int id;
  final String name;

  Category({
    required this.id,
    required this.name,
  });

 factory Category.fromJson(Map<String, dynamic> json) {
  return Category(
    id: (json['id'] ?? json['category_id'] ?? 0) as int, // fallback kalau null
    name: json['name']?.toString() ?? 'Tanpa Nama',      // aman dari null
  );
}


  Map<String, dynamic> toJson() {
    return {
      'category_id': id,
      'name': name,
    };
  }
}