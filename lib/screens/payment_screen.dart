import 'package:flutter/material.dart';
import '../models/round.dart';
import '../models/sale.dart';
import '../models/card.dart';
import '../models/payment_result.dart';
import '../services/payment_service.dart';
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
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startPayment());
  }

  Future<void> _startPayment() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      // 1. Processar Pagamento (Mocked service handles web)
      PaymentResult paymentResult;
      
      await Future.delayed(const Duration(seconds: 2));

      if (widget.method == PaymentMethod.credit) {
        paymentResult = await _paymentService.payCredit(widget.totalAmount);
      } else {
        paymentResult = await _paymentService.payDebit(widget.totalAmount);
      }

      if (!paymentResult.success) {
        throw Exception(paymentResult.errorMessage ?? 'Pagamento não aprovado');
      }

      // 2. Simular resposta da API (Mocked Sale)
      final saleResponse = SaleResponse(
        purchaseId: DateTime.now().millisecondsSinceEpoch,
        cards: [
          BingoCard(
            code: 'SB-ABC12345',
            numbers: [1,5,12,23,34,45,56,67,8,19,20,31,42,53,64,75,6,17,28,39,50,61,72,3,14],
          ),
          if (widget.quantity > 1)
            BingoCard(
              code: 'SB-XYZ67890',
              numbers: [2,6,13,24,35,46,57,68,9,20,21,32,43,54,65,71,7,18,29,40,51,62,73,4,15],
            ),
        ],
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => SuccessScreen(
              sale: saleResponse,
              round: widget.round,
              terminalId: 'POS-TEST001',
            ),
          ),
        );
      }

    } catch (e) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ErrorScreen(
              message: e.toString().contains('Exception') 
                  ? e.toString().split('Exception: ')[1] 
                  : e.toString(),
              onRetry: () {
                Navigator.of(context).pop();
                _startPayment();
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LoadingIndicator(message: 'Agurdando Pagamento...'),
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
