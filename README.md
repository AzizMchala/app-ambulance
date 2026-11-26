# Urgences médicales — module E2 « SOS et historique »

Application mobile académique de gestion des urgences médicales. Ce dépôt contient le module **E2** (responsable : Aziz),
conçu pour être intégré dans l'application Flutter commune avec les modules E1, E3, E4, E5 et E6.

| Dossier | Contenu |
|---|---|
| `mobile/` | Application Flutter (Riverpod, GoRouter, Dio, Geolocator, Permission Handler, flutter_map + MapTiler) |
| `backend/` | API REST unique Spring Boot 4 / Java 21 / Spring Data JPA / Spring Security (JWT) / Flyway |
| `infrastructure/` | Docker Compose : MySQL 8.4 (+ API en option) |
| `docs/` | Architecture, contrat API, intégration avec les autres modules |

## Démarrage rapide

### 1. Base de données et API (Docker)

```powershell
cd infrastructure
copy .env.example .env   # puis remplacer chaque valeur (secret JWT : 32 caractères min.)
docker compose --env-file .env up -d --build
```

- API : http://localhost:8082 — documentation Swagger : http://localhost:8082/swagger-ui.html
- MySQL : `localhost:3308` (uniquement sur la machine locale)

Sans Docker pour l'API : `docker compose --env-file .env up -d mysql`, puis dans `backend/` :

```powershell
$env:JAVA_HOME = "C:\Java\jdk-21"; $env:URGENCES_DB_PASSWORD = "..."; $env:URGENCES_JWT_SECRET = "..."; .\mvnw spring-boot:run
```

### 2. Application mobile

La clé MapTiler va dans `mobile/config/secrets.local.json` (ignoré par Git, modèle : `secrets.example.json`).

```powershell
cd mobile
flutter pub get
# Émulateur Android
flutter run --dart-define-from-file=config/dev-emulator.json --dart-define-from-file=config/secrets.local.json
# Téléphone Android branché en USB (l'API locale passe par le câble)
adb reverse tcp:8082 tcp:8082
flutter run --dart-define-from-file=config/dev-device.json --dart-define-from-file=config/secrets.local.json
```

### 3. Tests

```powershell
cd mobile;  flutter analyze; flutter test          # 41 tests (domaine, données, contrôleurs, écrans patient et hôpital)
cd backend; .\mvnw test                             # 13 tests d'intégration sur un vrai MySQL (Testcontainers)
```

## Deux espaces selon le rôle

Le même écran de connexion sert à tous ; l'application ouvre ensuite l'espace du rôle du compte :

| Rôle | Espace | Ce qu'il fait |
|---|---|---|
| `PATIENT` (inscription libre) | **SOS** | envoie une alerte, suit la décision en direct, consulte son historique |
| `RESPONDER` (hôpital / secours) | **Espace hôpital** | file « À traiter / En cours / Clôturées » actualisée toutes les 15 s, fiche avec carte et itinéraire, décisions : Accepter, Refuser (message obligatoire), Démarrer, Terminer |

Un patient ne peut pas ouvrir l'espace hôpital et inversement (redirection dans l'application, 403 côté API).
L'inscription crée toujours un patient : les comptes hôpital ne s'inscrivent pas eux-mêmes.
En développement, un compte hôpital de démonstration est créé si `URGENCES_DEV_RESPONDER_EMAIL` et
`URGENCES_DEV_RESPONDER_PASSWORD` sont définis dans `infrastructure/.env` (à ne jamais définir en production).

Démonstration : un téléphone connecté en hôpital, un autre appareil (ou Flutter web) connecté en patient ;
le SOS apparaît dans « À traiter » en moins de 15 s et la décision s'affiche chez le patient de la même façon.

Voir [docs/architecture.md](docs/architecture.md), [docs/api-contract.md](docs/api-contract.md) et
[docs/integration.md](docs/integration.md).
