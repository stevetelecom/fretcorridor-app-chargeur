import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_toast.dart';
import 'features/auth/providers/session_provider.dart';

/// Accueil provisoire - liste des demandes et historique arrivent au
/// Sprint 6 (plan §4). Pour l'instant : acces a la publication d'une
/// demande et deconnexion.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final user = session.valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FretCorridor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: () async {
              await ref.read(sessionProvider.notifier).logout();
              if (context.mounted) {
                AppToast.success('Déconnexion réussie');
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_shipping_outlined, size: 64, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                user != null ? 'Bonjour ${user.firstName}' : 'Bienvenue',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => context.go('/shipment/new'),
                icon: const Icon(Icons.add),
                label: const Text('Publier une demande'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
