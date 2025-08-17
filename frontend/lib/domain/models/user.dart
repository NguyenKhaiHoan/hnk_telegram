class User {
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    this.isOnline = false,
    this.profilePicture,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isOnline: json['is_online'] as bool,
      profilePicture: json['profile_picture'] as String?,
    );
  }

  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
  final bool isOnline;
  final String? profilePicture;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'created_at': createdAt.toIso8601String(),
      'is_online': isOnline,
      'profile_picture': profilePicture,
    };
  }
}
