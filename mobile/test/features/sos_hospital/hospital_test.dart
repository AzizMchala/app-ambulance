import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:urgences_medicales/app/app.dart';
import 'package:urgences_medicales/core/errors/app_failure.dart';
import 'package:urgences_medicales/core/services/location_service.dart';
import 'package:urgences_medicales/features/auth/domain/auth_user.dart';
import 'package:urgences_medicales/features/auth/presentation/session_controller.dart';
import 'package:urgences_medicales/features/sos/domain/entities/sos_request.dart';
import 'package:urgences_medicales/features/sos/domain/entities/sos_status.dart';
import 'package:urgences_medicales/features/sos/presentation/providers/sos_providers.dart';
import 'package:urgences_medicales/features/sos_hospital/domain/entities/hospital_sos.dart';
import 'package:urgences_medicales/features/sos_hospital/domain/repositories/hospital_sos_repository.dart';
import 'package:urgences_medicales/features/sos_hospital/domain/usecases/hospital_usecases.dart';
import 'package:urgences_medicales/features/sos_hospital/presentation/providers/hospital_providers.dart';
import 'package:urgences_medicales/shared/models/page_result.dart';

import '../../support/fakes.dart';

/// Hôpital en mémoire qui applique les mêmes transitions que l'API.
class FakeHospitalRepository implements HospitalSosRepository {
  FakeHospitalRepository(List<HospitalSosItem> seed) : items = {for (final i in seed) i.request.id: i};

  final Map<int, HospitalSosItem> items;
  final decisions = <(int, SosStatus, String?)>[];

  static const _allowed = {
    SosStatus.pending: {SosStatus.accepted, SosStatus.rejected, SosStatus.cancelled},
    SosStatus.accepted: {SosStatus.inProgress, SosStatus.completed, SosStatus.cancelled},
    SosStatus.inProgress: {SosStatus.completed},
  };

  @override
  Future<PageResult<HospitalSosItem>> list({
    required Set<SosStatus> statuses,
    required int page,
    required int size,
  }) async {
    final match = items.values.where((i) => statuses.contains(i.request.status)).toList();
    return PageResult(items: match, page: 0, size: size, totalElements: match.length, totalPages: 1);
  }

  @override
  Future<HospitalSosItem> getById(int id) async => items[id] ?? (throw const NotFoundFailure());

  @override
  Future<List<SosHistoryEntry>> getHistory(int id) async => [
    SosHistoryEntry(id: 1, newStatus: SosStatus.pending, createdAt: testNow),
  ];

  @override
  Future<HospitalSosItem> updateStatus(int id, {required SosStatus status, String? message}) async {
    final current = items[id]!;
    if (!(_allowed[current.request.status] ?? const {}).contains(status)) {
      throw const ApiFailure(status: 409, code: 'INVALID_STATUS_TRANSITION');
    }
    decisions.add((id, status, message));
    final updated = HospitalSosItem(
      request: current.request.copyWith(status: status, decisionMessage: message),
      patientId: current.patientId,
      patientName: current.patientName,
    );
    items[id] = updated;
    return updated;
  }
}

HospitalSosItem hospitalItem(int id, SosStatus status, {String name = 'Sami Ben Ali'}) => HospitalSosItem(
  request: sosRequest(id: id, status: status),
  patientId: 10 + id,
  patientName: name,
);

class _ResponderSession extends SessionController {
  @override
  Future<AuthUser?> build() async =>
      const AuthUser(id: 2, fullName: 'Équipe de régulation', email: 'hopital@test.tn', role: 'RESPONDER');
}

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> pumpApp(
  WidgetTester tester, {
  required SessionController Function() session,
  FakeHospitalRepository? hospital,
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        sessionControllerProvider.overrideWith(session),
        hospitalSosRepositoryProvider.overrideWithValue(hospital ?? FakeHospitalRepository([])),
        sosRepositoryProvider.overrideWithValue(FakeSosRepository()),
        locationServiceProvider.overrideWithValue(FakeLocationService(serviceEnabled: false)),
      ],
      child: const UrgencesApp(),
    ),
  );
  await settle(tester);
}

void main() {
  setUpAll(() => initializeDateFormatting('fr'));

  group('règles', () {
    test('actions proposées selon le statut', () {
      expect(SosStatus.pending.hospitalActions, [HospitalDecision.accept, HospitalDecision.reject]);
      expect(SosStatus.accepted.hospitalActions, [HospitalDecision.start, HospitalDecision.complete]);
      expect(SosStatus.inProgress.hospitalActions, [HospitalDecision.complete]);
      expect(SosStatus.completed.hospitalActions, isEmpty);
      expect(SosStatus.cancelled.hospitalActions, isEmpty);
    });

    test('un refus sans message est bloqué avant l\'appel réseau', () async {
      final repo = FakeHospitalRepository([hospitalItem(1, SosStatus.pending)]);
      expect(() => DecideSos(repo)(1, HospitalDecision.reject, '  '), throwsA(isA<ValidationFailure>()));
      expect(repo.decisions, isEmpty);
    });
  });

  testWidgets('connexion « hôpital » : arrive sur l\'espace hôpital, jamais sur les écrans patient', (tester) async {
    await pumpApp(
      tester,
      session: _ResponderSession.new,
      hospital: FakeHospitalRepository([hospitalItem(5, SosStatus.pending), hospitalItem(6, SosStatus.accepted)]),
    );
    expect(find.text('Demandes SOS'), findsOneWidget);
    expect(find.text('SOS'), findsNothing);
    // File « à traiter » : seulement la demande en attente, avec son compteur.
    expect(find.textContaining('Demande n° 5'), findsOneWidget);
    expect(find.textContaining('Demande n° 6'), findsNothing);
    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.text('En cours'));
    await settle(tester);
    expect(find.textContaining('Demande n° 6'), findsOneWidget);
  });

  testWidgets('connexion « patient » : arrive sur l\'écran SOS', (tester) async {
    await pumpApp(tester, session: FakeSession.new);
    expect(find.text('SOS'), findsOneWidget);
    expect(find.text('Demandes SOS'), findsNothing);
  });

  testWidgets('l\'hôpital accepte une demande avec un message', (tester) async {
    final repo = FakeHospitalRepository([hospitalItem(5, SosStatus.pending)]);
    await pumpApp(tester, session: _ResponderSession.new, hospital: repo);

    await tester.tap(find.textContaining('Demande n° 5'));
    await settle(tester);
    expect(find.text('Sami Ben Ali'), findsOneWidget);
    expect(find.text('Accepter'), findsOneWidget);
    expect(find.text('Refuser'), findsOneWidget);

    // Refus sans message : bloqué dans la feuille, rien n'est envoyé.
    await tester.tap(find.text('Refuser'));
    await settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Refuser').last);
    await settle(tester);
    expect(find.text('Un message est obligatoire pour refuser une demande.'), findsOneWidget);
    expect(repo.decisions, isEmpty);
    await tester.tap(find.text('Annuler'));
    await settle(tester);

    await tester.tap(find.text('Accepter'));
    await settle(tester);
    await tester.enterText(find.byType(TextField), 'Ambulance en route.');
    await tester.tap(find.widgetWithText(FilledButton, 'Accepter').last);
    await settle(tester);

    expect(repo.decisions.single, (5, SosStatus.accepted, 'Ambulance en route.'));
    expect(find.text('Demande acceptée'), findsNothing, reason: 'l\'hôpital voit le libellé court');
    expect(find.text('Acceptée'), findsWidgets);
    expect(find.text('Démarrer'), findsOneWidget);
    expect(find.text('Terminer'), findsOneWidget);
  });
}
