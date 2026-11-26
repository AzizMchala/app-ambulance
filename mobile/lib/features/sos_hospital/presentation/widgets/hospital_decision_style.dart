import 'package:flutter/widgets.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../domain/entities/hospital_sos.dart';

/// Traduction visuelle des décisions de l'hôpital.
extension HospitalDecisionStyle on HospitalDecision {
  String label(AppLocalizations l) => switch (this) {
    HospitalDecision.accept => l.hospitalActionAccept,
    HospitalDecision.reject => l.hospitalActionReject,
    HospitalDecision.start => l.hospitalActionStart,
    HospitalDecision.complete => l.hospitalActionComplete,
  };

  String sheetTitle(AppLocalizations l) => switch (this) {
    HospitalDecision.accept => l.hospitalSheetAcceptTitle,
    HospitalDecision.reject => l.hospitalSheetRejectTitle,
    HospitalDecision.start => l.hospitalSheetStartTitle,
    HospitalDecision.complete => l.hospitalSheetCompleteTitle,
  };

  IconData get icon => switch (this) {
    HospitalDecision.accept => PhosphorIconsLight.checkCircle,
    HospitalDecision.reject => PhosphorIconsLight.xCircle,
    HospitalDecision.start => PhosphorIconsLight.ambulance,
    HospitalDecision.complete => PhosphorIconsLight.sealCheck,
  };

  /// Le bouton principal est à l'encre ; le refus est un bouton secondaire, jamais rouge vif
  /// à côté de « Accepter », pour éviter une erreur de geste.
  AppButtonVariant get buttonVariant =>
      this == HospitalDecision.reject ? AppButtonVariant.secondary : AppButtonVariant.primary;
}
