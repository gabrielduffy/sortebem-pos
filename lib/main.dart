import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/activation_screen.dart';
import 'screens/sale_screen.dart';
import 'services/storage_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Forçar modo retrato
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  
  runApp(const SortebemApp());
}

class SortebemApp extends StatelessWidget {
  const SortebemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sortebem POS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFF97316),
        scaffoldBackgroundColor: Colors.white,
         colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFFF97316),
          secondary: const Color(0xFF1F2937),
        ),
        useMaterial3: true,
      ),
      home: const Initializer(),
    );
  }
}

class Initializer extends StatelessWidget {
  const Initializer({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: StorageService().isActivated(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        // Se ativado vai para Vendas, senão Ativação
        if (snapshot.data == true) {
          return const SaleScreen();
        } else {
          return const ActivationScreen();
        }
      },
    );
  }
}
