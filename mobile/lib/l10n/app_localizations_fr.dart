// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Urgences';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonSeeDetails => 'Voir les détails';

  @override
  String get errorNetwork => 'Pas de connexion au serveur. Vérifiez votre réseau.';

  @override
  String get errorTimeout => 'Le serveur met trop de temps à répondre.';

  @override
  String get errorUnauthenticated => 'Votre session a expiré. Reconnectez-vous.';

  @override
  String get errorForbidden => 'Vous n\'avez pas accès à cette ressource.';

  @override
  String get errorNotFound => 'Élément introuvable.';

  @override
  String get errorValidation => 'Certaines informations sont invalides.';

  @override
  String get errorServer => 'Le serveur a rencontré une erreur. Réessayez dans un instant.';

  @override
  String get errorUnexpected => 'Une erreur inattendue est survenue.';

  @override
  String get errorSosAlreadyActive => 'Vous avez déjà une demande SOS en cours.';

  @override
  String get errorInvalidTransition => 'Cette demande ne peut plus être modifiée.';

  @override
  String get authLoginTitle => 'Connexion';

  @override
  String get authLoginSubtitle => 'Accédez à votre espace.';

  @override
  String get authEmail => 'Adresse e-mail';

  @override
  String get authPassword => 'Mot de passe';

  @override
  String get authLoginAction => 'Se connecter';

  @override
  String get authNoAccount => 'Pas encore de compte ?';

  @override
  String get authCreateAccount => 'Créer un compte';

  @override
  String get authRegisterTitle => 'Créer un compte';

  @override
  String get authRegisterSubtitle => 'Quelques informations pour vous identifier auprès des secours.';

  @override
  String get authFullName => 'Nom complet';

  @override
  String get authRegisterAction => 'Créer mon compte';

  @override
  String get authHaveAccount => 'Déjà inscrit ?';

  @override
  String get authInvalidCredentials => 'E-mail ou mot de passe incorrect.';

  @override
  String get authEmailTaken => 'Cette adresse e-mail est déjà utilisée.';

  @override
  String get authEmailInvalid => 'Adresse e-mail invalide.';

  @override
  String get authPasswordTooShort => '8 caractères minimum.';

  @override
  String get authFieldRequired => 'Champ obligatoire.';

  @override
  String get authLogout => 'Se déconnecter';

  @override
  String sosHomeGreeting(String name) {
    return 'Bonjour $name';
  }

  @override
  String get sosHomeTitle => 'Besoin d\'une aide médicale ?';

  @override
  String get sosHomeSubtitle => 'Rien n\'est envoyé sans votre confirmation.';

  @override
  String get sosButtonLabel => 'SOS';

  @override
  String get sosButtonHint => 'Préparer une alerte';

  @override
  String get sosButtonSemantics => 'Bouton SOS. Ouvre la vérification de l\'alerte avant envoi.';

  @override
  String get locationTitle => 'Votre position';

  @override
  String get locationChecking => 'Vérification de la localisation…';

  @override
  String get locationAcquiring => 'Recherche du signal GPS…';

  @override
  String get locationReady => 'Position GPS disponible';

  @override
  String locationAccuracy(int meters) {
    return 'Précision ± $meters m';
  }

  @override
  String get locationStale => 'Position ancienne';

  @override
  String locationStaleAge(int minutes) {
    return 'Relevée il y a $minutes min : elle n\'est peut-être plus exacte.';
  }

  @override
  String get locationServiceOff => 'La localisation est désactivée';

  @override
  String get locationServiceOffHint => 'Activez-la pour joindre votre position à l\'alerte.';

  @override
  String get locationPermissionNeeded => 'Autorisation nécessaire';

  @override
  String get locationPermissionNeededHint => 'Votre position aide les secours à vous trouver plus vite.';

  @override
  String get locationPermissionDenied => 'Accès à la position refusé';

  @override
  String get locationPermissionDeniedForeverHint =>
      'Autorisez la localisation dans les réglages, ou saisissez votre adresse.';

  @override
  String get locationTimeout => 'Aucun signal GPS pour l\'instant';

  @override
  String get locationTimeoutHint => 'Rapprochez-vous d\'une fenêtre, réessayez ou saisissez votre adresse.';

  @override
  String get locationError => 'Localisation indisponible';

  @override
  String get locationErrorHint => 'Vous pouvez saisir votre adresse à la place.';

  @override
  String get locationActionEnable => 'Activer';

  @override
  String get locationActionAllow => 'Autoriser';

  @override
  String get locationActionSettings => 'Réglages';

  @override
  String get locationActionRetry => 'Réessayer';

  @override
  String get locationActionRefresh => 'Actualiser la position';

  @override
  String get locationSourceGps => 'GPS en direct';

  @override
  String get locationSourceLastKnown => 'Dernière position connue';

  @override
  String get locationSourceManual => 'Adresse saisie';

  @override
  String get locationCoordinates => 'Coordonnées';

  @override
  String locationCapturedAt(String time) {
    return 'Relevée à $time';
  }

  @override
  String get locationMapUnavailable => 'Carte indisponible sans position GPS';

  @override
  String get latestTitle => 'Dernière demande';

  @override
  String get latestEmpty => 'Aucune demande envoyée pour l\'instant.';

  @override
  String get homeHistory => 'Historique';

  @override
  String get homeHistoryHint => 'Toutes vos demandes';

  @override
  String homeCall(String number) {
    return 'Appeler le $number';
  }

  @override
  String get homeCallHint => 'SAMU, même sans Internet';

  @override
  String get reviewTitle => 'Vérifier l\'alerte';

  @override
  String get reviewIntro => 'Contrôlez votre localisation avant d\'envoyer.';

  @override
  String get reviewAddressLabel => 'Adresse ou repère';

  @override
  String get reviewAddressHintGps => 'Facultatif : étage, bâtiment, repère…';

  @override
  String get reviewAddressHintRequired => 'Rue, ville, repère visible…';

  @override
  String get reviewAddressRequired => 'Saisissez une adresse : aucune position GPS utilisable.';

  @override
  String get reviewAddressTooShort => 'Adresse trop courte (5 caractères minimum).';

  @override
  String get reviewUseStale => 'Envoyer quand même cette position ancienne';

  @override
  String get reviewNoCoordinates =>
      'Aucune coordonnée GPS ne sera envoyée : l\'adresse saisie sera la seule localisation.';

  @override
  String get reviewSend => 'Envoyer l\'alerte SOS';

  @override
  String get reviewSending => 'Envoi en cours…';

  @override
  String get confirmTitle => 'Envoyer l\'alerte ?';

  @override
  String get confirmBody => 'Votre demande sera transmise aux secours avec la localisation ci-dessous.';

  @override
  String get confirmSend => 'Envoyer';

  @override
  String get sendFailedTitle => 'L\'alerte n\'a pas été envoyée';

  @override
  String sendFailedNetworkHint(String number) {
    return 'Si c\'est urgent, appelez directement le $number.';
  }

  @override
  String get sendViewActive => 'Voir la demande en cours';

  @override
  String get sentBanner => 'Alerte enregistrée par le serveur. Les secours ont reçu votre demande.';

  @override
  String get historyTitle => 'Historique';

  @override
  String get historyEmptyTitle => 'Aucune demande';

  @override
  String get historyEmptyBody => 'Vos demandes SOS apparaîtront ici dès leur envoi.';

  @override
  String get historyLoadMoreError => 'Impossible de charger la suite.';

  @override
  String requestNumber(int id) {
    return 'Demande n° $id';
  }

  @override
  String get statusPending => 'En attente';

  @override
  String get statusAccepted => 'Acceptée';

  @override
  String get statusInProgress => 'En cours';

  @override
  String get statusCompleted => 'Terminée';

  @override
  String get statusRejected => 'Refusée';

  @override
  String get statusCancelled => 'Annulée';

  @override
  String get statusUnknown => 'Inconnu';

  @override
  String get statusHeadlinePending => 'En attente de décision';

  @override
  String get statusHeadlineAccepted => 'Demande acceptée';

  @override
  String get statusHeadlineInProgress => 'Prise en charge en cours';

  @override
  String get statusHeadlineCompleted => 'Intervention terminée';

  @override
  String get statusHeadlineRejected => 'Demande refusée';

  @override
  String get statusHeadlineCancelled => 'Demande annulée';

  @override
  String get statusHeadlineUnknown => 'Statut non reconnu par l\'application';

  @override
  String get detailDecision => 'Décision';

  @override
  String get detailNoDecision => 'Aucune décision reçue pour l\'instant.';

  @override
  String get detailDecisionMessage => 'Message des secours';

  @override
  String get detailNoDecisionMessage => 'Aucun message n\'accompagne cette décision.';

  @override
  String get detailLocation => 'Localisation';

  @override
  String get detailInfo => 'Informations';

  @override
  String get detailId => 'Identifiant';

  @override
  String get detailDate => 'Date';

  @override
  String get detailTime => 'Heure';

  @override
  String get detailUpdated => 'Dernière mise à jour';

  @override
  String get detailCapturedAt => 'Position relevée';

  @override
  String get detailTimeline => 'Suivi du statut';

  @override
  String get detailTimelineEmpty => 'Aucun changement de statut enregistré.';

  @override
  String get detailAutoRefresh => 'Actualisation automatique';

  @override
  String detailUpdatedAt(String when) {
    return 'Mis à jour $when';
  }

  @override
  String get detailCancel => 'Annuler la demande';

  @override
  String get detailCancelTitle => 'Annuler cette demande ?';

  @override
  String get detailCancelBody => 'Les secours sauront que vous n\'avez plus besoin d\'aide.';

  @override
  String get detailCancelConfirm => 'Oui, annuler';

  @override
  String get detailKeep => 'Garder';

  @override
  String get detailCancelled => 'Demande annulée.';

  @override
  String get detailRefreshFailed => 'Actualisation impossible : les informations affichées peuvent être anciennes.';

  @override
  String get relativeNow => 'à l\'instant';

  @override
  String relativeMinutes(int n) {
    return 'il y a $n min';
  }

  @override
  String relativeHours(int n) {
    return 'il y a $n h';
  }

  @override
  String relativeAt(String date) {
    return 'le $date';
  }

  @override
  String get roleHospital => 'Espace hôpital';

  @override
  String hospitalGreeting(String name) {
    return 'Bonjour $name';
  }

  @override
  String get hospitalTitle => 'Demandes SOS';

  @override
  String get hospitalSubtitle => 'Actualisation automatique toutes les 15 secondes.';

  @override
  String get hospitalTabToHandle => 'À traiter';

  @override
  String get hospitalTabOngoing => 'En cours';

  @override
  String get hospitalTabClosed => 'Clôturées';

  @override
  String get hospitalEmptyToHandle => 'Aucune demande en attente.';

  @override
  String get hospitalEmptyOngoing => 'Aucune intervention en cours.';

  @override
  String get hospitalEmptyClosed => 'Aucune demande clôturée.';

  @override
  String get hospitalEmptyBody => 'Les nouvelles alertes apparaîtront ici automatiquement.';

  @override
  String get hospitalPatient => 'Patient';

  @override
  String hospitalPatientId(int id) {
    return 'Dossier patient n° $id';
  }

  @override
  String hospitalStaleWarning(String when) {
    return 'Position ancienne : relevée $when. Confirmez l\'adresse avec le patient si possible.';
  }

  @override
  String get hospitalDirections => 'Itinéraire';

  @override
  String get hospitalActionAccept => 'Accepter';

  @override
  String get hospitalActionReject => 'Refuser';

  @override
  String get hospitalActionStart => 'Démarrer';

  @override
  String get hospitalActionComplete => 'Terminer';

  @override
  String get hospitalSheetAcceptTitle => 'Accepter la demande';

  @override
  String get hospitalSheetRejectTitle => 'Refuser la demande';

  @override
  String get hospitalSheetStartTitle => 'Intervention en cours';

  @override
  String get hospitalSheetCompleteTitle => 'Terminer l\'intervention';

  @override
  String get hospitalSheetBody => 'Le patient verra ce changement et votre message sur son écran de suivi.';

  @override
  String get hospitalMessageLabel => 'Message pour le patient';

  @override
  String get hospitalMessageHintOptional => 'Facultatif : ex. « Ambulance en route, arrivée dans 10 min »';

  @override
  String get hospitalMessageHintRequired => 'Obligatoire : raison du refus et conseil au patient';

  @override
  String get hospitalMessageRequired => 'Un message est obligatoire pour refuser une demande.';

  @override
  String hospitalDecisionSaved(String status) {
    return 'Décision enregistrée : $status.';
  }

  @override
  String get hospitalDecisionConflict =>
      'La demande a changé entre-temps (annulée par le patient ou traitée par un collègue). Elle a été rechargée.';

  @override
  String get hospitalNoAction => 'Demande clôturée : aucune action possible.';
}
