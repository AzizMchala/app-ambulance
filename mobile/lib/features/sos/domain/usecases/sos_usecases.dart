import '../../../../shared/models/page_result.dart';
import '../entities/sos_draft.dart';
import '../entities/sos_request.dart';
import '../repositories/sos_repository.dart';

/// Cas d'utilisation fins autour du [SosRepository]. Ils gardent les contrôleurs indépendants
/// de la couche data et rendent chaque action testable seule.

class SendSos {
  const SendSos(this._repository);

  final SosRepository _repository;

  Future<SosRequest> call(SosDraft draft) => _repository.create(draft);
}

class GetSosPage {
  const GetSosPage(this._repository);

  final SosRepository _repository;

  static const defaultPageSize = 20;

  Future<PageResult<SosRequest>> call({required int page, int size = defaultPageSize}) =>
      _repository.list(page: page, size: size);
}

class GetLatestSos {
  const GetLatestSos(this._repository);

  final SosRepository _repository;

  /// La plus récente demande du patient, ou `null` s'il n'en a jamais envoyé.
  Future<SosRequest?> call() async {
    final page = await _repository.list(page: 0, size: 1);
    return page.items.isEmpty ? null : page.items.first;
  }
}

class GetSosDetail {
  const GetSosDetail(this._repository);

  final SosRepository _repository;

  Future<SosRequest> call(int id) => _repository.getById(id);
}

class GetSosStatus {
  const GetSosStatus(this._repository);

  final SosRepository _repository;

  Future<SosStatusSnapshot> call(int id) => _repository.getStatus(id);
}

class GetSosStatusHistory {
  const GetSosStatusHistory(this._repository);

  final SosRepository _repository;

  /// Changements de statut, du plus ancien au plus récent.
  Future<List<SosHistoryEntry>> call(int id) async {
    final entries = await _repository.getHistory(id);
    return [...entries]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }
}

class CancelSos {
  const CancelSos(this._repository);

  final SosRepository _repository;

  Future<SosRequest> call(int id) => _repository.cancel(id);
}
