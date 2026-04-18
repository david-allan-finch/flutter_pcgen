import 'bonus_obj.dart';

// Utility methods for working with BonusObj collections.
abstract final class BonusUtilities {
  // Returns all bonuses in the list that match the given type and name.
  static List<BonusObj> getBonusFromList(Iterable<BonusObj>? bonusList, String aType, String aName) {
    final aList = <BonusObj>[];
    if (bonusList == null) return aList;
    for (final aBonus in bonusList) {
      if (aBonus.getTypeOfBonus() != aType) continue;
      final infoList = aBonus.getBonusInfoList();
      if (infoList.length > 1) {
        for (final aBI in aBonus.getBonusInfo().split(',')) {
          if (aBI == aName) aList.add(aBonus);
        }
      } else if (aBonus.getBonusInfo() == aName) {
        aList.add(aBonus);
      }
    }
    return aList;
  }
}
