import 'ip_location_data.dart';

abstract class GeneralResponse {
  IPLocationData? ipLocationData;
  String? deeplink;
  bool? rootDomain;

  GeneralResponse();

  GeneralResponse.fromJSON(Map<String, dynamic>? json);

  Map<String, dynamic> toJSON();
}

class ClientCampaignData {
  final String id;
  final String name;
  final String type;
  final String? adNetwork;
  final String? groupName;
  final String? assetGroupName;
  final String? assetName;

  ClientCampaignData({
    required this.id,
    required this.name,
    required this.type,
    this.adNetwork,
    this.groupName,
    this.assetGroupName,
    this.assetName,
  });

  static ClientCampaignData? fromJSON(Map<String, dynamic>? json) {
    if (json == null) return null;
    return ClientCampaignData(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      adNetwork: json['ad_network'],
      groupName: json['group_name'],
      assetGroupName: json['asset_group_name'],
      assetName: json['asset_name'],
    );
  }

  Map<String, dynamic> toJSON() => {
        'id': id,
        'name': name,
        'type': type,
        'ad_network': adNetwork,
        'group_name': groupName,
        'asset_group_name': assetGroupName,
        'asset_name': assetName,
      };
}
