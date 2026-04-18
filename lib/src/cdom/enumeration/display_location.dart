// Type-safe constant for display location names (e.g. where an ability shows on sheet).
final class DisplayLocation implements Comparable<DisplayLocation> {
  static final Map<String, DisplayLocation> _typeMap = {};
  static int _ordinalCount = 0;

  final String _name;
  final int _ordinal;

  DisplayLocation._(this._name) : _ordinal = _ordinalCount++;

  static DisplayLocation getConstant(String name) {
    return _typeMap.putIfAbsent(name.toLowerCase(), () => DisplayLocation._(name));
  }

  static DisplayLocation valueOf(String name) {
    final result = _typeMap[name.toLowerCase()];
    if (result == null) throw ArgumentError('$name is not a previously defined Type');
    return result;
  }

  static List<DisplayLocation> getAllConstants() => List.unmodifiable(_typeMap.values);
  static void clearConstants() { _typeMap.clear(); }

  int getOrdinal() => _ordinal;
  String getComparisonString() => _name.toUpperCase();

  @override
  String toString() => _name;

  @override
  int compareTo(DisplayLocation other) => _name.compareTo(other._name);
}
