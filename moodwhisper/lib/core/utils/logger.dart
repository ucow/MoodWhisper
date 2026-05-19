import 'package:logger/logger.dart';

/// 日志等级
enum LogLevel {
  debug,
  info,
  warn,
  error,
}

/// AppLogger - 统一日志封装
/// 基于开发计划 v1.3 P0.12 日志体系
class AppLogger {
  static Logger? _logger;
  static LogLevel _minLevel = LogLevel.debug;

  /// 初始化日志系统
  static void init({LogLevel minLevel = LogLevel.debug}) {
    _minLevel = minLevel;
    _logger = Logger(
      filter: _CustomFilter(minLevel),
      printer: _CustomPrinter(),
      output: ConsoleOutput(),
    );
  }

  /// DEBUG 级别 - 开发调试
  static void d(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// INFO 级别 - 关键操作
  static void i(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// WARN 级别 - 可恢复异常
  static void w(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.warn, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// ERROR 级别 - 需关注错误
  static void e(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (_logger == null) {
      init();
    }

    final fullMessage = tag != null ? '[$tag] $message' : message;

    switch (level) {
      case LogLevel.debug:
        _logger?.d(fullMessage);
        break;
      case LogLevel.info:
        _logger?.i(fullMessage);
        break;
      case LogLevel.warn:
        _logger?.w(fullMessage);
        break;
      case LogLevel.error:
        if (error != null) {
          _logger?.e('$fullMessage\nError: $error', stackTrace: stackTrace);
        } else {
          _logger?.e(fullMessage, stackTrace: stackTrace);
        }
        break;
    }
  }
}

/// 自定义过滤器
class _CustomFilter extends LogFilter {
  final LogLevel _minLevel;

  _CustomFilter(this._minLevel);

  @override
  bool shouldLog(Level level) {
    switch (_minLevel) {
      case LogLevel.debug:
        return true;
      case LogLevel.info:
        return level != Level.debug;
      case LogLevel.warn:
        return level == Level.warning || level == Level.error;
      case LogLevel.error:
        return level == Level.error;
    }
  }
}

/// 自定义格式打印器
class _CustomPrinter extends LogPrinter {
  @override
  void log(Level level, message, {error, stackTrace}) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 23);
    final levelStr = _levelToString(level);
    print('$timestamp $levelStr $message');
  }

  String _levelToString(Level level) {
    switch (level) {
      case Level.debug:
        return '🔍 DEBUG';
      case Level.info:
        return 'ℹ️  INFO';
      case Level.warning:
        return '⚠️  WARN';
      case Level.error:
        return '❌ ERROR';
      default:
        return '📝';
    }
  }
}
