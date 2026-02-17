import 'package:graphql/client.dart';

/// Manages the GraphQL client lifecycle.
///
/// The client must be configured with server URL and API key before use.
/// It can be reset on logout and reconfigured on login.
class GraphQLClientManager {
  GraphQLClient? _client;
  String? _serverUrl;

  /// Configure the client with server credentials.
  void configure({required String serverUrl, required String apiKey}) {
    final cleanUrl = serverUrl.endsWith('/')
        ? serverUrl.substring(0, serverUrl.length - 1)
        : serverUrl;
    _serverUrl = cleanUrl;

    final httpLink = HttpLink(
      '$cleanUrl/graphql',
      defaultHeaders: {'x-api-key': apiKey},
    );

    _client = GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(store: InMemoryStore()),
    );
  }

  /// Returns the configured [GraphQLClient].
  ///
  /// Throws [StateError] if [configure] has not been called.
  GraphQLClient get client {
    final c = _client;
    if (c == null) {
      throw StateError(
        'GraphQL client not configured. Call configure() first.',
      );
    }
    return c;
  }

  /// The currently configured server URL, or null if not configured.
  String? get serverUrl => _serverUrl;

  /// Whether the client has been configured.
  bool get isConfigured => _client != null;

  /// Reset the client (e.g. on logout).
  void reset() {
    _client = null;
    _serverUrl = null;
  }
}
