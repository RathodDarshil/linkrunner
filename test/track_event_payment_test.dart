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
          userId: 'user_1',
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
          'userId': 'user_1',
          'status': 'PAYMENT_COMPLETED',
        },
      });
    });

    test('payment status defaults to completed and is always sent', () async {
      await LinkRunner().trackEvent(
        eventName: 'purchase',
        payment: EventPayment(amount: 0, paymentId: 'pay_2', currency: 'INR', userId: ''),
      );

      final payment = (calls.single.arguments as Map)['payment'] as Map;
      expect(payment, {
        'amount': 0.0,
        'paymentId': 'pay_2',
        'currency': 'INR',
        'userId': '',
        'status': 'PAYMENT_COMPLETED',
      });
    });

    test('rethrows native errors', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        throw PlatformException(code: 'INVALID_ARGUMENT', message: 'Invalid payment');
      });

      await expectLater(
        LinkRunner().trackEvent(
          eventName: 'purchase',
          payment: EventPayment(amount: 1, paymentId: 'p', currency: 'USD', userId: 'u'),
        ),
        throwsA(isA<PlatformException>()),
      );
    });
  });


  group('trackPayment', () {
    test('sends a trackEvent call carrying the payment and userId', () async {
      await LinkRunner().trackPayment(
        eventName: 'first_payment',
        paymentId: 'order_456',
        userId: 'user_123',
        amount: 499.0,
        currency: 'inr',
        status: PaymentStatus.PAYMENT_INITIATED,
        eventData: {'plan': 'pro'},
      );

      expect(calls, hasLength(1));
      expect(calls.single.method, 'trackEvent');
      expect(calls.single.arguments, {
        'eventName': 'first_payment',
        'eventData': {'plan': 'pro'},
        'payment': {
          'amount': 499.0,
          'paymentId': 'order_456',
          'currency': 'INR',
          'userId': 'user_123',
          'status': 'PAYMENT_INITIATED',
        },
      });
    });

    test('status defaults to completed and eventData to an empty map', () async {
      await LinkRunner().trackPayment(
        eventName: 'DEFAULT',
        paymentId: 'p1',
        userId: 'user_1',
        amount: 10,
        currency: 'USD',
      );

      final args = calls.single.arguments as Map;
      expect(args['eventData'], {});
      expect(args.containsKey('eventId'), isFalse);
      expect((args['payment'] as Map)['status'], 'PAYMENT_COMPLETED');
    });

    test('passes a blank userId through for the native saved-user fallback', () async {
      await LinkRunner().trackPayment(
        eventName: 'purchase',
        paymentId: 'p1',
        userId: '',
        amount: 1,
        currency: 'USD',
      );

      expect(((calls.single.arguments as Map)['payment'] as Map)['userId'], '');
    });

    test('rejects invalid amount, paymentId or currency before the channel', () async {
      final invalid = <Future<void> Function()>[
        () => LinkRunner().trackPayment(
            eventName: 'e', paymentId: 'p', userId: 'u', amount: -1, currency: 'USD'),
        () => LinkRunner().trackPayment(
            eventName: 'e', paymentId: 'p', userId: 'u', amount: double.nan, currency: 'USD'),
        () => LinkRunner().trackPayment(
            eventName: 'e', paymentId: ' ', userId: 'u', amount: 1, currency: 'USD'),
        () => LinkRunner().trackPayment(
            eventName: 'e', paymentId: 'p', userId: 'u', amount: 1, currency: 'US'),
      ];
      for (final call in invalid) {
        await expectLater(call(), throwsArgumentError);
      }
      expect(calls, isEmpty);
    });

    test('rethrows native errors', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        throw PlatformException(code: 'TRACK_EVENT_FAILED', message: 'boom');
      });

      await expectLater(
        LinkRunner().trackPayment(
            eventName: 'purchase', paymentId: 'p', userId: 'u', amount: 1, currency: 'USD'),
        throwsA(isA<PlatformException>()),
      );
    });
  });
  group('EventPayment validation', () {
    test('rejects negative, NaN and infinite amounts', () {
      for (final amount in [-0.01, double.nan, double.infinity, double.negativeInfinity]) {
        expect(
          () => EventPayment(amount: amount, paymentId: 'p', currency: 'USD', userId: 'u'),
          throwsArgumentError,
          reason: 'amount $amount',
        );
      }
    });

    test('rejects blank paymentId', () {
      for (final id in ['', '   ']) {
        expect(
          () => EventPayment(amount: 1, paymentId: id, currency: 'USD', userId: 'u'),
          throwsArgumentError,
        );
      }
    });

    test('rejects currency that is not 3 letters', () {
      for (final currency in ['', 'US', 'USDT', 'U5D', '\$\$\$', 'ÜSD']) {
        expect(
          () => EventPayment(amount: 1, paymentId: 'p', currency: currency, userId: 'u'),
          throwsArgumentError,
          reason: 'currency "$currency"',
        );
      }
    });

    test('normalizes currency to trimmed upper case', () {
      expect(EventPayment(amount: 1, paymentId: 'p', currency: ' eur ', userId: 'u').currency, 'EUR');
    });

    test('invalid payment never reaches the native channel', () async {
      expect(
        () => LinkRunner().trackEvent(
          eventName: 'purchase',
          payment: EventPayment(amount: -1, paymentId: 'p', currency: 'USD', userId: 'u'),
        ),
        throwsArgumentError,
      );
      expect(calls, isEmpty);
    });
  });
}
