import '../../base/util/case_insensitive_map.dart';
import '../../base/util/format_manager.dart';

// Typesafe key for FACTSET (multi-value FACT) storage in CDOMObject.
class FactSetKey<T> {
  static final CaseInsensitiveMap<FactSetKey<dynamic>> _typeMap = CaseInsensitiveMap();

  final String _fieldName;
  final FormatManager<T> formatManager;

  FactSetKey._(this._fieldName, this.formatManager);

  @override
  String toString() => _fieldName;

  static FactSetKey<T> getConstant<T>(String name, FormatManager<T> fmtManager) {
    final existing = _typeMap[name];
    if (existing != null) return existing as FactSetKey<T>;
    final key = FactSetKey<T>._(name, fmtManager);
    _typeMap[name] = key;
    return key;
  }

  static FactSetKey<T> valueOf<T>(String name) {
    final key = _typeMap[name];
    if (key == null) throw ArgumentError('$name is not a previously defined FactSetKey');
    return key as FactSetKey<T>;
  }

  static Iterable<FactSetKey<dynamic>> getAllConstants() =>
      List.unmodifiable(_typeMap.values());

  static void clearConstants() => _typeMap.clear();
}
