import '../../domain/entities/sos_draft.dart';
import '../../domain/entities/sos_location.dart';
import '../../domain/entities/sos_request.dart';
import '../../domain/entities/sos_status.dart';

/// Conversion JSON ⇄ entités, alignée sur les DTO de l'API (voir docs/api-contract.md).
///
/// Écrite à la main plutôt qu'avec json_serializable : quatre objets plats ne justifient pas
/// une étape de génération de code pour toute l'équipe. Un champ obligatoire absent lève une
/// erreur de type, transformée en `ServerFailure` par `guardApi` : jamais de demande à moitié lue.
abstract final class SosJson {
  static DateTime _date(Object? v) => DateTime.parse(v! as String).toLocal();

  static DateTime? _dateOrNull(Object? v) => v == null ? null : _date(v);

  static double? _double(Object? v) => (v as num?)?.toDouble();

  static String? _text(Object? v) {
    final s = v as String?;
    return s == null || s.trim().isEmpty ? null : s;
  }

  static SosRequest request(Map<String, Object?> json) => SosRequest(
    id: (json['id']! as num).toInt(),
    location: SosLocation(
      source: LocationSource.fromApi(json['locationSource'] as String?),
      latitude: _double(json['latitude']),
      longitude: _double(json['longitude']),
      accuracyMeters: _double(json['locationAccuracy']),
      capturedAt: _dateOrNull(json['locationCapturedAt']),
      address: _text(json['address']),
    ),
    status: SosStatus.fromApi(json['status']! as String),
    decisionMessage: _text(json['decisionMessage']),
    createdAt: _date(json['createdAt']),
    updatedAt: _date(json['updatedAt']),
  );

  static SosStatusSnapshot status(Map<String, Object?> json) => SosStatusSnapshot(
    id: (json['id']! as num).toInt(),
    status: SosStatus.fromApi(json['status']! as String),
    decisionMessage: _text(json['decisionMessage']),
    updatedAt: _date(json['updatedAt']),
  );

  static SosHistoryEntry history(Map<String, Object?> json) {
    final old = json['oldStatus'] as String?;
    return SosHistoryEntry(
      id: (json['id']! as num).toInt(),
      oldStatus: old == null ? null : SosStatus.fromApi(old),
      newStatus: SosStatus.fromApi(json['newStatus']! as String),
      description: _text(json['description']),
      createdAt: _date(json['createdAt']),
    );
  }

  /// Corps de `POST /api/sos`. Les champs absents ne sont pas envoyés.
  static Map<String, Object?> create(SosDraft draft) {
    final l = draft.location;
    return {
      'clientRequestId': draft.clientRequestId,
      'locationSource': l.source!.apiValue,
      if (l.latitude != null) 'latitude': l.latitude,
      if (l.longitude != null) 'longitude': l.longitude,
      if (l.accuracyMeters != null) 'locationAccuracy': double.parse(l.accuracyMeters!.toStringAsFixed(1)),
      if (l.capturedAt != null) 'locationCapturedAt': l.capturedAt!.toUtc().toIso8601String(),
      if (l.hasAddress) 'address': l.address!.trim(),
    };
  }
}
