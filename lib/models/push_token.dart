enum PushTokenType {
  FCM,
  APN
}

class PushTokenInfo {
  final String token;
  final PushTokenType tokenType;

  const PushTokenInfo({
    required this.token,
    required this.tokenType,
  });
}
