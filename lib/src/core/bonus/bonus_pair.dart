import '../../cdom/base/cdom_object.dart';
import '../player_character.dart';

// Represents a resolved bonus key → formula pair, used during bonus calculation.
class BonusPair {
  final String fullyQualifiedBonusType;
  final String formula; // formula string
  final Object? creatorObj;

  BonusPair(this.fullyQualifiedBonusType, this.formula, this.creatorObj);

  num resolve(PlayerCharacter aPC) {
    String source = '';
    if (creatorObj is CDOMObject) {
      source = (creatorObj as CDOMObject).getQualifiedKey() ?? '';
    }
    return aPC.getVariableValue(formula, source);
  }
}
