import 'package:dio/dio.dart';

import '../errors/app_failure.dart';

/// Exécute un appel réseau et transforme toute erreur en [AppFailure].
/// Une réponse au format inattendu devient [ServerFailure] : jamais de données à moitié lues.
Future<T> guardApi<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on AppFailure {
    rethrow;
  } on DioException catch (e) {
    final inner = e.error;
    if (inner is AppFailure) throw inner;
    throw failureFromDio(e);
  } on FormatException {
    throw const ServerFailure(code: 'BAD_RESPONSE_FORMAT');
  } on TypeError {
    throw const ServerFailure(code: 'BAD_RESPONSE_FORMAT');
  }
}
