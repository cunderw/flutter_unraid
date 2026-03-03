class AppConstants {
  AppConstants._();

  static const String appName = 'Unraid Manager';

  // Secure storage keys
  static const String keyServerUrl = 'server_url';
  static const String keyApiKey = 'api_key';

  // Settings keys
  static const String keyOpenLinksExternally = 'open_links_externally';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 10);

  // Defaults
  static const int defaultLogTailLines = 100;
}
