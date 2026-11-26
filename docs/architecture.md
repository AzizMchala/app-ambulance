# Architecture du module E2

## Vue d'ensemble

```
Flutter (logique métier, interactions, GPS)  ──HTTPS/JSON + JWT──►  Spring Boot (API REST, sécurité, persistance)  ──►  MySQL
```

Flutter ne parle jamais directement à MySQL. Aucun mot de passe MySQL ni secret n'est présent dans l'application.

## Flutter — Feature-First + Clean Architecture légère

```
lib/
  main.dart                     initialisation (dates fr, ProviderScope sans nouvel essai automatique)
  app/                          PARTAGÉ : app.dart, router/ (routeur principal), theme/ (design system)
  core/                         PARTAGÉ : config, constants, errors, network (Dio), services (GPS, jeton, carte, composeur), utils
  shared/                       PARTAGÉ : widgets du design system, PageResult
  l10n/                         textes (ARB, français ; prêt pour d'autres langues)
  features/
    auth/                       PARTAGÉ : connexion minimale (à enrichir par E1)
    sos/                        MODULE E2
      domain/      entities/ (SosRequest, SosLocation, SosStatus, SosDraft) · repositories/ (contrat) · usecases/
      data/        datasources/ (appels HTTP) · models/ (JSON) · repositories/ (implémentation)
      presentation/ controllers/ (Riverpod) · providers/ (injection) · screens/ · widgets/ · sos_routes.dart
    sos_hospital/               MODULE E2 — espace hôpital (rôle RESPONDER)
      domain/      HospitalSosItem, HospitalQueue (3 files), HospitalDecision · repository · usecases (DecideSos…)
      data/        appels /api/responder/sos
      presentation/ file (3 onglets, actualisation 15 s), fiche + décisions, hospital_routes.dart
```

Le routeur principal oriente chaque rôle : `PATIENT` → `/sos`, `RESPONDER` → `/hospital`, et interdit l'espace
de l'autre rôle. L'espace hôpital réutilise les entités, la carte et la frise du module SOS (aucune duplication).

Règles respectées : les écrans n'appellent jamais Dio ; les contrôleurs passent par les cas d'utilisation ;
les cas d'utilisation ne connaissent que des interfaces (`SosRepository`, `LocationService`) ; toute erreur devient
une `AppFailure` traduite en message par `failureMessage` (un seul endroit).

### Décisions importantes

| Décision | Raison |
|---|---|
| Riverpod 3, providers d'injection (`sosRepositoryProvider`, `locationServiceProvider`) | Substitution simple en test et pour l'intégration (une ligne `overrideWithValue`). |
| Pas de Freezed / json_serializable | 4 objets JSON plats : la conversion manuelle (`SosJson`) évite une étape de génération de code pour toute l'équipe. Un champ manquant lève une erreur, jamais de demande à moitié lue. |
| Clé d'idempotence `clientRequestId` (UUID généré sur le téléphone) | Si la réponse se perd et que le patient réessaie, le serveur renvoie la demande existante au lieu d'en créer une deuxième. |
| Une seule demande active par patient | Évite les doublons sous stress ; le serveur répond `409 SOS_ALREADY_ACTIVE` avec l'id de la demande en cours. |
| Suivi par relecture (`/status` toutes les 15 s, au premier plan uniquement) | Simple et fiable ; remplaçable par FCM ou WebSocket sans toucher l'écran. |
| Jeton dans `flutter_secure_storage` | Keystore / Keychain, jamais SharedPreferences. |
| Journaux Dio : méthode, chemin, statut | Aucun corps ni en-tête : ni jeton, ni position, ni donnée médicale. |
| Pas de nouvel essai automatique des providers | Une erreur s'affiche ; le patient décide de réessayer. |

### Localisation (GPS)

1. Le service de localisation et l'autorisation sont **vérifiés** à l'ouverture, mais l'autorisation n'est **demandée**
   que lorsque le patient appuie sur « Autoriser » ou prépare une alerte.
2. Relevé haute précision avec délai de 15 s.
3. En cas d'échec, la dernière position connue est proposée, **toujours marquée « Position ancienne »** avec son âge,
   et n'est envoyée (en `LAST_KNOWN`) que si le patient coche « Envoyer quand même ».
   Un relevé dit « courant » mais vieux de plus de 2 min est aussi marqué ancien.
