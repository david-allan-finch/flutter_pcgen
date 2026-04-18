// Type-safe constant for race types (Humanoid, Undead, Dragon, etc.).
class RaceType {
  static final Map<String, RaceType> _typeMap = {};
  static int _ordinalCount = 0;

  final String _name;
  final int _ordinal;

  RaceType._(this._name) : _ordinal = _ordinalCount++;

  static RaceType getConstant(String name) {
    final key = name.toLowerCase();
    return _typeMap.putIfAbsent(key, () => RaceType._(name));
  }

  static RaceType valueOf(String name) {
    final result = _typeMap[name.toLowerCase()];
    if (result == null) throw ArgumentError('$name is not a previously defined RaceType');
    return result;
  }

  static List<RaceType> getAllConstants() => List.unmodifiable(_typeMap.values);
  static void clearConstants() { _typeMap.clear(); }

  int getOrdinal() => _ordinal;

  @override
  String toString() => _name;

  @override
  bool operator ==(Object other) => other is RaceType && _name.toLowerCase() == other._name.toLowerCase();

  @override
  int get hashCode => _name.toLowerCase().hashCode;
}
