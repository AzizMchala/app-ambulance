import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/failure_messages.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/sos_location.dart';
import '../../domain/entities/sos_request.dart';
import '../../domain/entities/sos_status.dart';
import '../controllers/sos_detail_controller.dart';
import '../widgets/location_map.dart';
import '../widgets/sos_status_style.dart';
import '../widgets/status_timeline.dart';

/// Suivi d'une demande : statut réel, décision, localisation envoyée et frise des changements.
class SosDetailScreen extends ConsumerWidget {
  const SosDetailScreen({super.key, required this.id, this.justSent = false});

  final int id;

  /// Arrivée depuis l'envoi : le serveur vient de confirmer l'enregistrement.
  final bool justSent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final provider = sosDetailControllerProvider(id);
    final detail = ref.watch(provider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.requestNumber(id)),
        actions: [
          if (detail.hasValue)
            IconButton(
              tooltip: l.commonRetry,
              icon: const Icon(PhosphorIconsLight.arrowClockwise),
              onPressed: () => ref.read(provider.notifier).refreshStatus(force: true),
            ),
        ],
      ),
      body: switch (detail) {
        AsyncData(:final value) => RefreshIndicator(
          onRefresh: () => ref.read(provider.notifier).refreshStatus(force: true),
          child: _DetailBody(state: value, justSent: justSent, id: id),
        ),
        AsyncError(:final error) => ErrorView(
          message: failureMessage(l, error is AppFailure ? error : UnexpectedFailure(error)),
          onRetry: () => ref.invalidate(provider),
        ),
        _ => const LoadingView(),
      },
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.state, required this.justSent, required this.id});

  final SosDetailState state;
  final bool justSent;
  final int id;

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final ok = await AppFeedback.confirm(
      context,
      title: l.detailCancelTitle,
      body: l.detailCancelBody,
      confirmLabel: l.detailCancelConfirm,
      cancelLabel: l.detailKeep,
      danger: true,
    );
    if (!ok || !context.mounted) return;
    final failure = await ref.read(sosDetailControllerProvider(id).notifier).cancel();
    if (!context.mounted) return;
    AppFeedback.toast(
      context,
      failure == null ? l.detailCancelled : failureMessage(l, failure),
      error: failure != null,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final r = state.request;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSpace.x10),
      children: [
        ContentFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (justSent) ...[
                InlineNotice(tone: NoticeTone.success, message: l.sentBanner),
                const SizedBox(height: AppSpace.x4),
              ],
              if (state.refreshFailed) ...[
                InlineNotice(tone: NoticeTone.warning, message: l.detailRefreshFailed),
                const SizedBox(height: AppSpace.x4),
              ],
              _StatusHero(request: r, syncedAt: state.syncedAt),
              const SizedBox(height: AppSpace.x6),
              SectionLabel(l.detailDecision),
              _DecisionCard(request: r),
              const SizedBox(height: AppSpace.x6),
              SectionLabel(l.detailLocation),
              _LocationCard(location: r.location),
              const SizedBox(height: AppSpace.x6),
              SectionLabel(l.detailTimeline),
              AppCard(child: StatusTimeline(entries: state.history)),
              const SizedBox(height: AppSpace.x6),
              SectionLabel(l.detailInfo),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: AppSpace.x5, vertical: AppSpace.x3),
                child: Column(
                  children: [
                    InfoRow(label: l.detailId, value: '#${r.id}', selectable: true),
                    InfoRow(label: l.detailDate, value: Formatters.dateLong(r.createdAt)),
                    InfoRow(label: l.detailTime, value: Formatters.time(r.createdAt)),
                    InfoRow(
                      label: l.detailUpdated,
                      value: '${Formatters.date(r.updatedAt)} · ${Formatters.time(r.updatedAt)}',
                    ),
                  ],
                ),
              ),
              if (r.status.isCancellableByPatient) ...[
                const SizedBox(height: AppSpace.x8),
                AppButton(
                  label: l.detailCancel,
                  variant: AppButtonVariant.secondary,
                  icon: PhosphorIconsLight.prohibit,
                  loading: state.isCancelling,
                  onPressed: () => _cancel(context, ref),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusHero extends StatelessWidget {
  const _StatusHero({required this.request, required this.syncedAt});

  final SosRequest request;
  final DateTime syncedAt;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final tone = statusToneColors(context, request.status.tone);

    return AppCard(
      padding: const EdgeInsets.all(AppSpace.x6),
      child: Semantics(
        liveRegion: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconBadge(
                  icon: request.status.icon,
                  background: tone.background,
                  foreground: tone.foreground,
                  size: 52,
                ),
                const Spacer(),
                StatusPill(label: request.status.label(l), tone: request.status.tone, large: true),
              ],
            ),
            const SizedBox(height: AppSpace.x5),
            Text(request.status.headline(l), style: context.text.headlineMedium),
            const SizedBox(height: AppSpace.x2),
            // Wrap : sur un écran étroit, la date passe à la ligne au lieu de déborder.
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpace.x2,
              runSpacing: AppSpace.x1,
              children: [
                if (request.status.isActive)
                  Text.rich(
                    TextSpan(
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.only(right: AppSpace.x2),
                            child: _LiveDot(color: c.success),
                          ),
                        ),
                        TextSpan(text: l.detailAutoRefresh),
                      ],
                    ),
                    style: context.text.bodySmall,
                  ),
                Text(l.detailUpdatedAt(Formatters.relative(l, request.updatedAt)), style: context.text.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DecisionCard extends StatelessWidget {
  const _DecisionCard({required this.request});

  final SosRequest request;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final decided = request.status != SosStatus.pending && request.status != SosStatus.unknown;
    final message = request.decisionMessage;

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            message != null || decided ? PhosphorIconsLight.chatCircleText : PhosphorIconsLight.hourglassMedium,
            color: c.inkSoft,
            size: 24,
          ),
          const SizedBox(width: AppSpace.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message != null) ...[
                  Text(l.detailDecisionMessage, style: context.text.labelSmall),
                  const SizedBox(height: AppSpace.x2),
                  Text(message, style: context.text.bodyLarge),
                ] else
                  Text(decided ? l.detailNoDecisionMessage : l.detailNoDecision, style: context.text.bodyMedium),
              ],
            ),
          ),
        ],
      ),
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
              stale: source == LocationSource.lastKnown,
              height: 180,
              interactive: true,
            ),
            const SizedBox(height: AppSpace.x3),
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
          if (location.hasAddress) InfoRow(label: l.reviewAddressLabel, value: location.address!),
        ],
      ),
    );
  }
}

class _LiveDot extends StatefulWidget {
  const _LiveDot({required this.color});

  final Color color;

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.value = 1;
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: Tween<double>(begin: 0.35, end: 1).animate(_c),
    child: Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
    ),
  );
}
