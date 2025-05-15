
class PushTokenInfo {
  final String fcmPushToken;
  final String? apnsPushToken;
  final String platformOS;

  const PushTokenInfo({
    required this.fcmPushToken,
    this.apnsPushToken,
    required this.platformOS,
  });
}
