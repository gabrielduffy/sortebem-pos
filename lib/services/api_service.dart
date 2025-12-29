import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/terminal.dart';
import '../models/round.dart';
import '../models/sale.dart';

class ApiService {
  // Função para garantir que a string tenha apenas caracteres ASCII válidos
  String _clean(String input) {
    return input.replaceAll(RegExp(r'[^\x20-\x7E]'), '').trim();
  }

  Future<Terminal> activateTerminal(String terminalId, String apiKey) async {
    try {
      final host = _clean(ApiConfig.baseUrl);
      final path = _clean(ApiConfig.authPath);
      final uri = Uri.https(host, path);
      
      print('DEBUG: Chamando API em: ${uri.toString()}');

      final response = await http.post(
        uri,
        // Removendo headers manuais temporariamente para isolar o erro "Invalid name"
        body: jsonEncode({
          'terminal_id': _clean(terminalId),
          'api_key': _clean(apiKey),
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['ok'] == true) {
          return Terminal.fromJson(body['data']);
        } else {
          throw Exception(body['error'] ?? 'Falha na ativação');
        }
      } else {
        throw Exception('Erro na requisição: ${response.statusCode}');
      }
    } catch (e) {
      print('DEBUG: Erro detalhado: $e');
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<RoundResponse> getCurrentRound(String terminalId) async {
    try {
      final host = _clean(ApiConfig.baseUrl);
      final path = _clean(ApiConfig.currentRoundPath);
      final uri = Uri.https(host, path);

      final response = await http.get(
        uri,
        headers: {
          'X-Terminal-ID': _clean(terminalId),
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['ok'] == true) {
          return RoundResponse.fromJson(body['data']);
        } else {
          throw Exception(body['error'] ?? 'Falha ao buscar rodada');
        }
      } else {
        throw Exception('Erro na requisição: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<SaleResponse> createSale(String terminalId, SaleRequest request) async {
    try {
      final host = _clean(ApiConfig.baseUrl);
      final path = _clean(ApiConfig.salePath);
      final uri = Uri.https(host, path);

      final response = await http.post(
        uri,
        headers: {
          'X-Terminal-ID': _clean(terminalId),
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['ok'] == true) {
          return SaleResponse.fromJson(body['data']);
        } else {
          throw Exception(body['error'] ?? 'Falha ao registrar venda');
        }
      } else {
        throw Exception('Erro na requisição: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
}
