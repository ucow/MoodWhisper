import 'package:go_router/go_router.dart';
import 'package:mood_whisper/app/shell/main_shell.dart';
import 'package:mood_whisper/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:mood_whisper/features/record/presentation/screens/record_screen.dart';
import 'package:mood_whisper/features/list/presentation/screens/list_screen.dart';
import 'package:mood_whisper/features/statistics/presentation/screens/statistics_screen.dart';
import 'package:mood_whisper/features/profile/presentation/screens/profile_screen.dart';

class AppRouter {
  static const String onboarding = '/onboarding';
  static const String record = '/record';
  static const String list = '/list';
  static const String statistics = '/statistics';
  static const String profile = '/profile';

  static final GoRouter router = GoRouter(
    initialLocation: onboarding,
    routes: [
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: record,
                builder: (context, state) => const RecordScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: list,
                builder: (context, state) => const ListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: statistics,
                builder: (context, state) => const StatisticsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
