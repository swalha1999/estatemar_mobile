class AppConfig {
  // Set to true to use mock data, false to use real API
  static const bool useMockData = true;
  
  // API Configuration
  static const String apiBaseUrl = 'https://estatemar.com/api';
  static const Duration networkTimeout = Duration(seconds: 10);
  
  // Mock data configuration
  static const Duration mockNetworkDelay = Duration(milliseconds: 500);
  
  // App Configuration
  static const String appName = 'EstateMar Mobile';
  static const String appVersion = '1.0.0';
  
  // Feature flags
  static const bool enableOfflineMode = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = false;
}
