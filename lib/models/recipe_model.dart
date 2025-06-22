class Recipe {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime createdAt;
  final String username;
  final String? profilePicture; // Bisa jadi null
  final int favoritesCount;
  final int commentsCount;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.createdAt,
    required this.username,
    this.profilePicture,
    required this.favoritesCount,
    required this.commentsCount,
  });

  // Factory constructor untuk membuat instance Recipe dari JSON
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at']),
      username: json['username'],
      profilePicture: json['profile_picture'],
      favoritesCount: json['favorites_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
    );
  }
}