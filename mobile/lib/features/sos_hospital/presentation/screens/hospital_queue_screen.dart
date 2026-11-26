import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/failure_messages.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../auth/presentation/account_menu.dart';
import '../../../auth/presentation/session_controller.dart';
import '../../domain/entities/hospital_sos.dart';
import '../controllers/hospital_queue_controller.dart';
import '../hospital_paths.dart';
import '../widgets/hospital_request_card.dart';

/// Écran principal de l'espace hôpital : trois files (à traiter, en cours, clôturées).
class HospitalQueueScreen extends ConsumerStatefulWidget {
  const HospitalQueueScreen({super.key});

  @override
  ConsumerState<HospitalQueueScreen> createState() => _HospitalQueueScreenState();
}

class _HospitalQueueScreenState extends ConsumerState<HospitalQueueScreen> {
  HospitalQueue _queue = HospitalQueue.toHandle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final user = ref.watch(sessionControllerProvider).value;
    // La file « à traiter » est toujours écoutée : son compteur reste juste quel que soit l'onglet.
    final toHandle = ref.watch(hospitalQueueControllerProvider(HospitalQueue.toHandle));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpace.x4),
                  Row(
                    children: [
                      Expanded(child: Text(l.roleHospital.toUpperCase(), style: context.text.labelSmall)),
                      const AccountMenuButton(),
                    ],
                  ),
                  if (user != null) Text(l.hospitalGreeting(user.fullName), style: context.text.bodyMedium),
                  const SizedBox(height: AppSpace.x2),
                  Text(l.hospitalTitle, style: context.text.headlineLarge),
                  const SizedBox(height: AppSpace.x1),
                  Text(l.hospitalSubtitle, style: context.text.bodySmall),
                  const SizedBox(height: AppSpace.x5),
                  _QueueTabs(
                    selected: _queue,
                    pendingCount: toHandle.value?.total,
                    onSelected: (q) => setState(() => _queue = q),
                  ),
                  const SizedBox(height: AppSpace.x3),
                ],
              ),
            ),
            Expanded(
              child: _QueueList(key: ValueKey(_queue), queue: _queue),
            ),
          ],
        ),
      ),
    );
  }
}

class _QueueTabs extends StatelessWidget {
  const _QueueTabs({required this.selected, required this.pendingCount, required this.onSelected});

  final HospitalQueue selected;
  final int? pendingCount;
  final ValueChanged<HospitalQueue> onSelected;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    String label(HospitalQueue q) => switch (q) {
      HospitalQueue.toHandle => l.hospitalTabToHandle,
      HospitalQueue.ongoing => l.hospitalTabOngoing,
      HospitalQueue.closed => l.hospitalTabClosed,
    };

    return Container(
      padding: const EdgeInsets.all(AppSpace.x1),
      decoration: BoxDecoration(color: c.surfaceSunken, borderRadius: BorderRadius.circular(AppRadius.md)),
      child: Row(
        children: [
          for (final q in HospitalQueue.values)
            Expanded(
              child: Semantics(
                selected: q == selected,
                button: true,
                child: GestureDetector(
                  onTap: () => onSelected(q),
                  child: AnimatedContainer(
                    duration: AppMotion.fast,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: q == selected ? c.surface : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      boxShadow: q == selected ? c.shadowCard : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            label(q),
                            overflow: TextOverflow.ellipsis,
                            style: context.text.labelMedium!.copyWith(
                              fontWeight: FontWeight.w600,
                              color: q == selected ? c.ink : c.inkSoft,
                            ),
                          ),
                        ),
                        if (q == HospitalQueue.toHandle && (pendingCount ?? 0) > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                            decoration: BoxDecoration(
                              color: c.danger,
                              borderRadius: BorderRadius.circular(AppRadius.full),
                            ),
                            child: Text(
                              '$pendingCount',
                              style: context.text.labelSmall!.copyWith(color: c.onDanger, letterSpacing: 0),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _QueueList extends ConsumerStatefulWidget {
  const _QueueList({super.key, required this.queue});

  final HospitalQueue queue;

  @override
  ConsumerState<_QueueList> createState() => _QueueListState();
}

class _QueueListState extends ConsumerState<_QueueList> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 300) {
        ref.read(hospitalQueueControllerProvider(widget.queue).notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final failure = await ref.read(hospitalQueueControllerProvider(widget.queue).notifier).refresh();
    if (failure != null && mounted) {
      AppFeedback.toast(context, failureMessage(AppLocalizations.of(context), failure), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final provider = hospitalQueueControllerProvider(widget.queue);
    final state = ref.watch(provider);

    return switch (state) {
      AsyncData(:final value) => RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: AppSpace.x2, bottom: AppSpace.x10),
          children: [
            if (value.refreshFailed)
              ContentFrame(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpace.x3),
                  child: InlineNotice(tone: NoticeTone.warning, message: l.detailRefreshFailed),
                ),
              ),
            if (value.items.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpace.x10),
                child: MessageView(
                  icon: switch (widget.queue) {
                    HospitalQueue.toHandle => PhosphorIconsLight.bellSimple,
                    HospitalQueue.ongoing => PhosphorIconsLight.ambulance,
                    HospitalQueue.closed => PhosphorIconsLight.archive,
                  },
                  title: switch (widget.queue) {
                    HospitalQueue.toHandle => l.hospitalEmptyToHandle,
                    HospitalQueue.ongoing => l.hospitalEmptyOngoing,
                    HospitalQueue.closed => l.hospitalEmptyClosed,
                  },
                  body: widget.queue == HospitalQueue.closed ? null : l.hospitalEmptyBody,
                ),
              ),
            for (final item in value.items)
              ContentFrame(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpace.x3),
                  child: HospitalRequestCard(
                    item: item,
                    onTap: () => context.push(HospitalPaths.detail(item.request.id)),
                  ),
                ),
              ),
            if (value.isLoadingMore) const Padding(padding: EdgeInsets.all(AppSpace.x6), child: LoadingView()),
            if (value.loadMoreFailure != null)
              ContentFrame(
                child: InlineNotice(
                  tone: NoticeTone.danger,
                  message: '${l.historyLoadMoreError} ${failureMessage(l, value.loadMoreFailure!)}',
                  action: AppButton(
                    label: l.commonRetry,
                    compact: true,
                    expand: false,
                    variant: AppButtonVariant.secondary,
                    onPressed: () => ref.read(provider.notifier).loadMore(),
                  ),
                ),
              ),
          ],
        ),
      ),
      AsyncError(:final error) => ErrorView(
        message: failureMessage(l, error is AppFailure ? error : UnexpectedFailure(error)),
        onRetry: () => ref.invalidate(provider),
      ),
      _ => const LoadingView(),
    };
  }
}
