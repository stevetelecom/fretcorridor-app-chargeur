import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/auth/providers/session_provider.dart';
import 'features/shipment_request/presentation/shipment_wizard_screen.dart';
import 'features/offers/presentation/offers_screen.dart';
import 'home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Requis avant toute ouverture de Box (DraftStorageService) - stocke le
  // brouillon de demande en local pour resister aux coupures reseau
  // (UC-MKT-01 E4).
  await Hive.initFlutter();

  runApp(const ProviderScope(child: FretCorridorApp()));
}

/// Redirection centrale : les ecrans proteges (home, nouvelle demande)
/// exigent une session active ; login/register restent accessibles sans
/// session. Evite de dupliquer ce controle dans chaque ecran.
class FretCorridorApp extends ConsumerWidget {
  const FretCorridorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter(
      initialLocation: '/login',
      redirect: (context, state) {
        final session = ref.read(sessionProvider);
        final isLoggedIn = session.valueOrNull != null;
        final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';

        if (!isLoggedIn && !isAuthRoute) return '/login';
        if (isLoggedIn && isAuthRoute) return '/home';
        return null;
      },
      routes: [
        GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
        GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(path: '/shipment/new', builder: (context, state) => const ShipmentWizardScreen()),
        GoRoute(
          path: '/shipment/:id/offers',
          builder: (context, state) => OffersScreen(shipmentRequestId: state.pathParameters['id']!),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'FretCorridor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}
