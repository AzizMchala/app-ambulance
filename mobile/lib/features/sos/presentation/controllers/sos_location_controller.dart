import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/services/location_service.dart';
import '../../domain/usecases/get_sos_location.dart';
import '../providers/sos_providers.dart';

/// Ce que l'écran sait de la localisation à un instant donné.
sealed class SosLocationState {
  const SosLocationState();
}

class LocationChecking extends SosLocationState {
  const LocationChecking();
}

class LocationAcquiring extends SosLocationState {
  const LocationAcquiring();
}

class LocationReady extends SosLocationState {
  const LocationReady(this.reading, this.readAt);

  final SosLocationReading reading;

  /// Quand l'application a obtenu cette lecture (pour savoir s'il faut la rafraîchir).
  final DateTime readAt;
}

enum LocationProblem { serviceDisabled, permissionNeeded, permissionDeniedForever, timeout, unavailable }

class LocationUnavailable extends SosLocationState {
  const LocationUnavailable(this.problem);

  final LocationProblem problem;
}

/// Pilote la localisation pour le SOS : vérification, demande d'autorisation au bon moment,
/// relevé, et nouvel essai quand le patient revient des réglages.
///
/// L'autorisation n'est jamais demandée à l'ouverture de l'application : seulement quand le patient
/// appuie sur « Autoriser » ou quand il prépare une alerte.
class SosLocationController extends Notifier<SosLocationState> {
  AppLifecycleListener? _lifecycle;
  int _generation = 0;

  /// Au-delà, une lecture est refaite avant l'envoi.
  static const maxReadingAge = Duration(minutes: 1);

  @override
  SosLocationState build() {
    _lifecycle = AppLifecycleListener(
      onResume: () {
        if (state is LocationUnavailable) refresh();
      },
    );
    ref.onDispose(() => _lifecycle?.dispose());
    Future.microtask(refresh);
    return const LocationChecking();
  }

  LocationService get _service => ref.read(locationServiceProvider);

  Future<void> refresh({bool askPermission = false}) async {
    final generation = ++_generation;
    bool stillCurrent() => generation == _generation && ref.mounted;

    state = const LocationChecking();
    try {
      if (!await _service.isServiceEnabled()) {
        if (stillCurrent()) state = const LocationUnavailable(LocationProblem.serviceDisabled);
        return;
      }
      var permission = await _service.checkPermission();
      if (permission == LocationPermissionStatus.denied && askPermission) {
        permission = await _service.requestPermission();
      }
      if (!stillCurrent()) return;
      if (permission != LocationPermissionStatus.granted) {
        state = LocationUnavailable(
          permission == LocationPermissionStatus.deniedForever
              ? LocationProblem.permissionDeniedForever
              : LocationProblem.permissionNeeded,
        );
        return;
      }

      state = const LocationAcquiring();
      final reading = await ref.read(getSosLocationProvider)();
      if (stillCurrent()) state = LocationReady(reading, DateTime.now());
    } on AppFailure catch (failure) {
      if (stillCurrent()) state = LocationUnavailable(_problemFor(failure));
    } catch (_) {
      if (stillCurrent()) state = const LocationUnavailable(LocationProblem.unavailable);
    }
  }

  /// Avant l'envoi : redemande l'autorisation si besoin, ou rafraîchit une lecture trop vieille.
  Future<void> prepareForSending() async {
    final s = state;
    if (s is LocationUnavailable && s.problem == LocationProblem.permissionNeeded) {
      await refresh(askPermission: true);
    } else if (s is LocationReady && DateTime.now().difference(s.readAt) > maxReadingAge) {
      await refresh();
    } else if (s is LocationUnavailable && s.problem != LocationProblem.permissionDeniedForever) {
      await refresh();
    }
  }

  /// Ouvre l'écran système qui règle le problème courant.
  Future<void> openSettings() async {
    final s = state;
    if (s is! LocationUnavailable) return;
    if (s.problem == LocationProblem.serviceDisabled) {
      await _service.openLocationSettings();
    } else {
      await _service.openAppSettings();
    }
  }

  static LocationProblem _problemFor(AppFailure failure) => switch (failure) {
    LocationServiceDisabledFailure() => LocationProblem.serviceDisabled,
    LocationPermissionFailure(permanently: true) => LocationProblem.permissionDeniedForever,
    LocationPermissionFailure() => LocationProblem.permissionNeeded,
    LocationTimeoutFailure() => LocationProblem.timeout,
    _ => LocationProblem.unavailable,
  };
}

/// Gardé en vie pendant la session : l'écran principal et l'écran de vérification partagent la même lecture.
final sosLocationControllerProvider = NotifierProvider<SosLocationController, SosLocationState>(
  SosLocationController.new,
);
