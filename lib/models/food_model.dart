class Food {
  final String name;
  final String description;
  final String image;
  final String duration;
  final String price;
  final int likes;
  
  Food({
    required this.name,
    required this.description,
    required this.image,
    required this.duration,
    required this.price,
    required this.likes,
  });
  
  // Convert from Map to Food object
  factory Food.fromMap(Map<String, dynamic> map) {
    return Food(
      name: map['name'] as String,
      description: map['description'] as String,
      image: map['image'] as String,
      duration: map['duration'] as String,
      price: map['price'] as String,
      likes: map['likes'] as int,
    );
  }
  
  // Convert Food object to Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'image': image,
      'duration': duration,
      'price': price,
      'likes': likes,
    };
  }
}