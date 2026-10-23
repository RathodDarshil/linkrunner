import 'package:flutter_test/flutter_test.dart';
import 'package:linkrunner/models/lr_user_data.dart';

// LIN-3534: setUserData can be called right after init, before the app knows its user.
void main() {
  test('id-less user data omits id and keeps analytics ids', () {
    final json = LRUserData(mixpanelDistinctId: 'mp-1', moengageUserId: 'moe-1').toJSON();

    expect(json.containsKey('id'), isFalse);
    expect(json['mixpanel_distinct_id'], 'mp-1');
    expect(json['moengage_user_id'], 'moe-1');
  });

  test('empty id is treated as absent', () {
    expect(LRUserData(id: '', posthogDistinctId: 'ph-1').toJSON().containsKey('id'), isFalse);
  });

  test('id is sent when present', () {
    expect(LRUserData(id: 'user-1').toJSON()['id'], 'user-1');
  });
}
