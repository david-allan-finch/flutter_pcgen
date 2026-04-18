import '../../base/util/case_insensitive_map.dart';

// Typesafe constant for variable (DEFINE:) characteristics of a CDOMObject.
class VariableKey {
  static CaseInsensitiveMap<VariableKey>? _typeMap;
  static int _ordinalCount = 0;

  final String _fieldName;
  final int ordinal;

  VariableKey._(this._fieldName) : ordinal = _ordinalCount++;

  @override
  String toString() => _fieldName;

  static CaseInsensitiveMap<VariableKey> get _map {
    _typeMap ??= CaseInsensitiveMap();
    return _typeMap!;
  }

  static VariableKey getConstant(String name) {
    final existing = _map[name];
    if (existing != null) return existing;
    final key = VariableKey._(name);
    _map[name] = key;
    return key;
  }

  static VariableKey valueOf(String name) {
    final key = _map[name];
    if (key == null) throw ArgumentError('$name is not a previously defined VariableKey');
    return key;
  }

  static Iterable<VariableKey> getAllConstants() =>
      List.unmodifiable(_map.values());

  static void clearConstants() => _map.clear();
}
