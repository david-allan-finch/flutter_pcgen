import '../../../cdom/base/cdom_object.dart';
import '../../../cdom/enumeration/list_key.dart';
import '../../pc_class.dart';

// Renames class-references in variables and bonuses when a PCClass key changes.
final class PCClassKeyChange {
  PCClassKeyChange._();

  static void changeReferences(String oldClass, PCClass pcc) {
    final newClass = pcc.getKeyName();
    if (oldClass == newClass) return;

    _renameVariables(oldClass, pcc, newClass);
    _renameBonusTarget(pcc, oldClass, newClass);

    for (final pcl in pcc.getOriginalClassLevelCollection()) {
      _renameVariables(oldClass, pcl, newClass);
      _renameBonusTarget(pcl, oldClass, newClass);
    }
  }

  static void _renameVariables(String oldClass, CDOMObject pcc, String newClass) {
    for (final vk in pcc.getVariableKeys()) {
      final current = pcc.get(vk).toString();
      pcc.put(vk, current.replaceAll('=$oldClass', '=$newClass'));
    }
  }

  static void _renameBonusTarget(CDOMObject cdo, String oldClass, String newClass) {
    final bonusList = cdo.getListFor(ListKey.bonus);
    if (bonusList == null) return;

    for (final bonusObj in List.from(bonusList)) {
      final bonus = bonusObj.toString();
      int offs = -1;
      for (;;) {
        offs = bonus.indexOf('=$oldClass', offs + 1);
        if (offs < 0) break;
        final newBonus = bonus.substring(0, offs + 1) +
            newClass +
            bonus.substring(offs + oldClass.length + 1);
        // Bonus.newBonus — stub; add to list if non-null
        cdo.addToListFor(ListKey.bonus, newBonus);
        cdo.removeFromListFor(ListKey.bonus, bonusObj);
      }
    }
  }
}
