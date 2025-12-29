import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/terminal.dart';
import '../models/round.dart';
import '../models/sale.dart';
import 'storage_service.dart';

class ApiService {
  final _storage = StorageService();

  Future<Map<String, String>> _getHeaders() async {
    final credentials = await _storage.getCredentials();
    final token = credentials['token'];
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Terminal> activateTerminal(String terminalCode, String apiKey) async {
    try {
      final uri = Uri.https(ApiConfig.baseUrl, ApiConfig.authPath);
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'terminal_code': terminalCode.trim(),
          'api_key': apiKey.trim(),
        }),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200 && body['ok'] == true) {
        // Salvar token se vier na resposta
        if (body['data']['token'] != null) {
          await _storage.saveCredentials(
             terminalId: terminalCode, 
             apiKey: apiKey, 
             token: body['data']['token']
          );
        }
        return Terminal.fromJson(body['data']);
      } else {
        throw Exception(body['error'] ?? 'Falha na ativação (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<RoundResponse> getCurrentRound() async {
    try {
      final uri = Uri.https(ApiConfig.baseUrl, ApiConfig.currentRoundPath);
      final headers = await _getHeaders();
      final response = await http.get(uri, headers: headers);

      final body = jsonDecode(response.body);
      if (response.statusCode == 200 && body['ok'] == true) {
        return RoundResponse.fromJson(body['data']);
      } else {
        throw Exception(body['error'] ?? 'Falha ao buscar rodada');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<SaleResponse> createSale(SaleRequest request) async {
    try {
      final uri = Uri.https(ApiConfig.baseUrl, ApiConfig.salePath);
      final headers = await _getHeaders();
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(request.toJson()),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200 && body['ok'] == true) {
        return SaleResponse.fromJson(body['data']);
      } else {
        throw Exception(body['error'] ?? 'Falha ao registrar venda');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<String> getPurchaseStatus(int purchaseId) async {
    try {
      final uri = Uri.https(ApiConfig.baseUrl, '/pos/purchases/$purchaseId/status');
      final headers = await _getHeaders();
      final response = await http.get(uri, headers: headers);

      final body = jsonDecode(response.body);
      if (response.statusCode == 200 && body['ok'] == true) {
        return body['data']['payment_status'];
      } else {
        throw Exception(body['error'] ?? 'Erro ao verificar status');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
}
