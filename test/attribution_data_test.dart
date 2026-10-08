import 'package:flutter_test/flutter_test.dart';
import 'package:linkrunner/models/attribution_data.dart';

void main() {
  final campaign = <String, dynamic>{'id': 'c1', 'name': 'Campaign', 'type': 'ORGANIC'};

  group('AttributionData', () {
    test('parses gaid and leaves idfa null', () {
      final data = AttributionData.fromJSON({
        'deeplink': null,
        'campaign_data': campaign,
        'gaid': '38400000-8cf0-11bd-b23e-10b96e40000d',
        'idfa': null,
      });

      expect(data.gaid, '38400000-8cf0-11bd-b23e-10b96e40000d');
      expect(data.idfa, isNull);
      expect(data.toJSON()['gaid'], '38400000-8cf0-11bd-b23e-10b96e40000d');
    });

    test('parses idfa', () {
      final data = AttributionData.fromJSON({
        'campaign_data': campaign,
        'idfa': '6D92078A-8246-4BA4-AE5B-76104861E7DC',
      });

      expect(data.idfa, '6D92078A-8246-4BA4-AE5B-76104861E7DC');
      expect(data.gaid, isNull);
    });

    test('parses a map without gaid and idfa', () {
      final data = AttributionData.fromJSON({
        'deeplink': 'https://example.com/path',
        'campaign_data': campaign,
      });

      expect(data.deeplink, 'https://example.com/path');
      expect(data.gaid, isNull);
      expect(data.idfa, isNull);
    });
  });
}
