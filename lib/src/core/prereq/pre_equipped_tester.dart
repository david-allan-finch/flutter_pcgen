// Copyright (c) Bryan McRoberts, 2001; Chris Ward, 2003.
//
// Translation of pcgen.core.prereq.PreEquippedTester

import 'abstract_prerequisite_test.dart';
import 'prerequisite.dart';
import 'prerequisite_exception.dart';
import 'prerequisite_operator.dart';

/// Abstract base for PREEQUIP-family testers. Handles the common logic of
/// scanning a character's equipped items by location.
abstract class PreEquippedTester extends AbstractPrerequisiteTest {
  /// Tests whether the character has a qualifying item equipped at [equippedType].
  ///
  /// [equippedType] corresponds to an EquipmentLocation value (passed as dynamic
  /// until the EquipmentLocation enum is fully translated).
  int passesPreEquipHandleTokens(
      Prerequisite prereq, dynamic character, dynamic equippedType) {
    bool isEquipped = false;

    if (character.hasEquipment()) {
      String aString = prereq.key ?? '';
      for (final eq in character.getDisplay().getEquippedEquipmentSet()) {
        if (eq.getLocation() != equippedType) continue;

        if (aString.startsWith('WIELDCATEGORY=') ||
            aString.startsWith('WIELDCATEGORY.')) {
          final wCat = eq.getEffectiveWieldCategory(character);
          if (wCat != null &&
              wCat.getKeyName().toLowerCase() ==
                  aString.substring(14).toLowerCase()) {
            isEquipped = true;
            break;
          }
        } else if (aString.startsWith('TYPE=') || aString.startsWith('TYPE.')) {
          isEquipped = eq.isType(aString);
          break;
        } else {
          String eqName;
          if (aString.startsWith('BASEITEM=')) {
            eqName = eq.getBaseItemName();
            aString = aString.substring(aString.indexOf('=') + 1);
          } else {
            eqName = eq.getName();
          }

          final percentPos = aString.indexOf('%');
          if (percentPos >= 0) {
            if (eqName.substring(0, percentPos).toLowerCase() ==
                aString.substring(0, percentPos).toLowerCase()) {
              isEquipped = true;
              break;
            }
          } else if (eqName.toLowerCase() == aString.toLowerCase()) {
            isEquipped = true;
            break;
          }
        }
      }
    }

    final op = prereq.operator;
    int runningTotal;
    if (op == PrerequisiteOperator.eq || op == PrerequisiteOperator.gteq) {
      runningTotal = isEquipped ? 1 : 0;
    } else if (op == PrerequisiteOperator.neq || op == PrerequisiteOperator.lt) {
      runningTotal = isEquipped ? 0 : 1;
    } else {
      throw PrerequisiteException('Invalid comparison operator for PREEQUIP: $op');
    }

    return countedTotal(prereq, runningTotal);
  }
}
