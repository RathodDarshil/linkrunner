class LRUserData {
  final String id;
  final String? name;
  final String? phone;
  final String? email;
  final String? isFirstTimeUser;
  final String? userCreatedAt;

  LRUserData({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.isFirstTimeUser,
    this.userCreatedAt,
  });

  Map<String, String?> toJSON() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'is_first_time_user': isFirstTimeUser,
      'user_created_at': userCreatedAt,
    };
  }
}
