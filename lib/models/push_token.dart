
class PushTokenInfo {
  final String fcmPushToken;
  final String apnPushToken;
  final String platformOS;

  const PushTokenInfo({
    required this.fcmPushToken,
    required this.apnPushToken,
    required this.platformOS,
  });
}
