# Contrat API — module E2

Base : `/api`. JSON UTF-8, dates ISO 8601 en UTC. Toutes les routes sauf `/api/auth/login` et `/api/auth/register`
exigent `Authorization: Bearer <jeton>`. Documentation interactive : `/swagger-ui.html`.

## Erreurs (format unique)

```json
{ "status": 409, "code": "SOS_ALREADY_ACTIVE", "message": "Vous avez déjà une demande SOS en cours.",
  "path": "/api/sos", "timestamp": "2026-11-25T22:28:00Z",
  "fields": { "address": "Required" }, "details": { "activeRequestId": 7 } }
```

| HTTP | code | Quand |
|---|---|---|
| 400 | `VALIDATION_FAILED` | champs invalides (`fields` : champ → règle) |
| 400 | `INVALID_PARAMETER`, `MALFORMED_REQUEST` | paramètre ou corps illisible |
| 401 | `UNAUTHENTICATED`, `INVALID_CREDENTIALS` | jeton absent / invalide / expiré ; mauvais identifiants |
| 403 | `FORBIDDEN` | rôle insuffisant |
| 404 | `SOS_NOT_FOUND` | demande inexistante **ou appartenant à un autre patient** |
| 409 | `SOS_ALREADY_ACTIVE` | une demande est déjà en cours (`details.activeRequestId`) |
| 409 | `INVALID_STATUS_TRANSITION`, `CONCURRENT_UPDATE` | transition interdite ; modification simultanée |
| 409 | `EMAIL_TAKEN` | inscription avec un e-mail existant |
| 500 | `INTERNAL_ERROR` | erreur imprévue (aucun détail technique renvoyé) |

## Authentification (partagée)

| Méthode | Chemin | Corps → Réponse |
|---|---|---|
| POST | `/api/auth/register` | `{fullName, email, password(8+)}` → **201** `{accessToken, tokenType, expiresAt, user}` |
| POST | `/api/auth/login` | `{email, password}` → **200** même réponse |
| GET | `/api/auth/me` | → `{id, fullName, email, role}` |

## SOS — patient (rôle PATIENT)

| Méthode | Chemin | Description |
|---|---|---|
| POST | `/api/sos` | Créer. **201** + `Location`, ou **200** si `clientRequestId` déjà reçu (idempotence) |
| GET | `/api/sos?page=0&size=20` | Mes demandes, plus récentes d'abord (`size` ≤ 50) |
| GET | `/api/sos/{id}` | Détail |
| GET | `/api/sos/{id}/status` | Statut léger pour le suivi : `{id, status, decisionMessage, updatedAt}` |
| GET | `/api/sos/{id}/history` | Changements de statut, du plus ancien au plus récent |
| POST | `/api/sos/{id}/cancel` | Annuler (seulement si `PENDING`) |

Création :

```json
{ "clientRequestId": "3f2b8c1e-…", "locationSource": "GPS",
  "latitude": 36.80651, "longitude": 10.18152, "locationAccuracy": 12.5,
  "locationCapturedAt": "2026-11-25T22:27:50Z", "address": "2e étage (facultatif)" }
```

Règles : `GPS` / `LAST_KNOWN` → latitude, longitude et `locationCapturedAt` obligatoires ;
`MANUAL` → `address` (5 à 255 caractères) obligatoire, pas de coordonnées.

Réponse `SosResponse` :

```json
{ "id": 1, "latitude": null, "longitude": null, "address": "12 rue de Marseille, Tunis",
  "locationSource": "MANUAL", "locationAccuracy": null, "locationCapturedAt": null,
  "status": "PENDING", "decisionMessage": null,
  "createdAt": "2026-11-25T22:28:00Z", "updatedAt": "2026-11-25T22:28:00Z" }
```

Page : `{ "items": [...], "page": 0, "size": 20, "totalElements": 1, "totalPages": 1 }`.

Historique : `[{ "id": 1, "sosRequestId": 1, "oldStatus": null, "newStatus": "PENDING", "description": "…", "createdAt": "…" }]`.

## SOS — espace hôpital (rôle RESPONDER)

| Méthode | Chemin | Description |
|---|---|---|
| GET | `/api/responder/sos?status=PENDING&status=ACCEPTED` | File (par défaut : demandes actives) ; actives : plus anciennes d'abord ; clôturées : plus récentes d'abord |
| GET | `/api/responder/sos/{id}` | Détail : `{ request: SosResponse, patientId, patientName }` |
| GET | `/api/responder/sos/{id}/history` | Changements de statut |
| PATCH | `/api/responder/sos/{id}/status` | `{status, message}` — un refus (`REJECTED`) exige un message |

## Statuts et transitions

```
PENDING ─► ACCEPTED ─► IN_PROGRESS ─► COMPLETED
   │           ├────────────────────► COMPLETED
   │           └─► CANCELLED
   ├─► REJECTED
   └─► CANCELLED (patient ou secours)
```

Un client qui reçoit un statut inconnu l'affiche comme « Statut non reconnu » au lieu de le deviner.
