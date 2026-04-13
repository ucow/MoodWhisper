import 'package:go_router/go_router.dart';
import 'package:mood_whisper/app/shell/main_shell.dart';
import 'package:mood_whisper/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:mood_whisper/features/record/presentation/screens/record_screen.dart';
import 'package:mood_whisper/features/home/presentation/screens/home_screen.dart';
import 'package:mood_whisper/features/list/presentation/screens/list_screen.dart';
import 'package:mood_whisper/features/profile/presentation/screens/profile_screen.dart';

class AppRouter {
  static const String onboarding = '/onboarding';
  static const String record = '/record';
  static const String dashboard = '/dashboard';
  static const String history = '/history';
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
                path: dashboard,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: history,
                builder: (context, state) => const ListScreen(),
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
