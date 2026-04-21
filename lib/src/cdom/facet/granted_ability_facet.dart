// Copyright (c) Thomas Parker, 2010.
//
// Translation of pcgen.cdom.facet.GrantedAbilityFacet

import 'package:flutter_pcgen/src/cdom/base/category.dart';
import 'package:flutter_pcgen/src/cdom/content/cn_ability.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/nature.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/object_key.dart';
import 'package:flutter_pcgen/src/cdom/helper/cn_ability_selection.dart';
import 'package:flutter_pcgen/src/core/ability.dart';
import 'package:flutter_pcgen/src/core/ability_category.dart';
import 'package:flutter_pcgen/src/util/enumeration/view.dart';
import 'base/abstract_cnas_enforcing_facet.dart';

/// Tracks all granted [CNAbilitySelection] objects for a Player Character.
class GrantedAbilityFacet extends AbstractCNASEnforcingFacet {
  // init() would register with OutputDB — omitted (output layer not yet translated).

  bool hasAbilityVisibleTo(CharID id, Category<Ability> cat, View view) {
    final list = getList(id);
    if (list == null) return false;
    for (final array in list) {
      final cna = array[0].cnas.getCNAbility();
      if (cna.getAbilityCategory() == cat &&
          (cna.getAbility().getSafe(ObjectKey.getConstant<dynamic>('VISIBILITY'))
                  as dynamic)
              .isVisibleTo(view)) {
        return true;
      }
    }
    return false;
  }

  List<CNAbility> getPoolAbilities(CharID id, Category<Ability> cat,
      [Nature? n]) {
    final list = getList(id);
    if (list == null) return const [];
    return [
      for (final array in list)
        if (array[0].cnas.getCNAbility().getAbilityCategory() == cat &&
            (n == null || array[0].cnas.getCNAbility().getNature() == n))
          array[0].cnas.getCNAbility()
    ];
  }

  List<CNAbility> getCNAbilitiesByCategory(CharID id, Category<Ability> cat,
      [Nature? n]) {
    final list = getList(id);
    if (list == null) return const [];
    return [
      for (final array in list)
        if (array[0].cnas.getCNAbility().getAbilityCategory().getParentCategory() == cat &&
            (n == null || array[0].cnas.getCNAbility().getNature() == n))
          array[0].cnas.getCNAbility()
    ];
  }

  List<CNAbility> getCNAbilities(CharID id) {
    final list = getList(id);
    if (list == null) return const [];
    return [for (final array in list) array[0].cnas.getCNAbility()];
  }

  List<CNAbility> getCNAbilitiesForAbility(CharID id, Ability ability) {
    final list = getList(id);
    if (list == null) return const [];
    final cat = ability.getCDOMCategory();
    final result = <CNAbility>{};
    for (final array in list) {
      final cna = array[0].cnas.getCNAbility();
      if (cna.getAbilityCategory().getParentCategory() == cat &&
          cna.getAbilityKey() == ability.getKeyName()) {
        result.add(cna);
      }
    }
    return result.toList();
  }

  bool hasAbilityKeyed(CharID id, Category<Ability> cat, String aKey) {
    final list = getList(id);
    if (list == null) return false;
    for (final array in list) {
      final cna = array[0].cnas.getCNAbility();
      if (cna.getAbilityCategory().getParentCategory() == cat &&
          cna.getAbilityKey() == aKey) {
        return true;
      }
    }
    return false;
  }

  bool hasAbilityInPool(CharID id, AbilityCategory cat) {
    final list = getList(id);
    if (list == null) return false;
    return list
        .any((array) => array[0].cnas.getCNAbility().getAbilityCategory() == cat);
  }
}
