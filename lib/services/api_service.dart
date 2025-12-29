import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/terminal.dart';
import '../models/round.dart';
import '../models/sale.dart';

class ApiService {
  Future<Terminal> activateTerminal(String terminalId, String apiKey) async {
    try {
      final uri = Uri.https(ApiConfig.baseUrl, ApiConfig.authPath);
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'terminal_id': terminalId.trim(),
          'api_key': apiKey.trim(),
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
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<RoundResponse> getCurrentRound(String terminalId) async {
    try {
      final uri = Uri.https(ApiConfig.baseUrl, ApiConfig.currentRoundPath);
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Terminal-ID': terminalId.trim(),
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
      final uri = Uri.https(ApiConfig.baseUrl, ApiConfig.salePath);
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Terminal-ID': terminalId.trim(),
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
