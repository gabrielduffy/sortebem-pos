import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/payment_result.dart';
import 'payment_service_mock.dart';

class PaymentService {
  final _mock = PaymentServiceMock();

  Future<PaymentResult> payCredit(double amount) async {
    if (kIsWeb) {
      // Modo web - usar mock
      return await _mock.processPayment(amount: amount, method: 'credit');
    }
    
    // Modo Android - usar PagSeguro real
    // TODO: Implementar quando testar na maquininha
    return PaymentResult(success: false, errorMessage: 'Não implementado no Android ainda');
  }

  Future<PaymentResult> payDebit(double amount) async {
    if (kIsWeb) {
      // Modo web - usar mock
      return await _mock.processPayment(amount: amount, method: 'debit');
    }
    
    // Modo Android - usar PagSeguro real
    // TODO: Implementar quando testar na maquininha
    return PaymentResult(success: false, errorMessage: 'Não implementado no Android ainda');
  }
}
