import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/settings_providers.dart';
import '../../features/calendar/calendar_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/summary/summary_screen.dart';
import '../../shared/widgets/scaffold_with_nav.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final settings = ref.read(settingsRepositoryProvider);
  return GoRouter(
    initialLocation: '/calendar',
    refreshListenable: settings,
    redirect: (context, state) {
      if (settings.onboardingComplete == null) return null;
      final onOnboarding = state.matchedLocation.startsWith('/onboarding');
      if (!settings.onboardingComplete! && !onOnboarding) return '/onboarding';
      if (settings.onboardingComplete! && onOnboarding) return '/calendar';
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ScaffoldWithNav(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/calendar', builder: (_, __) => const CalendarScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/summary', builder: (_, __) => const SummaryScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
          ]),
        ],
      ),
    ],
  );
});
