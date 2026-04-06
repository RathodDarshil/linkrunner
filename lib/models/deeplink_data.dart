class DeeplinkData {
  final bool isLinkrunner;
  final String? deeplink;
  final bool? processing;

  DeeplinkData({
    required this.isLinkrunner,
    this.deeplink,
    this.processing,
  });

  factory DeeplinkData.fromJSON(Map<String, dynamic>? json) {
    if (json == null) {
      throw ArgumentError('JSON data cannot be null');
    }

    final data = json['data'] as Map<String, dynamic>?;

    return DeeplinkData(
      isLinkrunner: data?['is_linkrunner'] as bool? ?? false,
      deeplink: data?['deeplink'] as String?,
      processing: data?['processing'] as bool?,
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      'is_linkrunner': isLinkrunner,
      'deeplink': deeplink,
      'processing': processing,
    };
  }
}
