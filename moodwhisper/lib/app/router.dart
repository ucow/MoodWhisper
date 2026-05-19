import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/onboarding/pages/onboarding_page.dart';
import 'features/main_shell/pages/main_shell_page.dart';
import 'features/record/pages/record_page.dart';
import 'features/record_list/pages/record_list_page.dart';
import 'features/statistics/pages/statistics_page.dart';
import 'features/settings/pages/settings_page.dart';

/// 路由路径常量
class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String main = '/main';
  static const String record = '/record';
  static const String recordList = '/list';
  static const String statistics = '/statistics';
  static const String settings = '/settings';
}

/// 首次引导状态 Provider
final onboardingCompletedProvider = StateProvider<bool>((ref) => false);

/// 路由配置
final routerProvider = Provider<GoRouter>((ref) {
  final onboardingCompleted = ref.watch(onboardingCompletedProvider);

  return GoRouter(
    initialLocation: onboardingCompleted ? AppRoutes.main : AppRoutes.onboarding,
    routes: [
      // 首次引导
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),

      // 主页面壳（含 Tab Bar）
      ShellRoute(
        builder: (context, state, child) => MainShellPage(child: child),
        routes: [
          // 记录页
          GoRoute(
            path: AppRoutes.record,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: RecordPage(),
            ),
          ),
          // 列表页
          GoRoute(
            path: AppRoutes.recordList,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: RecordListPage(),
            ),
          ),
          // 统计页
          GoRoute(
            path: AppRoutes.statistics,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: StatisticsPage(),
            ),
          ),
          // 设置页
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsPage(),
            ),
          ),
        ],
      ),
    ],

    // 路由守卫：未完成引导则跳转到引导页
    redirect: (context, state) {
      final isOnboarding = state.matchedLocation == AppRoutes.onboarding;

      if (!onboardingCompleted && !isOnboarding) {
        return AppRoutes.onboarding;
      }

      if (onboardingCompleted && isOnboarding) {
        return AppRoutes.main;
      }

      return null;
    },
  );
});

/// Tab Bar 索引 Helper
class TabBarHelper {
  static const int recordIndex = 0;
  static const int listIndex = 1;
  static const int statsIndex = 2;
  static const int settingsIndex = 3;

  static String getPath(int index) {
    switch (index) {
      case recordIndex:
        return AppRoutes.record;
      case listIndex:
        return AppRoutes.recordList;
      case statsIndex:
        return AppRoutes.statistics;
      case settingsIndex:
        return AppRoutes.settings;
      default:
        return AppRoutes.record;
    }
  }

  static int getIndex(String path) {
    if (path.startsWith(AppRoutes.record)) return recordIndex;
    if (path.startsWith(AppRoutes.recordList)) return listIndex;
    if (path.startsWith(AppRoutes.statistics)) return statsIndex;
    if (path.startsWith(AppRoutes.settings)) return settingsIndex;
    return recordIndex;
  }
}
