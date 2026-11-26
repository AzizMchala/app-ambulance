import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stockage du jeton d'accès. Le jeton vit dans le Keystore (Android) ou le Keychain (iOS),
/// jamais dans SharedPreferences.
abstract interface class TokenStore {
  Future<String?> read();
  Future<void> write(String token);
  Future<void> clear();
}

class SecureTokenStore implements TokenStore {
  SecureTokenStore([FlutterSecureStorage? storage]) : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'auth.access_token';
  final FlutterSecureStorage _storage;

  /// Copie en mémoire : évite un aller-retour Keystore à chaque requête.
  String? _cache;
  bool _loaded = false;

  @override
  Future<String?> read() async {
    if (_loaded) return _cache;
    _cache = await _storage.read(key: _key);
    _loaded = true;
    return _cache;
  }

  @override
  Future<void> write(String token) async {
    _cache = token;
    _loaded = true;
    await _storage.write(key: _key, value: token);
  }

  @override
  Future<void> clear() async {
    _cache = null;
    _loaded = true;
    await _storage.delete(key: _key);
  }
}

final tokenStoreProvider = Provider<TokenStore>((ref) => SecureTokenStore());
