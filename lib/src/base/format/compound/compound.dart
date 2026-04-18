import '../../util/format_manager.dart';

// Represents a compound value consisting of a primary value and secondary values.
abstract interface class Compound {
  Object getPrimary();
  Object? getSecondary(String key);
  FormatManager<dynamic> getPrimaryFormatManager();
}
