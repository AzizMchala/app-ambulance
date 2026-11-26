import 'package:dio/dio.dart';

import '../../../../core/network/api_guard.dart';
import '../../../../shared/models/page_result.dart';
import '../../domain/entities/sos_draft.dart';
import '../../domain/entities/sos_request.dart';
import '../models/sos_models.dart';

/// Appels HTTP du module E2. Seule cette classe connaît les chemins de l'API.
class SosRemoteDataSource {
  const SosRemoteDataSource(this._dio);

  final Dio _dio;

  static const _base = '/api/sos';

  Map<String, Object?> _map(Object? data) => (data! as Map).cast<String, Object?>();

  Future<SosRequest> create(SosDraft draft) => guardApi(() async {
    final r = await _dio.post<Object?>(_base, data: SosJson.create(draft));
    return SosJson.request(_map(r.data));
  });

  Future<PageResult<SosRequest>> list({required int page, required int size}) => guardApi(() async {
    final r = await _dio.get<Object?>(_base, queryParameters: {'page': page, 'size': size});
    return PageResult.fromJson(_map(r.data), SosJson.request);
  });

  Future<SosRequest> getById(int id) => guardApi(() async {
    final r = await _dio.get<Object?>('$_base/$id');
    return SosJson.request(_map(r.data));
  });

  Future<SosStatusSnapshot> getStatus(int id) => guardApi(() async {
    final r = await _dio.get<Object?>('$_base/$id/status');
    return SosJson.status(_map(r.data));
  });

  Future<List<SosHistoryEntry>> getHistory(int id) => guardApi(() async {
    final r = await _dio.get<Object?>('$_base/$id/history');
    final list = r.data! as List<Object?>;
    return [for (final e in list) SosJson.history((e! as Map).cast<String, Object?>())];
  });

  Future<SosRequest> cancel(int id) => guardApi(() async {
    final r = await _dio.post<Object?>('$_base/$id/cancel');
    return SosJson.request(_map(r.data));
  });
}
