// Translation of pcgen.system.application.LoggingUncaughtExceptionHandler

/// Logs uncaught exceptions to the PCGen logger.
class LoggingUncaughtExceptionHandler {
  LoggingUncaughtExceptionHandler._();

  static void install() {
    // In Dart, use Zone.current.handleUncaughtError or runZonedGuarded
    // TODO: integrate with Dart's error handling
  }
}
