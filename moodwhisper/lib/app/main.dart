import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme.dart';
import 'router.dart';
import 'core/utils/logger.dart';
import 'core/constants/strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化日志
  AppLogger.init(minLevel: LogLevel.debug);
  AppLogger.i('MoodWhisper starting...', tag: 'App');

  runApp(
    const ProviderScope(
      child: MoodWhisperApp(),
    ),
  );
}

/// MoodWhisper 应用根组件
class MoodWhisperApp extends ConsumerWidget {
  const MoodWhisperApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
