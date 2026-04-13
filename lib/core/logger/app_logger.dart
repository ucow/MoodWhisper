import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
    level: kDebugMode ? Level.debug : Level.nothing,
  );

  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  static void info(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  static void warning(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void fatal(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  static void logApiRequest(String method, String url, {Map<String, dynamic>? params}) {
    debug('[API] $method $url', params);
  }

  static void logApiResponse(String url, int statusCode, Duration duration) {
    debug('[API] $url → $statusCode (${duration.inMilliseconds}ms)');
  }

  static void logDbOperation(String operation, String table, {String? id}) {
    debug('[DB] $operation on $table${id != null ? ' ($id)' : ''}');
  }

  static void logNavigation(String routeName, {Map<String, dynamic>? params}) {
    debug('[NAV] → $routeName', params);
  }
}
