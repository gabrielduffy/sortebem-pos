import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../widgets/loading_indicator.dart';
import 'sale_screen.dart';

class ActivationScreen extends StatefulWidget {
  const ActivationScreen({super.key});

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final _terminalIdController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _apiService = ApiService();
  final _storageService = StorageService();
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkActivation();
  }

  Future<void> _checkActivation() async {
    if (await _storageService.isActivated()) {
      _navigateToSale();
    }
  }

  void _navigateToSale() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SaleScreen()),
    );
  }

  Future<void> _activate() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final terminal = await _apiService.activateTerminal(
        _terminalIdController.text,
        _apiKeyController.text,
      );
      
      await _storageService.saveCredentials(
        terminal.terminalId,
        _apiKeyController.text,
      );
      
      _navigateToSale();
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: LoadingIndicator(message: 'Ativando terminal...'),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ativação Terminal')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.settings_remote, size: 64, color: Color(0xFFF97316)),
            const SizedBox(height: 32),
            TextField(
              controller: _terminalIdController,
              decoration: const InputDecoration(
                labelText: 'ID do Terminal',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                labelText: 'Chave de API',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(16),
              ),
              obscureText: true,
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 32),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _activate,
                child: const Text(
                  'ATIVAR TERMINAL',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
