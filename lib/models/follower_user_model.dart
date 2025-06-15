// File: lib/models/follower_user_model.dart

class FollowerUser {
  final int id;
  final String username;
  final String fullName;
  final String? profilePicture;
  bool isFollowing; // Status apakah SAYA (pengguna login) mengikuti user ini

  FollowerUser({
    required this.id,
    required this.username,
    required this.fullName,
    this.profilePicture,
    required this.isFollowing,
  });

  factory FollowerUser.fromJson(Map<String, dynamic> json) {
    return FollowerUser(
      id: json['id'],
      username: json['username'],
      fullName: json['full_name'],
      profilePicture: json['profile_picture'],
      // API harusnya memberikan status follow dari perspektif pengguna yang login
      // 'isFollowedByMe' adalah alias yang saya sarankan di query SQL sebelumnya
      isFollowing: (json['isFollowedByMe'] == 1 || json['isFollowedByMe'] == true),
    );
  }
}