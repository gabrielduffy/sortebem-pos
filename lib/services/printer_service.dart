import 'package:flutter/foundation.dart' show kIsWeb;
import 'printer_service_mock.dart';

class PrinterService {
  final _mock = PrinterServiceMock();

  Future<bool> printReceipt(String text) async {
    if (kIsWeb) {
      // Modo web - usar mock
      return await _mock.printReceipt(text);
    }
    
    // Modo Android - usar PagSeguro real
    // TODO: Implementar quando testar na maquininha
    return false;
  }
}
