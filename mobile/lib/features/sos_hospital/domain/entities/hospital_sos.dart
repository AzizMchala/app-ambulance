import 'package:flutter/foundation.dart';

import '../../../sos/domain/entities/sos_request.dart';
import '../../../sos/domain/entities/sos_status.dart';

/// Une demande vue par l'hôpital : la demande elle-même et le patient concerné.
@immutable
class HospitalSosItem {
  const HospitalSosItem({required this.request, required this.patientId, required this.patientName});

  final SosRequest request;
  final int patientId;
  final String patientName;
}

/// Les trois files de l'espace hôpital, chacune associée aux statuts réels de l'API.
enum HospitalQueue {
  toHandle({SosStatus.pending}),
  ongoing({SosStatus.accepted, SosStatus.inProgress}),
  closed({SosStatus.completed, SosStatus.rejected, SosStatus.cancelled});

  const HospitalQueue(this.statuses);

  final Set<SosStatus> statuses;
}

/// Ce que l'hôpital peut faire. Le serveur reste juge : il refuse toute transition interdite.
enum HospitalDecision {
  accept(SosStatus.accepted),
  reject(SosStatus.rejected),
  start(SosStatus.inProgress),
  complete(SosStatus.completed);

  const HospitalDecision(this.target);

  final SosStatus target;

  /// Un refus doit toujours être expliqué au patient.
  bool get requiresMessage => this == reject;
}

extension HospitalActions on SosStatus {
  /// Actions proposées selon le statut actuel (mêmes règles que `SosStatus.next()` côté API).
  List<HospitalDecision> get hospitalActions => switch (this) {
    SosStatus.pending => const [HospitalDecision.accept, HospitalDecision.reject],
    SosStatus.accepted => const [HospitalDecision.start, HospitalDecision.complete],
    SosStatus.inProgress => const [HospitalDecision.complete],
    _ => const [],
  };
}
