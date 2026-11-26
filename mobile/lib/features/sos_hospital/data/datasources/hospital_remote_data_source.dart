import 'package:dio/dio.dart';

import '../../../../core/network/api_guard.dart';
import '../../../../shared/models/page_result.dart';
import '../../../sos/data/models/sos_models.dart';
import '../../../sos/domain/entities/sos_request.dart';
import '../../../sos/domain/entities/sos_status.dart';
import '../../domain/entities/hospital_sos.dart';

/// Appels HTTP de l'espace hôpital (`/api/responder/sos`).
class HospitalRemoteDataSource {
  const HospitalRemoteDataSource(this._dio);

  final Dio _dio;

  static const _base = '/api/responder/sos';

  static Map<String, Object?> _map(Object? data) => (data! as Map).cast<String, Object?>();

  static HospitalSosItem _item(Map<String, Object?> json) => HospitalSosItem(
    request: SosJson.request(_map(json['request'])),
    patientId: (json['patientId']! as num).toInt(),
    patientName: json['patientName']! as String,
  );

  Future<PageResult<HospitalSosItem>> list({required Set<SosStatus> statuses, required int page, required int size}) =>
      guardApi(() async {
        final r = await _dio.get<Object?>(
          _base,
          queryParameters: {
            'status': [for (final s in statuses) s.apiValue],
            'page': page,
            'size': size,
          },
          // `status=PENDING&status=ACCEPTED` : format attendu par Spring pour une liste.
          options: Options(listFormat: ListFormat.multi),
        );
        return PageResult.fromJson(_map(r.data), _item);
      });

  Future<HospitalSosItem> getById(int id) => guardApi(() async {
    final r = await _dio.get<Object?>('$_base/$id');
    return _item(_map(r.data));
  });

  Future<List<SosHistoryEntry>> getHistory(int id) => guardApi(() async {
    final r = await _dio.get<Object?>('$_base/$id/history');
    return [for (final e in r.data! as List<Object?>) SosJson.history(_map(e))];
  });

  Future<HospitalSosItem> updateStatus(int id, {required SosStatus status, String? message}) => guardApi(() async {
    final r = await _dio.patch<Object?>('$_base/$id/status', data: {'status': status.apiValue, 'message': ?message});
    return _item(_map(r.data));
  });
}
