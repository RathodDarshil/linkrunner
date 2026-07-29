/// Tri-state consent signal for Google Ads.
///
/// [UNKNOWN] is a distinct state, not a synonym for [DENIED] or [GRANTED]. A signal left
/// unknown is reported as unknown and dropped from the payload, never sent as a denial.
enum ConsentStatus { GRANTED, DENIED, UNKNOWN }

/// Google Ads consent state, normally sourced from your Consent Management Platform.
///
/// Set it with `linkrunner.setConsent(...)` before `init`, and call it again whenever
/// your CMP state changes. Defaults to all-[ConsentStatus.UNKNOWN], which is reported
/// honestly rather than assumed permissive.
class LRConsent {
  /// Whether the user is in the European Economic Area, UK or Switzerland.
  final ConsentStatus isEEA;

  /// Consent to send user data to Google for advertising purposes.
  final ConsentStatus adUserData;

  /// Consent to use the data for ad personalization.
  final ConsentStatus adPersonalization;

  const LRConsent({
    this.isEEA = ConsentStatus.UNKNOWN,
    this.adUserData = ConsentStatus.UNKNOWN,
    this.adPersonalization = ConsentStatus.UNKNOWN,
  });

  Map<String, dynamic> toJSON() {
    return {
      'isEEA': isEEA.name,
      'adUserData': adUserData.name,
      'adPersonalization': adPersonalization.name,
    };
  }
}
