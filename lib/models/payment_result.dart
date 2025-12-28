class PaymentResult {
  final bool success;
  final String? transactionCode;
  final String? cardBrand;
  final String? lastDigits;
  final String? errorMessage;

  PaymentResult({
    required this.success,
    this.transactionCode,
    this.cardBrand,
    this.lastDigits,
    this.errorMessage,
  });
}
