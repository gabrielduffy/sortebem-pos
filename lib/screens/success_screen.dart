import 'package:flutter/material.dart';
import '../models/sale.dart';
import '../models/round.dart';
import '../models/card.dart';
import '../services/printer_service.dart';
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
  bool _isPrinting = false;
  String _status = 'Pagamento confirmado!';

  @override
  void initState() {
    super.initState();
    // Iniciar primeira impressão automaticamente? 
    // Melhor deixar o usuário clicar para economizar papel se ele não quiser.
  }

  Future<void> _printReceipt() async {
    setState(() {
      _isPrinting = true;
      _status = 'Imprimindo...';
    });

    try {
      // Simular impressão de cada cartela
      for (var card in widget.sale.cards) {
        String receipt = _generateReceiptText(card);
        await _printerService.printReceipt(receipt);
        await Future.delayed(const Duration(milliseconds: 500));
      }
      
      setState(() => _status = 'Impressão concluída');
    } catch (e) {
      setState(() => _status = 'Erro na impressão: $e');
    } finally {
      setState(() => _isPrinting = false);
    }
  }

  String _generateReceiptText(BingoCard card) {
    StringBuffer buffer = StringBuffer();
    buffer.writeln('--------------------------------');
    buffer.writeln('       SORTEBEM POS');
    buffer.writeln('--------------------------------');
    buffer.writeln('Rodada #${widget.round.number} (${widget.round.type.toUpperCase()})');
    buffer.writeln('Data: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} ${DateTime.now().hour}:${DateTime.now().minute}');
    buffer.writeln('--------------------------------');
    buffer.writeln('CARTELA: ${card.code}');
    buffer.writeln('--------------------------------');
    
    // Imprimir Grid 5x5
    for (var row in card.numbers) {
      buffer.writeln(row.map((n) => n.toString().padLeft(2, '0')).join('  '));
    }
    
    buffer.writeln('--------------------------------');
    buffer.writeln('Valor Pago: R\$ ${widget.round.cardPrice.toStringAsFixed(2)}');
    buffer.writeln('--------------------------------');
    buffer.writeln('       BOA SORTE!');
    buffer.writeln('--------------------------------');
    buffer.writeln('\n\n');
    return buffer.toString();
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Icon(Icons.check_circle, size: 80, color: Color(0xFF10B981)),
                const SizedBox(height: 16),
                const Text(
                  'Pagamento Aprovado!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                ),
                Text(
                  '${widget.sale.cards.length} cartelas geradas',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.sale.cards.length,
                    itemBuilder: (context, index) {
                      final card = widget.sale.cards[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('CÓDIGO: ${card.code}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const Divider(),
                              Table(
                                children: card.numbers.map((row) {
                                  return TableRow(
                                    children: row.map((n) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: Text(n.toString(), textAlign: TextAlign.center),
                                      );
                                    }).toList(),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),
                if (_isPrinting)
                  const LoadingIndicator(message: 'Imprimindo...')
                else
                  Text(_status, style: const TextStyle(color: Colors.grey)),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isPrinting ? null : _printReceipt,
                    icon: const Icon(Icons.print),
                    label: const Text('IMPRIMIR BILHETES', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF97316),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                    child: const Text('NOVA VENDA', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
