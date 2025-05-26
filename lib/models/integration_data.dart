class IntegrationData {
  final String? clevertapId;

  IntegrationData({
    this.clevertapId,
  });

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> data = {};
    
    if (clevertapId != null) data['clevertap_id'] = clevertapId;
    
    return data;
  }
}
