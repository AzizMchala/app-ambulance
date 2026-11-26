import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:urgences_medicales/app/theme/app_theme.dart';
import 'package:urgences_medicales/core/services/location_service.dart';
import 'package:urgences_medicales/features/auth/presentation/session_controller.dart';
import 'package:urgences_medicales/features/sos/domain/entities/sos_location.dart';
import 'package:urgences_medicales/features/sos/domain/entities/sos_request.dart';
import 'package:urgences_medicales/features/sos/domain/entities/sos_status.dart';
import 'package:urgences_medicales/features/sos/presentation/providers/sos_providers.dart';
import 'package:urgences_medicales/features/sos/presentation/sos_routes.dart';
import 'package:urgences_medicales/l10n/app_localizations.dart';

import '../../../support/fakes.dart';

/// L'application réelle (routes, thème, textes) sur des doublures de dépôt et de GPS.
Future<GoRouter> pumpSos(
  WidgetTester tester, {
  required String location,
  required FakeSosRepository repo,
  FakeLocationService? gps,
}) async {
  final router = GoRouter(initialLocation: location, routes: sosRoutes);
  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        sosRepositoryProvider.overrideWithValue(repo),
        // Sans GPS : les tests n'affichent pas de carte (pas de tuiles réseau).
        locationServiceProvider.overrideWithValue(gps ?? FakeLocationService(serviceEnabled: false)),
        sessionControllerProvider.overrideWith(FakeSession.new),
      ],
      child: MaterialApp.router(
        theme: buildAppTheme(Brightness.light),
        routerConfig: router,
        locale: const Locale('fr'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    ),
  );
  // Le halo du bouton SOS tourne en boucle : on avance le temps au lieu d'attendre la fin.
  await settle(tester);
  return router;
}

/// Avance le temps (transitions de page, requêtes simulées) sans attendre la fin du halo animé.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUpAll(() => initializeDateFormatting('fr'));

  testWidgets('accueil : bouton SOS, état GPS réel, état vide', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    addTearDown(tester.view.reset);
    await pumpSos(tester, location: '/sos', repo: FakeSosRepository());

    expect(find.text('SOS'), findsOneWidget);
    expect(find.text('Bonjour Aziz'), findsOneWidget);
    expect(find.text('La localisation est désactivée'), findsOneWidget);
    expect(find.text('Aucune demande envoyée pour l\'instant.'), findsOneWidget);
  });

  testWidgets('accueil : dernière demande affichée avec son vrai statut', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    addTearDown(tester.view.reset);
    await pumpSos(
      tester,
      location: '/sos',
      repo: FakeSosRepository(seed: [sosRequest(id: 7, status: SosStatus.accepted)]),
    );
    expect(find.text('Demande acceptée'), findsOneWidget);
    expect(find.textContaining('Demande n° 7'), findsOneWidget);
  });

  testWidgets('envoi sans GPS : adresse exigée, confirmation, puis suivi', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    addTearDown(tester.view.reset);
    final repo = FakeSosRepository();
    final router = await pumpSos(tester, location: '/sos/new', repo: repo);

    await tester.tap(find.text('Envoyer l\'alerte SOS'));
    await tester.pump();
    expect(find.text('Saisissez une adresse : aucune position GPS utilisable.'), findsOneWidget);
    expect(repo.createdDrafts, isEmpty);

    await tester.enterText(find.byType(TextField), '12 rue de Marseille, Tunis');
    await tester.tap(find.text('Envoyer l\'alerte SOS'));
    await settle(tester);
    expect(find.text('Envoyer l\'alerte ?'), findsOneWidget);
    expect(repo.createdDrafts, isEmpty, reason: 'rien ne part avant la confirmation');

    await tester.tap(find.text('Envoyer'));
    await settle(tester);

    expect(repo.createdDrafts.single.location.source, LocationSource.manual);
    expect(router.state.uri.toString(), '/sos/100?sent=1');
    expect(find.textContaining('Alerte enregistrée par le serveur'), findsOneWidget);
    expect(find.text('En attente de décision'), findsWidgets);
    expect(find.text('Aucune décision reçue pour l\'instant.'), findsOneWidget);
  });

  testWidgets('détail : décision et message reçus du serveur, frise de suivi', (tester) async {
    tester.view.physicalSize = const Size(1080, 3200);
    addTearDown(tester.view.reset);
    final repo = FakeSosRepository(
      seed: [
        sosRequest(
          id: 3,
          status: SosStatus.rejected,
          decisionMessage: 'Rapprochez-vous des urgences de Charles Nicolle.',
        ),
      ],
      history: [
        SosHistoryEntry(id: 1, newStatus: SosStatus.pending, createdAt: testNow),
        SosHistoryEntry(
          id: 2,
          oldStatus: SosStatus.pending,
          newStatus: SosStatus.rejected,
          description: 'Rapprochez-vous des urgences de Charles Nicolle.',
          createdAt: testNow.add(const Duration(minutes: 3)),
        ),
      ],
    );
    await pumpSos(tester, location: '/sos/3', repo: repo);

    expect(find.text('Demande refusée'), findsWidgets);
    expect(find.text('Message des secours'), findsOneWidget);
    expect(find.text('En attente de décision'), findsOneWidget, reason: 'étape initiale dans la frise');
    expect(find.text('Annuler la demande'), findsNothing, reason: 'une demande décidée ne s\'annule plus');
  });

  testWidgets('historique vide', (tester) async {
    await pumpSos(tester, location: '/sos/history', repo: FakeSosRepository());
    expect(find.text('Aucune demande'), findsOneWidget);
  });

  testWidgets('GPS refusé définitivement : renvoi vers les réglages', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    addTearDown(tester.view.reset);
    final gps = FakeLocationService(permission: LocationPermissionStatus.deniedForever);
    await pumpSos(tester, location: '/sos', repo: FakeSosRepository(), gps: gps);
    expect(find.text('Accès à la position refusé'), findsOneWidget);
    expect(find.text('Réglages'), findsOneWidget);
  });
}
