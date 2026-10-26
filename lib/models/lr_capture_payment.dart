import 'lr_payment_status.dart';

export 'lr_payment_status.dart';

@Deprecated('Pass the payment name as the trackEvent eventName, for example "FIRST_PAYMENT"')
enum PaymentType {
  FIRST_PAYMENT,
  WALLET_TOPUP,
  FUNDS_WITHDRAWAL,
  SUBSCRIPTION_CREATED,
  SUBSCRIPTION_RENEWED,
  DEFAULT_PAYMENT,
  ONE_TIME,
  RECURRING,
}

@Deprecated('Use trackEvent with amount, paymentId and currency in eventData')
class LRCapturePayment {
  final String paymentId;
  final String userId;
  final double amount;
  // ignore: deprecated_member_use_from_same_package
  final PaymentType? type;
  final PaymentStatus? status;
  final Map<String, dynamic>? eventData;

  LRCapturePayment({
    required this.paymentId,
    required this.userId,
    required this.amount,
    this.type,
    this.status,
    this.eventData,
  }) {
    if (paymentId.trim().isEmpty) {
      throw ArgumentError('paymentId must not be empty');
    }
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> json = {
      'payment_id': paymentId,
      'user_id': userId,
      'amount': amount,
      // ignore: deprecated_member_use_from_same_package
      'type': type?.name ?? PaymentType.DEFAULT_PAYMENT.name,
      'status': status?.name ?? PaymentStatus.PAYMENT_COMPLETED.name,
    };

    if (eventData != null) {
      json['event_data'] = eventData;
    }

    return json;
  }
}
