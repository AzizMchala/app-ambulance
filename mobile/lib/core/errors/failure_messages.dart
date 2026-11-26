import '../../l10n/app_localizations.dart';
import 'app_failure.dart';

/// Message lisible pour un patient. Point unique : aucun écran ne fabrique ses propres messages d'erreur.
String failureMessage(AppLocalizations l, AppFailure failure) {
  switch (failure.code) {
    case 'SOS_ALREADY_ACTIVE':
      return l.errorSosAlreadyActive;
    case 'INVALID_STATUS_TRANSITION':
      return l.errorInvalidTransition;
    case 'INVALID_CREDENTIALS':
      return l.authInvalidCredentials;
    case 'EMAIL_TAKEN':
      return l.authEmailTaken;
  }
  return switch (failure) {
    NetworkFailure(timeout: true) => l.errorTimeout,
    NetworkFailure() => l.errorNetwork,
    UnauthenticatedFailure() => l.errorUnauthenticated,
    ForbiddenFailure() => l.errorForbidden,
    NotFoundFailure() => l.errorNotFound,
    ValidationFailure() => l.errorValidation,
    ServerFailure() => l.errorServer,
    LocationServiceDisabledFailure() => l.locationServiceOff,
    LocationPermissionFailure() => l.locationPermissionDenied,
    LocationTimeoutFailure() => l.locationTimeout,
    LocationUnavailableFailure() => l.locationError,
    ApiFailure(:final message) when message != null && message.isNotEmpty => message,
    _ => l.errorUnexpected,
  };
}
