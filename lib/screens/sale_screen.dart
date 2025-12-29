import 'package:flutter/material.dart';
import '../models/round.dart';
import '../models/terminal.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../widgets/quantity_selector.dart';
import '../widgets/round_selector.dart';
import '../widgets/payment_method_selector.dart';
import '../widgets/loading_indicator.dart';
import '../utils/formatters.dart';
import 'payment_screen.dart';

class SaleScreen extends StatefulWidget {
  const SaleScreen({super.key});

  @override
  State<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> {
  final _apiService = ApiService();
  final _storage = StorageService();
  
  RoundResponse? _roundResponse;
  Terminal? _terminal;
  Round? _selectedRound;
  int _quantity = 1;
  bool _isLoading = true;
  String? _error;

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
      // Tentar carregar da API Real
      final roundData = await _apiService.getCurrentRound();
      
      // Carregar dados salvos do terminal
      final creds = await _storage.getCredentials();
      // Em produção, buscaríamos os detalhes do terminal da API ou storage
      final terminal = Terminal(
        terminalId: creds['terminal_id'] ?? 'POS-TEST001',
        establishment: Establishment(id: 1, name: 'Estabelecimento'),
      );

      setState(() {
        _roundResponse = roundData;
        _terminal = terminal;
        _selectedRound = roundData.regular;
        _isLoading = false;
      });
    } catch (e) {
      // Fallback para Mock se falhar (Modo de Desenvolvimento)
      print('Aviso: Usando dados mockados devido a erro: $e');
      
      final mockResponse = RoundResponse(
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

      setState(() {
        _roundResponse = mockResponse;
        _terminal = Terminal(
          terminalId: 'POS-TEST001',
          establishment: Establishment(id: 1, name: 'Bar do João (Dev)'),
        );
        _selectedRound = _roundResponse!.regular;
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
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: LoadingIndicator(message: 'Carregando rodada...'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/logo.png',
          height: 40,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.grey),
            onPressed: _loadData,
          )
        ],
      ),
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (_terminal != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _terminal!.establishment.name,
                    style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      RoundSelector(
                        regular: _roundResponse!.regular,
                        special: _roundResponse!.special,
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
      ),
    );
  }
}
