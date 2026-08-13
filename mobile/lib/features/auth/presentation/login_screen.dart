import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/video_background_scaffold.dart';
import '../../../core/widgets/language_toggle.dart';
import '../../../core/widgets/pin_field.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/session_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _phoneNumber = '';
  final _pinController = TextEditingController();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(sessionProvider.notifier)
        .login(phoneNumber: _phoneNumber, pin: _pinController.text.trim());

    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final state = ref.read(sessionProvider);
    state.whenOrNull(
      data: (user) {
        if (user != null) {
          AppToast.success(l10n.loginSuccess);
          context.go('/home');
        }
      },
      error: (error, _) => AppToast.error(_readableError(error, l10n)),
    );
  }

  String _readableError(Object error, AppLocalizations l10n) {
    if (error is DioException && error.response?.data is Map) {
      final message = error.response!.data['message'];
      if (message is String) return message;
    }
    return l10n.loginError;
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionProvider);
    final l10n = AppLocalizations.of(context)!;

    return VideoBackgroundScaffold(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        tooltip: l10n.back,
        onPressed: () => context.go('/onboarding'),
      ),
      trailing: const LanguageToggle(),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 24, offset: Offset(0, 8)),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset('assets/images/logo.jpeg', height: 72),
                  const SizedBox(height: 24),
                  Text(
                    l10n.login,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  IntlPhoneField(
                    // Cameroun pre-selectionne par defaut (indicatif +237
                    // pre-rempli automatiquement) - reste ouvert a tous les
                    // pays de la zone CEMAC et au-dela via le selecteur.
                    initialCountryCode: 'CM',
                    decoration: InputDecoration(
                      labelText: l10n.phoneLabel,
                      prefixIcon: const Icon(Icons.phone_outlined),
                    ),
                    dropdownIconPosition: IconPosition.trailing,
                    onChanged: (phone) =>
                        _phoneNumber = phone.completeNumber,
                    validator: (phone) {
                      if (phone == null || phone.number.trim().isEmpty) {
                        return l10n.phoneRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  PinField(controller: _pinController),
                  const SizedBox(height: 24),
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
                        : Text(l10n.login),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.go('/register'),
                    child: Text(l10n.createAccount),
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
