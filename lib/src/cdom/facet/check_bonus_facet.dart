// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.CheckBonusFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/core/bonus/bonus_obj.dart';
import 'package:flutter_pcgen/src/core/bonus/bonus_utilities.dart';
import 'package:flutter_pcgen/src/cdom/facet/bonus_checking_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/model/check_facet.dart';

/// Calculates bonus values contributed by [PCCheck] objects (save bonus lines).
///
/// @deprecated by STATMODSAVE Code Control
class CheckBonusFacet {
  late BonusCheckingFacet bonusCheckingFacet;
  late CheckFacet checkFacet;

  /// Returns the total bonus from checks for [type]/[name].
  @Deprecated('Replaced by STATMODSAVE Code Control')
  double getCheckBonusTo(CharID id, String type, String name) {
    double bonus = 0;
    final upperType = type.toUpperCase();
    final upperName = name.toUpperCase();
    for (final check in checkFacet.getSet(id)) {
      final tempList = BonusUtilities.getBonusFromList(
          check.getSafeListFor(ListKey.getConstant<BonusObj>('BONUS')),
          upperType,
          upperName);
      if (tempList.isNotEmpty) {
        bonus +=
            bonusCheckingFacet.getAllBonusValues(id, tempList, check.getQualifiedKey());
      }
    }
    return bonus;
  }
}
