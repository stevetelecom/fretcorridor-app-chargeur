import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('fr'),
    Locale('en'),
  ];

  /// No description provided for @login.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get login;

  /// No description provided for @phoneLabel.
  ///
  /// In fr, this message translates to:
  /// **'Telephone'**
  String get phoneLabel;

  /// No description provided for @phoneRequired.
  ///
  /// In fr, this message translates to:
  /// **'Numero de telephone requis'**
  String get phoneRequired;

  /// No description provided for @pinLabel.
  ///
  /// In fr, this message translates to:
  /// **'Code PIN (4 a 6 chiffres)'**
  String get pinLabel;

  /// No description provided for @createAccount.
  ///
  /// In fr, this message translates to:
  /// **'Creer un compte'**
  String get createAccount;

  /// No description provided for @createMyAccountButton.
  ///
  /// In fr, this message translates to:
  /// **'Creer mon compte'**
  String get createMyAccountButton;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In fr, this message translates to:
  /// **'Deja un compte ? Se connecter'**
  String get alreadyHaveAccount;

  /// No description provided for @back.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get back;

  /// No description provided for @loginSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Connexion reussie'**
  String get loginSuccess;

  /// No description provided for @loginError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de connexion.'**
  String get loginError;

  /// No description provided for @registerSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Compte cree avec succes'**
  String get registerSuccess;

  /// No description provided for @registerError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'inscription.'**
  String get registerError;

  /// No description provided for @quickRegisterBanner.
  ///
  /// In fr, this message translates to:
  /// **'Inscription rapide - vous pourrez completer votre profil plus tard.'**
  String get quickRegisterBanner;

  /// No description provided for @individualAccountType.
  ///
  /// In fr, this message translates to:
  /// **'Particulier'**
  String get individualAccountType;

  /// No description provided for @companyAccountType.
  ///
  /// In fr, this message translates to:
  /// **'Entreprise'**
  String get companyAccountType;

  /// No description provided for @companyNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Raison sociale'**
  String get companyNameLabel;

  /// No description provided for @companyNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'La raison sociale est requise'**
  String get companyNameRequired;

  /// No description provided for @firstNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Prenom'**
  String get firstNameLabel;

  /// No description provided for @firstNameContactLabel.
  ///
  /// In fr, this message translates to:
  /// **'Prenom du contact'**
  String get firstNameContactLabel;

  /// No description provided for @firstNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le prenom est requis'**
  String get firstNameRequired;

  /// No description provided for @lastNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get lastNameLabel;

  /// No description provided for @lastNameContactLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom du contact'**
  String get lastNameContactLabel;

  /// No description provided for @lastNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le nom est requis'**
  String get lastNameRequired;

  /// No description provided for @onboardingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vos envois,\nsans complications'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Publiez votre demande de transport et connectez-vous aux transporteurs du corridor CEMAC, en toute simplicite.'**
  String get onboardingSubtitle;

  /// No description provided for @start.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get start;

  /// No description provided for @alreadyAccountOnboarding.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez deja un compte ? '**
  String get alreadyAccountOnboarding;

  /// No description provided for @loginLink.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get loginLink;

  /// No description provided for @showPin.
  ///
  /// In fr, this message translates to:
  /// **'Afficher le code'**
  String get showPin;

  /// No description provided for @hidePin.
  ///
  /// In fr, this message translates to:
  /// **'Masquer le code'**
  String get hidePin;

  /// No description provided for @pinRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le code PIN est requis'**
  String get pinRequired;

  /// No description provided for @pinInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Le code PIN doit contenir entre 4 et 6 chiffres'**
  String get pinInvalid;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
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
