import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/sos_request.dart';
import 'sos_status_style.dart';

/// Texte de localisation d'une demande : l'adresse si elle existe, sinon les coordonnées.
String sosLocationSummary(SosRequest r) {
  final loc = r.location;
  if (loc.hasAddress) return loc.address!;
  if (loc.hasCoordinates) return Formatters.coordinates(loc.latitude!, loc.longitude!);
  return '—';
}

/// Ligne d'historique : identifiant, date, heure, statut et localisation.
class SosRequestTile extends StatelessWidget {
  const SosRequestTile({super.key, required this.request, required this.onTap});

  final SosRequest request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final tone = statusToneColors(context, request.status.tone);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpace.x4),
      semanticLabel:
          '${l.requestNumber(request.id)}, ${request.status.label(l)}, ${Formatters.date(request.createdAt)} ${Formatters.time(request.createdAt)}',
      child: ExcludeSemantics(
        child: Row(
          children: [
            IconBadge(icon: request.status.icon, background: tone.background, foreground: tone.foreground),
            const SizedBox(width: AppSpace.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(l.requestNumber(request.id), style: context.text.titleMedium)),
                      StatusPill(label: request.status.label(l), tone: request.status.tone),
                    ],
                  ),
                  const SizedBox(height: AppSpace.x1),
                  Text(
                    '${Formatters.date(request.createdAt)} · ${Formatters.time(request.createdAt)}',
                    style: context.text.bodySmall,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(PhosphorIconsLight.mapPin, size: 14, color: c.inkMuted),
                      const SizedBox(width: AppSpace.x1),
                      Expanded(
                        child: Text(
                          sosLocationSummary(request),
                          style: context.text.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpace.x2),
            Icon(PhosphorIconsLight.caretRight, size: 18, color: c.inkMuted),
          ],
        ),
      ),
    );
  }
}
