import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkrunner/main.dart';

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
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  Map<dynamic, dynamic> initArgs() {
    final initCalls = calls.where((c) => c.method == 'init').toList();
    expect(initCalls, hasLength(1));
    return initCalls.single.arguments as Map<dynamic, dynamic>;
  }

  group('init privacyMode', () {
    test('omits privacyMode when not passed, so native keeps the stored value',
        () async {
      await LinkRunner().init('token');

      final args = initArgs();
      expect(args.containsKey('privacyMode'), isFalse);
      expect(args['token'], 'token');
      expect(args['debug'], false);
      expect(args['disableIdfa'], false);
      expect(args['platform'], 'FLUTTER');
    });

    test('omits privacyMode when passed as null', () async {
      await LinkRunner().init('token', null, null, false, false, null);

      expect(initArgs().containsKey('privacyMode'), isFalse);
    });

    test('forwards privacyMode true', () async {
      await LinkRunner().init('token', 'secret', 'key', false, true, true);

      final args = initArgs();
      expect(args['privacyMode'], true);
      expect(args['secretKey'], 'secret');
      expect(args['keyId'], 'key');
      expect(args['debug'], true);
    });

    test('forwards privacyMode false so a stored true can be turned off',
        () async {
      await LinkRunner().init('token', null, null, false, false, false);

      expect(initArgs()['privacyMode'], false);
    });
  });
}
