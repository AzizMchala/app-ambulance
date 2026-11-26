import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../domain/entities/sos_request.dart';
import '../providers/sos_providers.dart';
import 'sos_history_controller.dart';

@immutable
class SosDetailState {
  const SosDetailState({
    required this.request,
    required this.history,
    required this.syncedAt,
    this.refreshFailed = false,
    this.isCancelling = false,
  });

  final SosRequest request;
  final List<SosHistoryEntry> history;

  /// Dernière synchronisation réussie avec le serveur.
  final DateTime syncedAt;

  /// La dernière actualisation a échoué : les données peuvent être anciennes, on le dit.
  final bool refreshFailed;
  final bool isCancelling;

  SosDetailState copyWith({
    SosRequest? request,
    List<SosHistoryEntry>? history,
    DateTime? syncedAt,
    bool? refreshFailed,
    bool? isCancelling,
  }) => SosDetailState(
    request: request ?? this.request,
    history: history ?? this.history,
    syncedAt: syncedAt ?? this.syncedAt,
    refreshFailed: refreshFailed ?? this.refreshFailed,
    isCancelling: isCancelling ?? this.isCancelling,
  );
}

/// Détail et suivi d'une demande. Tant qu'elle est active, le statut est relu toutes les
/// [pollInterval] via l'endpoint léger `/status` ; le détail complet n'est rechargé que s'il a changé.
///
/// Point d'évolution : des notifications push (FCM) ou un WebSocket remplaceraient le minuteur
/// sans changer l'écran.
class SosDetailController extends AsyncNotifier<SosDetailState> {
  SosDetailController(this.id);

  final int id;
  Timer? _timer;

  static const pollInterval = Duration(seconds: 15);

  @override
  Future<SosDetailState> build() async {
    ref.onDispose(() => _timer?.cancel());
    final loaded = await _load();
    _schedulePolling(loaded.request);
    return loaded;
  }

  Future<SosDetailState> _load() async {
    final results = await Future.wait<Object>([
      ref.read(getSosDetailProvider)(id),
      ref.read(getSosStatusHistoryProvider)(id),
    ]);
    return SosDetailState(
      request: results[0] as SosRequest,
      history: results[1] as List<SosHistoryEntry>,
      syncedAt: DateTime.now(),
    );
  }

  void _schedulePolling(SosRequest request) {
    _timer?.cancel();
    if (!request.status.isActive) return;
    _timer = Timer.periodic(pollInterval, (_) {
      // Pas d'appel réseau quand l'application est en arrière-plan.
      final lifecycle = WidgetsBinding.instance.lifecycleState;
      if (lifecycle == null || lifecycle == AppLifecycleState.resumed) refreshStatus();
    });
  }

  /// Relit le statut ; recharge détail et suivi seulement si le serveur signale un changement.
  Future<void> refreshStatus({bool force = false}) async {
    final current = state.value;
    if (current == null) return;
    try {
      final snapshot = await ref.read(getSosStatusProvider)(id);
      final changed =
          snapshot.status != current.request.status || !snapshot.updatedAt.isAtSameMomentAs(current.request.updatedAt);
      final next = changed || force ? await _load() : current.copyWith(syncedAt: DateTime.now(), refreshFailed: false);
      if (!ref.mounted) return;
      state = AsyncData(next);
      if (changed) {
        _schedulePolling(next.request);
        ref.invalidate(latestSosProvider);
      }
    } on AppFailure {
      final latest = state.value;
      if (ref.mounted && latest != null) state = AsyncData(latest.copyWith(refreshFailed: true));
    }
  }

  /// Annulation par le patient. Renvoie l'échec pour que l'écran l'affiche, `null` si réussie.
  Future<AppFailure?> cancel() async {
    final current = state.value;
    if (current == null || current.isCancelling) return null;
    state = AsyncData(current.copyWith(isCancelling: true));
    try {
      await ref.read(cancelSosProvider)(id);
      final reloaded = await _load();
      if (!ref.mounted) return null;
      state = AsyncData(reloaded);
      _schedulePolling(reloaded.request);
      ref.invalidate(latestSosProvider);
      ref.invalidate(sosHistoryControllerProvider);
      return null;
    } on AppFailure catch (failure) {
      final latest = state.value ?? current;
      if (ref.mounted) state = AsyncData(latest.copyWith(isCancelling: false));
      return failure;
    }
  }
}

final sosDetailControllerProvider = AsyncNotifierProvider.autoDispose.family<SosDetailController, SosDetailState, int>(
  SosDetailController.new,
);
