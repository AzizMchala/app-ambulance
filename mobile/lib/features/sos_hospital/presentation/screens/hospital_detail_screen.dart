import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/failure_messages.dart';
import '../../../../core/services/directions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../sos/domain/entities/sos_location.dart';
import '../../../sos/presentation/widgets/location_map.dart';
import '../../../sos/presentation/widgets/sos_status_style.dart';
import '../../../sos/presentation/widgets/status_timeline.dart';
import '../../domain/entities/hospital_sos.dart';
import '../controllers/hospital_detail_controller.dart';
import '../widgets/decision_sheet.dart';
import '../widgets/hospital_decision_style.dart';

/// Détail d'une demande pour l'hôpital : patient, localisation, suivi, et les décisions possibles.
class HospitalDetailScreen extends ConsumerWidget {
  const HospitalDetailScreen({super.key, required this.id});

  final int id;

  Future<void> _decide(BuildContext context, WidgetRef ref, HospitalDecision decision) async {
    final message = await showDecisionSheet(context, decision);
    if (message == null || !context.mounted) return;
    final l = AppLocalizations.of(context);
    final failure = await ref.read(hospitalDetailControllerProvider(id).notifier).decide(decision, message);
    if (!context.mounted) return;
    if (failure == null) {
      AppFeedback.toast(context, l.hospitalDecisionSaved(decision.target.label(l)));
    } else {
      final conflict = failure is ApiFailure && failure.status == 409;
      AppFeedback.toast(context, conflict ? l.hospitalDecisionConflict : failureMessage(l, failure), error: true);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final provider = hospitalDetailControllerProvider(id);
    final detail = ref.watch(provider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.requestNumber(id)),
        actions: [
          if (detail.hasValue)
            IconButton(
              tooltip: l.commonRetry,
              icon: const Icon(PhosphorIconsLight.arrowClockwise),
              onPressed: () => ref.read(provider.notifier).reload(),
            ),
        ],
      ),
      body: switch (detail) {
        AsyncData(:final value) => RefreshIndicator(
          onRefresh: () => ref.read(provider.notifier).reload(),
          child: _Body(state: value),
        ),
        AsyncError(:final error) => ErrorView(
          message: failureMessage(l, error is AppFailure ? error : UnexpectedFailure(error)),
          onRetry: () => ref.invalidate(provider),
        ),
        _ => const LoadingView(),
      },
      bottomNavigationBar: switch (detail) {
        AsyncData(:final value) when value.item.request.status.hospitalActions.isNotEmpty => SafeArea(
          minimum: const EdgeInsets.only(bottom: AppSpace.x3),
          child: ContentFrame(
            padding: const EdgeInsets.fromLTRB(AppSpace.gutter, AppSpace.x3, AppSpace.gutter, 0),
            child: _ActionBar(state: value, onDecide: (d) => _decide(context, ref, d)),
          ),
        ),
        _ => null,
      },
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.state, required this.onDecide});

  final HospitalDetailState state;
  final ValueChanged<HospitalDecision> onDecide;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    // Ordre d'affichage : action secondaire à gauche, action principale à droite (sous le pouce).
    final actions = state.item.request.status.hospitalActions.reversed.toList();
    final busy = state.deciding != null;
    return Row(
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpace.x3),
          Expanded(
            child: AppButton(
              label: actions[i].label(l),
              icon: actions[i].icon,
              // La dernière action (à droite) est la principale ; les autres restent discrètes.
              variant: i == actions.length - 1 ? AppButtonVariant.primary : AppButtonVariant.secondary,
              loading: state.deciding == actions[i],
              onPressed: busy ? null : () => onDecide(actions[i]),
            ),
          ),
        ],
      ],
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state});

  final HospitalDetailState state;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final r = state.item.request;
    final tone = statusToneColors(context, r.status.tone);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSpace.x10),
      children: [
        ContentFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.refreshFailed) ...[
                InlineNotice(tone: NoticeTone.warning, message: l.detailRefreshFailed),
                const SizedBox(height: AppSpace.x4),
              ],
              AppCard(
                padding: const EdgeInsets.all(AppSpace.x6),
                child: Semantics(
                  liveRegion: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconBadge(
                            icon: r.status.icon,
                            background: tone.background,
                            foreground: tone.foreground,
                            size: 52,
                          ),
                          const Spacer(),
                          StatusPill(label: r.status.label(l), tone: r.status.tone, large: true),
                        ],
                      ),
                      const SizedBox(height: AppSpace.x5),
                      Text(l.hospitalPatient.toUpperCase(), style: context.text.labelSmall),
                      const SizedBox(height: AppSpace.x1),
                      Text(state.item.patientName, style: context.text.headlineMedium),
                      const SizedBox(height: AppSpace.x1),
                      Text(
                        '${l.hospitalPatientId(state.item.patientId)} · ${Formatters.relative(l, r.createdAt)}',
                        style: context.text.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpace.x6),
              SectionLabel(l.detailLocation),
              _LocationCard(location: r.location),
              if (r.decisionMessage != null) ...[
                const SizedBox(height: AppSpace.x6),
                SectionLabel(l.detailDecisionMessage),
                AppCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(PhosphorIconsLight.chatCircleText, color: c.inkSoft),
                      const SizedBox(width: AppSpace.x3),
                      Expanded(child: Text(r.decisionMessage!, style: context.text.bodyLarge)),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpace.x6),
              SectionLabel(l.detailTimeline),
              AppCard(child: StatusTimeline(entries: state.history)),
              if (r.status.hospitalActions.isEmpty) ...[
                const SizedBox(height: AppSpace.x6),
                InlineNotice(tone: NoticeTone.info, message: l.hospitalNoAction),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.location});

  final SosLocation location;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final source = location.source;
    final stale = source == LocationSource.lastKnown;
    return AppCard(
      padding: const EdgeInsets.all(AppSpace.x4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (location.hasCoordinates) ...[
            LocationMap(
              latitude: location.latitude,
              longitude: location.longitude,
              accuracyMeters: location.accuracyMeters,
              stale: stale,
              height: 220,
              interactive: true,
            ),
            const SizedBox(height: AppSpace.x3),
          ],
          if (stale && location.capturedAt != null) ...[
            InlineNotice(
              tone: NoticeTone.warning,
              message: l.hospitalStaleWarning(Formatters.relative(l, location.capturedAt!)),
            ),
            const SizedBox(height: AppSpace.x2),
          ],
          if (source != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.x1),
              child: Row(
                children: [
                  Icon(source.icon, size: 18, color: context.colors.inkSoft),
                  const SizedBox(width: AppSpace.x2),
                  Expanded(child: Text(source.label(l), style: context.text.titleSmall)),
                  if (location.accuracyMeters != null)
                    Text(l.locationAccuracy(location.accuracyMeters!.round()), style: context.text.bodySmall),
                ],
              ),
            ),
          if (location.hasCoordinates)
            InfoRow(
              label: l.locationCoordinates,
              value: Formatters.coordinates(location.latitude!, location.longitude!),
              selectable: true,
            ),
          if (location.capturedAt != null)
            InfoRow(
              label: l.detailCapturedAt,
              value: '${Formatters.date(location.capturedAt!)} · ${Formatters.time(location.capturedAt!)}',
            ),
          if (location.hasAddress) InfoRow(label: l.reviewAddressLabel, value: location.address!, selectable: true),
          const SizedBox(height: AppSpace.x2),
          AppButton(
            label: l.hospitalDirections,
            icon: PhosphorIconsLight.navigationArrow,
            variant: AppButtonVariant.secondary,
            onPressed: () =>
                openDirections(latitude: location.latitude, longitude: location.longitude, address: location.address),
          ),
        ],
      ),
    );
  }
}
