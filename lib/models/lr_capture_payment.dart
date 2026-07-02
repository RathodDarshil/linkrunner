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

enum PaymentStatus {
  PAYMENT_INITIATED,
  PAYMENT_COMPLETED,
  PAYMENT_FAILED,
  PAYMENT_CANCELLED,
}

class LRCapturePayment {
  final String paymentId;
  final String userId;
  final double amount;
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
      'type': type?.name ?? PaymentType.DEFAULT_PAYMENT.name,
      'status': status?.name ?? PaymentStatus.PAYMENT_COMPLETED.name,
    };

    if (eventData != null) {
      json['event_data'] = eventData;
    }

    return json;
  }
}
