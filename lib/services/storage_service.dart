import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String keyTerminalId = 'terminal_id';
  static const String keyApiKey = 'api_key';

  Future<void> saveCredentials(String terminalId, String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyTerminalId, terminalId);
    await prefs.setString(keyApiKey, apiKey);
  }

  Future<Map<String, String?>> getCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'terminal_id': prefs.getString(keyTerminalId),
      'api_key': prefs.getString(keyApiKey),
    };
  }

  Future<bool> isActivated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(keyTerminalId) && prefs.containsKey(keyApiKey);
  }
  
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
