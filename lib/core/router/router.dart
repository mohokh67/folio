import 'package:go_router/go_router.dart';
import 'package:folio/features/calendar/calendar_screen.dart';
import 'package:folio/features/summary/summary_screen.dart';
import 'package:folio/features/settings/settings_screen.dart';
import 'package:folio/shared/widgets/scaffold_with_nav.dart';

final router = GoRouter(
  initialLocation: '/calendar',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          ScaffoldWithNav(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/calendar',
              builder: (context, state) => const CalendarScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/summary',
              builder: (context, state) => const SummaryScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
