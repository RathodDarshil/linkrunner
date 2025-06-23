class LRCapturePayment {
  final String? paymentId;
  final String userId;
  final double amount;
  final String type;
  final String status;

  LRCapturePayment({
    this.paymentId,
    required this.userId,
    required this.amount,
    this.type = 'DEFAULT',
    this.status = 'PAYMENT_COMPLETED',
  });

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> json = {
      'user_id': userId,
      'amount': amount,
      'type': type,
      'status': status,
    };

    if (paymentId != null) {
      json['payment_id'] = paymentId;
    }

    return json;
  }
}
