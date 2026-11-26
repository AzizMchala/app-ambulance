import 'package:flutter/foundation.dart';

/// D'où vient la localisation jointe à la demande. Identique à `LocationSource` côté API.
enum LocationSource {
  /// Relevé GPS frais, pris au moment de la demande.
  gps('GPS'),

  /// Dernière position mise en cache par le téléphone : ancienne, toujours signalée comme telle.
  lastKnown('LAST_KNOWN'),

  /// Pas de coordonnées : adresse saisie par le patient.
  manual('MANUAL');

  const LocationSource(this.apiValue);

  final String apiValue;

  static LocationSource? fromApi(String? value) {
    for (final s in values) {
      if (s.apiValue == value) return s;
    }
    return null;
  }
}

/// Localisation d'une demande SOS : des coordonnées réelles, une adresse, ou les deux.
@immutable
class SosLocation {
  const SosLocation({
    required this.source,
    this.latitude,
    this.longitude,
    this.accuracyMeters,
    this.capturedAt,
    this.address,
  });

  final LocationSource? source;
  final double? latitude;
  final double? longitude;
  final double? accuracyMeters;

  /// Moment réel du relevé GPS (et non celui de l'envoi).
  final DateTime? capturedAt;
  final String? address;

  bool get hasCoordinates => latitude != null && longitude != null;

  bool get hasAddress => address != null && address!.trim().isNotEmpty;

  @override
  bool operator ==(Object other) =>
      other is SosLocation &&
      other.source == source &&
      other.latitude == latitude &&
      other.longitude == longitude &&
      other.accuracyMeters == accuracyMeters &&
      other.capturedAt == capturedAt &&
      other.address == address;

  @override
  int get hashCode => Object.hash(source, latitude, longitude, accuracyMeters, capturedAt, address);
}
