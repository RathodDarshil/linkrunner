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
    test('without payment sends the same arguments as before', () async {
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

    test('with payment passes the payment fields through', () async {
      await LinkRunner().trackEvent(
        eventName: 'purchase',
        eventData: {'plan': 'pro'},
        payment: EventPayment(
          amount: 9.99,
          paymentId: 'pay_1',
          currency: 'usd',
          status: PaymentStatus.PAYMENT_COMPLETED,
        ),
      );

      expect(calls.single.method, 'trackEvent');
      expect(calls.single.arguments, {
        'eventName': 'purchase',
        'eventData': {'plan': 'pro'},
        'payment': {
          'amount': 9.99,
          'paymentId': 'pay_1',
          'currency': 'USD',
          'status': 'PAYMENT_COMPLETED',
        },
      });
    });

    test('payment status is optional and omitted when not set', () async {
      await LinkRunner().trackEvent(
        eventName: 'purchase',
        payment: EventPayment(amount: 0, paymentId: 'pay_2', currency: 'INR'),
      );

      final payment = (calls.single.arguments as Map)['payment'] as Map;
      expect(payment, {'amount': 0.0, 'paymentId': 'pay_2', 'currency': 'INR'});
      expect(payment.containsKey('status'), isFalse);
    });

    test('rethrows native errors', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        throw PlatformException(code: 'INVALID_ARGUMENT', message: 'Invalid payment');
      });

      await expectLater(
        LinkRunner().trackEvent(
          eventName: 'purchase',
          payment: EventPayment(amount: 1, paymentId: 'p', currency: 'USD'),
        ),
        throwsA(isA<PlatformException>()),
      );
    });
  });

  group('EventPayment validation', () {
    test('rejects negative, NaN and infinite amounts', () {
      for (final amount in [-0.01, double.nan, double.infinity, double.negativeInfinity]) {
        expect(
          () => EventPayment(amount: amount, paymentId: 'p', currency: 'USD'),
          throwsArgumentError,
          reason: 'amount $amount',
        );
      }
    });

    test('rejects blank paymentId', () {
      for (final id in ['', '   ']) {
        expect(
          () => EventPayment(amount: 1, paymentId: id, currency: 'USD'),
          throwsArgumentError,
        );
      }
    });

    test('rejects currency that is not 3 letters', () {
      for (final currency in ['', 'US', 'USDT', 'U5D', '\$\$\$', 'ÜSD']) {
        expect(
          () => EventPayment(amount: 1, paymentId: 'p', currency: currency),
          throwsArgumentError,
          reason: 'currency "$currency"',
        );
      }
    });

    test('normalizes currency to trimmed upper case', () {
      expect(EventPayment(amount: 1, paymentId: 'p', currency: ' eur ').currency, 'EUR');
    });

    test('invalid payment never reaches the native channel', () async {
      expect(
        () => LinkRunner().trackEvent(
          eventName: 'purchase',
          payment: EventPayment(amount: -1, paymentId: 'p', currency: 'USD'),
        ),
        throwsArgumentError,
      );
      expect(calls, isEmpty);
    });
  });
}
