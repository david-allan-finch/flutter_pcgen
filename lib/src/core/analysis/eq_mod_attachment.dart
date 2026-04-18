import '../../../cdom/enumeration/list_key.dart';
import '../../../cdom/enumeration/string_key.dart';

// Attaches EqModRefs to an Equipment's modifier lists during finalisation.
final class EqModAttachment {
  EqModAttachment._();

  static void finishEquipment(dynamic eq) {
    for (int i = 1; i <= 2; i++) {
      final head = eq.getEquipmentHeadReference(i);
      if (head == null) continue;
      final modInfoList = head.getListFor(ListKey.eqModInfo);
      if (modInfoList == null) continue;

      for (final modRef in modInfoList) {
        final modList = head.getListFor(ListKey.eqMod);
        dynamic eqMod = modRef.getRef().get();
        final eqModKey = eqMod.getKeyName() as String;
        dynamic curMod;

        if (modList != null) {
          for (final mod in modList) {
            if (mod.getKeyName() == eqModKey) {
              curMod = mod;
              break;
            }
          }
        }

        if (curMod == null) {
          if ((eqMod.getSafe(StringKey.choiceString) as String).isNotEmpty) {
            eqMod = eqMod.clone();
          }
          eq.addToEqModifierList(eqMod, i == 1);
          curMod = eqMod;
        }

        for (final assoc in modRef.getAssociations()) {
          eq.addAssociation(curMod, assoc);
        }
      }
    }
  }
}
