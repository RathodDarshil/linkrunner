// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkrunner/main.dart';
import 'package:linkrunner/models/lr_capture_payment.dart';
import 'package:linkrunner/models/lr_remove_payment.dart';

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

  test('capturePayment sends the old capturePayment call', () async {
    await LinkRunner().capturePayment(
      capturePayment: LRCapturePayment(
        paymentId: 'order_1',
        userId: 'user_1',
        amount: 499.0,
        type: PaymentType.FIRST_PAYMENT,
      ),
    );

    expect(calls.single.method, 'capturePayment');
    expect(calls.single.arguments, {
      'userId': 'user_1',
      'amount': 499.0,
      'paymentId': 'order_1',
      'type': 'FIRST_PAYMENT',
      'status': 'PAYMENT_COMPLETED',
      'eventData': null,
    });
  });

  test('removePayment sends the old removePayment call', () async {
    await LinkRunner().removePayment(
      removePayment: LRRemovePayment(paymentId: 'order_1', userId: 'user_1'),
    );

    expect(calls.single.method, 'removePayment');
    expect(calls.single.arguments, {'userId': 'user_1', 'paymentId': 'order_1'});
  });

  test('PaymentStatus from main.dart and lr_capture_payment.dart is the same type', () {
    final LRCapturePayment payment = LRCapturePayment(
      paymentId: 'order_1',
      userId: 'user_1',
      amount: 1,
      status: PaymentStatus.PAYMENT_FAILED,
    );
    expect(payment.toJSON()['status'], 'PAYMENT_FAILED');
  });
}
