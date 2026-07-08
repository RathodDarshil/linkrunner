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
  final String? adNetworkCampaignId;
  final String? adSetId;
  final String? adSetName;
  final String? adCreativeId;
  final String? adCreativeName;
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
    this.adNetworkCampaignId,
    this.adSetId,
    this.adSetName,
    this.adCreativeId,
    this.adCreativeName,
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
      adNetworkCampaignId: json['ad_network_campaign_id'] as String?,
      adSetId: json['ad_set_id'] as String?,
      adSetName: json['ad_set_name'] as String?,
      adCreativeId: json['ad_creative_id'] as String?,
      adCreativeName: json['ad_creative_name'] as String?,
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
      'ad_network_campaign_id': adNetworkCampaignId,
      'ad_set_id': adSetId,
      'ad_set_name': adSetName,
      'ad_creative_id': adCreativeId,
      'ad_creative_name': adCreativeName,
      'type': type,
      'installed_at': installedAt,
      'store_click_at': storeClickAt,
    };
  }
}
