import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/failure_messages.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/sos_request.dart';
import '../controllers/sos_history_controller.dart';
import '../sos_paths.dart';
import '../widgets/sos_request_tile.dart';

/// Historique paginé des demandes du patient connecté, regroupé par mois.
class SosHistoryScreen extends ConsumerStatefulWidget {
  const SosHistoryScreen({super.key});

  @override
  ConsumerState<SosHistoryScreen> createState() => _SosHistoryScreenState();
}

class _SosHistoryScreenState extends ConsumerState<SosHistoryScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 400) ref.read(sosHistoryControllerProvider.notifier).loadMore();
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final failure = await ref.read(sosHistoryControllerProvider.notifier).refresh();
    if (failure != null && mounted) {
      AppFeedback.toast(context, failureMessage(AppLocalizations.of(context), failure), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final history = ref.watch(sosHistoryControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.historyTitle)),
      body: switch (history) {
        AsyncData(:final value) when value.items.isEmpty => RefreshIndicator(
          onRefresh: _refresh,
          child: LayoutBuilder(
            builder: (context, box) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: box.maxHeight,
                child: MessageView(
                  icon: PhosphorIconsLight.clockCounterClockwise,
                  title: l.historyEmptyTitle,
                  body: l.historyEmptyBody,
                ),
              ),
            ),
          ),
        ),
        AsyncData(:final value) => RefreshIndicator(
          onRefresh: _refresh,
          child: _HistoryList(state: value, controller: _scroll),
        ),
        AsyncError(:final error) => ErrorView(
          message: failureMessage(l, error is AppFailure ? error : UnexpectedFailure(error)),
          onRetry: () => ref.invalidate(sosHistoryControllerProvider),
        ),
        _ => const LoadingView(),
      },
    );
  }
}

class _HistoryList extends ConsumerWidget {
  const _HistoryList({required this.state, required this.controller});

  final SosHistoryState state;
  final ScrollController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final rows = <Object>[];
    String? month;
    for (final r in state.items) {
      final m = Formatters.monthYear(r.createdAt);
      if (m != month) {
        rows.add(m);
        month = m;
      }
      rows.add(r);
    }

    return ListView.builder(
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: AppSpace.x2, bottom: AppSpace.x10),
      itemCount: rows.length + 1,
      itemBuilder: (context, i) {
        if (i == rows.length) return _Footer(state: state);
        final row = rows[i];
        return ContentFrame(
          child: row is SosRequest
              ? Padding(
                  padding: const EdgeInsets.only(bottom: AppSpace.x3),
                  child: SosRequestTile(request: row, onTap: () => context.push(SosPaths.detail(row.id))),
                )
              : Padding(
                  padding: EdgeInsets.only(top: i == 0 ? AppSpace.x2 : AppSpace.x5),
                  child: SectionLabel(row as String),
                ),
        );
      },
      semanticChildCount: state.items.length,
      key: PageStorageKey(l.historyTitle),
    );
  }
}

class _Footer extends ConsumerWidget {
  const _Footer({required this.state});

  final SosHistoryState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    if (state.isLoadingMore) {
      return const Padding(padding: EdgeInsets.all(AppSpace.x6), child: LoadingView());
    }
    if (state.loadMoreFailure != null) {
      return ContentFrame(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpace.x4),
          child: InlineNotice(
            tone: NoticeTone.danger,
            message: '${l.historyLoadMoreError} ${failureMessage(l, state.loadMoreFailure!)}',
            action: AppButton(
              label: l.commonRetry,
              compact: true,
              expand: false,
              variant: AppButtonVariant.secondary,
              onPressed: () => ref.read(sosHistoryControllerProvider.notifier).loadMore(),
            ),
          ),
        ),
      );
    }
    if (!state.hasMore) {
      return Padding(
        padding: const EdgeInsets.all(AppSpace.x4),
        child: Center(child: Icon(PhosphorIconsLight.dotsThree, color: context.colors.inkMuted)),
      );
    }
    return const SizedBox(height: AppSpace.x10);
  }
}
