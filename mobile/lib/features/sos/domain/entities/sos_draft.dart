import 'package:flutter/foundation.dart';

import 'sos_location.dart';

/// Demande prête à être envoyée, avant confirmation par le serveur.
///
/// [clientRequestId] reste le même pendant toutes les tentatives d'envoi d'une même alerte :
/// si la réponse se perd et que le patient réessaie, le serveur renvoie la demande déjà créée
/// au lieu d'en créer une seconde (idempotence).
@immutable
class SosDraft {
  const SosDraft({required this.clientRequestId, required this.location});

  final String clientRequestId;
  final SosLocation location;
}
