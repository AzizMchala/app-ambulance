import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/services/location_service.dart';

/// Résultat d'une recherche de position pour une alerte.
@immutable
class SosLocationReading {
  const SosLocationReading({required this.fix, required this.isStale, this.freshFailure});

  final GeoFix fix;

  /// `true` si [fix] est la dernière position connue du téléphone et non un relevé frais.
  final bool isStale;

  /// Pourquoi le relevé frais a échoué, quand [isStale] est vrai.
  final AppFailure? freshFailure;

  Duration ageAt(DateTime now) => now.difference(fix.capturedAt);
}

/// Politique de localisation du SOS :
/// 1. service activé et autorisation accordée, sinon échec explicite ;
/// 2. relevé frais en haute précision avec délai limité ;
/// 3. si le relevé échoue, la dernière position connue, toujours marquée comme ancienne ;
/// 4. sinon échec : l'écran propose une adresse manuelle. Aucune coordonnée n'est inventée.
class GetSosLocation {
  const GetSosLocation(this._location, {this.timeout = const Duration(seconds: 15)});

  final LocationService _location;
  final Duration timeout;

  /// Une position plus récente que ce seuil est considérée comme actuelle.
  static const freshnessLimit = Duration(minutes: 2);

  Future<SosLocationReading> call({DateTime Function() now = DateTime.now}) async {
    if (!await _location.isServiceEnabled()) throw const LocationServiceDisabledFailure();
    final permission = await _location.checkPermission();
    if (permission != LocationPermissionStatus.granted) {
      throw LocationPermissionFailure(permanently: permission == LocationPermissionStatus.deniedForever);
    }

    try {
      final fix = await _location.currentFix(timeout: timeout);
      // Certains téléphones renvoient un relevé en cache comme « courant » : on vérifie sa date.
      final stale = now().difference(fix.capturedAt) > freshnessLimit;
      return SosLocationReading(fix: fix, isStale: stale);
    } on AppFailure catch (failure) {
      if (failure is LocationServiceDisabledFailure || failure is LocationPermissionFailure) rethrow;
      final last = await _location.lastKnownFix();
      if (last == null) rethrow;
      return SosLocationReading(fix: last, isStale: true, freshFailure: failure);
    }
  }
}
