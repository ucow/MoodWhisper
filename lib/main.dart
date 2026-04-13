import 'package:flutter/material.dart';
import 'package:mood_whisper/app/router/app_router.dart';
import 'package:mood_whisper/core/theme/theme.dart';

void main() {
  runApp(const MoodWhisperApp());
}

class MoodWhisperApp extends StatelessWidget {
  const MoodWhisperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MoodWhisper',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}
