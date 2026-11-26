import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urgences_medicales/core/network/dio_provider.dart';
import 'package:urgences_medicales/core/services/token_store.dart';

class _MemoryTokens implements TokenStore {
  String? value = 'jeton';

  @override
  Future<void> clear() async => value = null;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String token) async => value = token;
}

class _Capture extends RequestInterceptorHandler {
  RequestOptions? sent;

  @override
  void next(RequestOptions requestOptions) => sent = requestOptions;
}

void main() {
  Future<Map<String, dynamic>> headersFor(String path) async {
    final interceptor = AuthInterceptor(tokens: _MemoryTokens(), onUnauthorized: () {});
    final handler = _Capture();
    await interceptor.onRequest(RequestOptions(path: path), handler);
    return handler.sent!.headers;
  }

  test('le jeton part vers /api/auth/me (restauration de session) et les routes SOS', () async {
    expect((await headersFor('/api/auth/me'))['Authorization'], 'Bearer jeton');
    expect((await headersFor('/api/sos'))['Authorization'], 'Bearer jeton');
  });

  test('pas de jeton vers la connexion et l\'inscription', () async {
    expect((await headersFor('/api/auth/login')).containsKey('Authorization'), isFalse);
    expect((await headersFor('/api/auth/register')).containsKey('Authorization'), isFalse);
  });
}
