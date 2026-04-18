// Type-safe constant for race subtypes (Elf, Goblinoid, Shapechanger, etc.).
class RaceSubType {
  static final Map<String, RaceSubType> _typeMap = {};
  static int _ordinalCount = 0;

  final String _name;
  final int _ordinal;

  RaceSubType._(this._name) : _ordinal = _ordinalCount++;

  static RaceSubType getConstant(String name) {
    final key = name.toLowerCase();
    return _typeMap.putIfAbsent(key, () => RaceSubType._(name));
  }

  static RaceSubType valueOf(String name) {
    final result = _typeMap[name.toLowerCase()];
    if (result == null) throw ArgumentError('$name is not a previously defined RaceSubType');
    return result;
  }

  static List<RaceSubType> getAllConstants() => List.unmodifiable(_typeMap.values);
  static void clearConstants() { _typeMap.clear(); }

  int getOrdinal() => _ordinal;

  @override
  String toString() => _name;

  @override
  bool operator ==(Object other) => other is RaceSubType && _name.toLowerCase() == other._name.toLowerCase();

  @override
  int get hashCode => _name.toLowerCase().hashCode;
}
