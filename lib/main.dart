import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mood_whisper/app/router/app_router.dart';
import 'package:mood_whisper/core/services/sentry_service.dart';
import 'package:mood_whisper/core/theme/theme.dart';
import 'package:mood_whisper/shared/providers/mood_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SentryService.initialize();

  runApp(const ProviderScope(child: MoodWhisperApp()));
}

class MoodWhisperApp extends ConsumerWidget {
  const MoodWhisperApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'MoodWhisper',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeMode,
      routerConfig: AppRouter.router,
    );
  }
}
