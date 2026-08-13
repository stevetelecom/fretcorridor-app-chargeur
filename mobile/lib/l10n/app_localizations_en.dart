// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get login => 'Log in';

  @override
  String get phoneLabel => 'Phone number';

  @override
  String get phoneRequired => 'Phone number is required';

  @override
  String get pinLabel => 'PIN code (4 to 6 digits)';

  @override
  String get createAccount => 'Create an account';

  @override
  String get createMyAccountButton => 'Create my account';

  @override
  String get alreadyHaveAccount => 'Already have an account? Log in';

  @override
  String get back => 'Back';

  @override
  String get loginSuccess => 'Logged in successfully';

  @override
  String get loginError => 'Login error.';

  @override
  String get registerSuccess => 'Account created successfully';

  @override
  String get registerError => 'Error while creating the account.';

  @override
  String get quickRegisterBanner =>
      'Quick sign-up - you can complete your profile later.';

  @override
  String get individualAccountType => 'Individual';

  @override
  String get companyAccountType => 'Company';

  @override
  String get companyNameLabel => 'Company name';

  @override
  String get companyNameRequired => 'Company name is required';

  @override
  String get firstNameLabel => 'First name';

  @override
  String get firstNameContactLabel => 'Contact first name';

  @override
  String get firstNameRequired => 'First name is required';

  @override
  String get lastNameLabel => 'Last name';

  @override
  String get lastNameContactLabel => 'Contact last name';

  @override
  String get lastNameRequired => 'Last name is required';

  @override
  String get onboardingTitle => 'Your shipments,\nmade simple';

  @override
  String get onboardingSubtitle =>
      'Post your transport request and connect with carriers across the CEMAC corridor, with ease.';

  @override
  String get start => 'Get started';

  @override
  String get alreadyAccountOnboarding => 'Already have an account? ';

  @override
  String get loginLink => 'Log in';

  @override
  String get showPin => 'Show code';

  @override
  String get hidePin => 'Hide code';

  @override
  String get pinRequired => 'PIN code is required';

  @override
  String get pinInvalid => 'PIN code must be 4 to 6 digits';
}
