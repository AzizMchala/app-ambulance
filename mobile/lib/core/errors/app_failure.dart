import 'package:dio/dio.dart';

/// Une seule famille d'erreurs pour toute l'application.
/// Les écrans ne voient jamais d'exception réseau brute : la couche data traduit tout en [AppFailure].
sealed class AppFailure implements Exception {
  const AppFailure({this.code});

  /// Code métier renvoyé par l'API (`SOS_ALREADY_ACTIVE`, `INVALID_STATUS_TRANSITION`…).
  final String? code;
}

/// Pas de réseau, serveur injoignable ou délai dépassé.
class NetworkFailure extends AppFailure {
  const NetworkFailure({this.timeout = false});

  final bool timeout;
}

class UnauthenticatedFailure extends AppFailure {
  const UnauthenticatedFailure({super.code});
}

class ForbiddenFailure extends AppFailure {
  const ForbiddenFailure({super.code});
}

class NotFoundFailure extends AppFailure {
  const NotFoundFailure({super.code});
}

/// Erreurs de saisie, champ par champ, telles que renvoyées par l'API.
class ValidationFailure extends AppFailure {
  const ValidationFailure(this.fields, {super.code});

  final Map<String, String> fields;
}

/// Refus métier prévu (409, 422, 429…).
class ApiFailure extends AppFailure {
  const ApiFailure({required this.status, super.code, this.message, this.details = const {}});

  final int status;
  final String? message;
  final Map<String, Object?> details;
}

class ServerFailure extends AppFailure {
  const ServerFailure({super.code});
}

/// Erreur locale imprévue (format inattendu, bug). Jamais masquée : elle est affichée comme telle.
class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure([this.cause]);

  final Object? cause;
}

AppFailure failureFromDio(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const NetworkFailure(timeout: true);
    case DioExceptionType.connectionError:
      return const NetworkFailure();
    default:
      break;
  }
  final response = e.response;
  if (response == null) return const NetworkFailure();

  final body = response.data;
  final map = body is Map ? body.cast<String, Object?>() : const <String, Object?>{};
  final code = map['code'] as String?;
  final status = response.statusCode ?? 500;

  switch (status) {
    case 400:
      final rawFields = map['fields'];
      if (rawFields is Map && rawFields.isNotEmpty) {
        return ValidationFailure(rawFields.map((k, v) => MapEntry(k.toString(), v.toString())), code: code);
      }
      return ApiFailure(status: status, code: code, message: map['message'] as String?);
    case 401:
      return UnauthenticatedFailure(code: code);
    case 403:
      return ForbiddenFailure(code: code);
    case 404:
      return NotFoundFailure(code: code);
    default:
      if (status >= 500) return ServerFailure(code: code);
      final details = map['details'];
      return ApiFailure(
        status: status,
        code: code,
        message: map['message'] as String?,
        details: details is Map ? details.cast<String, Object?>() : const {},
      );
  }
}

/// Erreurs de localisation. Jamais de coordonnées inventées : l'appelant propose une adresse manuelle.
class LocationServiceDisabledFailure extends AppFailure {
  const LocationServiceDisabledFailure();
}

class LocationPermissionFailure extends AppFailure {
  const LocationPermissionFailure({required this.permanently});

  /// Refus définitif : seul l'écran des réglages peut rendre l'accès.
  final bool permanently;
}

class LocationTimeoutFailure extends AppFailure {
  const LocationTimeoutFailure();
}

class LocationUnavailableFailure extends AppFailure {
  const LocationUnavailableFailure([this.cause]);

  final Object? cause;
}
