class LRUserData {
  final String id;
  final String? name;
  final String? phone;
  final String? email;
  final String? clevertapId;

  LRUserData({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.clevertapId,
  });

  Map<String, String?> toJSON() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'clevertap_id': clevertapId,
    };
  }
}
