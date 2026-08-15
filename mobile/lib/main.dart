import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/providers/locale_provider.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/auth/providers/session_provider.dart';
import 'features/shipment_request/presentation/shipment_wizard_screen.dart';
import 'features/offers/presentation/offers_screen.dart';
import 'features/payment/presentation/payment_screen.dart';
import 'features/tracking/presentation/tracking_screen.dart';
import 'features/history/presentation/history_screen.dart';
import 'core/widgets/splash_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Requis avant toute ouverture de Box (DraftStorageService) - stocke le
  // brouillon de demande en local pour resister aux coupures reseau
  // (UC-MKT-01 E4).
  await Hive.initFlutter();
  await Hive.openBox(OnboardingScreen.hiveBoxName);

  runApp(const ProviderScope(child: FretCorridorApp()));
}

/// Redirection centrale : les ecrans proteges (home, nouvelle demande)
/// exigent une session active ; login/register restent accessibles sans
/// session. Evite de dupliquer ce controle dans chaque ecran.
///
/// ConsumerStatefulWidget + GoRouter construit une seule fois dans
/// initState (et non dans build()) : le router NE DOIT PAS etre recree a
/// chaque rebuild, sinon chaque changement de locale (qui declenche un
/// rebuild via ref.watch(localeProvider) plus bas) regenererait un routeur
/// tout neuf et ecraserait la position de navigation en cours - c'etait le
/// bug observe ou changer de langue renvoyait vers /login. Le controle de
/// session (isLoggedIn) reste dynamique via ref.read (relu a chaque
/// redirect(), pas fige a la construction).
class FretCorridorApp extends ConsumerStatefulWidget {
  const FretCorridorApp({super.key});

  @override
  ConsumerState<FretCorridorApp> createState() => _FretCorridorAppState();
}

class _FretCorridorAppState extends ConsumerState<FretCorridorApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      // Le splash (reveil backend, cold start Render) precede toujours
      // l'onboarding - il gere lui-meme la redirection une fois le
      // backend confirme pret (voir SplashScreen._goNext).
      initialLocation: '/splash',
      redirect: (context, state) {
        final session = ref.read(sessionProvider);
        final isLoggedIn = session.valueOrNull != null;
        final isAuthRoute =
            state.matchedLocation == '/login' ||
            state.matchedLocation == '/register';
        final isOnboardingRoute = state.matchedLocation == '/onboarding';
        final isSplashRoute = state.matchedLocation == '/splash';

        if (isSplashRoute || isOnboardingRoute) return null;
        if (!isLoggedIn && !isAuthRoute) return '/login';
        if (isLoggedIn && isAuthRoute) return '/home';
        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/shipment/new',
          builder: (context, state) => const ShipmentWizardScreen(),
        ),
        GoRoute(
          path: '/shipment/:id/offers',
          builder: (context, state) =>
              OffersScreen(shipmentRequestId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/shipment/:id/payment',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            return PaymentScreen(
              shipmentRequestId: state.pathParameters['id']!,
              offerId: extra['offerId'] as String,
              carrierName: extra['carrierName'] as String,
              amountXaf: extra['amountXaf'] as double,
            );
          },
        ),
        GoRoute(
          path: '/shipment/:id/tracking',
          builder: (context, state) =>
              TrackingScreen(shipmentRequestId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) => const HistoryScreen(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FretCorridor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      // Bilingue FR/EN (Sprint 7) - genere par flutter gen-l10n depuis
      // lib/l10n/app_fr.arb et app_en.arb (voir l10n.yaml a la racine du
      // module mobile). Le francais est la langue source (template-arb-file)
      // et sert de repli si la locale de l'appareil n'est ni fr ni en.
      // ref.watch ici ne reconstruit QUE MaterialApp.router (locale/theme),
      // plus jamais _router lui-meme (construit une seule fois ci-dessus).
      locale: ref.watch(localeProvider),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _router,
    );
  }
}
