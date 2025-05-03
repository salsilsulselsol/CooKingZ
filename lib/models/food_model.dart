class Food {
  final int? id;
  final String name;
  final String? description;
  final String image;
  final int? cookingTime;
  final double? rating;
  final int? likes;
  final String? price;
  final String? difficulty;

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
  });

  factory Food.fromMap(Map<String, dynamic> map) {
    return Food(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      image: map['image'] as String,
      cookingTime: map['cookingTime'] as int?,
      rating: (map['rating'] as num?)?.toDouble(),
      likes: map['likes'] as int?,
      price: map['price'] as String?,
      difficulty: map['difficulty'] as String?,
    );
  }

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