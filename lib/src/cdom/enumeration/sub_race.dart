// Type-safe constant for sub-races (e.g. Deep Dwarf, High Elf).
final class SubRace {
  static final Map<String, SubRace> _typeMap = {};
  static int _ordinalCount = 0;

  final String _name;
  final int _ordinal;

  SubRace._(this._name) : _ordinal = _ordinalCount++;

  static SubRace getConstant(String name) {
    final key = name.toLowerCase();
    return _typeMap.putIfAbsent(key, () => SubRace._(name));
  }

  static SubRace valueOf(String name) {
    final result = _typeMap[name.toLowerCase()];
    if (result == null) throw ArgumentError('$name is not a previously defined SubRace');
    return result;
  }

  static List<SubRace> getAllConstants() => List.unmodifiable(_typeMap.values);
  static void clearConstants() { _typeMap.clear(); }

  int getOrdinal() => _ordinal;

  @override
  String toString() => _name;
}
