import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../services/token_store.dart';

/// Émet quand le serveur refuse le jeton (401) : la session écoute et se ferme.
final sessionExpiredProvider = Provider<StreamController<void>>((ref) {
  final controller = StreamController<void>.broadcast();
  ref.onDispose(controller.close);
  return controller;
});

/// Client HTTP unique de l'application. Tous les modules (E1 à E6) passent par lui :
/// mêmes délais, même jeton, mêmes journaux.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      sendTimeout: AppConfig.receiveTimeout,
      headers: {'Accept': 'application/json'},
    ),
  );
  dio.interceptors.add(
    AuthInterceptor(
      tokens: ref.watch(tokenStoreProvider),
      onUnauthorized: () => ref.read(sessionExpiredProvider).add(null),
    ),
  );
  if (kDebugMode) dio.interceptors.add(SafeLogInterceptor());
  ref.onDispose(dio.close);
  return dio;
});

/// Ajoute le jeton Bearer et signale un refus de session.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.tokens, required this.onUnauthorized});

  final TokenStore tokens;
  final void Function() onUnauthorized;

  /// Seules la connexion et l'inscription sont publiques : elles ne reçoivent pas de jeton,
  /// et un 401 y signifie « identifiants faux », pas « session expirée ».
  /// (`/api/auth/me` n'est PAS publique : elle restaure la session au démarrage.)
  static const publicPaths = {'/api/auth/login', '/api/auth/register'};

  static bool isPublic(String path) => publicPaths.contains(path);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (!isPublic(options.path)) {
      final token = await tokens.read();
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401 && !isPublic(err.requestOptions.path)) onUnauthorized();
    handler.next(err);
  }
}

/// Journal de développement : méthode, chemin et statut seulement.
/// Jamais de corps ni d'en-têtes : ils contiennent le jeton, des positions GPS et des données médicales.
class SafeLogInterceptor extends Interceptor {
  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    debugPrint('API ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      'API ${err.response?.statusCode ?? err.type.name} ${err.requestOptions.method} ${err.requestOptions.path}',
    );
    handler.next(err);
  }
}
