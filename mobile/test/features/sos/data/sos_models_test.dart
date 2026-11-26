import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urgences_medicales/core/errors/app_failure.dart';
import 'package:urgences_medicales/features/sos/data/models/sos_models.dart';
import 'package:urgences_medicales/features/sos/domain/entities/sos_draft.dart';
import 'package:urgences_medicales/features/sos/domain/entities/sos_location.dart';
import 'package:urgences_medicales/features/sos/domain/entities/sos_status.dart';
import 'package:urgences_medicales/shared/models/page_result.dart';

void main() {
  final json = <String, Object?>{
    'id': 42,
    'latitude': 36.80651,
    'longitude': 10.18152,
    'address': null,
    'locationSource': 'GPS',
    'locationAccuracy': 12.5,
    'locationCapturedAt': '2026-11-25T13:29:50Z',
    'status': 'ACCEPTED',
    'decisionMessage': 'Une ambulance part vers vous.',
    'createdAt': '2026-11-25T13:30:00Z',
    'updatedAt': '2026-11-25T13:32:00.123456Z',
  };

  test('lit une demande renvoyée par l\'API', () {
    final r = SosJson.request(json);
    expect(r.id, 42);
    expect(r.status, SosStatus.accepted);
    expect(r.location.source, LocationSource.gps);
    expect(r.location.accuracyMeters, 12.5);
    expect(r.decisionMessage, 'Une ambulance part vers vous.');
    expect(r.updatedAt.toUtc(), DateTime.utc(2026, 11, 25, 13, 32, 0, 123, 456));
  });

  test('champ obligatoire absent : erreur, pas de demande à moitié lue', () {
    expect(() => SosJson.request({...json}..remove('status')), throwsA(isA<TypeError>()));
  });

  test('lit une page', () {
    final page = PageResult.fromJson({
      'items': [json],
      'page': 0,
      'size': 20,
      'totalElements': 21,
      'totalPages': 2,
    }, SosJson.request);
    expect(page.items.single.id, 42);
    expect(page.hasNext, isTrue);
  });

  test('corps de création : aucun champ vide envoyé', () {
    final body = SosJson.create(
      const SosDraft(
        clientRequestId: 'c0ffee00-0000-4000-8000-000000000000',
        location: SosLocation(source: LocationSource.manual, address: ' Rue de Rome '),
      ),
    );
    expect(body, {
      'clientRequestId': 'c0ffee00-0000-4000-8000-000000000000',
      'locationSource': 'MANUAL',
      'address': 'Rue de Rome',
    });
  });

  group('failureFromDio', () {
    DioException withResponse(int status, Object? data) {
      final options = RequestOptions(path: '/api/sos');
      return DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: options, statusCode: status, data: data),
      );
    }

    test('délai dépassé', () {
      final f = failureFromDio(DioException(requestOptions: RequestOptions(), type: DioExceptionType.receiveTimeout));
      expect(f, isA<NetworkFailure>().having((n) => n.timeout, 'timeout', isTrue));
    });

    test('conflit métier avec détails', () {
      final f = failureFromDio(
        withResponse(409, {
          'code': 'SOS_ALREADY_ACTIVE',
          'details': {'activeRequestId': 7},
        }),
      );
      expect(f, isA<ApiFailure>().having((a) => a.details['activeRequestId'], 'active', 7));
      expect(f.code, 'SOS_ALREADY_ACTIVE');
    });

    test('validation champ par champ', () {
      final f = failureFromDio(
        withResponse(400, {
          'code': 'VALIDATION_FAILED',
          'fields': {'address': 'Required'},
        }),
      );
      expect(f, isA<ValidationFailure>().having((v) => v.fields['address'], 'address', 'Required'));
    });

    test('404 et 500', () {
      expect(failureFromDio(withResponse(404, {'code': 'SOS_NOT_FOUND'})), isA<NotFoundFailure>());
      expect(failureFromDio(withResponse(503, 'Bad gateway')), isA<ServerFailure>());
    });
  });
}
