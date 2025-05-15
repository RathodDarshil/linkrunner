class LRUserData {
  final String id;
  final String? name;
  final String? phone;
  final String? email;
  final String? mixpanelDistinctId;
  final String? amplitudeDeviceId;
  final String? posthogDistinctId;

  LRUserData({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.mixpanelDistinctId,
    this.amplitudeDeviceId,
    this.posthogDistinctId,
  });

  Map<String, String?> toJSON() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'mixpanel_distinct_id': mixpanelDistinctId,
      'amplitude_device_id': amplitudeDeviceId,
      'posthog_distinct_id': posthogDistinctId,
    };
  }
}
