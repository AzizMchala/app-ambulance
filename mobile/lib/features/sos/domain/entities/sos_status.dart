/// Statuts d'une demande SOS, identiques à l'énumération `SosStatus` de l'API.
///
/// L'application ne décide jamais d'un statut : elle affiche celui que renvoie le serveur.
/// Une valeur que cette version ne connaît pas devient [unknown] au lieu d'être devinée.
enum SosStatus {
  pending('PENDING'),
  accepted('ACCEPTED'),
  inProgress('IN_PROGRESS'),
  completed('COMPLETED'),
  rejected('REJECTED'),
  cancelled('CANCELLED'),
  unknown('UNKNOWN');

  const SosStatus(this.apiValue);

  final String apiValue;

  static SosStatus fromApi(String? value) {
    for (final s in values) {
      if (s.apiValue == value) return s;
    }
    return SosStatus.unknown;
  }

  /// La demande attend encore une suite (décision ou intervention).
  bool get isActive => this == pending || this == accepted || this == inProgress;

  /// Seule une demande sans décision peut être annulée par le patient.
  bool get isCancellableByPatient => this == pending;
}
