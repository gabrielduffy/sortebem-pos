import 'package:flutter/material.dart';
import '../models/round.dart';
import '../models/terminal.dart';
import '../widgets/quantity_selector.dart';
import '../widgets/round_selector.dart';
import '../widgets/payment_method_selector.dart';
import '../utils/formatters.dart';
import 'payment_screen.dart';

class SaleScreen extends StatefulWidget {
  const SaleScreen({super.key});

  @override
  State<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> {
  // Dados mockados para teste
  final RoundResponse mockRoundResponse = RoundResponse(
    regular: Round(
      id: 1,
      number: 123,
      type: 'regular',
      cardPrice: 5.00,
      sellingEndsAt: DateTime.now().add(const Duration(minutes: 7)),
    ),
    special: Round(
      id: 2,
      number: 124,
      type: 'special',
      cardPrice: 10.00,
      sellingEndsAt: DateTime.now().add(const Duration(minutes: 57)),
    ),
  );

  final Terminal mockTerminal = Terminal(
    terminalId: 'POS-TEST001',
    establishment: Establishment(id: 1, name: 'Bar do João (Dev)'),
  );

  Round? _selectedRound;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _selectedRound = mockRoundResponse.regular;
  }

  void _processSale(PaymentMethod method) {
    if (_selectedRound == null) return;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          round: _selectedRound!,
          quantity: _quantity,
          method: method,
          totalAmount: _selectedRound!.cardPrice * _quantity,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text('SORTEBEM POS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(mockTerminal.establishment.name, style: const TextStyle(fontSize: 12)),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF97316),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    RoundSelector(
                      regular: mockRoundResponse.regular,
                      special: mockRoundResponse.special,
                      selected: _selectedRound,
                      onSelected: (r) => setState(() => _selectedRound = r),
                    ),
                    const SizedBox(height: 24),
                    const Text('Quantidade de Cartelas', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 16),
                    QuantitySelector(
                      quantity: _quantity,
                      onChanged: (q) => setState(() => _quantity = q),
                    ),
                    const SizedBox(height: 32),
                    Divider(thickness: 2, color: Colors.grey[200]),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('TOTAL', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        Text(
                          Formatters.currency(_selectedRound!.cardPrice * _quantity),
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            PaymentMethodSelector(onSelected: _processSale),
          ],
        ),
      ),
    );
  }
}
