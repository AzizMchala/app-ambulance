import '../../../../shared/models/page_result.dart';
import '../../domain/entities/sos_draft.dart';
import '../../domain/entities/sos_request.dart';
import '../../domain/repositories/sos_repository.dart';
import '../datasources/sos_remote_data_source.dart';

/// Implémentation connectée : chaque donnée vient de l'API, aucune copie locale n'est inventée.
///
/// Point d'extension prévu : un cache local en lecture (historique hors ligne) se brancherait ici
/// sans toucher aux écrans ni aux cas d'utilisation.
class SosRepositoryImpl implements SosRepository {
  const SosRepositoryImpl(this._remote);

  final SosRemoteDataSource _remote;

  @override
  Future<SosRequest> create(SosDraft draft) => _remote.create(draft);

  @override
  Future<PageResult<SosRequest>> list({required int page, required int size}) => _remote.list(page: page, size: size);

  @override
  Future<SosRequest> getById(int id) => _remote.getById(id);

  @override
  Future<SosStatusSnapshot> getStatus(int id) => _remote.getStatus(id);

  @override
  Future<List<SosHistoryEntry>> getHistory(int id) => _remote.getHistory(id);

  @override
  Future<SosRequest> cancel(int id) => _remote.cancel(id);
}
