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
  Map<String, String>? _customerData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initFlow());
  }

  Future<void> _initFlow() async {
    // 1. Mostrar Dialog de Dados do Cliente
    final data = await _showCustomerDialog();
    if (data == null) {
      if (mounted) Navigator.of(context).pop();
      return;
    }
    
    setState(() => _customerData = data);
    _startPayment();
  }

  Future<Map<String, String>?> _showCustomerDialog() async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final cpfController = TextEditingController();
    
    return showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Dados do Cliente'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nome *'),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: cpfController,
                decoration: const InputDecoration(labelText: 'CPF'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF97316),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nome é obrigatório')),
                );
                return;
              }
              Navigator.pop(context, {
                'name': nameController.text.trim(),
                'phone': phoneController.text.trim(),
                'cpf': cpfController.text.trim(),
              });
            },
            child: const Text('CONFIRMAR'),
          ),
        ],
      ),
    );
  }

  Future<void> _startPayment() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      // 2. Iniciar Pagamento no PagSeguro (Mock handles web)
      PaymentResult paymentResult;
      
      if (widget.method == PaymentMethod.credit) {
        paymentResult = await _paymentService.payCredit(widget.totalAmount);
      } else {
        paymentResult = await _paymentService.payDebit(widget.totalAmount);
      }

      if (!paymentResult.success) {
        throw Exception(paymentResult.errorMessage ?? 'Pagamento não aprovado');
      }

      // 3. Registrar na API (Mocked Sale response for now)
      // Em produção aqui chamaria ApiService.createSale()
      await Future.delayed(const Duration(seconds: 1)); // Simula delay da API
      
      final saleResponse = SaleResponse(
        purchase: Purchase(
          id: DateTime.now().millisecondsSinceEpoch,
          totalAmount: widget.totalAmount,
          paymentStatus: 'approved',
        ),
        cards: List.generate(widget.quantity, (index) => BingoCard(
          id: index + 1,
          code: 'SB-${_generateRandomCode()}',
          numbers: _generateMockNumbers(),
        )),
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
              onRetry: _startPayment,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  String _generateRandomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = DateTime.now().microsecondsSinceEpoch;
    return List.generate(8, (i) => chars[(rnd + i) % chars.length]).join();
  }

  List<List<int>> _generateMockNumbers() {
    return List.generate(5, (row) => 
      List.generate(5, (col) => (row * 15) + (col * 3) + 1)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF7ED),
              Color(0xFFFFEDD5),
            ],
          ),
        ),
        child: Center(
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
              if (_customerData != null) ...[
                const SizedBox(height: 32),
                Text('Cliente: ${_customerData!['name']}', style: const TextStyle(color: Colors.grey)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
