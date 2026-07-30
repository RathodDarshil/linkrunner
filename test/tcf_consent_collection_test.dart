import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkrunner/linkrunner.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('linkrunner_native');
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('enableTCFConsentCollection', () {
    test('forwards the flag to the native SDK on iOS', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      await LinkRunner().enableTCFConsentCollection(true);

      expect(calls, hasLength(1));
      expect(calls.single.method, 'enableTCFConsentCollection');
      expect(calls.single.arguments, {'enabled': true});
    });

    test('defaults to enabling collection', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      await LinkRunner().enableTCFConsentCollection();

      expect(calls.single.arguments, {'enabled': true});
    });

    test('forwards a disable call', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      await LinkRunner().enableTCFConsentCollection(false);

      expect(calls.single.arguments, {'enabled': false});
    });

    // The native Android SDK supports TCF from 4.2.0, so Android goes through the
    // same method channel handler as iOS.
    test('forwards the flag to the native SDK on Android', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      await LinkRunner().enableTCFConsentCollection(true);

      expect(calls, hasLength(1));
      expect(calls.single.method, 'enableTCFConsentCollection');
      expect(calls.single.arguments, {'enabled': true});
    });

    test('is a no-op on other platforms', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

      await LinkRunner().enableTCFConsentCollection(true);

      expect(calls, isEmpty);
    });
  });
}
