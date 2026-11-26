import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/status_pill.dart';
import '../../domain/entities/sos_request.dart';
import 'sos_status_style.dart';

/// Frise verticale des changements de statut, tels qu'enregistrés par le serveur.
class StatusTimeline extends StatelessWidget {
  const StatusTimeline({super.key, required this.entries});

  /// Du plus ancien au plus récent.
  final List<SosHistoryEntry> entries;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (entries.isEmpty) return Text(l.detailTimelineEmpty, style: context.text.bodyMedium);

    final ordered = entries.reversed.toList();
    return Column(
      children: [
        for (var i = 0; i < ordered.length; i++)
          _TimelineRow(entry: ordered[i], isFirst: i == 0, isLast: i == ordered.length - 1),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.entry, required this.isFirst, required this.isLast});

  final SosHistoryEntry entry;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final tone = statusToneColors(context, entry.newStatus.tone);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isFirst ? tone.foreground : c.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: isFirst ? tone.foreground : c.inkMuted.withValues(alpha: 0.5), width: 2),
                  ),
                ),
                if (!isLast) Expanded(child: Container(width: 2, color: c.line)),
              ],
            ),
          ),
          const SizedBox(width: AppSpace.x3),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpace.x5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.newStatus.headline(l),
                    style: context.text.titleSmall!.copyWith(color: isFirst ? c.ink : c.inkSoft),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${Formatters.date(entry.createdAt)} · ${Formatters.time(entry.createdAt)}',
                    style: context.text.bodySmall,
                  ),
                  if (entry.description != null) ...[
                    const SizedBox(height: 2),
                    Text(entry.description!, style: context.text.bodyMedium),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
