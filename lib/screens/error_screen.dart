import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorScreen({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.error, size: 80, color: Color(0xFFEF4444)),
            const SizedBox(height: 24),
            const Text(
              'Ocorreu um erro',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 48),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                   backgroundColor: const Color(0xFF1F2937),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                    Navigator.of(context).pop(); // Back to PaymentScreen, wait...
                    // PaymentScreen calls onRetry? 
                    // Usually ErrorScreen replaces PaymentScreen so pop goes to SaleScreen?
                    // But onRetry should restart the process.
                    onRetry(); 
                    // If onRetry starts logic again, we might need to be in the context that can show UI or navigate.
                },
                child: const Text('TENTAR NOVAMENTE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
                onPressed: () {
                     Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('CANCELAR'),
            )
          ],
        ),
      ),
    );
  }
}
