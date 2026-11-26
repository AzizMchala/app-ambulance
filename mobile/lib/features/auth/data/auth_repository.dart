import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/network/api_guard.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/services/token_store.dart';
import '../domain/auth_user.dart';

/// Connexion, inscription et restauration de session.
class AuthRepository {
  const AuthRepository(this._dio, this._tokens);

  final Dio _dio;
  final TokenStore _tokens;

  Future<AuthUser> login({required String email, required String password}) => guardApi(() async {
    final r = await _dio.post<Object?>('/api/auth/login', data: {'email': email.trim(), 'password': password});
    return _storeSession(r.data);
  });

  Future<AuthUser> register({required String fullName, required String email, required String password}) =>
      guardApi(() async {
        final r = await _dio.post<Object?>(
          '/api/auth/register',
          data: {'fullName': fullName.trim(), 'email': email.trim(), 'password': password},
        );
        return _storeSession(r.data);
      });

  /// Session enregistrée encore valide, sinon `null`. Un jeton refusé est effacé.
  Future<AuthUser?> restore() async {
    if (await _tokens.read() == null) return null;
    try {
      return await guardApi(() async {
        final r = await _dio.get<Object?>('/api/auth/me');
        return AuthUser.fromJson((r.data! as Map).cast<String, Object?>());
      });
    } on UnauthenticatedFailure {
      await _tokens.clear();
      return null;
    }
  }

  Future<void> logout() => _tokens.clear();

  Future<AuthUser> _storeSession(Object? data) async {
    final map = (data! as Map).cast<String, Object?>();
    await _tokens.write(map['accessToken']! as String);
    return AuthUser.fromJson((map['user']! as Map).cast<String, Object?>());
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(dioProvider), ref.watch(tokenStoreProvider)),
);
