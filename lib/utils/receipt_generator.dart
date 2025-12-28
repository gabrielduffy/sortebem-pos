import '../models/sale.dart';
import '../models/round.dart';
import '../models/terminal.dart';
import 'formatters.dart';

class ReceiptGenerator {
  static String generate(SaleResponse sale, Round round, Terminal terminal) {
    final StringBuffer buffer = StringBuffer();
    
    // Header
    buffer.writeln('================================');
    buffer.writeln('SORTEBEM');
    buffer.writeln('SORTEIO BENEFICENTE');
    buffer.writeln('ESTABELECIMENTO:');
    buffer.writeln(terminal.establishment.name);
    buffer.writeln('RODADA: #${round.number} (${round.type == 'regular' ? 'Regular' : 'Especial'})');
    buffer.writeln('DATA: ${Formatters.date(DateTime.now())}');
    buffer.writeln('================================');
    buffer.writeln('');

    // Cartelas
    for (var card in sale.cards) {
      buffer.writeln('CARTELA: ${card.code}');
      buffer.writeln(_formatNumbers(card.numbers));
      buffer.writeln('Valor: ${Formatters.currency(round.cardPrice)}');
      buffer.writeln('--------------------------------');
      buffer.writeln('');
    }

    // Footer
    buffer.writeln('BOA SORTE!');
    buffer.writeln('Acompanhe: sortebem.com.br');
    buffer.writeln('');
    buffer.writeln('');
    buffer.writeln(''); // Espaço para corte

    return buffer.toString();
  }

  static String _formatNumbers(List<int> numbers) {
    // Format 5x5 matrix
    final buffer = StringBuffer();
    buffer.writeln('|  S  |  O  |  R  |  T  |  E  |');
    
    // Assegura que temos 25 números (ou 24 com free space se fosse o caso, mas aqui parece 25 ou 24, o prompt diz XX no meio)
    // O prompt mostra "XX" na posição 12 (índice 0-24, row 2 col 2)
    // Se a lista vier com 24, inserimos mock ou tratamos. O prompt diz que "numbers" vem da API.
    // Vou assumir que venha linear 25 números ou 24
    
    List<String> formattedNums = numbers.map((n) => n.toString().padLeft(2, '0')).toList();
    
    // Se for bingo padrão de 75 bolas, o meio é livre.
    // O exemplo mostra: row 3: 03, 18, XX, 48, 63. 
    // Indice 12 (13º numero)
    
    if (formattedNums.length == 24) {
      formattedNums.insert(12, 'XX');
    } else if (formattedNums.length == 25) {
       // Se já vier com 0 ou algo indicando o meio, substituimos visualmente ou deixamos.
       // Vou assumir que a API manda numeros.
    }

    /*
    00 05 10 15 20
    01 06 11 16 21
    ...
    Mas o bingo geralmente é coluna por coluna?
    O exemplo: 
    | 01 | 16 | 31 | 46 | 61 |
    Isso sugere colunas: B(1-15), I(16-30), N(31-45), G(46-60), O(61-75).
    S-O-R-T-E map to B-I-N-G-O ranges.
    
    Vou fazer loop de linhas (0 a 4) e pegar o índice correto se estiver ordenado por colunas ou linhas.
    Geralmente arrays vêm linear. Se linear for Row-major: 0,1,2,3,4 é a linha 1.
    Se o exemplo é:
    01 16 31 46 61
    Isso são os indices 0, 5, 10, 15, 20 se for col-major?
    Ou simplesmente a lista já vem na ordem de leitura?
    "numbers": [1,5,12,23,34,45,56,67,8,19,20,31,42,53,64,75,6,17,28,39,50,61,72,3,14]
    O exemplo do prompt tem 25 números.
    Vou imprimir em 5 linhas de 5.
    */
    
    for (int i = 0; i < 5; i++) {
        String line = '|';
        for (int j = 0; j < 5; j++) {
            int index = i * 5 + j;
            if (index < formattedNums.length) {
                line += '  ${formattedNums[index]} |';
            }
        }
        buffer.writeln(line);
    }

    return buffer.toString();
  }
}
