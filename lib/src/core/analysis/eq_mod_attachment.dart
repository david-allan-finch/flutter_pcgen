//
// Copyright 2008 (C) Tom Parker <thpr@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.core.analysis.EqModAttachment
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
