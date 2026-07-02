import 'package:flutter_test/flutter_test.dart';
import 'package:linkrunner/models/lr_capture_payment.dart';

void main() {
  group('LRCapturePayment', () {
    test('builds and serializes payment_id when provided', () {
      final payment = LRCapturePayment(
        paymentId: 'payment_123',
        userId: 'user_1',
        amount: 99.99,
      );

      final json = payment.toJSON();

      expect(payment.paymentId, 'payment_123');
      expect(json['payment_id'], 'payment_123');
    });

    test('throws when payment_id is empty', () {
      expect(
        () => LRCapturePayment(
          paymentId: '',
          userId: 'user_1',
          amount: 99.99,
        ),
        throwsArgumentError,
      );
    });
  });
}
