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

  group('trackEvent', () {
    test('custom event sends the same arguments as before', () async {
      await LinkRunner().trackEvent(
        eventName: 'add_to_cart',
        eventData: {'sku': 'a1'},
        eventId: 42,
      );

      expect(calls, hasLength(1));
      expect(calls.single.method, 'trackEvent');
      expect(calls.single.arguments, {
        'eventName': 'add_to_cart',
        'eventData': {'sku': 'a1'},
        'eventId': '42',
      });
    });

    test('without eventData or eventId sends an empty eventData map only', () async {
      await LinkRunner().trackEvent(eventName: 'open');

      expect(calls.single.arguments, {'eventName': 'open', 'eventData': {}});
    });

    test('custom event with amount and currency in eventData is passed unchanged', () async {
      await LinkRunner().trackEvent(
        eventName: 'cart_value',
        eventData: {'amount': 250, 'currency': 'INR', 'status': 'open', 'userId': 'u_7'},
      );

      expect(calls.single.arguments, {
        'eventName': 'cart_value',
        'eventData': {'amount': 250, 'currency': 'INR', 'status': 'open', 'userId': 'u_7'},
      });
    });

    test('payment fields in eventData pass through with numbers kept as numbers', () async {
      await LinkRunner().trackEvent(
        eventName: 'FIRST_PAYMENT',
        eventData: {
          'amount': 1200,
          'paymentId': 'bk_10231',
          'currency': 'INR',
          'userId': 'playo_u_8842',
          'venue_id': 'v_221',
        },
      );

      final eventData = (calls.single.arguments as Map)['eventData'] as Map;
      expect(calls.single.arguments['eventName'], 'FIRST_PAYMENT');
      expect(eventData['amount'], 1200);
      expect(eventData['amount'], isA<num>());
      expect(eventData, {
        'amount': 1200,
        'paymentId': 'bk_10231',
        'currency': 'INR',
        'userId': 'playo_u_8842',
        'venue_id': 'v_221',
      });
    });

    test('PaymentStatus in eventData is sent as its name', () async {
      final eventData = {
        'amount': 1200.5,
        'paymentId': 'bk_10231',
        'currency': 'INR',
        'userId': '',
        'status': PaymentStatus.PAYMENT_CANCELLED,
      };
      await LinkRunner().trackEvent(eventName: 'FIRST_PAYMENT', eventData: eventData);

      final sent = (calls.single.arguments as Map)['eventData'] as Map;
      expect(sent['status'], 'PAYMENT_CANCELLED');
      expect(sent['amount'], 1200.5);
      expect(eventData['status'], PaymentStatus.PAYMENT_CANCELLED);
    });

    test('a status string is passed through as is', () async {
      await LinkRunner().trackEvent(
        eventName: 'FIRST_PAYMENT',
        eventData: {'amount': 1, 'paymentId': 'p', 'currency': 'INR', 'userId': 'u', 'status': 'PAYMENT_FAILED'},
      );

      expect(((calls.single.arguments as Map)['eventData'] as Map)['status'], 'PAYMENT_FAILED');
    });

    test('rethrows native errors', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        throw PlatformException(
            code: 'TRACK_EVENT_FAILED', message: 'amount, paymentId and currency must be sent together');
      });

      await expectLater(
        LinkRunner().trackEvent(eventName: 'FIRST_PAYMENT', eventData: {'amount': 1, 'paymentId': 'p'}),
        throwsA(isA<PlatformException>()),
      );
    });
  });
}
