import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../domain/entities/sos_request.dart';
import '../providers/sos_providers.dart';

@immutable
class SosHistoryState {
  const SosHistoryState({
    required this.items,
    required this.nextPage,
    required this.hasMore,
    this.isLoadingMore = false,
    this.loadMoreFailure,
  });

  final List<SosRequest> items;
  final int nextPage;
  final bool hasMore;
  final bool isLoadingMore;
  final AppFailure? loadMoreFailure;

  SosHistoryState copyWith({
    List<SosRequest>? items,
    int? nextPage,
    bool? hasMore,
    bool? isLoadingMore,
    AppFailure? loadMoreFailure,
    bool clearFailure = false,
  }) => SosHistoryState(
    items: items ?? this.items,
    nextPage: nextPage ?? this.nextPage,
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    loadMoreFailure: clearFailure ? null : (loadMoreFailure ?? this.loadMoreFailure),
  );
}

/// Historique paginé, toujours lu depuis l'API.
class SosHistoryController extends AsyncNotifier<SosHistoryState> {
  @override
  Future<SosHistoryState> build() => _firstPage();

  Future<SosHistoryState> _firstPage() async {
    final page = await ref.read(getSosPageProvider)(page: 0);
    return SosHistoryState(items: page.items, nextPage: 1, hasMore: page.hasNext);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true, clearFailure: true));
    try {
      final page = await ref.read(getSosPageProvider)(page: current.nextPage);
      if (!ref.mounted) return;
      // Une demande créée entre deux pages décale la liste : on écarte les doublons.
      final known = {for (final r in current.items) r.id};
      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...page.items.where((r) => !known.contains(r.id))],
          nextPage: current.nextPage + 1,
          hasMore: page.hasNext,
          isLoadingMore: false,
        ),
      );
    } on AppFailure catch (failure) {
      if (ref.mounted) state = AsyncData(current.copyWith(isLoadingMore: false, loadMoreFailure: failure));
    }
  }

  /// Tirer pour actualiser : garde la liste affichée si l'actualisation échoue et renvoie l'erreur.
  Future<AppFailure?> refresh() async {
    try {
      final fresh = await _firstPage();
      if (ref.mounted) state = AsyncData(fresh);
      return null;
    } on AppFailure catch (failure) {
      if (ref.mounted && state.value == null) state = AsyncError(failure, StackTrace.current);
      return failure;
    }
  }
}

final sosHistoryControllerProvider = AsyncNotifierProvider.autoDispose<SosHistoryController, SosHistoryState>(
  SosHistoryController.new,
);
