import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/video_background_scaffold.dart';
import '../../../core/widgets/pin_field.dart';
import '../providers/session_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  // Raison sociale - affiche/valide uniquement quand _accountType ==
  // 'ENTREPRISE' (CDC UC-IDA-02 etape 1). NIU/forme juridique/pieces sont
  // completes plus tard dans le profil (inscription rapide, RG-012).
  final _companyNameController = TextEditingController();
  String _phoneNumber = '';
  final _pinController = TextEditingController();

  String _accountType = 'PARTICULIER';

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _companyNameController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(sessionProvider.notifier)
        .register(
          accountType: _accountType,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          phoneNumber: _phoneNumber,
          pin: _pinController.text.trim(),
          // Uniquement transmis pour une entreprise - null pour un
          // particulier (AuthApi.register l'omet du payload dans ce cas).
          companyName: _accountType == 'ENTREPRISE'
              ? _companyNameController.text.trim()
              : null,
        );

    if (!mounted) return;
    final state = ref.read(sessionProvider);
    state.whenOrNull(
      data: (user) {
        if (user != null) {
          AppToast.success('Compte cree avec succes');
          context.go('/home');
        }
      },
      error: (error, _) => AppToast.error(_readableError(error)),
    );
  }

  String _readableError(Object error) {
    if (error is DioException && error.response?.data is Map) {
      final message = error.response!.data['message'];
      if (message is String) return message;
    }
    return 'Erreur lors de l\'inscription.';
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionProvider);

    return VideoBackgroundScaffold(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        tooltip: 'Retour',
        onPressed: () => context.go('/login'),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Creer un compte',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.errorBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.errorBorder),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.primary),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Inscription rapide - vous pourrez completer votre profil plus tard.',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'PARTICULIER',
                        label: Text('Particulier'),
                      ),
                      ButtonSegment(
                        value: 'ENTREPRISE',
                        label: Text('Entreprise'),
                      ),
                    ],
                    selected: {_accountType},
                    onSelectionChanged: (selection) =>
                        setState(() => _accountType = selection.first),
                  ),
                  const SizedBox(height: 24),
                  // Champ specifique entreprise (CDC UC-IDA-02 etape 1) : seule
                  // vraie difference de flux entre les deux types de compte a
                  // ce stade d'inscription rapide.
                  if (_accountType == 'ENTREPRISE') ...[
                    TextFormField(
                      controller: _companyNameController,
                      decoration: const InputDecoration(
                        labelText: 'Raison sociale',
                        prefixIcon: Icon(Icons.apartment_outlined),
                      ),
                      validator: (v) =>
                          (_accountType == 'ENTREPRISE' &&
                              (v == null || v.trim().length < 2))
                          ? 'La raison sociale est requise'
                          : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      // Libelle contextuel : pour une entreprise, ce champ
                      // designe le contact, pas l'entite elle-meme.
                      labelText: _accountType == 'ENTREPRISE'
                          ? 'Prenom du contact'
                          : 'Prenom',
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    validator: (v) => (v == null || v.trim().length < 2)
                        ? 'Le prenom est requis'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: _accountType == 'ENTREPRISE'
                          ? 'Nom du contact'
                          : 'Nom',
                      prefixIcon: const Icon(Icons.badge_outlined),
                    ),
                    validator: (v) => (v == null || v.trim().length < 2)
                        ? 'Le nom est requis'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  IntlPhoneField(
                    initialCountryCode: 'CM',
                    decoration: const InputDecoration(labelText: 'Telephone'),
                    dropdownIconPosition: IconPosition.trailing,
                    onChanged: (phone) => _phoneNumber = phone.completeNumber,
                    validator: (phone) {
                      if (phone == null || phone.number.trim().isEmpty) {
                        return 'Numero de telephone requis';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  PinField(controller: _pinController),
                  if (sessionState.hasError) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.errorBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_readableError(sessionState.error!)),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: sessionState.isLoading ? null : _submit,
                    child: sessionState.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Creer mon compte'),
                  ),
                  const SizedBox(height: 12),
                  // Lien retour connexion - un utilisateur qui a deja un
                  // compte ne doit pas etre coince sur l'ecran d'inscription.
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Deja un compte ? Se connecter'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
