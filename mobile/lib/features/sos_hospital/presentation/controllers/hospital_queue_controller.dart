import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../domain/entities/hospital_sos.dart';
import '../../domain/usecases/hospital_usecases.dart';
import '../providers/hospital_providers.dart';

@immutable
class HospitalQueueState {
  const HospitalQueueState({
    required this.items,
    required this.total,
    required this.hasMore,
    this.isLoadingMore = false,
    this.loadMoreFailure,
    this.refreshFailed = false,
  });

  final List<HospitalSosItem> items;

  /// Nombre total de demandes dans cette file selon le serveur.
  final int total;
  final bool hasMore;
  final bool isLoadingMore;
  final AppFailure? loadMoreFailure;

  /// La dernière actualisation automatique a échoué : la liste affichée peut être ancienne.
  final bool refreshFailed;

  HospitalQueueState copyWith({bool? isLoadingMore, AppFailure? loadMoreFailure, bool clearFailure = false}) =>
      HospitalQueueState(
        items: items,
        total: total,
        hasMore: hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        loadMoreFailure: clearFailure ? null : (loadMoreFailure ?? this.loadMoreFailure),
        refreshFailed: refreshFailed,
      );
}

/// Une file de l'espace hôpital, relue toutes les [pollInterval] tant que l'application est au premier plan.
/// Les nouvelles alertes apparaissent donc sans action de l'équipe.
class HospitalQueueController extends AsyncNotifier<HospitalQueueState> {
  HospitalQueueController(this.queue);

  final HospitalQueue queue;
  Timer? _timer;

  static const pollInterval = Duration(seconds: 15);

  @override
  Future<HospitalQueueState> build() async {
    ref.onDispose(() => _timer?.cancel());
    final first = await _fetch(GetHospitalQueue.pageSize);
    _timer = Timer.periodic(pollInterval, (_) {
      final lifecycle = WidgetsBinding.instance.lifecycleState;
      if (lifecycle == null || lifecycle == AppLifecycleState.resumed) refresh();
    });
    return first;
  }

  /// Relit d'un coup tout ce qui est déjà affiché (jusqu'à la taille maximale d'une page).
  Future<HospitalQueueState> _fetch(int size) async {
    final page = await ref.read(getHospitalQueueProvider)(queue, size: size);
    return HospitalQueueState(items: page.items, total: page.totalElements, hasMore: page.hasNext);
  }

  /// Actualisation (minuteur ou geste). Garde la liste affichée si elle échoue et renvoie l'erreur.
  Future<AppFailure?> refresh() async {
    final current = state.value;
    final size = max(GetHospitalQueue.pageSize, min(current?.items.length ?? 0, GetHospitalQueue.maxPageSize));
    try {
      final fresh = await _fetch(size);
      if (ref.mounted) state = AsyncData(fresh);
      return null;
    } on AppFailure catch (failure) {
      if (!ref.mounted) return failure;
      if (current == null) {
        state = AsyncError(failure, StackTrace.current);
      } else {
        state = AsyncData(
          HospitalQueueState(items: current.items, total: current.total, hasMore: current.hasMore, refreshFailed: true),
        );
      }
      return failure;
    }
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true, clearFailure: true));
    try {
      // Page suivante calculée sur ce qui est affiché : la file bouge, on écarte les doublons.
      final nextPage = current.items.length ~/ GetHospitalQueue.pageSize;
      final page = await ref.read(getHospitalQueueProvider)(queue, page: nextPage);
      if (!ref.mounted) return;
      final known = {for (final i in current.items) i.request.id};
      state = AsyncData(
        HospitalQueueState(
          items: [...current.items, ...page.items.where((i) => !known.contains(i.request.id))],
          total: page.totalElements,
          hasMore: page.hasNext,
        ),
      );
    } on AppFailure catch (failure) {
      if (ref.mounted) state = AsyncData(current.copyWith(isLoadingMore: false, loadMoreFailure: failure));
    }
  }
}

final hospitalQueueControllerProvider = AsyncNotifierProvider.autoDispose
    .family<HospitalQueueController, HospitalQueueState, HospitalQueue>(HospitalQueueController.new);
