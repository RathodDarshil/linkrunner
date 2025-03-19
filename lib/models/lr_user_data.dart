class LRUserData {
  final String id;
  final String? name;
  final String? phone;
  final String? email;
  final String? mixpanelDistinctId;
  final String? amplitudeUserId;
  final String? posthogDistinctId;

  LRUserData({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.mixpanelDistinctId,
    this.amplitudeUserId,
    this.posthogDistinctId,
  });

  Map<String, String?> toJSON() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'mixpanel_distinct_id': mixpanelDistinctId,
      'amplitude_user_id': amplitudeUserId,
      'posthog_distinct_id': posthogDistinctId,
    };
  }
}
