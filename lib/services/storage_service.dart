import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyTerminalId = 'terminal_id';
  static const String _keyApiKey = 'api_key';
  static const String _keyToken = 'auth_token';

  Future<void> saveCredentials({
    required String terminalId,
    required String apiKey,
    String? token,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTerminalId, terminalId);
    await prefs.setString(_keyApiKey, apiKey);
    if (token != null) await prefs.setString(_keyToken, token);
  }

  Future<Map<String, String?>> getCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'terminal_id': prefs.getString(_keyTerminalId),
      'api_key': prefs.getString(_keyApiKey),
      'token': prefs.getString(_keyToken),
    };
  }

  Future<bool> isActivated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyTerminalId) && prefs.containsKey(_keyApiKey);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
