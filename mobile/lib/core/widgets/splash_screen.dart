import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/auth/providers/session_provider.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../theme/app_theme.dart';

/// Ecran affiche au tout premier lancement, avant onboarding/login : le
/// backend (plan gratuit Render) peut mettre jusqu'a 2-3 minutes a se
/// reveiller apres une periode d'inactivite. Sans cet ecran, le premier
/// essai d'un utilisateur (connexion ou inscription) echoue silencieusement
/// pendant ce reveil - ici on ping /actuator/health en boucle avec un
/// message clair, plutot que de laisser l'utilisateur taper ses
/// identifiants dans le vide.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  String _statusMessage = 'Connexion au serveur...';
  bool _showSlowHint = false;
  Timer? _slowHintTimer;

  @override
  void initState() {
    super.initState();
    // Au-dela de 8s, c'est probablement un reveil du backend (cold start
    // Render) plutot qu'un simple aller-retour reseau - on le dit
    // explicitement pour ne pas laisser croire a un blocage.
    _slowHintTimer = Timer(const Duration(seconds: 8), () {
      if (mounted) {
        setState(() {
          _showSlowHint = true;
          _statusMessage = 'Reveil du serveur en cours...\nCela peut prendre jusqu\'a 2 minutes.';
        });
      }
    });
    _pingUntilReady();
  }

  @override
  void dispose() {
    _slowHintTimer?.cancel();
    super.dispose();
  }

  Future<void> _pingUntilReady() async {
    final dio = ref.read(dioClientProvider);
    const maxAttempts = 30;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final response = await dio.get(
          '/actuator/health',
          options: Options(
            sendTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        );
        if (response.statusCode == 200) {
          _goNext();
          return;
        }
      } catch (_) {
        // Backend pas encore pret - on reessaie apres une courte pause.
      }
      await Future.delayed(const Duration(seconds: 3));
    }
    // Au-dela du nombre max de tentatives, on laisse quand meme passer -
    // l'utilisateur verra l'erreur normale de l'ecran de connexion plutot
    // que de rester bloque indefiniment sur ce splash.
    _goNext();
  }

  void _goNext() {
    if (!mounted) return;
    final seen = Hive.box(OnboardingScreen.hiveBoxName)
            .get(OnboardingScreen.seenKey, defaultValue: false) ==
        true;
    context.go(seen ? '/login' : '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/logo.jpeg', height: 72),
              const SizedBox(height: 32),
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 24),
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (_showSlowHint) ...[
                const SizedBox(height: 8),
                Text(
                  'Cela n\'arrive qu\'au premier lancement apres une pause.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
