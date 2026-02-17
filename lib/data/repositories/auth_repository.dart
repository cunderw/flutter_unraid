import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter_unraid/utils/constants.dart';

class AuthRepository {
  final FlutterSecureStorage _storage;

  AuthRepository(this._storage);

  Future<void> saveCredentials({
    required String serverUrl,
    required String apiKey,
  }) async {
    await _storage.write(key: AppConstants.keyServerUrl, value: serverUrl);
    await _storage.write(key: AppConstants.keyApiKey, value: apiKey);
  }

  Future<({String serverUrl, String apiKey})?> getCredentials() async {
    final serverUrl = await _storage.read(key: AppConstants.keyServerUrl);
    final apiKey = await _storage.read(key: AppConstants.keyApiKey);
    if (serverUrl != null && apiKey != null) {
      return (serverUrl: serverUrl, apiKey: apiKey);
    }
    return null;
  }

  Future<void> clearCredentials() async {
    await _storage.delete(key: AppConstants.keyServerUrl);
    await _storage.delete(key: AppConstants.keyApiKey);
  }
}
