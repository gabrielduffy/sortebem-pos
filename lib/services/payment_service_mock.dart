import '../models/payment_result.dart';

class PaymentServiceMock {
  Future<PaymentResult> processPayment({
    required double amount,
    required String method, // 'credit' ou 'debit'
  }) async {
    // Simula delay do pagamento
    await Future.delayed(const Duration(seconds: 2));
    
    // Simula sucesso 90% das vezes
    final success = DateTime.now().millisecond % 10 != 0;
    
    if (success) {
      return PaymentResult(
        success: true,
        transactionCode: 'TXN${DateTime.now().millisecondsSinceEpoch}',
        cardBrand: 'VISA',
        lastDigits: '1234',
      );
    } else {
      return PaymentResult(
        success: false,
        errorMessage: 'Cartão recusado - saldo insuficiente',
      );
    }
  }
}
