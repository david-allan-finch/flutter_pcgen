import '../enumeration/object_key.dart';
import 'cn_ability_selection.dart';

// Utility methods for checking whether two CNAbilitySelections can coexist on a PC.
final class CNAbilitySelectionUtilities {
  CNAbilitySelectionUtilities._();

  static bool canCoExist(CNAbilitySelection cnas1, CNAbilitySelection cnas2) {
    final cna = cnas1.getCNAbility();
    final a = cna.getAbility();
    final ocna = cnas2.getCNAbility();

    if (ocna.getAbilityCategory().getParentCategory() !=
        cna.getAbilityCategory().getParentCategory()) {
      return true;
    }
    if (ocna.getAbility() != a) return true;

    if (!a.getSafe(ObjectKey.multipleAllowed)) return false;
    if (a.getSafe(ObjectKey.stacks)) return true;

    return cnas1.getSelection() != cnas2.getSelection();
  }
}
