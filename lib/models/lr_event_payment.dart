enum PaymentStatus {
  PAYMENT_INITIATED,
  PAYMENT_COMPLETED,
  PAYMENT_FAILED,
  PAYMENT_CANCELLED,
}

final RegExp _currencyCode = RegExp(r'^[A-Za-z]{3}$');

/// Revenue attached to a tracked event; the event name becomes the payment type.
class EventPayment {
  final double amount;
  final String paymentId;
  final String currency;
  final PaymentStatus? status;

  EventPayment({
    required this.amount,
    required this.paymentId,
    required String currency,
    this.status,
  }) : currency = currency.trim().toUpperCase() {
    if (!amount.isFinite || amount < 0) {
      throw ArgumentError.value(amount, 'amount', 'must be a finite number >= 0');
    }
    if (paymentId.trim().isEmpty) {
      throw ArgumentError.value(paymentId, 'paymentId', 'must not be blank');
    }
    if (!_currencyCode.hasMatch(this.currency)) {
      throw ArgumentError.value(currency, 'currency', 'must be a 3-letter ISO 4217 code');
    }
  }

  Map<String, dynamic> toJSON() {
    final json = <String, dynamic>{
      'amount': amount,
      'paymentId': paymentId,
      'currency': currency,
    };
    if (status != null) {
      json['status'] = status!.name;
    }
    return json;
  }
}
