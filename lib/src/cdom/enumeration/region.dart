// Type-safe constant for character regions; NONE is a pre-defined constant.
final class Region implements Comparable<Region> {
  static final Map<String, Region> _typeMap = {};
  static int _ordinalCount = 0;

  static final Region none = Region._('None');

  final String _name;
  final int _ordinal;

  Region._(this._name) : _ordinal = _ordinalCount++ {
    _typeMap[_name.toLowerCase()] = this;
  }

  static Region getConstant(String name) {
    return _typeMap.putIfAbsent(name.toLowerCase(), () => Region._(name));
  }

  static Region valueOf(String name) {
    final result = _typeMap[name.toLowerCase()];
    if (result == null) throw ArgumentError('$name is not a previously defined Region');
    return result;
  }

  static List<Region> getAllConstants() => List.unmodifiable(_typeMap.values);
  static void clearConstants() { _typeMap.clear(); }

  int getOrdinal() => _ordinal;

  @override
  String toString() => _name;

  @override
  int compareTo(Region other) => _name.toLowerCase().compareTo(other._name.toLowerCase());
}