4. Sinon, adresse manuelle obligatoire (`MANUAL`). Aucune coordonnée n'est jamais inventée ;
   la carte n'est jamais centrée sur un lieu par défaut.
5. Retour des réglages système : nouvel essai automatique (écoute du cycle de vie de l'application).

### Envoi

Écran SOS → écran de vérification (carte, précision, source, adresse) → boîte de confirmation qui récapitule
exactement ce qui part → `POST /api/sos` → l'écran de suivi n'apparaît **qu'après la réponse du serveur**.
En cas d'échec réseau : message clair, nouvel essai possible (même clé d'idempotence), bouton « Appeler le 190 ».

### Design system

Inspiré de LammaPets (« Carnet clair ») : fond gris chaud `#F3F3F0`, surfaces blanches, encre marine `#0B1026`,
bleu d'action `#2563B0`. Le rouge `#D93A40` est **réservé au SOS** et aux erreurs graves. Typographies Bricolage
Grotesque (titres) et Instrument Sans (interface), licences OFL incluses. Jetons : `AppSpace`, `AppRadius`,
`AppSize`, `AppMotion`, couleurs `context.colors`. Mode sombre prévu. Animations courtes, désactivées si le système
demande de réduire les animations ; cibles tactiles ≥ 48 px ; libellés d'accessibilité sur le bouton SOS et les cartes.

## Backend — Spring Boot

```
com.urgences.api
  config/   SecurityConfig (JWT HS256, rôles), JwtConfig, OpenApiConfig, SecurityProperties
  common/   ApiException, GlobalExceptionHandler, ApiErrorResponse, PageResponse, JsonSecurityHandlers
  user/     User, Role (PATIENT | RESPONDER), UserRepository
  auth/     inscription, connexion, /me, compte secours de démonstration
  sos/      domain/ (SosRequest, SosHistory, SosStatus, LocationSource) · SosService (patient) ·
            ResponderSosService (secours) · dto/ · web/ (contrôleurs)
```

- **Contrôle d'accès** : le patient est toujours celui du jeton ; toutes les lectures passent par
  `findByIdAndPatientId` → une demande d'un autre patient répond **404** (son existence n'est pas révélée).
- **Transitions de statut** centralisées dans `SosStatus.next()` ; chaque changement écrit une ligne `sos_history`.
- **Concurrence** : verrou pessimiste sur le patient à la création, verrou optimiste (`@Version`) sur la demande.
- **Schéma** versionné par Flyway (`V1__users_and_sos.sql`) avec contraintes CHECK (coordonnées valides et
  appariées, au moins une localisation, statuts connus) et clés étrangères `ON DELETE CASCADE`.

### Modèle de données

```
users (id, full_name, email UNIQUE, password_hash, role, created_at)
  1 ── n  sos_requests (id, patient_id FK, client_request_id, latitude, longitude, address, location_source,
                        location_accuracy, location_captured_at, status, decision_message, created_at, updated_at, version)
            1 ── n  sos_history (id, sos_request_id FK, old_status, new_status, description, changed_by_user_id FK, created_at)
```

Minimisation : seules la position au moment de l'alerte et l'adresse saisie sont conservées ; aucune trace GPS
continue. La suppression d'un compte supprime ses alertes.

## Hypothèses et limites (à valider avec l'équipe)

- **Authentification partagée minimale** (e-mail + mot de passe, jeton 12 h, sans jeton de rafraîchissement) :
  aucune n'existait. Elle est placée dans `features/auth` et `auth/` pour être reprise par E1, pas dupliquée.
- **Rôle RESPONDER = hôpital** : l'espace hôpital minimal (file, décisions) est fourni dans E2 pour une
  démonstration complète. E3/E6 (ambulances, équipe) pourront l'étendre ou ajouter leurs rôles.
- Les comptes hôpital ne s'inscrivent pas eux-mêmes ; en attendant une administration des comptes, seul le compte
  de démonstration (variables `URGENCES_DEV_RESPONDER_*`) existe.
- Pas encore de limitation du nombre d'essais de connexion ni de notifications push : points prévus.
- Numéro d'urgence : SAMU Tunisie **190** (ouverture du composeur uniquement).
