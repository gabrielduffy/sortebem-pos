import '../models/sale.dart';
import '../models/round.dart';
import 'formatters.dart';

class ReceiptGenerator {
  static String generate({
    required SaleResponse sale,
    required Round round,
    required String terminalId,
    required String establishmentName,
  }) {
    final StringBuffer buffer = StringBuffer();
    
    // Header
    buffer.writeln('================================');
    buffer.writeln('          SORTEBEM');
    buffer.writeln('================================');
    buffer.writeln('ESTAB: $establishmentName');
    buffer.writeln('RODADA: #${round.number} (${round.type.toUpperCase()})');
    buffer.writeln('DATA: ${Formatters.date(DateTime.now())}');
    buffer.writeln('TERMINAL: $terminalId');
    buffer.writeln('================================');
    buffer.writeln('');

    // Cartelas
    for (var card in sale.cards) {
      buffer.writeln('CARTELA: ${card.code}');
      buffer.writeln('--------------------------------');
      
      // Imprimir Grid 5x5
      for (var row in card.numbers) {
        buffer.writeln(row.map((n) => n.toString().padLeft(2, '0')).join('  '));
      }
      
      buffer.writeln('--------------------------------');
      buffer.writeln('VALOR: ${Formatters.currency(round.cardPrice)}');
      buffer.writeln('--------------------------------\n');
    }

    // Footer
    buffer.writeln('          BOA SORTE!');
    buffer.writeln('  Acompanhe: sortebem.com.br');
    buffer.writeln('\n\n\n'); 

    return buffer.toString();
  }
}
