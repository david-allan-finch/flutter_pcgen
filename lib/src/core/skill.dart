// Translation of pcgen.core.Skill

import '../cdom/enumeration/list_key.dart';
import '../cdom/enumeration/object_key.dart';
import 'pcobject.dart';

/// Represents a skill (e.g., Acrobatics, Perception).
final class Skill extends PObject {
  String getLocalScopeName() => 'PC.SKILL';

  /// Returns the abbreviation of the key ability stat for this skill.
  String getKeyStatAbb() {
    final keyStat = getSafe(ObjectKey.getConstant<dynamic>('KEY_STAT'));
    return (keyStat as dynamic)?.get()?.getKeyName() ?? '';
  }

  /// Returns true if this skill can be used untrained.
  bool isUntrained() =>
      getSafe(ObjectKey.getConstant<bool>('USE_UNTRAINED', defaultValue: true))
          as bool? ??
      true;

  /// Returns true if this skill is exclusive to certain classes.
  bool isExclusive() =>
      getSafe(ObjectKey.getConstant<bool>('EXCLUSIVE', defaultValue: false))
          as bool? ??
      false;

  /// Returns raw bonus objects for this skill for the given character.
  List<dynamic> getRawBonusList(dynamic pc) =>
      getSafeListFor<dynamic>(ListKey.getConstant<dynamic>('BONUS'));

  @override
  bool operator ==(Object other) =>
      other is Skill &&
      getKeyName().toLowerCase() == other.getKeyName().toLowerCase();

  @override
  int get hashCode => getKeyName().toLowerCase().hashCode;
}
