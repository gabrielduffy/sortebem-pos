import 'package:flutter/material.dart';
import '../models/payment_result.dart';
import '../models/round.dart';
import '../models/sale.dart';
import '../services/api_service.dart';
import '../services/payment_service.dart';
import '../services/storage_service.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/payment_method_selector.dart';
import 'success_screen.dart';
import 'error_screen.dart';

class PaymentScreen extends StatefulWidget {
  final Round round;
  final int quantity;
  final PaymentMethod method;
  final double totalAmount;

  const PaymentScreen({
    super.key,
    required this.round,
    required this.quantity,
    required this.method,
    required this.totalAmount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _paymentService = PaymentService();
  final _apiService = ApiService();
  final _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    // Iniciar pagamento automaticamente após build
    WidgetsBinding.instance.addPostFrameCallback((_) => _startPayment());
  }

  Future<void> _startPayment() async {
    setState(() => _isProcessing = true);

    try {
      // 1. Processar Pagamento (PlugPag)
      PaymentResult paymentResult;
      
      // Use small delay to allow UI to render "Aproxime"
      await Future.delayed(const Duration(seconds: 1));

      if (widget.method == PaymentMethod.credit) {
        paymentResult = await _paymentService.payCredit(widget.totalAmount);
      } else {
        paymentResult = await _paymentService.payDebit(widget.totalAmount);
      }

      if (!paymentResult.success) {
        throw Exception(paymentResult.errorMessage ?? 'Pagamento não aprovado');
      }

      setState(() {
         // Atualizar status para "Registrando venda..." se quisesse, 
         // mas aqui mantém o loading geral.
      });

      // 2. Obter credenciais
      final creds = await _storageService.getCredentials();
      final terminalId = creds['terminal_id'];
      if (terminalId == null) throw Exception('Terminal ID perdido');

      // 3. Registrar na API
      final saleRequest = SaleRequest(
        roundId: widget.round.id,
        quantity: widget.quantity,
        paymentMethod: widget.method == PaymentMethod.credit ? 'credit_card' : 'debit_card',
        cardBrand: paymentResult.cardBrand ?? 'UNKNOWN',
        cardLastDigits: '0000', // PlugPag sometimes doesn't return digits in sandbox
        transactionId: paymentResult.transactionCode ?? 'OFFLINE-${DateTime.now().millisecondsSinceEpoch}',
      );

      final saleResponse = await _apiService.createSale(terminalId, saleRequest);

      // 4. Sucesso
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => SuccessScreen(
              sale: saleResponse,
              round: widget.round,
              terminalId: terminalId,
            ),
          ),
        );
      }

    } catch (e) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ErrorScreen(
              message: e.toString().replaceAll('Exception: ', ''),
              onRetry: _startPayment,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LoadingIndicator(message: 'Aguardando Pagamento...'),
            const SizedBox(height: 24),
            Text(
              'R\$ ${widget.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Insira ou aproxime o cartão', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
