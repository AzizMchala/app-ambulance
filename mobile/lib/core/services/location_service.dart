import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

import '../errors/app_failure.dart';

/// État de l'autorisation de localisation, indépendant du plugin utilisé.
enum LocationPermissionStatus { granted, denied, deniedForever }

/// Un relevé GPS réel, tel que fourni par le téléphone. Jamais construit à partir de valeurs par défaut.
@immutable
class GeoFix {
  const GeoFix({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.capturedAt,
  });

  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final DateTime capturedAt;
}

/// Accès plateforme au GPS. Aucune règle métier ici : ce service est réutilisable par E3 (ambulances).
///
/// Les permissions passent par permission_handler sur mobile. Sur le web, ce plugin n'a pas
/// d'implémentation : on passe alors par l'API du navigateur via geolocator.
abstract interface class LocationService {
  Future<bool> isServiceEnabled();
  Future<LocationPermissionStatus> checkPermission();
  Future<LocationPermissionStatus> requestPermission();

  /// Relevé frais. Lève [LocationTimeoutFailure] après [timeout], jamais de valeur approximative.
  Future<GeoFix> currentFix({required Duration timeout});

  /// Dernière position mise en cache par le système, avec sa vraie date. `null` si aucune.
  Future<GeoFix?> lastKnownFix();

  Future<bool> openAppSettings();
  Future<bool> openLocationSettings();
}

class DeviceLocationService implements LocationService {
  const DeviceLocationService();

  @override
  Future<bool> isServiceEnabled() => Geolocator.isLocationServiceEnabled();

  @override
  Future<LocationPermissionStatus> checkPermission() async {
    if (kIsWeb) return _fromGeolocator(await Geolocator.checkPermission());
    return _fromHandler(await ph.Permission.locationWhenInUse.status);
  }

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    if (kIsWeb) return _fromGeolocator(await Geolocator.requestPermission());
    return _fromHandler(await ph.Permission.locationWhenInUse.request());
  }

  @override
  Future<GeoFix> currentFix({required Duration timeout}) async {
    try {
      final p = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high, timeLimit: timeout),
      );
      return _toFix(p);
    } on TimeoutException {
      throw const LocationTimeoutFailure();
    } on LocationServiceDisabledException {
      throw const LocationServiceDisabledFailure();
    } on PermissionDeniedException {
      throw const LocationPermissionFailure(permanently: false);
    } catch (e) {
      throw LocationUnavailableFailure(e);
    }
  }

  @override
  Future<GeoFix?> lastKnownFix() async {
    // Le navigateur n'expose pas de dernière position connue.
    if (kIsWeb) return null;
    try {
      final p = await Geolocator.getLastKnownPosition();
      return p == null ? null : _toFix(p);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> openAppSettings() => kIsWeb ? Future.value(false) : ph.openAppSettings();

  @override
  Future<bool> openLocationSettings() => kIsWeb ? Future.value(false) : Geolocator.openLocationSettings();

  static GeoFix _toFix(Position p) => GeoFix(
    latitude: p.latitude,
    longitude: p.longitude,
    accuracyMeters: p.accuracy,
    capturedAt: p.timestamp.toLocal(),
  );

  static LocationPermissionStatus _fromHandler(ph.PermissionStatus s) {
    if (s.isGranted || s.isLimited) return LocationPermissionStatus.granted;
    if (s.isPermanentlyDenied || s.isRestricted) return LocationPermissionStatus.deniedForever;
    return LocationPermissionStatus.denied;
  }

  static LocationPermissionStatus _fromGeolocator(LocationPermission p) => switch (p) {
    LocationPermission.always || LocationPermission.whileInUse => LocationPermissionStatus.granted,
    LocationPermission.deniedForever => LocationPermissionStatus.deniedForever,
    _ => LocationPermissionStatus.denied,
  };
}

final locationServiceProvider = Provider<LocationService>((ref) => const DeviceLocationService());
