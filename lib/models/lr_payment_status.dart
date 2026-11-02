/// Payment statuses; only PAYMENT_COMPLETED payments count as revenue and reach ad networks.
enum PaymentStatus {
  PAYMENT_INITIATED,
  PAYMENT_COMPLETED,
  PAYMENT_FAILED,
  PAYMENT_CANCELLED,
}
