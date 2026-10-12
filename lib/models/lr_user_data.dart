/// User data for `signup` and `setUserData`.
///
/// [id] is your customer user id. `signup` requires it; `setUserData` does not, so it
/// can be called right after `init` with only analytics ids (for example
/// [mixpanelDistinctId]), before your app knows the user.
class LRUserData {
  final String? id;
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
  final String? gaSessionId;
  final String? netcoreDeviceGuid;
  final String? moengageUserId;

  LRUserData({
    this.id,
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
    this.gaSessionId,
    this.netcoreDeviceGuid,
    this.moengageUserId,
  });

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> result = {};

    // An empty id is treated as absent, so an id-less setUserData sends no id.
    if (id != null && id!.isNotEmpty) result['id'] = id;
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
    if (gaSessionId != null) result['ga_session_id'] = gaSessionId;
    if (netcoreDeviceGuid != null) result['netcore_device_guid'] = netcoreDeviceGuid;
    if (moengageUserId != null) result['moengage_user_id'] = moengageUserId;
    
    return result;
  }
}
