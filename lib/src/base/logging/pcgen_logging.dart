import 'package:logging/logging.dart';
import 'severity.dart';

class PCGenLogging {
  static final Logger _logger = Logger('PCGen');

  PCGenLogging._();

  static void log(Severity severity, String message, [Object? error]) {
    switch (severity) {
      case Severity.trace:
      case Severity.debug:
        _logger.fine(message);
      case Severity.info:
        _logger.info(message);
      case Severity.warning:
        _logger.warning(message);
      case Severity.error:
      case Severity.lsevere:
        _logger.severe(message, error);
    }
  }

  static void errorPrint(String message, [Object? error]) =>
      _logger.severe(message, error);

  static void warningPrint(String message) => _logger.warning(message);

  static void infoPrint(String message) => _logger.info(message);

  static bool isDebugEnabled() =>
      _logger.isLoggable(Level.FINE);
}
