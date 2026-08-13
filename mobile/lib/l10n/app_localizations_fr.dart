// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get login => 'Se connecter';

  @override
  String get phoneLabel => 'Telephone';

  @override
  String get phoneRequired => 'Numero de telephone requis';

  @override
  String get pinLabel => 'Code PIN (4 a 6 chiffres)';

  @override
  String get createAccount => 'Creer un compte';

  @override
  String get createMyAccountButton => 'Creer mon compte';

  @override
  String get alreadyHaveAccount => 'Deja un compte ? Se connecter';

  @override
  String get back => 'Retour';

  @override
  String get loginSuccess => 'Connexion reussie';

  @override
  String get loginError => 'Erreur de connexion.';

  @override
  String get registerSuccess => 'Compte cree avec succes';

  @override
  String get registerError => 'Erreur lors de l\'inscription.';

  @override
  String get quickRegisterBanner =>
      'Inscription rapide - vous pourrez completer votre profil plus tard.';

  @override
  String get individualAccountType => 'Particulier';

  @override
  String get companyAccountType => 'Entreprise';

  @override
  String get companyNameLabel => 'Raison sociale';

  @override
  String get companyNameRequired => 'La raison sociale est requise';

  @override
  String get firstNameLabel => 'Prenom';

  @override
  String get firstNameContactLabel => 'Prenom du contact';

  @override
  String get firstNameRequired => 'Le prenom est requis';

  @override
  String get lastNameLabel => 'Nom';

  @override
  String get lastNameContactLabel => 'Nom du contact';

  @override
  String get lastNameRequired => 'Le nom est requis';

  @override
  String get onboardingTitle => 'Vos envois,\nsans complications';

  @override
  String get onboardingSubtitle =>
      'Publiez votre demande de transport et connectez-vous aux transporteurs du corridor CEMAC, en toute simplicite.';

  @override
  String get start => 'Commencer';

  @override
  String get alreadyAccountOnboarding => 'Vous avez deja un compte ? ';

  @override
  String get loginLink => 'Connexion';

  @override
  String get showPin => 'Afficher le code';

  @override
  String get hidePin => 'Masquer le code';

  @override
  String get pinRequired => 'Le code PIN est requis';

  @override
  String get pinInvalid => 'Le code PIN doit contenir entre 4 et 6 chiffres';
}
