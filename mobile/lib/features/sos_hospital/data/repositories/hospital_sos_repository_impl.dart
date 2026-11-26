import '../../../../shared/models/page_result.dart';
import '../../../sos/domain/entities/sos_request.dart';
import '../../../sos/domain/entities/sos_status.dart';
import '../../domain/entities/hospital_sos.dart';
import '../../domain/repositories/hospital_sos_repository.dart';
import '../datasources/hospital_remote_data_source.dart';

/// Implémentation connectée : toutes les données et décisions passent par l'API.
class HospitalSosRepositoryImpl implements HospitalSosRepository {
  const HospitalSosRepositoryImpl(this._remote);

  final HospitalRemoteDataSource _remote;

  @override
  Future<PageResult<HospitalSosItem>> list({required Set<SosStatus> statuses, required int page, required int size}) =>
      _remote.list(statuses: statuses, page: page, size: size);

  @override
  Future<HospitalSosItem> getById(int id) => _remote.getById(id);

  @override
  Future<List<SosHistoryEntry>> getHistory(int id) => _remote.getHistory(id);

  @override
  Future<HospitalSosItem> updateStatus(int id, {required SosStatus status, String? message}) =>
      _remote.updateStatus(id, status: status, message: message);
}
