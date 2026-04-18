import '../../core/pc_class.dart';
import '../../core/player_character.dart';
import 'spell_level.dart';

// Pairs a class filter with min/max spell-level formulas for the SPELLLEVEL token.
class SpellLevelInfo {
  final dynamic _filter; // PrimitiveCollection<PCClass>
  final dynamic _minimumLevel; // Formula
  final dynamic _maximumLevel; // Formula

  SpellLevelInfo(dynamic classFilter, dynamic minLevel, dynamic maxLevel)
      : _filter = classFilter,
        _minimumLevel = minLevel,
        _maximumLevel = maxLevel;

  @override
  String toString() =>
      '${_filter.getLSTformat(false)}|$_minimumLevel|$_maximumLevel';

  List<SpellLevel> getLevels(PlayerCharacter pc) {
    final list = <SpellLevel>[];
    // filter.getCollection stub
    for (final cl in (_filter.getCollection(pc, null) as List<PCClass>? ?? const [])) {
      final min = _minimumLevel.resolve(pc, cl.getQualifiedKey()).toInt() as int;
      final max = _maximumLevel.resolve(pc, cl.getQualifiedKey()).toInt() as int;
      for (int i = min; i <= max; i++) {
        list.add(SpellLevel(cl, i));
      }
    }
    return list;
  }

  bool allow(PlayerCharacter pc, PCClass cl) =>
      pc.getClassKeyed(cl.getKeyName()) != null;
}
