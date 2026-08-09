import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/pin_field.dart';
import '../providers/session_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController(text: '+237');
  final _pinController = TextEditingController();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(sessionProvider.notifier).login(
          phoneNumber: _phoneController.text.trim(),
          pin: _pinController.text.trim(),
        );

    if (!mounted) return;
    final state = ref.read(sessionProvider);
    state.whenOrNull(
      data: (user) {
        if (user != null) {
          AppToast.success('Connexion reussie');
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
    return 'Erreur de connexion.';
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset('assets/images/logo.jpeg', height: 72),
                  const SizedBox(height: 24),
                  Text('Se connecter', style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Telephone', prefixIcon: Icon(Icons.phone_outlined)),
                    validator: (v) {
                      if (v == null || !RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(v)) {
                        return 'Format international requis, ex: +237654862989';
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
                            height: 20, width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Se connecter'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.go('/register'),
                    child: const Text('Creer un compte'),
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
