# Intégrer E2 dans l'application commune

## Côté Flutter

1. **Copier** `lib/features/sos/` et `lib/features/sos_hospital/` tels quels. Il ne dépend que des éléments partagés ci-dessous.
2. **Éléments partagés** (à garder en un seul exemplaire dans l'app commune, sans les dupliquer) :
   - `app/theme/` (design system : `AppColors`, `AppSpace`, `AppRadius`, `buildAppTheme`)
   - `shared/widgets/` (`AppButton`, `AppCard`, `StatusPill`, `InlineNotice`, `AppFeedback`, vues d'état, `ContentFrame`)
   - `shared/models/page_result.dart`
   - `core/` : `dioProvider` (client HTTP unique), `tokenStoreProvider`, `AppFailure` + `failureMessage`,
     `locationServiceProvider`, `MapTiles`, `openDialer`, `Formatters`, `AppConfig`
   - `features/auth/` : session (`sessionControllerProvider`) — à reprendre par E1, pas à recréer
3. **Routes** : ajouter `...sosRoutes, ...hospitalRoutes` au `GoRouter` principal (`app/router/app_router.dart`),
   avec la redirection par rôle (`AuthUser.isResponder`) déjà écrite dans ce fichier. Un nouveau rôle (ex. ambulancier
   pour E3) ajoute son espace et une ligne dans cette redirection.
   Liens depuis un autre module : `context.push(SosPaths.home)`, `SosPaths.history`, `SosPaths.detail(id)`.
4. **Textes** : fusionner les clés de `lib/l10n/app_fr.arb` (préfixes `sos*`, `location*`, `review*`, `hospital*`, `role*`,
   `detail*`, `history*`, `status*`).
5. **Dépendances** nécessaires à E2 : `flutter_riverpod`, `go_router`, `dio`, `flutter_secure_storage`,
   `geolocator`, `permission_handler` (^12 tant que Flutter 3.38), `flutter_map`, `latlong2`, `intl`,
   `phosphor_flutter`, `url_launcher`.
6. **Natif** : permissions de localisation (AndroidManifest, Info.plist), requête `tel` (composeur),
   configuration HTTP en clair limitée au débogage (`android/app/src/debug`).
7. **Configuration** : `API_BASE_URL`, `APP_ENV`, `MAPTILER_KEY` via `--dart-define-from-file`.

## Côté Spring Boot

- Ajouter un paquet par module à côté de `com.urgences.api.sos` ; réutiliser `ApiException`,
  `GlobalExceptionHandler`, `PageResponse`, `CurrentUser`, la configuration de sécurité et la table `users`.
- Nouvelles tables : nouvelle migration Flyway `V2__…`, `V3__…` (ne jamais modifier `V1`).
- E3/E6 : l'espace hôpital existe déjà (rôle `RESPONDER`) ; ils peuvent l'étendre ou ajouter leurs rôles.
  Supprimer le compte de démonstration (`URGENCES_DEV_RESPONDER_*`) dès qu'une vraie gestion des comptes secours existe.

## Points de vigilance

- Une seule demande active par patient (règle serveur).
- Le statut affiché vient toujours du serveur : ne jamais simuler une acceptation côté application.
- Aucune donnée médicale ni position dans les journaux.
