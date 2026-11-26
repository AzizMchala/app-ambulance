import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/utils/request_id.dart';
import '../../domain/entities/sos_draft.dart';
import '../../domain/entities/sos_request.dart';
import '../providers/sos_providers.dart';
import 'sos_history_controller.dart';

sealed class SosSubmissionState {
  const SosSubmissionState();
}

class SubmissionIdle extends SosSubmissionState {
  const SubmissionIdle();
}

class SubmissionSending extends SosSubmissionState {
  const SubmissionSending();
}

/// Le serveur a confirmé l'enregistrement : c'est le seul état qui affiche « envoyée ».
class SubmissionSucceeded extends SosSubmissionState {
  const SubmissionSucceeded(this.request);

  final SosRequest request;
}

class SubmissionFailed extends SosSubmissionState {
  const SubmissionFailed(this.failure);

  final AppFailure failure;
}

/// Envoi d'une alerte. La même clé d'idempotence sert à toutes les tentatives de cet écran :
/// un nouvel essai après une coupure ne crée jamais une deuxième demande.
class SosSubmissionController extends Notifier<SosSubmissionState> {
  late final String clientRequestId = newRequestId();

  @override
  SosSubmissionState build() => const SubmissionIdle();

  Future<void> submit(SosDraft draft) async {
    if (state is SubmissionSending) return;
    state = const SubmissionSending();
    try {
      final created = await ref.read(sendSosProvider)(draft);
      if (!ref.mounted) return;
      ref.invalidate(latestSosProvider);
      ref.invalidate(sosHistoryControllerProvider);
      state = SubmissionSucceeded(created);
    } on AppFailure catch (failure) {
      if (ref.mounted) state = SubmissionFailed(failure);
    } catch (e) {
      if (ref.mounted) state = SubmissionFailed(UnexpectedFailure(e));
    }
  }
}

final sosSubmissionControllerProvider = NotifierProvider.autoDispose<SosSubmissionController, SosSubmissionState>(
  SosSubmissionController.new,
);
