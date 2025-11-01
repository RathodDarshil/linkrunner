class LRUserData {
  final String id;
  final String? name;
  final String? phone;
  final String? email;
  final String? userCreatedAt; 
  final bool? isFirstTimeUser; 
  final String? mixpanelDistinctId; 
  final String? amplitudeDeviceId; 
  final String? posthogDistinctId;
  final String? brazeDeviceId;
  final String? gaAppInstanceId;

  LRUserData({
    required this.id,
    this.name,
    this.phone,
    this.email,
    this.userCreatedAt,
    this.isFirstTimeUser,
    this.mixpanelDistinctId,
    this.amplitudeDeviceId,
    this.posthogDistinctId,
    this.brazeDeviceId,
    this.gaAppInstanceId,
  });

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> result = {
      'id': id,
    };
    
    // Add optional fields only if they are not null
    if (name != null) result['name'] = name;
    if (phone != null) result['phone'] = phone;
    if (email != null) result['email'] = email;
    if (userCreatedAt != null) result['user_created_at'] = userCreatedAt;
    if (isFirstTimeUser != null) result['is_first_time_user'] = isFirstTimeUser;
    if (mixpanelDistinctId != null) result['mixpanel_distinct_id'] = mixpanelDistinctId;
    if (amplitudeDeviceId != null) result['amplitude_device_id'] = amplitudeDeviceId;
    if (posthogDistinctId != null) result['posthog_distinct_id'] = posthogDistinctId;
    if (brazeDeviceId != null) result['braze_device_id'] = brazeDeviceId;
    if (gaAppInstanceId != null) result['ga_app_instance_id'] = gaAppInstanceId;
    
    return result;
  }
}
