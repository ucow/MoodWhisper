import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:mood_whisper/core/logger/app_logger.dart';

class SentryService {
  SentryService._();

  static Future<void> initialize() async {
    if (kDebugMode) {
      AppLogger.debug('[Sentry] Running in debug mode - Sentry disabled');
      return;
    }

    await SentryFlutter.init(
      (options) {
        options.dsn = const String.fromEnvironment(
          'SENTRY_DSN',
          defaultValue: '',
        );
        options.environment = kDebugMode ? 'debug' : 'release';
        options.release = 'mood_whisper@1.0.0';
        options.tracesSampleRate = 0.1;
        options.sampleRate = 0.1;
        options.attachStackTrace = true;
        options.maxRequestBodySize = RequestBodySize.never;
      },
      appRunner: () => AppLogger.debug('[Sentry] Initialized in release mode'),
    );
  }

  static void captureException(Object exception, {StackTrace? stackTrace}) {
    if (kDebugMode) {
      AppLogger.error('[Sentry] Exception (debug mode - not captured)',
          exception, stackTrace);
      return;
    }
    Sentry.captureException(exception, stackTrace: stackTrace);
  }

  static void captureMessage(String message, {SentryLevel level = SentryLevel.info}) {
    if (kDebugMode) {
      AppLogger.debug('[Sentry] Message (debug mode): $message');
      return;
    }
    Sentry.captureMessage(message, level: level);
  }

  static Future<void> flush() async {
    if (!kDebugMode) {
      await Sentry.flush(2000);
    }
  }
}
