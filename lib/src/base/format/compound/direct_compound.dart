import '../../util/format_manager.dart';
import 'compound.dart';

class DirectCompound implements Compound {
  final Object _primary;
  final FormatManager<dynamic> _primaryFormat;
  final Map<String, Object> _secondaries;

  DirectCompound(this._primary, this._primaryFormat, [Map<String, Object>? secondaries])
      : _secondaries = secondaries ?? {};

  @override
  Object getPrimary() => _primary;

  @override
  Object? getSecondary(String key) => _secondaries[key];

  @override
  FormatManager<dynamic> getPrimaryFormatManager() => _primaryFormat;

  @override
  String toString() {
    final buf = StringBuffer(_primaryFormat.unconvert(_primary));
    for (final entry in _secondaries.entries) {
      buf.write('|${entry.key}=${entry.value}');
    }
    return buf.toString();
  }
}
