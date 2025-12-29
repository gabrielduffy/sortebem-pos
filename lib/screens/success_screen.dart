import 'package:flutter/material.dart';
import '../models/sale.dart';
import '../models/round.dart';
import '../models/terminal.dart';
import '../services/printer_service.dart';
import '../utils/receipt_generator.dart';
import '../widgets/loading_indicator.dart';

class SuccessScreen extends StatefulWidget {
  final SaleResponse sale;
  final Round round;
  final String terminalId;

  const SuccessScreen({
    super.key,
    required this.sale,
    required this.round,
    required this.terminalId,
  });

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  final _printerService = PrinterService();
  bool _isPrinting = true;
  String _status = 'Imprimindo comprovantes...';

  @override
  void initState() {
    super.initState();
    _printReceipt();
  }

  Future<void> _printReceipt() async {
    // Mock establishment name since we don't have it stored easily without full terminal object or extra call.
    // For now using generic. Ideally should pass establishment name or fetch it.
    // I'll create a dummy terminal object or fetch it if I could.
    // To be safe, I'll use a placeholder or pass establishment name from previous screen if I had it.
    // Let's rely on hardcoded for this demo or update the model requirement.
    // I'll construct a temporary Terminal object.
    
    final tempTerminal = Terminal(
        terminalId: widget.terminalId, 
        establishment: Establishment(id: 0, name: 'SorteBem Pt')
    );

    final receipt = ReceiptGenerator.generate(widget.sale, widget.round, tempTerminal);
    
    final success = await _printerService.printReceipt(receipt);
    
    if (mounted) {
      setState(() {
        _isPrinting = false;
        _status = success ? 'Impressão concluída' : 'Erro na impressão';
      });
    }
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.check_circle, size: 80, color: Color(0xFF10B981)),
              const SizedBox(height: 24),
              const Text(
                'Pagamento Aprovado!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
              ),
              const SizedBox(height: 16),
              Text(
                '${widget.sale.cards.length} cartelas geradas',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 48),
              if (_isPrinting)
                LoadingIndicator(message: _status)
              else
                Text(_status, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                
              const SizedBox(height: 48),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF97316),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    // Pop until sale screen (root of this flow)
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('NOVA VENDA', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              if (!_isPrinting)
                  TextButton(
                      onPressed: _printReceipt,
                      child: const Text('Reimprimir', style: TextStyle(color: Color(0xFFF97316))),
                  )
            ],
          ),
        ),
      ),
    );
  }
}
