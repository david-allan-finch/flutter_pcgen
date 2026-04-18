// Type-safe constant for movement types (Walk, Fly, Swim, etc.).
class MovementType {
  static final Map<String, MovementType> _typeMap = {};
  static int _ordinalCount = 0;

  final String _name;
  final int _ordinal;

  MovementType._(this._name) : _ordinal = _ordinalCount++;

  static MovementType getConstant(String name) {
    final key = name.toLowerCase();
    return _typeMap.putIfAbsent(key, () => MovementType._(name));
  }

  static MovementType valueOf(String name) {
    final result = _typeMap[name.toLowerCase()];
    if (result == null) throw ArgumentError('$name is not a previously defined MovementType');
    return result;
  }

  static List<MovementType> getAllConstants() => List.unmodifiable(_typeMap.values);

  static void clearConstants() { _typeMap.clear(); }

  int getOrdinal() => _ordinal;

  @override
  String toString() => _name;

  @override
  bool operator ==(Object other) => other is MovementType && _name.toLowerCase() == other._name.toLowerCase();

  @override
  int get hashCode => _name.toLowerCase().hashCode;
}
