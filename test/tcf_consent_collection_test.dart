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

    // The native Android SDK has no TCF support, so the platform channel has no
    // handler for this method. Reaching it would throw MissingPluginException in
    // the caller's app, which is why the Dart layer returns before invoking it.
    test('is a no-op on Android', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      await LinkRunner().enableTCFConsentCollection(true);

      expect(calls, isEmpty);
    });
  });
}
