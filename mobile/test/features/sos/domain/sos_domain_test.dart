import 'package:flutter_test/flutter_test.dart';
import 'package:urgences_medicales/core/errors/app_failure.dart';
import 'package:urgences_medicales/core/services/location_service.dart';
import 'package:urgences_medicales/features/sos/domain/entities/sos_location.dart';
import 'package:urgences_medicales/features/sos/domain/entities/sos_status.dart';
import 'package:urgences_medicales/features/sos/domain/usecases/build_sos_draft.dart';
import 'package:urgences_medicales/features/sos/domain/usecases/get_sos_location.dart';

import '../../../support/fakes.dart';

void main() {
  final now = DateTime(2026, 11, 25, 14, 30);
  GeoFix fixAt(DateTime t) => GeoFix(latitude: 36.8, longitude: 10.18, accuracyMeters: 12, capturedAt: t);

  group('GetSosLocation', () {
    test('relevé frais : position actuelle', () async {
      final service = FakeLocationService(fix: fixAt(now));
      final reading = await GetSosLocation(service)(now: () => now);
      expect(reading.isStale, isFalse);
      expect(reading.fix.latitude, 36.8);
    });

    test('localisation désactivée : échec explicite', () async {
      final service = FakeLocationService(serviceEnabled: false, fix: fixAt(now));
      expect(GetSosLocation(service).call, throwsA(isA<LocationServiceDisabledFailure>()));
    });

    test('autorisation refusée définitivement', () async {
      final service = FakeLocationService(permission: LocationPermissionStatus.deniedForever);
      expect(
        GetSosLocation(service).call,
        throwsA(isA<LocationPermissionFailure>().having((f) => f.permanently, 'permanently', isTrue)),
      );
    });

    test('délai dépassé : dernière position connue, marquée ancienne', () async {
      final old = now.subtract(const Duration(minutes: 20));
      final service = FakeLocationService(fixError: const LocationTimeoutFailure(), lastKnown: fixAt(old));
      final reading = await GetSosLocation(service)(now: () => now);
      expect(reading.isStale, isTrue);
      expect(reading.freshFailure, isA<LocationTimeoutFailure>());
      expect(reading.ageAt(now).inMinutes, 20);
    });

    test('délai dépassé sans position connue : aucune coordonnée inventée', () async {
      final service = FakeLocationService(fixError: const LocationTimeoutFailure());
      expect(GetSosLocation(service).call, throwsA(isA<LocationTimeoutFailure>()));
    });

    test('relevé « courant » trop vieux : signalé comme ancien', () async {
      final service = FakeLocationService(fix: fixAt(now.subtract(const Duration(minutes: 10))));
      final reading = await GetSosLocation(service)(now: () => now);
      expect(reading.isStale, isTrue);
    });
  });

  group('BuildSosDraft', () {
    const build = BuildSosDraft();
    final fresh = SosLocationReading(fix: fixAt(now), isStale: false);
    final stale = SosLocationReading(fix: fixAt(now.subtract(const Duration(minutes: 30))), isStale: true);

    test('GPS frais : envoyé en GPS, adresse facultative', () {
      final r = build(clientRequestId: 'id', reading: fresh, acceptStale: false, address: '  ') as SosDraftReady;
      expect(r.draft.location.source, LocationSource.gps);
      expect(r.draft.location.address, isNull);
      expect(r.draft.location.capturedAt, now);
    });

    test('sans GPS : adresse obligatoire', () {
      final r = build(clientRequestId: 'id', reading: null, acceptStale: false, address: '');
      expect((r as SosDraftInvalid).issue, SosDraftIssue.addressRequired);
    });

    test('adresse trop courte', () {
      final r = build(clientRequestId: 'id', reading: null, acceptStale: false, address: 'abc');
      expect((r as SosDraftInvalid).issue, SosDraftIssue.addressTooShort);
    });

    test('position ancienne non acceptée : traitée comme absente', () {
      final r = build(clientRequestId: 'id', reading: stale, acceptStale: false, address: '');
      expect((r as SosDraftInvalid).issue, SosDraftIssue.addressRequired);

      final manual = build(clientRequestId: 'id', reading: stale, acceptStale: false, address: 'Rue de Rome, Tunis');
      final loc = (manual as SosDraftReady).draft.location;
      expect(loc.source, LocationSource.manual);
      expect(loc.hasCoordinates, isFalse);
    });

    test('position ancienne acceptée : envoyée en LAST_KNOWN', () {
      final r = build(clientRequestId: 'id', reading: stale, acceptStale: true, address: '') as SosDraftReady;
      expect(r.draft.location.source, LocationSource.lastKnown);
    });

    test('adresse trop longue refusée', () {
      final r = build(clientRequestId: 'id', reading: fresh, acceptStale: false, address: 'a' * 300);
      expect((r as SosDraftInvalid).issue, SosDraftIssue.addressTooLong);
    });
  });

  group('SosStatus', () {
    test('valeur inconnue de l\'API : jamais devinée', () {
      expect(SosStatus.fromApi('TRANSFERRED'), SosStatus.unknown);
      expect(SosStatus.fromApi('IN_PROGRESS'), SosStatus.inProgress);
    });

    test('seule une demande en attente est annulable', () {
      expect(SosStatus.pending.isCancellableByPatient, isTrue);
      expect(SosStatus.accepted.isCancellableByPatient, isFalse);
      expect(SosStatus.completed.isActive, isFalse);
    });
  });

  test('les doublures imitent le serveur', () async {
    final repo = FakeSosRepository(seed: [sosRequest(id: 1)]);
    final page = await repo.list(page: 0, size: 20);
    expect(page.items, hasLength(1));
  });
}
