class AttributionData {
  final String? deeplink;
  final CampaignData campaignData;

  AttributionData({
    this.deeplink,
    required this.campaignData,
  });

  factory AttributionData.fromJSON(Map<String, dynamic>? json) {
    if (json == null) {
      throw ArgumentError('JSON data cannot be null');
    }
    return AttributionData(
      deeplink: json['deeplink'] as String?,
      campaignData: CampaignData.fromJSON(json['campaign_data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      'deeplink': deeplink,
      'campaign_data': campaignData.toJSON(),
    };
  }
}

class CampaignData {
  final String id;
  final String name;
  final String? adNetwork;
  final String? groupName;
  final String? assetGroupName;
  final String? assetName;
  final String type;
  final String installedAt;
  final String storeClickAt;

  CampaignData({
    required this.id,
    required this.name,
    this.adNetwork,
    this.groupName,
    this.assetGroupName,
    this.assetName,
    required this.type,
    required this.installedAt,
    required this.storeClickAt,
  });

  factory CampaignData.fromJSON(Map<String, dynamic>? json) {
    if (json == null) {
      throw ArgumentError('Campaign data cannot be null');
    }
    return CampaignData(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      adNetwork: json['ad_network'] as String?,
      groupName: json['group_name'] as String?,
      assetGroupName: json['asset_group_name'] as String?,
      assetName: json['asset_name'] as String?,
      type: json['type'] as String? ?? '',
      installedAt: json['installed_at'] as String? ?? '',
      storeClickAt: json['store_click_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'name': name,
      'ad_network': adNetwork,
      'group_name': groupName,
      'asset_group_name': assetGroupName,
      'asset_name': assetName,
      'type': type,
      'installed_at': installedAt,
      'store_click_at': storeClickAt,
    };
  }
}
