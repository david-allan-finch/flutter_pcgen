import '../../base/util/case_insensitive_map.dart';

// Typesafe constant for Types applied to CDOMObjects.
class Type implements Comparable<Type> {
  static final CaseInsensitiveMap<Type> _typeMap = CaseInsensitiveMap();
  static int _ordinalCount = 0;

  static final Type natural = getConstant('Natural');
  static final Type custom = getConstant('Custom');
  static final Type none = getConstant('None');
  static final Type humanoid = getConstant('Humanoid');
  static final Type weapon = getConstant('Weapon');
  static final Type melee = getConstant('Melee');
  static final Type simple = getConstant('Simple');
  static final Type unarmed = getConstant('Unarmed');
  static final Type subdual = getConstant('Subdual');
  static final Type standard = getConstant('Standard');
  static final Type monk = getConstant('Monk');
  static final Type bludgeoning = getConstant('Bludgeoning');
  static final Type autoGen = getConstant('AUTO_GEN');
  static final Type both = getConstant('Both');
  static final Type thrown = getConstant('Thrown');
  static final Type ranged = getConstant('Ranged');
  static final Type kDouble = getConstant('Double');
  static final Type head1 = getConstant('Head1');
  static final Type head2 = getConstant('Head2');
  static final Type temporary = getConstant('TEMPORARY');
  static final Type divine = getConstant('Divine');
  static final Type potion = getConstant('Potion');
  static final Type ring = getConstant('Ring');
  static final Type scroll = getConstant('Scroll');
  static final Type wand = getConstant('Wand');
  static final Type monster = getConstant('Monster');
  static final Type shield = getConstant('Shield');
  static final Type armor = getConstant('Armor');
  static final Type magic = getConstant('Magic');
  static final Type masterwork = getConstant('Masterwork');
  static final Type any = getConstant('ANY');

  final String _fieldName;
  final int ordinal;

  Type._(this._fieldName) : ordinal = _ordinalCount++;

  String getComparisonString() => _fieldName.toUpperCase();

  @override
  String toString() => _fieldName;

  @override
  int compareTo(Type other) => _fieldName.compareTo(other._fieldName);

  static Type getConstant(String name) {
    final existing = _typeMap[name];
    if (existing != null) return existing;
    final type = Type._(name);
    _typeMap[name] = type;
    return type;
  }

  static Type? valueOf(String name) => _typeMap[name];

  static Iterable<Type> getAllConstants() =>
      List.unmodifiable(_typeMap.values());

  static void clearConstants() => _typeMap.clear();
}
