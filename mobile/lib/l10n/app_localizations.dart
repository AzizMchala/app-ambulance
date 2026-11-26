import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('fr')];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'Urgences'**
  String get appTitle;

  /// No description provided for @commonRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get commonRetry;

  /// No description provided for @commonCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get commonCancel;

  /// No description provided for @commonClose.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get commonClose;

  /// No description provided for @commonSeeDetails.
  ///
  /// In fr, this message translates to:
  /// **'Voir les détails'**
  String get commonSeeDetails;

  /// No description provided for @errorNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Pas de connexion au serveur. Vérifiez votre réseau.'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In fr, this message translates to:
  /// **'Le serveur met trop de temps à répondre.'**
  String get errorTimeout;

  /// No description provided for @errorUnauthenticated.
  ///
  /// In fr, this message translates to:
  /// **'Votre session a expiré. Reconnectez-vous.'**
  String get errorUnauthenticated;

  /// No description provided for @errorForbidden.
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'avez pas accès à cette ressource.'**
  String get errorForbidden;

  /// No description provided for @errorNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Élément introuvable.'**
  String get errorNotFound;

  /// No description provided for @errorValidation.
  ///
  /// In fr, this message translates to:
  /// **'Certaines informations sont invalides.'**
  String get errorValidation;

  /// No description provided for @errorServer.
  ///
  /// In fr, this message translates to:
  /// **'Le serveur a rencontré une erreur. Réessayez dans un instant.'**
  String get errorServer;

  /// No description provided for @errorUnexpected.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur inattendue est survenue.'**
  String get errorUnexpected;

  /// No description provided for @errorSosAlreadyActive.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez déjà une demande SOS en cours.'**
  String get errorSosAlreadyActive;

  /// No description provided for @errorInvalidTransition.
  ///
  /// In fr, this message translates to:
  /// **'Cette demande ne peut plus être modifiée.'**
  String get errorInvalidTransition;

  /// No description provided for @authLoginTitle.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get authLoginTitle;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Accédez à votre espace.'**
  String get authLoginSubtitle;

  /// No description provided for @authEmail.
  ///
  /// In fr, this message translates to:
  /// **'Adresse e-mail'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get authPassword;

  /// No description provided for @authLoginAction.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get authLoginAction;

  /// No description provided for @authNoAccount.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de compte ?'**
  String get authNoAccount;

  /// No description provided for @authCreateAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get authCreateAccount;

  /// No description provided for @authRegisterTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get authRegisterTitle;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Quelques informations pour vous identifier auprès des secours.'**
  String get authRegisterSubtitle;

  /// No description provided for @authFullName.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get authFullName;

  /// No description provided for @authRegisterAction.
  ///
  /// In fr, this message translates to:
  /// **'Créer mon compte'**
  String get authRegisterAction;

  /// No description provided for @authHaveAccount.
  ///
  /// In fr, this message translates to:
  /// **'Déjà inscrit ?'**
  String get authHaveAccount;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In fr, this message translates to:
  /// **'E-mail ou mot de passe incorrect.'**
  String get authInvalidCredentials;

  /// No description provided for @authEmailTaken.
  ///
  /// In fr, this message translates to:
  /// **'Cette adresse e-mail est déjà utilisée.'**
  String get authEmailTaken;

  /// No description provided for @authEmailInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Adresse e-mail invalide.'**
  String get authEmailInvalid;

  /// No description provided for @authPasswordTooShort.
  ///
  /// In fr, this message translates to:
  /// **'8 caractères minimum.'**
  String get authPasswordTooShort;

  /// No description provided for @authFieldRequired.
  ///
  /// In fr, this message translates to:
  /// **'Champ obligatoire.'**
  String get authFieldRequired;

  /// No description provided for @authLogout.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get authLogout;

  /// No description provided for @sosHomeGreeting.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour {name}'**
  String sosHomeGreeting(String name);

  /// No description provided for @sosHomeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Besoin d\'une aide médicale ?'**
  String get sosHomeTitle;

  /// No description provided for @sosHomeSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Rien n\'est envoyé sans votre confirmation.'**
  String get sosHomeSubtitle;

  /// No description provided for @sosButtonLabel.
  ///
  /// In fr, this message translates to:
  /// **'SOS'**
  String get sosButtonLabel;

  /// No description provided for @sosButtonHint.
  ///
  /// In fr, this message translates to:
  /// **'Préparer une alerte'**
  String get sosButtonHint;

  /// No description provided for @sosButtonSemantics.
  ///
  /// In fr, this message translates to:
  /// **'Bouton SOS. Ouvre la vérification de l\'alerte avant envoi.'**
  String get sosButtonSemantics;

  /// No description provided for @locationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre position'**
  String get locationTitle;

  /// No description provided for @locationChecking.
  ///
  /// In fr, this message translates to:
  /// **'Vérification de la localisation…'**
  String get locationChecking;

  /// No description provided for @locationAcquiring.
  ///
  /// In fr, this message translates to:
  /// **'Recherche du signal GPS…'**
  String get locationAcquiring;

  /// No description provided for @locationReady.
  ///
  /// In fr, this message translates to:
  /// **'Position GPS disponible'**
  String get locationReady;

  /// No description provided for @locationAccuracy.
  ///
  /// In fr, this message translates to:
  /// **'Précision ± {meters} m'**
  String locationAccuracy(int meters);

  /// No description provided for @locationStale.
  ///
  /// In fr, this message translates to:
  /// **'Position ancienne'**
  String get locationStale;

  /// No description provided for @locationStaleAge.
  ///
  /// In fr, this message translates to:
  /// **'Relevée il y a {minutes} min : elle n\'est peut-être plus exacte.'**
  String locationStaleAge(int minutes);

  /// No description provided for @locationServiceOff.
  ///
  /// In fr, this message translates to:
  /// **'La localisation est désactivée'**
  String get locationServiceOff;

  /// No description provided for @locationServiceOffHint.
  ///
  /// In fr, this message translates to:
  /// **'Activez-la pour joindre votre position à l\'alerte.'**
  String get locationServiceOffHint;

  /// No description provided for @locationPermissionNeeded.
  ///
  /// In fr, this message translates to:
  /// **'Autorisation nécessaire'**
  String get locationPermissionNeeded;

  /// No description provided for @locationPermissionNeededHint.
  ///
  /// In fr, this message translates to:
  /// **'Votre position aide les secours à vous trouver plus vite.'**
  String get locationPermissionNeededHint;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In fr, this message translates to:
  /// **'Accès à la position refusé'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionDeniedForeverHint.
  ///
  /// In fr, this message translates to:
  /// **'Autorisez la localisation dans les réglages, ou saisissez votre adresse.'**
  String get locationPermissionDeniedForeverHint;

  /// No description provided for @locationTimeout.
  ///
  /// In fr, this message translates to:
  /// **'Aucun signal GPS pour l\'instant'**
  String get locationTimeout;

  /// No description provided for @locationTimeoutHint.
  ///
  /// In fr, this message translates to:
  /// **'Rapprochez-vous d\'une fenêtre, réessayez ou saisissez votre adresse.'**
  String get locationTimeoutHint;

  /// No description provided for @locationError.
  ///
  /// In fr, this message translates to:
  /// **'Localisation indisponible'**
  String get locationError;

  /// No description provided for @locationErrorHint.
  ///
  /// In fr, this message translates to:
  /// **'Vous pouvez saisir votre adresse à la place.'**
  String get locationErrorHint;

  /// No description provided for @locationActionEnable.
  ///
  /// In fr, this message translates to:
  /// **'Activer'**
  String get locationActionEnable;

  /// No description provided for @locationActionAllow.
  ///
  /// In fr, this message translates to:
  /// **'Autoriser'**
  String get locationActionAllow;

  /// No description provided for @locationActionSettings.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get locationActionSettings;

  /// No description provided for @locationActionRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get locationActionRetry;

  /// No description provided for @locationActionRefresh.
  ///
  /// In fr, this message translates to:
  /// **'Actualiser la position'**
  String get locationActionRefresh;

  /// No description provided for @locationSourceGps.
  ///
  /// In fr, this message translates to:
  /// **'GPS en direct'**
  String get locationSourceGps;

  /// No description provided for @locationSourceLastKnown.
  ///
  /// In fr, this message translates to:
  /// **'Dernière position connue'**
  String get locationSourceLastKnown;

  /// No description provided for @locationSourceManual.
  ///
  /// In fr, this message translates to:
  /// **'Adresse saisie'**
  String get locationSourceManual;

  /// No description provided for @locationCoordinates.
  ///
  /// In fr, this message translates to:
  /// **'Coordonnées'**
  String get locationCoordinates;

  /// No description provided for @locationCapturedAt.
  ///
  /// In fr, this message translates to:
  /// **'Relevée à {time}'**
  String locationCapturedAt(String time);

  /// No description provided for @locationMapUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Carte indisponible sans position GPS'**
  String get locationMapUnavailable;

  /// No description provided for @latestTitle.
  ///
  /// In fr, this message translates to:
  /// **'Dernière demande'**
  String get latestTitle;

  /// No description provided for @latestEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune demande envoyée pour l\'instant.'**
  String get latestEmpty;

  /// No description provided for @homeHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get homeHistory;

  /// No description provided for @homeHistoryHint.
  ///
  /// In fr, this message translates to:
  /// **'Toutes vos demandes'**
  String get homeHistoryHint;

  /// No description provided for @homeCall.
  ///
  /// In fr, this message translates to:
  /// **'Appeler le {number}'**
  String homeCall(String number);

  /// No description provided for @homeCallHint.
  ///
  /// In fr, this message translates to:
  /// **'SAMU, même sans Internet'**
  String get homeCallHint;

  /// No description provided for @reviewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier l\'alerte'**
  String get reviewTitle;

  /// No description provided for @reviewIntro.
  ///
  /// In fr, this message translates to:
  /// **'Contrôlez votre localisation avant d\'envoyer.'**
  String get reviewIntro;

  /// No description provided for @reviewAddressLabel.
  ///
  /// In fr, this message translates to:
  /// **'Adresse ou repère'**
  String get reviewAddressLabel;

  /// No description provided for @reviewAddressHintGps.
  ///
  /// In fr, this message translates to:
  /// **'Facultatif : étage, bâtiment, repère…'**
  String get reviewAddressHintGps;

  /// No description provided for @reviewAddressHintRequired.
  ///
  /// In fr, this message translates to:
  /// **'Rue, ville, repère visible…'**
  String get reviewAddressHintRequired;

  /// No description provided for @reviewAddressRequired.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez une adresse : aucune position GPS utilisable.'**
  String get reviewAddressRequired;

  /// No description provided for @reviewAddressTooShort.
  ///
  /// In fr, this message translates to:
  /// **'Adresse trop courte (5 caractères minimum).'**
  String get reviewAddressTooShort;

  /// No description provided for @reviewUseStale.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer quand même cette position ancienne'**
  String get reviewUseStale;

  /// No description provided for @reviewNoCoordinates.
  ///
  /// In fr, this message translates to:
  /// **'Aucune coordonnée GPS ne sera envoyée : l\'adresse saisie sera la seule localisation.'**
  String get reviewNoCoordinates;

  /// No description provided for @reviewSend.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer l\'alerte SOS'**
  String get reviewSend;

  /// No description provided for @reviewSending.
  ///
  /// In fr, this message translates to:
  /// **'Envoi en cours…'**
  String get reviewSending;

  /// No description provided for @confirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer l\'alerte ?'**
  String get confirmTitle;

  /// No description provided for @confirmBody.
  ///
  /// In fr, this message translates to:
  /// **'Votre demande sera transmise aux secours avec la localisation ci-dessous.'**
  String get confirmBody;

  /// No description provided for @confirmSend.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get confirmSend;

  /// No description provided for @sendFailedTitle.
  ///
  /// In fr, this message translates to:
  /// **'L\'alerte n\'a pas été envoyée'**
  String get sendFailedTitle;

  /// No description provided for @sendFailedNetworkHint.
  ///
  /// In fr, this message translates to:
  /// **'Si c\'est urgent, appelez directement le {number}.'**
  String sendFailedNetworkHint(String number);

  /// No description provided for @sendViewActive.
  ///
  /// In fr, this message translates to:
  /// **'Voir la demande en cours'**
  String get sendViewActive;

  /// No description provided for @sentBanner.
  ///
  /// In fr, this message translates to:
  /// **'Alerte enregistrée par le serveur. Les secours ont reçu votre demande.'**
  String get sentBanner;

  /// No description provided for @historyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get historyTitle;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune demande'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptyBody.
  ///
  /// In fr, this message translates to:
  /// **'Vos demandes SOS apparaîtront ici dès leur envoi.'**
  String get historyEmptyBody;

  /// No description provided for @historyLoadMoreError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger la suite.'**
  String get historyLoadMoreError;

  /// No description provided for @requestNumber.
  ///
  /// In fr, this message translates to:
  /// **'Demande n° {id}'**
  String requestNumber(int id);

  /// No description provided for @statusPending.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get statusPending;

  /// No description provided for @statusAccepted.
  ///
  /// In fr, this message translates to:
  /// **'Acceptée'**
  String get statusAccepted;

  /// No description provided for @statusInProgress.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get statusInProgress;

  /// No description provided for @statusCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Terminée'**
  String get statusCompleted;

  /// No description provided for @statusRejected.
  ///
  /// In fr, this message translates to:
  /// **'Refusée'**
  String get statusRejected;

  /// No description provided for @statusCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulée'**
  String get statusCancelled;

  /// No description provided for @statusUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Inconnu'**
  String get statusUnknown;

  /// No description provided for @statusHeadlinePending.
  ///
  /// In fr, this message translates to:
  /// **'En attente de décision'**
  String get statusHeadlinePending;

  /// No description provided for @statusHeadlineAccepted.
  ///
  /// In fr, this message translates to:
  /// **'Demande acceptée'**
  String get statusHeadlineAccepted;

  /// No description provided for @statusHeadlineInProgress.
  ///
  /// In fr, this message translates to:
  /// **'Prise en charge en cours'**
  String get statusHeadlineInProgress;

  /// No description provided for @statusHeadlineCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Intervention terminée'**
  String get statusHeadlineCompleted;

  /// No description provided for @statusHeadlineRejected.
  ///
  /// In fr, this message translates to:
  /// **'Demande refusée'**
  String get statusHeadlineRejected;

  /// No description provided for @statusHeadlineCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Demande annulée'**
  String get statusHeadlineCancelled;

  /// No description provided for @statusHeadlineUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Statut non reconnu par l\'application'**
  String get statusHeadlineUnknown;

  /// No description provided for @detailDecision.
  ///
  /// In fr, this message translates to:
  /// **'Décision'**
  String get detailDecision;

  /// No description provided for @detailNoDecision.
  ///
  /// In fr, this message translates to:
  /// **'Aucune décision reçue pour l\'instant.'**
  String get detailNoDecision;

  /// No description provided for @detailDecisionMessage.
  ///
  /// In fr, this message translates to:
  /// **'Message des secours'**
  String get detailDecisionMessage;

  /// No description provided for @detailNoDecisionMessage.
  ///
  /// In fr, this message translates to:
  /// **'Aucun message n\'accompagne cette décision.'**
  String get detailNoDecisionMessage;

  /// No description provided for @detailLocation.
  ///
  /// In fr, this message translates to:
  /// **'Localisation'**
  String get detailLocation;

  /// No description provided for @detailInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations'**
  String get detailInfo;

  /// No description provided for @detailId.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant'**
  String get detailId;

  /// No description provided for @detailDate.
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get detailDate;

  /// No description provided for @detailTime.
  ///
  /// In fr, this message translates to:
  /// **'Heure'**
  String get detailTime;

  /// No description provided for @detailUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Dernière mise à jour'**
  String get detailUpdated;

  /// No description provided for @detailCapturedAt.
  ///
  /// In fr, this message translates to:
  /// **'Position relevée'**
  String get detailCapturedAt;

  /// No description provided for @detailTimeline.
  ///
  /// In fr, this message translates to:
  /// **'Suivi du statut'**
  String get detailTimeline;

  /// No description provided for @detailTimelineEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun changement de statut enregistré.'**
  String get detailTimelineEmpty;

  /// No description provided for @detailAutoRefresh.
  ///
  /// In fr, this message translates to:
  /// **'Actualisation automatique'**
  String get detailAutoRefresh;

  /// No description provided for @detailUpdatedAt.
  ///
  /// In fr, this message translates to:
  /// **'Mis à jour {when}'**
  String detailUpdatedAt(String when);

  /// No description provided for @detailCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler la demande'**
  String get detailCancel;

  /// No description provided for @detailCancelTitle.
  ///
  /// In fr, this message translates to:
  /// **'Annuler cette demande ?'**
  String get detailCancelTitle;

  /// No description provided for @detailCancelBody.
  ///
  /// In fr, this message translates to:
  /// **'Les secours sauront que vous n\'avez plus besoin d\'aide.'**
  String get detailCancelBody;

  /// No description provided for @detailCancelConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Oui, annuler'**
  String get detailCancelConfirm;

  /// No description provided for @detailKeep.
  ///
  /// In fr, this message translates to:
  /// **'Garder'**
  String get detailKeep;

  /// No description provided for @detailCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Demande annulée.'**
  String get detailCancelled;

  /// No description provided for @detailRefreshFailed.
  ///
  /// In fr, this message translates to:
  /// **'Actualisation impossible : les informations affichées peuvent être anciennes.'**
  String get detailRefreshFailed;

  /// No description provided for @relativeNow.
  ///
  /// In fr, this message translates to:
  /// **'à l\'instant'**
  String get relativeNow;

  /// No description provided for @relativeMinutes.
  ///
  /// In fr, this message translates to:
  /// **'il y a {n} min'**
  String relativeMinutes(int n);

  /// No description provided for @relativeHours.
  ///
  /// In fr, this message translates to:
  /// **'il y a {n} h'**
  String relativeHours(int n);

  /// No description provided for @relativeAt.
  ///
  /// In fr, this message translates to:
  /// **'le {date}'**
  String relativeAt(String date);

  /// No description provided for @roleHospital.
  ///
  /// In fr, this message translates to:
  /// **'Espace hôpital'**
  String get roleHospital;

  /// No description provided for @hospitalGreeting.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour {name}'**
  String hospitalGreeting(String name);

  /// No description provided for @hospitalTitle.
  ///
  /// In fr, this message translates to:
  /// **'Demandes SOS'**
  String get hospitalTitle;

  /// No description provided for @hospitalSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Actualisation automatique toutes les 15 secondes.'**
  String get hospitalSubtitle;

  /// No description provided for @hospitalTabToHandle.
  ///
  /// In fr, this message translates to:
  /// **'À traiter'**
  String get hospitalTabToHandle;

  /// No description provided for @hospitalTabOngoing.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get hospitalTabOngoing;

  /// No description provided for @hospitalTabClosed.
  ///
  /// In fr, this message translates to:
  /// **'Clôturées'**
  String get hospitalTabClosed;

  /// No description provided for @hospitalEmptyToHandle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune demande en attente.'**
  String get hospitalEmptyToHandle;

  /// No description provided for @hospitalEmptyOngoing.
  ///
  /// In fr, this message translates to:
  /// **'Aucune intervention en cours.'**
  String get hospitalEmptyOngoing;

  /// No description provided for @hospitalEmptyClosed.
  ///
  /// In fr, this message translates to:
  /// **'Aucune demande clôturée.'**
  String get hospitalEmptyClosed;

  /// No description provided for @hospitalEmptyBody.
  ///
  /// In fr, this message translates to:
  /// **'Les nouvelles alertes apparaîtront ici automatiquement.'**
  String get hospitalEmptyBody;

  /// No description provided for @hospitalPatient.
  ///
  /// In fr, this message translates to:
  /// **'Patient'**
  String get hospitalPatient;

  /// No description provided for @hospitalPatientId.
  ///
  /// In fr, this message translates to:
  /// **'Dossier patient n° {id}'**
  String hospitalPatientId(int id);

  /// No description provided for @hospitalStaleWarning.
  ///
  /// In fr, this message translates to:
  /// **'Position ancienne : relevée {when}. Confirmez l\'adresse avec le patient si possible.'**
  String hospitalStaleWarning(String when);

  /// No description provided for @hospitalDirections.
  ///
  /// In fr, this message translates to:
  /// **'Itinéraire'**
  String get hospitalDirections;

  /// No description provided for @hospitalActionAccept.
  ///
  /// In fr, this message translates to:
  /// **'Accepter'**
  String get hospitalActionAccept;

  /// No description provided for @hospitalActionReject.
  ///
  /// In fr, this message translates to:
  /// **'Refuser'**
  String get hospitalActionReject;

  /// No description provided for @hospitalActionStart.
  ///
  /// In fr, this message translates to:
  /// **'Démarrer'**
  String get hospitalActionStart;

  /// No description provided for @hospitalActionComplete.
  ///
  /// In fr, this message translates to:
  /// **'Terminer'**
  String get hospitalActionComplete;

  /// No description provided for @hospitalSheetAcceptTitle.
  ///
  /// In fr, this message translates to:
  /// **'Accepter la demande'**
  String get hospitalSheetAcceptTitle;

  /// No description provided for @hospitalSheetRejectTitle.
  ///
  /// In fr, this message translates to:
  /// **'Refuser la demande'**
  String get hospitalSheetRejectTitle;

  /// No description provided for @hospitalSheetStartTitle.
  ///
  /// In fr, this message translates to:
  /// **'Intervention en cours'**
  String get hospitalSheetStartTitle;

  /// No description provided for @hospitalSheetCompleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Terminer l\'intervention'**
  String get hospitalSheetCompleteTitle;

  /// No description provided for @hospitalSheetBody.
  ///
  /// In fr, this message translates to:
  /// **'Le patient verra ce changement et votre message sur son écran de suivi.'**
  String get hospitalSheetBody;

  /// No description provided for @hospitalMessageLabel.
  ///
  /// In fr, this message translates to:
  /// **'Message pour le patient'**
  String get hospitalMessageLabel;

  /// No description provided for @hospitalMessageHintOptional.
  ///
  /// In fr, this message translates to:
  /// **'Facultatif : ex. « Ambulance en route, arrivée dans 10 min »'**
  String get hospitalMessageHintOptional;

  /// No description provided for @hospitalMessageHintRequired.
  ///
  /// In fr, this message translates to:
  /// **'Obligatoire : raison du refus et conseil au patient'**
  String get hospitalMessageHintRequired;

  /// No description provided for @hospitalMessageRequired.
  ///
  /// In fr, this message translates to:
  /// **'Un message est obligatoire pour refuser une demande.'**
  String get hospitalMessageRequired;

  /// No description provided for @hospitalDecisionSaved.
  ///
  /// In fr, this message translates to:
  /// **'Décision enregistrée : {status}.'**
  String hospitalDecisionSaved(String status);

  /// No description provided for @hospitalDecisionConflict.
  ///
  /// In fr, this message translates to:
  /// **'La demande a changé entre-temps (annulée par le patient ou traitée par un collègue). Elle a été rechargée.'**
  String get hospitalDecisionConflict;

  /// No description provided for @hospitalNoAction.
  ///
  /// In fr, this message translates to:
  /// **'Demande clôturée : aucune action possible.'**
  String get hospitalNoAction;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
