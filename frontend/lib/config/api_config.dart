/// API Configuration for different environments
class ApiConfig {
  static const String _developmentBaseUrl = 'http://192.168.0.103:8080';
  static const String _stagingBaseUrl = 'https://staging-api.yourapp.com';
  static const String _productionBaseUrl = 'https://api.yourapp.com';

  /// Get base URL based on current environment
  static String get baseUrl {
    const environment = Environment.development;

    switch (environment) {
      case Environment.development:
        return _developmentBaseUrl;
      case Environment.staging:
        return _stagingBaseUrl;
      case Environment.production:
        return _productionBaseUrl;
    }
  }

  /// Connection timeout configuration
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 10);

  /// Retry configuration
  static const int maxRetries = 3;
  static const List<Duration> retryDelays = [
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 4),
  ];

  /// API Endpoints
  static const String loginEndpoint = '/login';
  static const String logoutEndpoint = '/logout';
  static const String usersEndpoint = '/users';
  static const String chatsEndpoint = '/chats';
  static const String messagesEndpoint = '/messages';
}

/// Environment enum
enum Environment {
  development,
  staging,
  production,
}

/// Network configuration
class NetworkConfig {
  /// Check if current environment is development
  static bool get isDevelopment => ApiConfig.baseUrl.contains('192.168.0.103');

  /// Check if current environment is staging
  static bool get isStaging => ApiConfig.baseUrl.contains('staging');

  /// Check if current environment is production
  static bool get isProduction => ApiConfig.baseUrl.contains('api.yourapp.com');
}
