class ApiConfig {
  static const String baseUrl = 'https://api.sortebem.com.br';
  
  // Endpoints
  static const String authEndpoint = '/pos/auth';
  static const String currentRoundEndpoint = '/pos/round/current';
  static const String saleEndpoint = '/pos/sale';
  
  // Headers
  static const String headerTerminalId = 'X-Terminal-ID';
  static const String headerContentType = 'Content-Type';
}
