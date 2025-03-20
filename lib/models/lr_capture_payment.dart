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
  final String? paymentId;
  final String userId;
  final double amount;
  final PaymentType? type;
  final PaymentStatus? status;

  LRCapturePayment({
    this.paymentId,
    required this.userId,
    required this.amount,
    this.type,
    this.status,
  });

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> json = {
      'user_id': userId,
      'amount': amount,
      'type': type?.name,
      'status': status?.name,
    };

    if (paymentId != null) {
      json['payment_id'] = paymentId;
    }

    return json;
  }
}
