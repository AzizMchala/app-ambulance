import 'package:flutter/widgets.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/status_pill.dart';
import '../../domain/entities/sos_location.dart';
import '../../domain/entities/sos_status.dart';

/// Traduction visuelle d'un statut : libellé, phrase de titre, tonalité et icône.
extension SosStatusStyle on SosStatus {
  String label(AppLocalizations l) => switch (this) {
    SosStatus.pending => l.statusPending,
    SosStatus.accepted => l.statusAccepted,
    SosStatus.inProgress => l.statusInProgress,
    SosStatus.completed => l.statusCompleted,
    SosStatus.rejected => l.statusRejected,
    SosStatus.cancelled => l.statusCancelled,
    SosStatus.unknown => l.statusUnknown,
  };

  String headline(AppLocalizations l) => switch (this) {
    SosStatus.pending => l.statusHeadlinePending,
    SosStatus.accepted => l.statusHeadlineAccepted,
    SosStatus.inProgress => l.statusHeadlineInProgress,
    SosStatus.completed => l.statusHeadlineCompleted,
    SosStatus.rejected => l.statusHeadlineRejected,
    SosStatus.cancelled => l.statusHeadlineCancelled,
    SosStatus.unknown => l.statusHeadlineUnknown,
  };

  StatusTone get tone => switch (this) {
    SosStatus.pending => StatusTone.warning,
    SosStatus.accepted || SosStatus.inProgress => StatusTone.info,
    SosStatus.completed => StatusTone.success,
    SosStatus.rejected => StatusTone.danger,
    SosStatus.cancelled || SosStatus.unknown => StatusTone.neutral,
  };

  IconData get icon => switch (this) {
    SosStatus.pending => PhosphorIconsLight.hourglassMedium,
    SosStatus.accepted => PhosphorIconsLight.checkCircle,
    SosStatus.inProgress => PhosphorIconsLight.ambulance,
    SosStatus.completed => PhosphorIconsLight.sealCheck,
    SosStatus.rejected => PhosphorIconsLight.xCircle,
    SosStatus.cancelled => PhosphorIconsLight.prohibit,
    SosStatus.unknown => PhosphorIconsLight.question,
  };
}

extension LocationSourceStyle on LocationSource {
  String label(AppLocalizations l) => switch (this) {
    LocationSource.gps => l.locationSourceGps,
    LocationSource.lastKnown => l.locationSourceLastKnown,
    LocationSource.manual => l.locationSourceManual,
  };

  IconData get icon => switch (this) {
    LocationSource.gps => PhosphorIconsLight.crosshair,
    LocationSource.lastKnown => PhosphorIconsLight.clockCounterClockwise,
    LocationSource.manual => PhosphorIconsLight.mapPinLine,
  };
}
