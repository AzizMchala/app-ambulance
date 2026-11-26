import '../../../../core/errors/app_failure.dart';
import '../../../../shared/models/page_result.dart';
import '../../../sos/domain/entities/sos_request.dart';
import '../entities/hospital_sos.dart';
import '../repositories/hospital_sos_repository.dart';

class GetHospitalQueue {
  const GetHospitalQueue(this._repository);

  final HospitalSosRepository _repository;

  static const pageSize = 20;

  /// Au-delà, l'API refuse la taille de page.
  static const maxPageSize = 50;

  Future<PageResult<HospitalSosItem>> call(HospitalQueue queue, {int page = 0, int size = pageSize}) =>
      _repository.list(statuses: queue.statuses, page: page, size: size);
}

class GetHospitalSosDetail {
  const GetHospitalSosDetail(this._repository);

  final HospitalSosRepository _repository;

  Future<(HospitalSosItem, List<SosHistoryEntry>)> call(int id) async {
    final results = await Future.wait<Object>([_repository.getById(id), _repository.getHistory(id)]);
    final history = [...results[1] as List<SosHistoryEntry>]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return (results[0] as HospitalSosItem, history);
  }
}

/// Enregistre une décision. Un refus sans message est bloqué avant l'appel réseau
/// (le serveur applique la même règle).
class DecideSos {
  const DecideSos(this._repository);

  final HospitalSosRepository _repository;

  Future<HospitalSosItem> call(int id, HospitalDecision decision, String message) {
    final trimmed = message.trim();
    if (decision.requiresMessage && trimmed.isEmpty) {
      throw const ValidationFailure({'message': 'RequiredForRejection'});
    }
    return _repository.updateStatus(id, status: decision.target, message: trimmed.isEmpty ? null : trimmed);
  }
}
