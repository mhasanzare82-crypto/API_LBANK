import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stores credentials locally using the platform secure-storage facilities.
/// Never log these values or commit them to source control.
class LbankCredentialsStore {
  LbankCredentialsStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _apiKeyName = 'lbank_futures_api_key';
  static const _secretName = 'lbank_futures_secret_key';

  final FlutterSecureStorage _storage;

  Future<void> save({
    required String apiKey,
    required String secretKey,
  }) async {
    if (apiKey.trim().isEmpty || secretKey.isEmpty) {
      throw ArgumentError('API Key and Secret Key are required.');
    }
    await _storage.write(key: _apiKeyName, value: apiKey.trim());
    await _storage.write(key: _secretName, value: secretKey);
  }

  Future<({String apiKey, String secretKey})?> read() async {
    final apiKey = await _storage.read(key: _apiKeyName);
    final secretKey = await _storage.read(key: _secretName);
    if (apiKey == null || secretKey == null) return null;
    return (apiKey: apiKey, secretKey: secretKey);
  }

  Future<void> clear() async {
    await _storage.delete(key: _apiKeyName);
    await _storage.delete(key: _secretName);
  }

  Future<bool> hasCredentials() async =>
      await _storage.containsKey(key: _apiKeyName) &&
      await _storage.containsKey(key: _secretName);
}
