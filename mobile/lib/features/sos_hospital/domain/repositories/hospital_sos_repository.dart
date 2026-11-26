import '../../../../shared/models/page_result.dart';
import '../../../sos/domain/entities/sos_request.dart';
import '../../../sos/domain/entities/sos_status.dart';
import '../entities/hospital_sos.dart';

/// Accès de l'hôpital (rôle RESPONDER) aux demandes SOS. Lève une `AppFailure` en cas d'échec.
abstract interface class HospitalSosRepository {
  Future<PageResult<HospitalSosItem>> list({required Set<SosStatus> statuses, required int page, required int size});

  Future<HospitalSosItem> getById(int id);

  Future<List<SosHistoryEntry>> getHistory(int id);

  Future<HospitalSosItem> updateStatus(int id, {required SosStatus status, String? message});
}
