import 'dart:async';
import 'package:flutter/material.dart';
import '../models/round.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../utils/formatters.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/quantity_selector.dart';
import '../widgets/round_selector.dart';
import '../widgets/payment_method_selector.dart';
import 'payment_screen.dart';

class SaleScreen extends StatefulWidget {
  const SaleScreen({super.key});

  @override
  State<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> {
  final _apiService = ApiService();
  final _storageService = StorageService();
  
  bool _isLoading = true;
  String? _error;
  RoundResponse? _rounds;
  Round? _selectedRound;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
       _isLoading = true; 
       _error = null;
    });

    try {
      final creds = await _storageService.getCredentials();
      if (creds['terminal_id'] == null) throw Exception('Terminal não ativado');

      final rounds = await _apiService.getCurrentRound(creds['terminal_id']!);
      setState(() {
        _rounds = rounds;
        _selectedRound = rounds.regular ?? rounds.special;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
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
    ).then((_) {
      // Refresh when returning (maybe new round available)
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: LoadingIndicator(message: 'Carregando rodadas...'));

    if (_error != null) {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Erro: $_error',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Tentar Novamente'),
              )
            ],
          ),
        ),
      );
    }

    if (_selectedRound == null) {
       return Scaffold(
        body: Center(
          child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               const Icon(Icons.warning, size: 64, color: Colors.orange),
               const SizedBox(height: 16),
               const Text('Nenhuma rodada disponível no momento.'),
               const SizedBox(height: 16),
               ElevatedButton(onPressed: _loadData, child: const Text('Atualizar'))
             ],
          ),
        ),
       );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('SORTEBEM POS'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF97316),
        actions: [
            IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadData,
            )
        ],
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
                      regular: _rounds?.regular,
                      special: _rounds?.special,
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
