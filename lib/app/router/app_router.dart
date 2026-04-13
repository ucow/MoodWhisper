import 'package:flutter/material.dart';
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
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: record,
                pageBuilder: (context, state) => _buildFadePage(
                  state: state,
                  child: const RecordScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: dashboard,
                pageBuilder: (context, state) => _buildFadePage(
                  state: state,
                  child: const HomeScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: history,
                pageBuilder: (context, state) => _buildFadePage(
                  state: state,
                  child: const ListScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: profile,
                pageBuilder: (context, state) => _buildFadePage(
                  state: state,
                  child: const ProfileScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  static CustomTransitionPage _buildFadePage({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
            reverseCurve: Curves.easeInOut,
          ),
          child: child,
        );
      },
    );
  }
}
