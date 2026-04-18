import '../../base/util/case_insensitive_map.dart';
import '../../base/util/format_manager.dart';

// Typesafe key for FACT storage in CDOMObject.
class FactKey<T> {
  static final CaseInsensitiveMap<FactKey<dynamic>> _typeMap = CaseInsensitiveMap();

  final String _fieldName;
  final FormatManager<T> formatManager;

  FactKey._(this._fieldName, this.formatManager);

  @override
  String toString() => _fieldName;

  T? cast(dynamic value) {
    if (value == null) return null;
    return value as T;
  }

  static FactKey<T> getConstant<T>(String name, FormatManager<T> fmtManager) {
    final existing = _typeMap[name];
    if (existing != null) return existing as FactKey<T>;
    final key = FactKey<T>._(name, fmtManager);
    _typeMap[name] = key;
    return key;
  }

  static FactKey<T> valueOf<T>(String name) {
    final key = _typeMap[name];
    if (key == null) throw ArgumentError('$name is not a previously defined FactKey');
    return key as FactKey<T>;
  }

  static Iterable<FactKey<dynamic>> getAllConstants() =>
      List.unmodifiable(_typeMap.values());

  static void clearConstants() => _typeMap.clear();
}
