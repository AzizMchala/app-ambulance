import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../sos/domain/entities/sos_location.dart';
import '../../../sos/domain/entities/sos_status.dart';
import '../../../sos/presentation/widgets/sos_request_tile.dart';
import '../../../sos/presentation/widgets/sos_status_style.dart';
import '../../domain/entities/hospital_sos.dart';

/// Carte d'une demande dans la file de l'hôpital : patient, ancienneté, localisation, statut.
/// Une demande en attente porte un liseré rouge : c'est la seule chose qui attire l'œil.
class HospitalRequestCard extends StatelessWidget {
  const HospitalRequestCard({super.key, required this.item, required this.onTap});

  final HospitalSosItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final r = item.request;
    final pending = r.status == SosStatus.pending;
    final source = r.location.source;

    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      semanticLabel:
          '${item.patientName}, ${l.requestNumber(r.id)}, ${r.status.label(l)}, ${Formatters.relative(l, r.createdAt)}',
      child: ExcludeSemantics(
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 5, color: pending ? c.danger : Colors.transparent),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpace.x4, AppSpace.x4, AppSpace.x4, AppSpace.x4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.patientName,
                              style: context.text.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppSpace.x2),
                          StatusPill(label: r.status.label(l), tone: r.status.tone),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${l.requestNumber(r.id)} · ${Formatters.relative(l, r.createdAt)}',
                        style: context.text.bodySmall!.copyWith(
                          color: pending ? c.onDangerTint : null,
                          fontWeight: pending ? FontWeight.w600 : null,
                        ),
                      ),
                      const SizedBox(height: AppSpace.x2),
                      Row(
                        children: [
                          Icon(source?.icon ?? PhosphorIconsLight.mapPin, size: 16, color: c.inkMuted),
                          const SizedBox(width: AppSpace.x1),
                          Expanded(
                            child: Text(
                              sosLocationSummary(r),
                              style: context.text.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (source == LocationSource.lastKnown) ...[
                            const SizedBox(width: AppSpace.x2),
                            StatusPill(label: l.locationStale, tone: StatusTone.warning),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
