import 'dart:developer' as dev;

/// Centralized logging service for the app.
///
/// Uses `dart:developer` log() which integrates with DevTools and
/// is stripped from release builds by the compiler.
class Log {
  Log._();

  static const _name = 'UnraidManager';

  /// Log a debug-level message.
  static void d(String message, {String? tag}) {
    dev.log(message, name: tag ?? _name, level: 500);
  }

  /// Log an info-level message.
  static void i(String message, {String? tag}) {
    dev.log(message, name: tag ?? _name, level: 800);
  }

  /// Log a warning-level message.
  static void w(String message, {String? tag, Object? error}) {
    dev.log(message, name: tag ?? _name, level: 900, error: error);
  }

  /// Log an error with optional exception and stack trace.
  static void e(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    dev.log(
      message,
      name: tag ?? _name,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
