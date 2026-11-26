import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr');
  runApp(
    // Pas de nouvel essai automatique des providers en erreur : l'erreur s'affiche
    // et c'est le patient qui choisit de réessayer.
    ProviderScope(retry: (_, _) => null, child: const UrgencesApp()),
  );
}
