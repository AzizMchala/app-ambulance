import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../sos/domain/entities/sos_request.dart';
import '../../domain/entities/hospital_sos.dart';
import '../providers/hospital_providers.dart';
import 'hospital_queue_controller.dart';

@immutable
class HospitalDetailState {
  const HospitalDetailState({required this.item, required this.history, this.deciding, this.refreshFailed = false});

  final HospitalSosItem item;
  final List<SosHistoryEntry> history;

  /// Décision en cours d'envoi (bouton en chargement), sinon `null`.
  final HospitalDecision? deciding;
  final bool refreshFailed;

  HospitalDetailState copyWith({HospitalDecision? deciding, bool clearDeciding = false, bool? refreshFailed}) =>
      HospitalDetailState(
        item: item,
        history: history,
        deciding: clearDeciding ? null : (deciding ?? this.deciding),
        refreshFailed: refreshFailed ?? this.refreshFailed,
      );
}

/// Détail d'une demande côté hôpital. Relu toutes les 15 s tant qu'elle est active :
/// si le patient annule ou si un collègue décide, l'écran le montre.
class HospitalDetailController extends AsyncNotifier<HospitalDetailState> {
  HospitalDetailController(this.id);

  final int id;
  Timer? _timer;

  static const pollInterval = Duration(seconds: 15);

  @override
  Future<HospitalDetailState> build() async {
    ref.onDispose(() => _timer?.cancel());
    final loaded = await _load();
    _schedule(loaded);
    return loaded;
  }

  Future<HospitalDetailState> _load() async {
    final (item, history) = await ref.read(getHospitalSosDetailProvider)(id);
    return HospitalDetailState(item: item, history: history);
  }

  void _schedule(HospitalDetailState s) {
    _timer?.cancel();
    if (!s.item.request.status.isActive) return;
    _timer = Timer.periodic(pollInterval, (_) {
      final lifecycle = WidgetsBinding.instance.lifecycleState;
      if (lifecycle == null || lifecycle == AppLifecycleState.resumed) reload();
    });
  }

  Future<void> reload() async {
    final current = state.value;
    if (current?.deciding != null) return;
    try {
      final fresh = await _load();
      if (!ref.mounted) return;
      state = AsyncData(fresh);
      _schedule(fresh);
    } on AppFailure {
      if (ref.mounted && current != null) state = AsyncData(current.copyWith(refreshFailed: true));
    }
  }

  /// Envoie la décision. Renvoie `null` si le serveur l'a enregistrée, sinon l'échec à afficher.
  /// Après un conflit (demande annulée ou déjà traitée), la demande est rechargée.
  Future<AppFailure?> decide(HospitalDecision decision, String message) async {
    final current = state.value;
    if (current == null || current.deciding != null) return null;
    state = AsyncData(current.copyWith(deciding: decision));
    try {
      await ref.read(decideSosProvider)(id, decision, message);
      final fresh = await _load();
      if (!ref.mounted) return null;
      state = AsyncData(fresh);
      _schedule(fresh);
      for (final queue in HospitalQueue.values) {
        ref.invalidate(hospitalQueueControllerProvider(queue));
      }
      return null;
    } on AppFailure catch (failure) {
      if (!ref.mounted) return failure;
      state = AsyncData(current.copyWith(clearDeciding: true));
      if (failure is ApiFailure && failure.status == 409) await reload();
      return failure;
    }
  }
}

final hospitalDetailControllerProvider = AsyncNotifierProvider.autoDispose
    .family<HospitalDetailController, HospitalDetailState, int>(HospitalDetailController.new);
