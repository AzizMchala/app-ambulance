import 'package:flutter/foundation.dart';

import 'sos_location.dart';
import 'sos_status.dart';

/// Une demande SOS telle qu'enregistrée par le serveur.
/// Un objet [SosRequest] n'existe dans l'application que si l'API l'a renvoyé.
@immutable
class SosRequest {
  const SosRequest({
    required this.id,
    required this.location,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.decisionMessage,
  });

  final int id;
  final SosLocation location;
  final SosStatus status;

  /// Message joint à la décision par les secours. `null` tant qu'aucun message n'est reçu.
  final String? decisionMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  SosRequest copyWith({SosStatus? status, String? decisionMessage, DateTime? updatedAt}) => SosRequest(
    id: id,
    location: location,
    status: status ?? this.status,
    decisionMessage: decisionMessage ?? this.decisionMessage,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}

/// Réponse légère de `GET /api/sos/{id}/status`, utilisée pour le suivi en direct.
@immutable
class SosStatusSnapshot {
  const SosStatusSnapshot({required this.id, required this.status, required this.updatedAt, this.decisionMessage});

  final int id;
  final SosStatus status;
  final String? decisionMessage;
  final DateTime updatedAt;
}

/// Un changement de statut conservé par le serveur (table `sos_history`).
@immutable
class SosHistoryEntry {
  const SosHistoryEntry({
    required this.id,
    required this.newStatus,
    required this.createdAt,
    this.oldStatus,
    this.description,
  });

  final int id;

  /// `null` pour la création de la demande.
  final SosStatus? oldStatus;
  final SosStatus newStatus;
  final String? description;
  final DateTime createdAt;
}
