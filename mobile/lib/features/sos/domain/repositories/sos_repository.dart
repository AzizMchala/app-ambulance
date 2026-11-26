import '../../../../shared/models/page_result.dart';
import '../entities/sos_draft.dart';
import '../entities/sos_request.dart';

/// Contrat d'accès aux demandes SOS du patient connecté.
/// Toutes les méthodes lèvent une `AppFailure` en cas d'échec, jamais une exception brute.
abstract interface class SosRepository {
  /// Crée la demande. Ne réussit que si le serveur a confirmé l'enregistrement.
  Future<SosRequest> create(SosDraft draft);

  Future<PageResult<SosRequest>> list({required int page, required int size});

  Future<SosRequest> getById(int id);

  Future<SosStatusSnapshot> getStatus(int id);

  Future<List<SosHistoryEntry>> getHistory(int id);

  Future<SosRequest> cancel(int id);
}
