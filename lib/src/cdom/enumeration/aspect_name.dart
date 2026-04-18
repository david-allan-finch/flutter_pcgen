// Type-safe constant for Ability Aspect names.
final class AspectName implements Comparable<AspectName> {
  static final Map<String, AspectName> _nameMap = {};
  static int _ordinalCount = 0;

  final String _name;
  final int _ordinal;

  AspectName._(this._name) : _ordinal = _ordinalCount++;

  static AspectName getConstant(String name) {
    return _nameMap.putIfAbsent(name.toLowerCase(), () => AspectName._(name));
  }

  static AspectName valueOf(String name) {
    final result = _nameMap[name.toLowerCase()];
    if (result == null) throw ArgumentError('$name is not a previously defined AspectName');
    return result;
  }

  static List<AspectName> getAllConstants() {
    if (_nameMap.isEmpty) return [];
    return List.unmodifiable(_nameMap.values);
  }

  static void clearConstants() { _nameMap.clear(); }

  int getOrdinal() => _ordinal;

  @override
  String toString() => _name;

  @override
  int compareTo(AspectName other) => _name.compareTo(other._name);

  @override
  bool operator ==(Object other) => other is AspectName && other._ordinal == _ordinal;

  @override
  int get hashCode => _ordinal;
}
