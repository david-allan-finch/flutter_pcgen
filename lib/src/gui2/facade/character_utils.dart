//
// Missing License Header, Copyright 2016 (C) Andrew Maitland <amaitland@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.gui2.facade.CharacterUtils

import 'package:flutter_pcgen/src/core/equipment.dart';
import 'package:flutter_pcgen/src/core/player_character.dart';
import 'package:flutter_pcgen/src/core/size_adjustment.dart';
import 'package:flutter_pcgen/src/core/globals.dart';
import 'package:flutter_pcgen/src/core/rule_constants.dart';
import 'package:flutter_pcgen/src/core/equipment_list.dart';
import 'package:flutter_pcgen/src/system/language_bundle.dart';
import 'package:flutter_pcgen/src/base/logging/pcgen_logging.dart';

/// Utility class for character-related operations.
final class CharacterUtils {
  CharacterUtils._();

  static bool _isFreeClothing(
      Equipment eq, PlayerCharacter aPC, SizeAdjustment pcSizeAdj) {
    return !eq.isType('Magic') &&
        (eq.getCost(aPC).toDouble() == 0.0) &&
        pcSizeAdj == eq.getSizeAdjustment();
  }

  /// Select a free set of starting clothes for the character if applicable.
  static void selectClothes(PlayerCharacter aPC) {
    if (Globals.checkRule(RuleConstants.freeclothes) &&
        aPC.display.totalNonMonsterLevels == 1) {
      // See what the PC is already carrying
      List<Equipment> clothes =
          aPC.getEquipmentOfType('Clothing.Resizable', 3);

      // Check to see if any of the clothing the PC is carrying will fit and
      // has a zero price attached
      SizeAdjustment pcSizeAdj = aPC.sizeAdjustment;
      bool hasClothes =
          clothes.any((eq) => _isFreeClothing(eq, aPC, pcSizeAdj));

      // If the PC has no clothing items allow them to pick a free set
      if (!hasClothes) {
        clothes = EquipmentList.getEquipmentOfType(
            'Clothing.Resizable.Starting', 'Magic.Custom.Auto_Gen');
        if (clothes.isEmpty) {
          clothes = EquipmentList.getEquipmentOfType(
              'Clothing.Resizable', 'Magic.Custom.Auto_Gen');
        }

        List<Equipment> selectedClothes = [];
        selectedClothes = Globals.getChoiceFromList(
          LanguageBundle.getString('in_sumSelectAFreeSetOfClothing'),
          clothes,
          selectedClothes,
          1,
          aPC,
        );

        if (selectedClothes.isNotEmpty) {
          Equipment? eq = selectedClothes.first;
          if (eq != null) {
            eq = eq.clone();
            eq.setQty(1.0);

            // Need to resize to fit?
            if (pcSizeAdj != eq.getSizeAdjustment()) {
              eq.resizeItem(aPC, pcSizeAdj);
            }

            eq.setCostMod('-${eq.getCost(aPC)}'); // make cost 0

            if (aPC.getEquipmentNamed(eq.nameItemFromModifiers(aPC)) == null) {
              aPC.addEquipment(eq);
            } else {
              Logging.errorPrint('Cannot add duplicate equipment to PC');
            }
          }
        }
      }
    }
  }
}
