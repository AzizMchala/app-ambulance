import '../entities/sos_draft.dart';
import '../entities/sos_location.dart';
import 'get_sos_location.dart';

/// Pourquoi une alerte ne peut pas encore partir.
enum SosDraftIssue { addressRequired, addressTooShort, addressTooLong }

/// Résultat de la préparation : soit un brouillon valide, soit le problème à corriger.
sealed class SosDraftResult {
  const SosDraftResult();
}

class SosDraftReady extends SosDraftResult {
  const SosDraftReady(this.draft);

  final SosDraft draft;
}

class SosDraftInvalid extends SosDraftResult {
  const SosDraftInvalid(this.issue);

  final SosDraftIssue issue;
}

/// Assemble la localisation à envoyer à partir de ce que l'écran a réellement obtenu.
///
/// Règles :
/// - un relevé frais est envoyé comme `GPS` ;
/// - un relevé ancien n'est envoyé (comme `LAST_KNOWN`) que si le patient l'a explicitement accepté ;
/// - sans coordonnées utilisables, une adresse d'au moins [minAddressLength] caractères est obligatoire.
class BuildSosDraft {
  const BuildSosDraft();

  static const minAddressLength = 5;
  static const maxAddressLength = 255;

  SosDraftResult call({
    required String clientRequestId,
    required SosLocationReading? reading,
    required bool acceptStale,
    required String address,
  }) {
    final trimmed = address.trim();
    if (trimmed.length > maxAddressLength) return const SosDraftInvalid(SosDraftIssue.addressTooLong);

    final usable = reading != null && (!reading.isStale || acceptStale) ? reading : null;
    if (usable == null) {
      if (trimmed.isEmpty) return const SosDraftInvalid(SosDraftIssue.addressRequired);
      if (trimmed.length < minAddressLength) return const SosDraftInvalid(SosDraftIssue.addressTooShort);
    }

    final location = usable == null
        ? SosLocation(source: LocationSource.manual, address: trimmed)
        : SosLocation(
            source: usable.isStale ? LocationSource.lastKnown : LocationSource.gps,
            latitude: usable.fix.latitude,
            longitude: usable.fix.longitude,
            accuracyMeters: usable.fix.accuracyMeters,
            capturedAt: usable.fix.capturedAt,
            address: trimmed.isEmpty ? null : trimmed,
          );
    return SosDraftReady(SosDraft(clientRequestId: clientRequestId, location: location));
  }
}
